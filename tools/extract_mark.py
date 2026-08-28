"""Cuts the Sielto mark out of a rendered icon sheet onto transparency.

    python tools/extract_mark.py <source.png>

The source is artwork delivered as a flat image: the green mark sitting on a
white rounded plate on a pale ground. Both of those are neutral and the mark is
the only coloured thing in the frame, which is what makes the cut reliable —
the glyph is found by its greenness, and the alpha inside that box comes from
how far each pixel is from white. The white gaps between the ribbons of the S
fall out with the plate, which is correct: they are gaps, not ink.

Writes `tools/sielto_mark.png`, which `make_icon.py` reads. Needs Pillow and
numpy. Only rerun this when new artwork arrives.
"""
import os
import sys

import numpy as np
from PIL import Image

_HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(_HERE, 'sielto_mark.png')

# Room around the ink for its own anti-aliased edge.
PAD = 8

# The palest mint in the mark scores about 60; the off-white ground about 20.
FLOOR = 20.0
RAMP = 22.0


def extract(path):
    src = Image.open(path).convert('RGB')
    a = np.asarray(src).astype(np.int16)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]

    green = (g > r + 12) & (g > b + 8)
    if not green.any():
        raise SystemExit('no green ink found in %s' % path)
    ys, xs = np.nonzero(green)
    x0, x1 = max(0, xs.min() - PAD), min(a.shape[1], xs.max() + 1 + PAD)
    y0, y1 = max(0, ys.min() - PAD), min(a.shape[0], ys.max() + 1 + PAD)

    crop = a[y0:y1, x0:x1]
    # Anything that is neither white nor neutral is ink: a pixel counts by
    # whichever it is more of, coloured or dark.
    score = np.maximum(
        crop.max(axis=2) - crop.min(axis=2), 255 - crop.min(axis=2),
    ).astype(np.float32)
    alpha = np.clip((score - FLOOR) / RAMP, 0.0, 1.0) * 255.0

    img = Image.fromarray(
        np.dstack([crop.astype(np.uint8), alpha.astype(np.uint8)]), 'RGBA',
    )
    return img.crop(img.getbbox())


if __name__ == '__main__':
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    mark = extract(sys.argv[1])
    mark.save(OUT)
    print('%s  %dx%d' % (OUT, mark.width, mark.height))
