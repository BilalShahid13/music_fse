#!/usr/bin/env python3
"""
Music FSE - Branding Asset Generator
Uses rsvg-convert to render the Lucide music SVG with proper round caps/joins,
then Pillow for compositing launcher assets with Inter font.

Run: python3 generate_assets.py
Requires: Pillow, rsvg-convert (brew install librsvg), Inter font at /tmp/inter_font/
"""

from PIL import Image, ImageDraw, ImageFont
import os
import subprocess
import tempfile
from shutil import copy2

# Brand colors
ACCENT_HEX = "#C76E00"
ACCENT = (199, 110, 0)       # #C76E00
DARK_BG = (13, 17, 23)       # #0D1117
SURFACE = (22, 27, 34)       # #161B22
WHITE = (230, 237, 243)      # #E6EDF3
TRANSPARENT = (0, 0, 0, 0)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ICON_DIR = os.path.join(BASE_DIR, "icon")
LAUNCHER_DIR = os.path.join(BASE_DIR, "launcher")

# rsvg-convert path (Homebrew on Apple Silicon)
RSVG = "/opt/homebrew/opt/librsvg/bin/rsvg-convert"

# Inter font paths
INTER_DIR = "/tmp/inter_font/extras/ttf"
INTER_BOLD = os.path.join(INTER_DIR, "Inter-Bold.ttf")
INTER_SEMIBOLD = os.path.join(INTER_DIR, "Inter-SemiBold.ttf")
INTER_MEDIUM = os.path.join(INTER_DIR, "Inter-Medium.ttf")
INTER_REGULAR = os.path.join(INTER_DIR, "Inter-Regular.ttf")

os.makedirs(ICON_DIR, exist_ok=True)
os.makedirs(LAUNCHER_DIR, exist_ok=True)


def make_svg(stroke_color=ACCENT_HEX, bg_color=None):
    """Generate the Lucide music SVG string with given stroke color and optional bg."""
    bg_rect = ""
    if bg_color:
        bg_rect = f'  <rect width="24" height="24" fill="{bg_color}" rx="0"/>\n'
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
     fill="none" stroke="{stroke_color}" stroke-width="2"
     stroke-linecap="round" stroke-linejoin="round">
{bg_rect}  <path d="M9 18V5l12-2v13"/>
  <circle cx="6" cy="18" r="3"/>
  <circle cx="18" cy="16" r="3"/>
