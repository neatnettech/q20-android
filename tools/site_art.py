#!/usr/bin/env python3
"""Generate the dithered art for site/: the stipple background and the Q20 illustration.

    python3 -m venv /tmp/v && /tmp/v/bin/pip install pillow numpy
    /tmp/v/bin/python tools/site_art.py
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

SITE = Path(__file__).resolve().parent.parent / "site"
rng = np.random.default_rng(20)


def stipple_bg(w=800, h=500):
    # computed at half size, scaled 2x nearest so each dot is a crisp 2px square
    """Organic dot blotches: dot probability follows a few soft blobs plus noise."""
    y, x = np.mgrid[0:h, 0:w] / np.array([h, w])[:, None, None]
    d = np.zeros((h, w))
    for cx, cy, r, a in [(0.04, 0.9, 0.28, 1.0), (1.0, 0.55, 0.22, 0.9),
                         (0.72, -0.02, 0.18, 0.7), (0.35, 1.05, 0.12, 0.6)]:
        d += a * np.exp(-(((x - cx) * w / h) ** 2 + (y - cy) ** 2) / (2 * r * r))
    # low frequency noise breaks the blob edges up
    n = rng.random((h // 50 + 2, w // 50 + 2))
    n = np.array(Image.fromarray((n * 255).astype("uint8")).resize((w, h), Image.BICUBIC)) / 255
    d = np.clip(d * (0.6 + 0.8 * n), 0, 1) ** 1.6
    dots = rng.random((h, w)) < d * 0.55
    img = Image.new("P", (w, h), 0)
    img.putpalette([0, 0, 0, 0x3a, 0x8a, 0x52])
    img.putdata((dots.astype("uint8")).ravel().tolist())
    img.resize((w * 2, h * 2), Image.NEAREST).save(SITE / "bg.png", transparency=0, optimize=True)


def q20_art(w=300, h=500):
    """BlackBerry Classic silhouette shaded in grey, then Floyd Steinberg to 1 bit ink."""
    img = Image.new("L", (w, h), 255)
    g = ImageDraw.Draw(img)
    # body with a vertical light to dark gradient
    body = Image.linear_gradient("L").resize((w - 20, h - 20)).point(lambda v: 150 + v * 0.35)
    mask = Image.new("L", body.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, *body.size], 46, fill=255)
    img.paste(body, (10, 10), mask)
    g.rounded_rectangle([10, 10, w - 10, h - 10], 46, outline=0, width=4)
    # screen: the real frame my stack drew on device
    frame = Image.open(SITE.parent / "runtime/art-qnx/src/raster_out.png").convert("L")
    frame = frame.point(lambda v: min(255, v * 2 + 40))
    g.rectangle([36, 44, w - 36, 272], fill=0)
    # nav row: call, menu, trackpad, back, end
    ny = 300
    for i, cx in enumerate([50, 100, 150, 200, 250]):
        if i == 2:
            g.rounded_rectangle([cx - 22, ny - 14, cx + 22, ny + 14], 8, fill=60, outline=0, width=2)
        else:
            g.ellipse([cx - 9, ny - 9, cx + 9, ny + 9], fill=200, outline=0, width=2)
    # four qwerty rows with frets between them
    for r in range(4):
        y0 = 336 + r * 34
        g.line([24, y0 - 4, w - 24, y0 - 4], fill=40, width=3)
        widths = [1] * 10 if r < 3 else [1, 1, 1, 4, 1, 1, 1]  # bottom row has the space bar
        unit = (w - 60) / sum(widths)
        x0 = 30
        for kw in widths:
            g.rounded_rectangle([x0 + 2, y0 + 4, x0 + kw * unit - 2, y0 + 24], 6, fill=225, outline=0, width=2)
            x0 += kw * unit
    # render at 300x500, shrink, then dither at final size so dots stay 1:1 on screen
    size = (180, 300)
    ink = img.resize(size, Image.LANCZOS).convert("1")  # Floyd Steinberg by default
    # the screen is thresholded, not dithered, so the frame text stays crisp
    sx, sy = round(36 * 0.6), round(44 * 0.6)
    scr = frame.resize((round(228 * 0.6), round(228 * 0.6)), Image.LANCZOS)
    ink.paste(scr.point(lambda v: 255 if v > 150 else 0).convert("1"), (sx, sy))
    out = Image.new("P", ink.size, 0)
    out.putpalette([0, 0, 0, 11, 13, 11])
    out.putdata([1 if p == 0 else 0 for p in ink.get_flattened_data()])
    out.save(SITE / "q20.png", transparency=0, optimize=True)


if __name__ == "__main__":
    stipple_bg()
    q20_art()
    for f in ("bg.png", "q20.png"):
        print(f, (SITE / f).stat().st_size, "bytes")
