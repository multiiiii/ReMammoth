"""
generate_icons.py — Launcher icon generator for ReMammoth color schemes.

Usage
-----
  Preview (contact sheet, no files written to mipmap folders):
      python tools/generate_icons.py --preview

  Generate all production PNGs:
      python tools/generate_icons.py

Tuning the logo size
--------------------
Change LOGO_FRACTION below, then run --preview to see the result as a
contact sheet (tools/preview.png) before committing.

  LOGO_FRACTION is the fraction of the foreground canvas that the logo
  image occupies (width = height = canvas * LOGO_FRACTION, centred).

  Adaptive icon safe zone ceiling: 72dp / 108dp ≈ 0.667
  Below that ceiling the logo is guaranteed not to be clipped by any
  launcher shape (circle, squircle, rounded square, etc.).

  Typical range: 0.58 – 0.66

What this script does NOT touch
--------------------------------
- The default Classic Blue icon (managed by flutter_launcher_icons / pubspec.yaml)
- mipmap-anydpi-v26/*.xml (static, already correct)
- values/colors.xml (static, already correct)
"""

import argparse
import os
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit("Pillow is required: pip install Pillow")

# ---------------------------------------------------------------------------
# Configuration — edit here
# ---------------------------------------------------------------------------

LOGO_FRACTION = 0.70  # fraction of foreground canvas; safe zone ceiling = 0.667

# Each entry: (icon_prefix, source_filename, background_rgb)
# icon_prefix determines output filenames:
#   legacy flat  → {prefix}.png
#   adaptive fg  → {prefix}_foreground.png
SCHEMES = [
    ("ic_launcher",          "app_logo.png",           (  1,  58, 101)),
    ("ic_launcher_fireice",  "app_logo_fireice.webp",  (110, 233, 239)),
    ("ic_launcher_darkmode", "app_logo_darkmode.webp", ( 24,  10,  10)),
    ("ic_launcher_jungle",   "app_logo_jungle.webp",   (156, 176, 128)),
]

DENSITIES = [
    # (res_folder,      legacy_px, foreground_px)
    ("mipmap-mdpi",     48,  108),
    ("mipmap-hdpi",     72,  162),
    ("mipmap-xhdpi",    96,  216),
    ("mipmap-xxhdpi",  144,  324),
    ("mipmap-xxxhdpi", 192,  432),
]

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

REPO = Path(__file__).resolve().parent.parent
ASSETS = REPO / "assets" / "images"
RES = REPO / "android" / "app" / "src" / "main" / "res"
TOOLS = REPO / "tools"


# ---------------------------------------------------------------------------
# Core helpers
# ---------------------------------------------------------------------------

def _make_foreground(source: Image.Image, canvas_px: int, logo_fraction: float,
                     bg_rgb: tuple[int, int, int]) -> Image.Image:
    """Return a canvas_px × canvas_px RGBA image: bg colour + logo centred."""
    logo_px = round(canvas_px * logo_fraction)
    offset = (canvas_px - logo_px) // 2
    canvas = Image.new("RGBA", (canvas_px, canvas_px), (*bg_rgb, 255))
    logo = source.resize((logo_px, logo_px), Image.LANCZOS)
    canvas.paste(logo, (offset, offset), logo if logo.mode == "RGBA" else None)
    return canvas


def _apply_circle_mask(img: Image.Image) -> Image.Image:
    """Clip img to a circle (simulates Android launcher shape masking)."""
    size = img.size
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size[0] - 1, size[1] - 1), fill=255)
    result = img.convert("RGBA")
    result.putalpha(mask)
    return result


# ---------------------------------------------------------------------------
# Preview
# ---------------------------------------------------------------------------

PREVIEW_FRACTIONS = [0.54, 0.58, 0.62, 0.66, 0.70]
PREVIEW_CELL_PX = 162   # hdpi foreground size
PREVIEW_PADDING = 12
PREVIEW_LABEL_H = 20
PREVIEW_BG = (240, 240, 240)


def generate_preview(fractions: list[float] = PREVIEW_FRACTIONS) -> None:
    sources = [(prefix.replace("ic_launcher_", "") or "default",
                Image.open(ASSETS / fname).convert("RGBA"), bg)
               for prefix, fname, bg in SCHEMES]

    cols = len(fractions)
    rows = len(sources)
    cell_w = PREVIEW_CELL_PX + PREVIEW_PADDING
    cell_h = PREVIEW_CELL_PX + PREVIEW_PADDING + PREVIEW_LABEL_H
    header_h = PREVIEW_LABEL_H + PREVIEW_PADDING
    row_label_w = 90

    img_w = row_label_w + cols * cell_w + PREVIEW_PADDING
    img_h = header_h + rows * cell_h + PREVIEW_PADDING

    sheet = Image.new("RGB", (img_w, img_h), PREVIEW_BG)
    draw = ImageDraw.Draw(sheet)

    try:
        font = ImageFont.truetype("arial.ttf", 12)
    except OSError:
        font = ImageFont.load_default()

    for c, frac in enumerate(fractions):
        x = row_label_w + c * cell_w + PREVIEW_PADDING // 2
        draw.text((x, PREVIEW_PADDING // 2), f"{frac:.0%}", fill=(60, 60, 60), font=font)

    for r, (label, source, bg_rgb) in enumerate(sources):
        y_base = header_h + r * cell_h
        draw.text((4, y_base + PREVIEW_CELL_PX // 2), label, fill=(60, 60, 60), font=font)
        for c, frac in enumerate(fractions):
            fg = _make_foreground(source, PREVIEW_CELL_PX, frac, bg_rgb)
            masked = _apply_circle_mask(fg)
            bg_cell = Image.new("RGB", (PREVIEW_CELL_PX, PREVIEW_CELL_PX), PREVIEW_BG)
            bg_cell.paste(masked, (0, 0), masked)
            sheet.paste(bg_cell, (row_label_w + c * cell_w, y_base))

    out = TOOLS / "preview.png"
    sheet.save(out)
    print(f"Preview written to {out}")


# ---------------------------------------------------------------------------
# Production generation
# ---------------------------------------------------------------------------

def generate_all(logo_fraction: float = LOGO_FRACTION) -> None:
    for prefix, source_fname, bg_rgb in SCHEMES:
        source = Image.open(ASSETS / source_fname).convert("RGBA")
        for density, legacy_px, fg_px in DENSITIES:
            folder = RES / density
            legacy = source.resize((legacy_px, legacy_px), Image.LANCZOS).convert("RGB")
            legacy.save(folder / f"{prefix}.png")
            fg = _make_foreground(source, fg_px, logo_fraction, bg_rgb)
            fg.save(folder / f"{prefix}_foreground.png")
        print(f"  {prefix}: done (fraction={logo_fraction:.0%})")
    print("All icons generated.")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="ReMammoth launcher icon generator")
    parser.add_argument(
        "--preview",
        action="store_true",
        help="Generate tools/preview.png contact sheet instead of writing mipmap files",
    )
    parser.add_argument(
        "--fraction",
        type=float,
        default=None,
        help="Override LOGO_FRACTION for this run (e.g. --fraction 0.64)",
    )
    args = parser.parse_args()

    fraction = args.fraction if args.fraction is not None else LOGO_FRACTION

    if args.preview:
        fracs = PREVIEW_FRACTIONS
        if args.fraction is not None and args.fraction not in fracs:
            fracs = sorted(set(fracs + [args.fraction]))
        generate_preview(fracs)
    else:
        print(f"Generating icons at LOGO_FRACTION={fraction:.0%} …")
        generate_all(fraction)
