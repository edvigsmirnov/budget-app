/// Substitution table, as two parallel strings so the pairing stays readable.
/// Restricted to Latin-1 Supplement and Latin Extended-A, which the bundled
/// fonts cover. Letters with no entry pass through.
const String _plain = 'acdeghijklnorstuwyzACDEGHIJKLNORSTUWYZ';
const String _accented = 'áçðéğĥíĵķłñóřšťúŵýžÁÇÐÉĞĤÍĴĶŁÑÓŘŠŤÚŴÝŽ';

final Map<String, String> _accents = Map<String, String>.fromIterables(
  _plain.split(''),
  _accented.split(''),
);

final RegExp _letter = RegExp('[A-Za-z]');

/// Rewrites [source] for layout testing: accents the letters, pads the result
/// by [expansion] and brackets it.
///
/// The brackets expose truncation at either end; the padding stands in for
/// languages that run longer than English. Text inside `{}` is copied
/// verbatim — accenting a placeholder name would break interpolation.
String pseudolocalize(String source, {double expansion = 0.35}) {
  assert(_plain.length == _accented.length, 'substitution table is unpaired');

  final StringBuffer out = StringBuffer('[');
  int depth = 0;
  int letters = 0;

  for (final String ch in source.split('')) {
    if (ch == '{') {
      depth++;
      out.write(ch);
    } else if (ch == '}') {
      if (depth > 0) depth--;
      out.write(ch);
    } else if (depth > 0) {
      out.write(ch);
    } else {
      if (_letter.hasMatch(ch)) letters++;
      out.write(_accents[ch] ?? ch);
    }
  }

  final int pad = (letters * expansion).round();
  if (pad > 0) {
    out.write(' ');
    out.write('·' * pad);
  }
  out.write(']');
  return out.toString();
}
