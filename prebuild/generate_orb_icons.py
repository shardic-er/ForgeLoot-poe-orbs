#!/usr/bin/env python3
# @load-order 10
"""Convert orb source PNGs to BLP2 icons for the WoW client.

Reads source PNGs from icons/Interface/Icons/, resizes to 64x64,
and converts to BLP2 (DXT1 + mipmaps). Overwrites the source PNGs
with the generated BLPs in-place.

Requires: Pillow, numpy
"""

import argparse
import os
import struct
import sys
from pathlib import Path

try:
    from PIL import Image, ImageEnhance
except ImportError:
    print("ERROR: Pillow is required for BLP generation. Install with: pip install Pillow")
    sys.exit(1)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

MODULE_DIR = Path(__file__).resolve().parent.parent
SOURCE_DIR = MODULE_DIR / 'icons' / 'Interface' / 'Icons'

# Source PNG -> output BLP name mapping
ORB_ICONS = {
    # Original 8
    'Orb_of_Alteration.png':      'INV_Orb_Alteration',
    'Orb_of_Transmutation.png':   'INV_Orb_Transmutation',
    'Regal_Orb.png':              'INV_Orb_Regal',
    'Exalted_Orb.png':            'INV_Orb_Exalted',
    'Orb_of_Alchemy.png':         'INV_Orb_Alchemy',
    'Orb_of_Scouring.png':        'INV_Orb_Scouring',
    'Chaos_Orb.png':              'INV_Orb_Chaos',
    'Divine_Orb.png':             'INV_Orb_Divine',
    # Renamed orb icons
    'Orb_of_Annulment.png':       'INV_Orb_Annulment',
    'Blessed_Orb.png':            'INV_Orb_Blessed',
    # New orb icons
    'Ancient_Orb.png':            'INV_Orb_Ancient',
    "Blacksmith's_Whetstone.png": 'INV_Orb_Whetstone',
    "Armourer's_Scrap.png":       'INV_Orb_Armorer',
    'Mirror_of_Kalandra.png':     'INV_Orb_Mirror',
    'Orb_of_Influence.png':       'INV_Orb_Influence',
    "Awakener's_Orb.png":         'INV_Orb_Awakener',
    'Scroll_of_Wisdom.png':       'INV_Orb_Identify',
    'Portal_Scroll.png':          'INV_Orb_Portal',
    "Jeweller's_Orb.png":         'INV_Orb_Jeweler',
}


# ---------------------------------------------------------------------------
# DXT1 Compression (same as skill-jewels generate_gem_icons.py)
# ---------------------------------------------------------------------------

def _rgb888_to_rgb565(r, g, b):
    return ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)


def _rgb565_to_rgb888(c):
    r = ((c >> 11) & 0x1F) * 255 // 31
    g = ((c >> 5) & 0x3F) * 255 // 63
    b = (c & 0x1F) * 255 // 31
    return (r, g, b)


