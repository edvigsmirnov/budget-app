#!/usr/bin/env python3
"""Regenerate assets/holidays/ from date.nager.at.

Only entries the source marks nationwide (`global: true`) are kept: a holiday
observed in one federal state must not shift a national pay date.

    python tools/fetch_holidays.py .                 # default year span
    python tools/fetch_holidays.py . --years 2026 2031
    python tools/fetch_holidays.py . --codes RU DE US

Writes one <CODE>.json per bundled country, index.json listing those codes, and
countries.json listing every country the API knows.
"""

from __future__ import annotations

import argparse
import json
import pathlib
import sys
import time
import urllib.error
import urllib.request

API = 'https://date.nager.at/api/v3'

# Country names per language, from Unicode's own data. Only the names live
# here; the code list stays in countries.json, so a locale file is an overlay
# and not a second source of truth about which countries exist.
CLDR = ('https://raw.githubusercontent.com/unicode-org/cldr-json/main'
        '/cldr-json/cldr-localenames-full/main')

TIMEOUT = 30
RETRIES = 3

# Kept in sync with index.json; used only when index.json is absent.
DEFAULT_CODES = [
    'AT', 'CA', 'CH', 'CZ', 'DE', 'ES', 'FI', 'FR', 'GB', 'IE',
    'IT', 'KZ', 'NL', 'NO', 'PL', 'PT', 'RU', 'SE', 'UA', 'US',
]


def get(url: str) -> object:
    for attempt in range(1, RETRIES + 1):
        try:
            with urllib.request.urlopen(url, timeout=TIMEOUT) as response:
                return json.load(response)
        except (urllib.error.URLError, TimeoutError, json.JSONDecodeError):
            if attempt == RETRIES:
                raise
            time.sleep(2 * attempt)
    raise AssertionError('unreachable')


def nationwide_dates(code: str, year: int) -> list[str]:
    entries = get(f'{API}/PublicHolidays/{year}/{code}')
    if not isinstance(entries, list):
        raise ValueError(f'{code} {year}: unexpected payload')
    dates = {
        e['date']
        for e in entries
        if isinstance(e, dict) and e.get('global') is True and e.get('date')
    }
    return sorted(dates)


def write_country_names(out: pathlib.Path, locales: list[str],
                        codes: set[str]) -> None:
    """One `countries.<locale>.json` per locale: code -> localized name.

    Names are not put in the app dictionaries on purpose. Two hundred country
    names in every dictionary is one identical block per language, and the
    parity test would demand all of them.
    """
    for locale in locales:
        payload = get(f'{CLDR}/{locale}/territories.json')
        try:
            names = (payload['main'][locale]  # type: ignore[index]
                     ['localeDisplayNames']['territories'])
        except (KeyError, TypeError):
            print(f'{locale}: no CLDR territories, skipped', file=sys.stderr)
            continue

        # Two-letter codes only: CLDR also carries numeric regions ("150" for
        # Europe) and `-alt-` variants, none of which are countries here.
        localized = {
            code: name
            for code, name in names.items()
            if len(code) == 2 and code.isalpha() and code in codes
        }
        path = out / f'countries.{locale}.json'
        path.write_text(
            json.dumps(dict(sorted(localized.items())), ensure_ascii=False,
                       indent=2) + '\n',
            encoding='utf-8')
        missing = len(codes) - len(localized)
        note = f', {missing} without a name' if missing else ''
        print(f'countries.{locale}.json: {len(localized)} names{note}')


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('root', type=pathlib.Path, help='repository root')
    parser.add_argument('--years', type=int, nargs=2, metavar=('FIRST', 'LAST'),
                        default=[2026, 2031])
    parser.add_argument('--codes', nargs='+', metavar='CC')
    parser.add_argument('--all', action='store_true',
                        help='every country in countries.json')
    parser.add_argument('--names', nargs='*', metavar='LOCALE',
                        default=['en', 'ru'],
                        help='locales to write country names for; '
                             'pass with no values to skip')
    parser.add_argument('--names-only', action='store_true',
                        help='refresh country names, leaving holidays alone')
    args = parser.parse_args()

    out = args.root / 'assets' / 'holidays'
    if not out.is_dir():
        print(f'not a holidays directory: {out}', file=sys.stderr)
        return 1

    if args.names_only:
        existing = json.loads(
            (out / 'countries.json').read_text(encoding='utf-8'))
        write_country_names(
            out, args.names, {r['code'] for r in existing})
        return 0

    index = out / 'index.json'
    if args.all:
        countries = get(f'{API}/AvailableCountries')
        codes = sorted(
            c['countryCode'].upper()
            for c in countries  # type: ignore[union-attr]
            if isinstance(c, dict) and c.get('countryCode')
        )
    elif args.codes:
        codes = [c.upper() for c in args.codes]
    elif index.exists():
        codes = json.loads(index.read_text(encoding='utf-8'))
    else:
        codes = DEFAULT_CODES

    first, last = args.years
    years = list(range(first, last + 1))

    written: list[str] = []
    for code in codes:
        by_year: dict[str, list[str]] = {}
        for year in years:
            dates = nationwide_dates(code, year)
            if dates:
                by_year[str(year)] = dates
            time.sleep(0.2)
        if not by_year:
            print(f'{code}: no nationwide days in {first}-{last}, skipped',
                  file=sys.stderr)
            continue
        path = out / f'{code}.json'
        path.write_text(json.dumps(by_year, indent=2) + '\n', encoding='utf-8')
        written.append(code)
        total = sum(len(v) for v in by_year.values())
        print(f'{code}: {total} days across {len(by_year)} years')

    # index.json lists what was actually written, never what was asked for: a
    # country with no nationwide days gets no file, and the app asserts the two
    # agree. Files for codes that dropped out are removed for the same reason.
    index.write_text(json.dumps(sorted(written), indent=2) + '\n',
                     encoding='utf-8')
    keep = {f'{c}.json' for c in written} | {'index.json', 'countries.json'}
    for stale in sorted(p for p in out.glob('*.json') if p.name not in keep):
        stale.unlink()
        print(f'removed stale {stale.name}', file=sys.stderr)

    countries = get(f'{API}/AvailableCountries')
    if isinstance(countries, list):
        rows = sorted(
            ({'code': c['countryCode'], 'name': c['name']}
             for c in countries
             if isinstance(c, dict) and c.get('countryCode') and c.get('name')),
            key=lambda r: r['name'],
        )
        (out / 'countries.json').write_text(
            json.dumps(rows, indent=2) + '\n', encoding='utf-8')
        print(f'countries.json: {len(rows)} countries')

        if args.names:
            write_country_names(out, args.names,
                                {r['code'] for r in rows})

    print(f'years {first}-{last}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