</svg>'''


def render_svg_to_png(svg_string, output_path, width, height=None):
    """Render an SVG string to PNG using rsvg-convert."""
    h = height or width
    with tempfile.NamedTemporaryFile(suffix=".svg", mode="w", delete=False) as f:
        f.write(svg_string)
        tmp_svg = f.name
    try:
        subprocess.run(
            [RSVG, "-w", str(width), "-h", str(h), "-o", output_path, tmp_svg],
            check=True, capture_output=True,
        )
    finally:
        os.unlink(tmp_svg)


def generate_icon(size, stroke_color=ACCENT_HEX, filename=None):
    """Generate a single app icon PNG via rsvg-convert."""
    svg = make_svg(stroke_color=stroke_color)
    out_path = os.path.join(ICON_DIR, filename or f"icon_{size}x{size}.png")
    render_svg_to_png(svg, out_path, size)
    print(f"  {os.path.basename(out_path)}")
    return Image.open(out_path)


def generate_icon_with_alpha(size, stroke_color=ACCENT_HEX, alpha=255):
    """Generate an icon and optionally reduce its opacity."""
    svg = make_svg(stroke_color=stroke_color)
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f:
        tmp_path = f.name
    render_svg_to_png(svg, tmp_path, size)
    img = Image.open(tmp_path).convert("RGBA")
    os.unlink(tmp_path)
    if alpha < 255:
        # Reduce alpha channel
        r, g, b, a = img.split()
        a = a.point(lambda x: int(x * alpha / 255))
        img = Image.merge("RGBA", (r, g, b, a))
    return img


def load_font(style="bold", size=48):
    """Load Inter font at given size. Falls back to system fonts."""
    paths = {
        "bold": [INTER_BOLD],
        "semibold": [INTER_SEMIBOLD],
        "medium": [INTER_MEDIUM],
        "regular": [INTER_REGULAR],
    }
    system_fallbacks = [
        "/System/Library/Fonts/SFProDisplay-Bold.otf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for fp in paths.get(style, []) + system_fallbacks:
        if os.path.exists(fp):
            try:
                return ImageFont.truetype(fp, size)
            except Exception:
                continue
    return ImageFont.load_default()


def draw_subtle_bg(draw, width, height):
    """Draw subtle geometric lines on dark background."""
    line_color = (25, 32, 42, 40)
    spacing = 80
    for i in range(-height, width + height, spacing):
        draw.line([(i, 0), (i + height, height)], fill=line_color, width=1)
    accent_subtle = ACCENT + (15,)
    draw.line([(0, height // 3), (width, height // 3 - 60)], fill=accent_subtle, width=1)
    draw.line([(0, height * 2 // 3), (width, height * 2 // 3 + 40)], fill=accent_subtle, width=1)


def generate_grid_cover():
    """600x900 portrait cover (Playnite/Steam grid)."""
    w, h = 600, 900
    img = Image.new("RGBA", (w, h), DARK_BG + (255,))
    draw = ImageDraw.Draw(img)
    draw_subtle_bg(draw, w, h)
    draw.rounded_rectangle([40, 120, w - 40, h - 120], radius=16, fill=SURFACE + (200,))

    icon_size = 220
    icon = generate_icon_with_alpha(icon_size)
    img.paste(icon, ((w - icon_size) // 2, 200), icon)

    font_title = load_font("bold", 48)
    font_sub = load_font("regular", 20)

    title = "Music FSE"
    bbox = draw.textbbox((0, 0), title, font=font_title)
    tw = bbox[2] - bbox[0]
    draw.text(((w - tw) // 2, 460), title, fill=WHITE + (255,), font=font_title)

    subtitle = "Full Screen Experience"
    bbox2 = draw.textbbox((0, 0), subtitle, font=font_sub)
    sw = bbox2[2] - bbox2[0]
    draw.text(((w - sw) // 2, 525), subtitle, fill=ACCENT + (200,), font=font_sub)

    draw.line([(w // 2 - 60, 570), (w // 2 + 60, 570)], fill=ACCENT + (180,), width=2)

    path = os.path.join(LAUNCHER_DIR, "grid_cover_600x900.png")
    img.save(path, "PNG")
    print(f"  {os.path.basename(path)}")


def generate_hero_banner():
    """1920x620 landscape hero banner."""
    w, h = 1920, 620
    img = Image.new("RGBA", (w, h), DARK_BG + (255,))
    draw = ImageDraw.Draw(img)
    draw_subtle_bg(draw, w, h)

    for x in range(w * 2 // 3, w):
        progress = (x - w * 2 // 3) / (w // 3)
        alpha = int(12 * progress)
        draw.line([(x, 0), (x, h)], fill=ACCENT + (alpha,), width=1)

    icon_size = 260
    icon = generate_icon_with_alpha(icon_size)
    img.paste(icon, (140, (h - icon_size) // 2), icon)

    font_title = load_font("bold", 84)
    font_sub = load_font("regular", 30)
    text_x = 140 + icon_size + 70

    draw.text((text_x, h // 2 - 75), "Music FSE", fill=WHITE + (255,), font=font_title)
    draw.text((text_x, h // 2 + 30), "Full Screen Experience", fill=ACCENT + (220,), font=font_sub)
    draw.rectangle([text_x, h // 2 + 78, text_x + 180, h // 2 + 82], fill=ACCENT + (160,))

    path = os.path.join(LAUNCHER_DIR, "hero_banner_1920x620.png")
    img.save(path, "PNG")
    print(f"  {os.path.basename(path)}")


def generate_logo_transparent():
    """960x540 logo on transparent background."""
    w, h = 960, 540
    img = Image.new("RGBA", (w, h), TRANSPARENT)
    draw = ImageDraw.Draw(img)

    icon_size = 140
    icon = generate_icon_with_alpha(icon_size)
    icon_x = (w - icon_size - 280) // 2
    icon_y = (h - icon_size) // 2
    img.paste(icon, (icon_x, icon_y), icon)

    font_title = load_font("bold", 68)
    text_x = icon_x + icon_size + 24
    draw.text((text_x, (h - 68) // 2), "Music FSE", fill=WHITE + (255,), font=font_title)

    path = os.path.join(LAUNCHER_DIR, "logo_960x540.png")
    img.save(path, "PNG")
    print(f"  {os.path.basename(path)}")


def generate_background():
    """1920x1080 background."""
    w, h = 1920, 1080
    img = Image.new("RGBA", (w, h), DARK_BG + (255,))
    draw = ImageDraw.Draw(img)
    draw_subtle_bg(draw, w, h)

    # Large faint watermark icon
    wm_size = 500
    wm = generate_icon_with_alpha(wm_size, alpha=20)
    img.paste(wm, (w - wm_size - 100, (h - wm_size) // 2), wm)

    path = os.path.join(LAUNCHER_DIR, "background_1920x1080.png")
    img.save(path, "PNG")
    print(f"  {os.path.basename(path)}")


def generate_square_capsule():
    """600x600 square capsule."""
    w, h = 600, 600
    img = Image.new("RGBA", (w, h), DARK_BG + (255,))
    draw = ImageDraw.Draw(img)
    draw_subtle_bg(draw, w, h)

    icon_size = 240
    icon = generate_icon_with_alpha(icon_size)
    img.paste(icon, ((w - icon_size) // 2, (h - icon_size) // 2 - 40), icon)

    font_title = load_font("semibold", 42)
    title = "Music FSE"
    bbox = draw.textbbox((0, 0), title, font=font_title)
    tw = bbox[2] - bbox[0]
    draw.text(((w - tw) // 2, (h + icon_size) // 2 + 10), title, fill=WHITE + (255,), font=font_title)

    path = os.path.join(LAUNCHER_DIR, "square_capsule_600x600.png")
    img.save(path, "PNG")
    print(f"  {os.path.basename(path)}")


if __name__ == "__main__":
    print("=== Music FSE Asset Generator (rsvg-convert + Inter) ===\n")

    # Verify tools
    if not os.path.exists(RSVG):
        print(f"ERROR: rsvg-convert not found at {RSVG}")
        print("  Install: brew install librsvg")
        exit(1)
    print(f"rsvg-convert: {RSVG}")

    if os.path.exists(INTER_BOLD):
        print(f"Inter font:   {INTER_DIR}")
    else:
        print("WARNING: Inter font not found — falling back to system fonts")
    print()

    print("App icons (accent on transparent):")
    for size in [16, 32, 48, 64, 128, 256, 512, 1024]:
        generate_icon(size)

    print("\nWhite icon variants:")
    for size in [16, 32, 48, 64, 128, 256]:
        generate_icon(size, stroke_color="#FFFFFF", filename=f"icon_{size}x{size}_white.png")

    print("\nMaster icon:")
    generate_icon(1024, filename="icon_master_1024.png")

    print("\nLauncher assets:")
    generate_grid_cover()
    generate_hero_banner()
    generate_logo_transparent()
    generate_background()
    generate_square_capsule()

    # Playnite icon alias
    src = os.path.join(ICON_DIR, "icon_256x256.png")
    dst = os.path.join(LAUNCHER_DIR, "playnite_icon_256x256.png")
    copy2(src, dst)
    print(f"  playnite_icon_256x256.png")

    print(f"\n=== Done! ===")
    print(f"  Icons:    {ICON_DIR}")
    print(f"  Launcher: {LAUNCHER_DIR}")