def _compress_dxt1_block(pixels, alphas):
    """Compress a 4x4 pixel block to 8 bytes of DXT1 data."""
    has_transparent = any(a < 128 for a in alphas)

    min_r = min(p[0] for p in pixels)
    max_r = max(p[0] for p in pixels)
    min_g = min(p[1] for p in pixels)
    max_g = max(p[1] for p in pixels)
    min_b = min(p[2] for p in pixels)
    max_b = max(p[2] for p in pixels)

    color0_rgb = (max_r, max_g, max_b)
    color1_rgb = (min_r, min_g, min_b)
    c0 = _rgb888_to_rgb565(*color0_rgb)
    c1 = _rgb888_to_rgb565(*color1_rgb)

    if has_transparent:
        if c0 > c1:
            c0, c1 = c1, c0
            color0_rgb, color1_rgb = color1_rgb, color0_rgb
        c0_exp = _rgb565_to_rgb888(c0)
        c1_exp = _rgb565_to_rgb888(c1)
        palette = [
            c0_exp,
            c1_exp,
            tuple((a + b) // 2 for a, b in zip(c0_exp, c1_exp)),
            (0, 0, 0),
        ]
        opaque_count = 3
    else:
        if c0 < c1:
            c0, c1 = c1, c0
            color0_rgb, color1_rgb = color1_rgb, color0_rgb
        elif c0 == c1:
            c0 = min(c0 + 1, 0xFFFF)
        c0_exp = _rgb565_to_rgb888(c0)
        c1_exp = _rgb565_to_rgb888(c1)
        palette = [
            c0_exp,
            c1_exp,
            tuple((2 * a + b) // 3 for a, b in zip(c0_exp, c1_exp)),
            tuple((a + 2 * b) // 3 for a, b in zip(c0_exp, c1_exp)),
        ]
        opaque_count = 4

    indices = 0
    for i in range(16):
        if has_transparent and alphas[i] < 128:
            idx = 3
        else:
            best_idx = 0
            best_dist = sum((a - b) ** 2 for a, b in zip(pixels[i], palette[0]))
            for j in range(1, opaque_count):
                d = sum((a - b) ** 2 for a, b in zip(pixels[i], palette[j]))
                if d < best_dist:
                    best_dist = d
                    best_idx = j
            idx = best_idx
        indices |= (idx << (i * 2))

    return struct.pack('<HHI', c0, c1, indices)


def _compress_image_dxt1(img_rgba):
    """Compress an RGBA PIL Image to DXT1 byte data."""
    import numpy as np
    data = np.array(img_rgba)
    h, w = data.shape[:2]

    blocks = []
    for by in range(0, h, 4):
        for bx in range(0, w, 4):
            block = data[by:by + 4, bx:bx + 4]
            pixels = block[:, :, :3].reshape(16, 3).tolist()
            alphas = block[:, :, 3].reshape(16).tolist()
            blocks.append(_compress_dxt1_block(
                [tuple(p) for p in pixels], alphas))

    return b''.join(blocks)


# ---------------------------------------------------------------------------
# BLP2 Writer
# ---------------------------------------------------------------------------

def _generate_mipmaps(img):
    """Generate a mipmap chain from img down to 1x1."""
    levels = [img]
    w, h = img.size
    while w > 1 or h > 1:
        w = max(1, w // 2)
        h = max(1, h // 2)
        levels.append(img.resize((w, h), Image.Resampling.LANCZOS))
    return levels


def _pad_to_block_size(img, block_size=4):
    """Pad image dimensions up to a multiple of block_size."""
    w, h = img.size
    pw = max(block_size, ((w + block_size - 1) // block_size) * block_size)
    ph = max(block_size, ((h + block_size - 1) // block_size) * block_size)
    if pw != w or ph != h:
        padded = Image.new('RGBA', (pw, ph), (0, 0, 0, 0))
        padded.paste(img, (0, 0))
        return padded
    return img


def png_to_blp(png_path, blp_path, target_size=64):
    """Convert a PNG to BLP2 with DXT1 compression and mipmaps."""
    img = Image.open(str(png_path)).convert("RGBA")
    if img.size != (target_size, target_size):
        img = img.resize((target_size, target_size), Image.Resampling.LANCZOS)

    # Composite onto black background -- WoW icons use opaque black, not alpha
    background = Image.new('RGBA', img.size, (0, 0, 0, 255))
    img = Image.alpha_composite(background, img)

    # Generate mipmap chain
    mipmaps = _generate_mipmaps(img)

    # Compress each level
    compressed = []
    for mip in mipmaps:
        mip = _pad_to_block_size(mip)
        compressed.append(_compress_image_dxt1(mip))

    # BLP2 header: 148 bytes
    header_size = 148
    offsets = [0] * 16
    sizes = [0] * 16
    current_offset = header_size
    for i, data in enumerate(compressed):
        offsets[i] = current_offset
        sizes[i] = len(data)
        current_offset += len(data)

    w, h = img.size
    header = struct.pack('<4sI', b'BLP2', 1)
    header += struct.pack('<BBBB', 2, 1, 0, len(compressed))
    header += struct.pack('<II', w, h)
    header += struct.pack('<16I', *offsets)
    header += struct.pack('<16I', *sizes)

    Path(blp_path).parent.mkdir(parents=True, exist_ok=True)
    with open(str(blp_path), 'wb') as f:
        f.write(header)
        for data in compressed:
            f.write(data)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description='Generate orb icon BLPs')
    parser.add_argument('--config', help='Path to project.yaml (unused)')
    parser.add_argument('--id-assignments', help='(unused)')
    parser.parse_args()

    print("[OrbIcons] Generating orb icon BLPs (DXT1 compressed)...")

    if not SOURCE_DIR.exists():
        print("[OrbIcons] ERROR: Source directory not found: %s" % SOURCE_DIR)
        sys.exit(1)

    generated = 0
    cached = 0
    errors = []

    for png_name, blp_base in sorted(ORB_ICONS.items()):
        png_path = SOURCE_DIR / png_name
        blp_path = SOURCE_DIR / (blp_base + '.blp')

        if not png_path.exists():
            errors.append("Missing source PNG: %s" % png_path)
            continue

        # Cache: skip if BLP is newer than source PNG
        if blp_path.exists():
            png_mtime = os.path.getmtime(str(png_path))
            blp_mtime = os.path.getmtime(str(blp_path))
            if blp_mtime >= png_mtime:
                cached += 1
                continue

        try:
            png_to_blp(png_path, blp_path)
            generated += 1
        except Exception as e:
            errors.append("Failed to convert %s: %s" % (png_name, e))

    if errors:
        for err in errors:
            print("[OrbIcons] ERROR: %s" % err)
        sys.exit(1)

    print("[OrbIcons] Generated %d BLPs, %d cached (unchanged)" % (generated, cached))
    print("[OrbIcons] Output: %s" % SOURCE_DIR)


if __name__ == '__main__':
    main()
