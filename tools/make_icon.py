"""Generates the Sielto app icon for all three platforms.

    python tools/make_icon.py .

The artwork is `tools/sielto_mark.png` — the green S whose top stroke leaves as
an arrow, already cut out onto transparency by `extract_mark.py`. This script
only places and scales it: a white rounded plate for launchers that do not
mask, the bare mark for Android's adaptive foreground.

Needs Pillow. Writes the Android mipmaps, the Linux PNG and the Windows ICO in
place. Set SCRATCH to also get proof sheets at 512 and 48.
"""
import os
import sys

from PIL import Image

WHITE = (255, 255, 255, 255)
SS = 8

_HERE = os.path.dirname(os.path.abspath(__file__))
MARK = os.path.join(_HERE, 'sielto_mark.png')


def mark_at(size):
    """The mark scaled to fit a square of `size`, centred, transparent around.

    Fitted by its longer side and centred on its own ink, so it carries the
    same optical weight at every density.
    """
    art = Image.open(MARK).convert('RGBA')
    art = art.crop(art.getbbox())
    w, h = art.size
    scale = size / float(max(w, h))
    resized = art.resize(
        (max(1, round(w * scale)), max(1, round(h * scale))), Image.LANCZOS,
    )
    out = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    out.alpha_composite(
        resized,
        ((size - resized.width) // 2, (size - resized.height) // 2),
    )
    return out


def rounded(size, radius_ratio=0.22):
    """The mark on a white rounded square, for launchers that do not mask."""
    from PIL import ImageDraw

    n = size * SS
    plate = Image.new('RGBA', (n, n), (0, 0, 0, 0))
    ImageDraw.Draw(plate).rounded_rectangle(
        [0, 0, n - 1, n - 1], radius=int(n * radius_ratio), fill=WHITE,
    )
    out = plate.resize((size, size), Image.LANCZOS)
    inner = int(size * 0.72)
    out.alpha_composite(mark_at(inner), ((size - inner) // 2,) * 2)
    return out


def adaptive_foreground(size):
    """Android's adaptive foreground: the mark inside the safe zone.

    The launcher scales the foreground up and masks it, so the ink has to stay
    well inside — roughly the middle half of the drawable.
    """
    canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    inner = int(size * 0.5)
    canvas.alpha_composite(mark_at(inner), ((size - inner) // 2,) * 2)
    return canvas


DENSITIES = {
    'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192,
}

if __name__ == '__main__':
    root = sys.argv[1] if len(sys.argv) > 1 else '.'
    # Proof sheets, only when somewhere to put them was named.
    scratch = os.environ.get('SCRATCH')
    res = os.path.join(root, 'android', 'app', 'src', 'main', 'res')

    for name, px in DENSITIES.items():
        folder = os.path.join(res, 'mipmap-%s' % name)
        os.makedirs(folder, exist_ok=True)
        rounded(px).save(os.path.join(folder, 'ic_launcher.png'))
        adaptive_foreground(px).save(
            os.path.join(folder, 'ic_launcher_foreground.png'))

    rounded(512).save(
        os.path.join(root, 'linux', 'runner', 'resources', 'sielto.png'))
    rounded(256).save(
        os.path.join(root, 'windows', 'runner', 'resources', 'app_icon.ico'),
        sizes=[(s, s) for s in (16, 24, 32, 48, 64, 128, 256)],
    )

    if scratch:
        rounded(512).save(os.path.join(scratch, 'icon_preview.png'))
        # Small, where a mark either survives or does not.
        rounded(48).resize((192, 192), Image.NEAREST).save(
            os.path.join(scratch, 'icon_small.png'))
    print('done')
