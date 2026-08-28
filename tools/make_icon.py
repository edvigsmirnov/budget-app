"""Generates the Sielto app icon for all three platforms.

    python tools/make_icon.py .

The mark is an S drawn as one rising stroke that ends in an arrowhead. The
path is sampled and stamped with discs rather than drawn with PIL's arc, which
has square caps and no join control. Rendered at 8x and downsampled, because a
launcher icon is judged on its edges.

Needs Pillow. Writes the Android mipmaps (legacy plus the adaptive
foreground), the Linux PNG and the Windows ICO in place.
"""
import math
import os
import sys

from PIL import Image, ImageDraw

GREEN = (76, 122, 82, 255)      # sage accentStrong, #4C7A52
WHITE = (255, 255, 255, 255)
SS = 8


def _arc_points(cx, cy, r, start_deg, end_deg, steps=180):
    """Samples an arc, sweeping from start to end however the signs run."""
    a0, a1 = math.radians(start_deg), math.radians(end_deg)
    return [
        (
            cx + r * math.cos(a0 + (a1 - a0) * i / steps),
            cy + r * math.sin(a0 + (a1 - a0) * i / steps),
        )
        for i in range(steps + 1)
    ]


def _stroke(d, points, width):
    """A round-capped, round-joined polyline."""
    half = width / 2
    for x, y in points:
        d.ellipse([x - half, y - half, x + half, y + half], fill=GREEN)


def draw_mark(size, *, background):
    n = size * SS
    img = Image.new('RGBA', (n, n), background)
    d = ImageDraw.Draw(img)
    u = n / 1000.0

    # Two overlapping circles make the bowls; the overlap is what keeps the
    # waist continuous instead of pinching to a point.
    r = 200 * u
    stroke = 84 * u
    cx = 470 * u
    top_cy = 375 * u
    bottom_cy = top_cy + 2 * r * 0.88

    # Screen angles: 0 right, 90 down, 180 left, 270 up.
    #
    # Upper bowl: from the waist (bottom of this circle), round the left, over
    # the top, stopping just past 12 where the tangent already points right.
    upper = _arc_points(cx, top_cy, r, 70, 275)
    # Lower bowl: from the waist (top of this circle), round the right, under
    # the bottom, out to the lower-left terminal.
    lower = _arc_points(cx, bottom_cy, r, 250, 495)

    _stroke(d, upper, stroke)
    _stroke(d, lower, stroke)

    # The stroke leaves the letter and keeps going: the S is the arrow, not a
    # letter with an arrow next to it.
    tail = upper[-1]
    ux, uy = math.cos(math.radians(-32)), math.sin(math.radians(-32))
    run = 200 * u
    tip = (tail[0] + ux * run, tail[1] + uy * run)
    _stroke(d, [
        (tail[0] + ux * run * t / 40, tail[1] + uy * run * t / 40)
        for t in range(41)
    ], stroke)

    # Head: apex on the same axis, base square to it.
    head = 104 * u
    px, py = -uy, ux
    # The base sits behind the tail's round cap, so the two read as one solid
    # head rather than a triangle with a bite out of it.
    base = (tip[0] - ux * head * 0.9, tip[1] - uy * head * 0.9)
    d.polygon(
        [
            (tip[0] + ux * head * 1.1, tip[1] + uy * head * 1.1),
            (base[0] + px * head * 0.85, base[1] + py * head * 0.85),
            (base[0] - px * head * 0.85, base[1] - py * head * 0.85),
        ],
        fill=GREEN,
    )

    return img.resize((size, size), Image.LANCZOS)


def mark_tight(size):
    """The mark, cropped to its ink and scaled to fill a square of `size`.

    Drawn from a fixed canvas the S sits off-centre and leaves slack on three
    sides, which at 48px reads as a small grey smudge. Cropping to the alpha
    box is what gives it the same optical weight at every density.
    """
    raw = draw_mark(size * 4, background=(0, 0, 0, 0))
    cropped = raw.crop(raw.getbbox())
    w, h = cropped.size
    scale = size / float(max(w, h))
    resized = cropped.resize(
        (max(1, int(round(w * scale))), max(1, int(round(h * scale)))),
        Image.LANCZOS,
    )
    out = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    out.alpha_composite(
        resized,
        ((size - resized.width) // 2, (size - resized.height) // 2),
    )
    return out


def rounded(size, radius_ratio=0.22):
    """The mark on a white rounded square, for launchers that do not mask."""
    n = size * SS
    plate = Image.new('RGBA', (n, n), (0, 0, 0, 0))
    ImageDraw.Draw(plate).rounded_rectangle(
        [0, 0, n - 1, n - 1], radius=int(n * radius_ratio), fill=WHITE,
    )
    out = plate.resize((size, size), Image.LANCZOS)
    inner = int(size * 0.78)
    out.alpha_composite(
        mark_tight(inner), ((size - inner) // 2, (size - inner) // 2),
    )
    return out


def adaptive_foreground(size):
    """Android's adaptive foreground: the mark inside the safe zone.

    The launcher scales the foreground up and masks it, so the ink has to stay
    well inside — roughly the middle 46% of the drawable.
    """
    canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    inner = int(size * 0.5)
    canvas.alpha_composite(
        mark_tight(inner), ((size - inner) // 2, (size - inner) // 2),
    )
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
