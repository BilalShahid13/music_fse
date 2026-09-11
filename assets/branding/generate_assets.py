#!/usr/bin/env python3
"""
Music FSE launcher asset generator.

Creates a clean launcher set tuned for Playnite and similar launchers without
thin line motifs that can read as visual defects once the artwork is cropped or
scaled by the host app.

Inputs:
- Lucide Music icon geometry
- Default accent color: #C76E00
- Bundled Inter fonts from assets/fonts

Run:
    python assets/branding/generate_assets.py

Requires:
    Pillow
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps

ACCENT = (199, 110, 0)
ACCENT_LIGHT = (231, 167, 88)
WHITE = (230, 237, 243)
MUTED = (153, 164, 176)
BG_TOP = (17, 22, 31)
BG_MID = (12, 16, 23)
BG_BOTTOM = (7, 10, 15)
TRANSPARENT = (0, 0, 0, 0)
RENDER_SCALE = 2

BASE_DIR = Path(__file__).resolve().parent
ASSETS_DIR = BASE_DIR.parent
LAUNCHER_DIR = BASE_DIR / "launcher"
FONT_DIR = ASSETS_DIR / "fonts"

LAUNCHER_DIR.mkdir(parents=True, exist_ok=True)

try:
    RESAMPLE = Image.Resampling.LANCZOS
except AttributeError:
    RESAMPLE = Image.LANCZOS

FONT_FILES = {
    "bold": FONT_DIR / "Inter-Bold.ttf",
    "semibold": FONT_DIR / "Inter-SemiBold.ttf",
    "medium": FONT_DIR / "Inter-Medium.ttf",
    "regular": FONT_DIR / "Inter-Regular.ttf",
}


def load_font(style: str, size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    path = FONT_FILES.get(style)
    if path and path.exists():
        return ImageFont.truetype(str(path), size)
    return ImageFont.load_default()


def _mix_channel(start: int, end: int, t: float) -> int:
    return round(start + ((end - start) * t))


def mix_color(start: tuple[int, int, int], end: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return tuple(_mix_channel(start[index], end[index], t) for index in range(3))


def build_vertical_gradient(size: tuple[int, int]) -> Image.Image:
    width, height = size
    gradient = Image.new("RGBA", (1, height))

    for y in range(height):
        t = y / max(height - 1, 1)
        if t < 0.52:
            color = mix_color(BG_TOP, BG_MID, t / 0.52)
        else:
            color = mix_color(BG_MID, BG_BOTTOM, (t - 0.52) / 0.48)
        gradient.putpixel((0, y), color + (255,))

    return gradient.resize((width, height), RESAMPLE)


def add_glow(
    image: Image.Image,
    center: tuple[int, int],
    radius: int,
    color: tuple[int, int, int],
    opacity: int,
) -> None:
    overlay = Image.new("RGBA", image.size, TRANSPARENT)
    draw = ImageDraw.Draw(overlay)
    cx, cy = center
    draw.ellipse(
        (cx - radius, cy - radius, cx + radius, cy + radius),
        fill=color + (opacity,),
    )
    blurred = overlay.filter(ImageFilter.GaussianBlur(max(12, radius // 3)))
    image.alpha_composite(blurred)


def add_grain(image: Image.Image, opacity: int = 10) -> None:
    noise = Image.effect_noise(image.size, 10).convert("L")
    noise = ImageOps.autocontrast(noise)
    alpha = noise.point(lambda value: int((value / 255) * opacity))
    grain = Image.new("RGBA", image.size, (255, 255, 255, 0))
    grain.putalpha(alpha)
    image.alpha_composite(grain)


def make_brand_canvas(size: tuple[int, int]) -> Image.Image:
    width, height = size
    canvas = build_vertical_gradient(size)
    add_glow(canvas, (int(width * 0.20), int(height * 0.14)), int(min(width, height) * 0.34), ACCENT, 62)
    add_glow(canvas, (int(width * 0.85), int(height * 0.10)), int(min(width, height) * 0.44), ACCENT, 28)
    add_glow(canvas, (width // 2, int(height * 1.06)), int(width * 0.72), WHITE, 18)
    add_grain(canvas, opacity=9)
    return canvas


def render_music_icon(
    size: int,
    color: tuple[int, int, int] = ACCENT,
    opacity: int = 255,
) -> Image.Image:
    render_size = max(size * 4, 128)
    svg_scale = render_size / 24.0
    stroke = max(2, round((2 / 24.0) * render_size))
    rgba = color + (opacity,)

    image = Image.new("RGBA", (render_size, render_size), TRANSPARENT)
    draw = ImageDraw.Draw(image)

    points = [
        (9 * svg_scale, 18 * svg_scale),
        (9 * svg_scale, 5 * svg_scale),
        (21 * svg_scale, 3 * svg_scale),
        (21 * svg_scale, 16 * svg_scale),
    ]

    try:
        draw.line(points, fill=rgba, width=stroke, joint="curve")
    except TypeError:
        draw.line(points, fill=rgba, width=stroke)

    cap_radius = stroke / 2
    end_x, end_y = points[-1]
    draw.ellipse(
        (end_x - cap_radius, end_y - cap_radius, end_x + cap_radius, end_y + cap_radius),
        fill=rgba,
    )

    for center_x, center_y, radius in ((6, 18, 3), (18, 16, 3)):
        x0 = ((center_x - radius) * svg_scale) - (stroke / 2)
        y0 = ((center_y - radius) * svg_scale) - (stroke / 2)
        x1 = ((center_x + radius) * svg_scale) + (stroke / 2)
        y1 = ((center_y + radius) * svg_scale) + (stroke / 2)
        draw.ellipse((x0, y0, x1, y1), outline=rgba, width=stroke)

    return image.resize((size, size), RESAMPLE)


def paste_centered(base: Image.Image, overlay: Image.Image, center: tuple[int, int]) -> tuple[int, int]:
    x = round(center[0] - (overlay.width / 2))
    y = round(center[1] - (overlay.height / 2))
    base.alpha_composite(overlay, dest=(x, y))
    return x, y


def measure_text(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont) -> tuple[int, int]:
    left, top, right, bottom = draw.textbbox((0, 0), text, font=font)
    return right - left, bottom - top


def draw_centered_text(
    draw: ImageDraw.ImageDraw,
    text: str,
    font: ImageFont.ImageFont,
    fill: tuple[int, int, int] | tuple[int, int, int, int],
    width: int,
    top: int,
) -> tuple[int, int]:
    text_width, text_height = measure_text(draw, text, font)
    x = round((width - text_width) / 2)
    draw.text((x, top), text, font=font, fill=fill)
    return text_width, text_height


def save_asset(image: Image.Image, output_name: str, final_size: tuple[int, int]) -> None:
    if image.size != final_size:
        image = image.resize(final_size, RESAMPLE)
    path = LAUNCHER_DIR / output_name
    image.save(path, "PNG", optimize=True)
    print(f"  {path.name}")


def generate_grid_cover() -> None:
    final_size = (600, 900)
    render_size = (final_size[0] * RENDER_SCALE, final_size[1] * RENDER_SCALE)
    width, height = render_size

    image = make_brand_canvas(render_size)
    add_glow(image, (width // 2, int(height * 0.27)), int(width * 0.24), ACCENT, 92)

    icon = render_music_icon(int(width * 0.35))
    paste_centered(image, icon, (width // 2, int(height * 0.29)))

    draw = ImageDraw.Draw(image)
    title_font = load_font("bold", 98)
    subtitle_font = load_font("medium", 36)

    draw_centered_text(draw, "Music FSE", title_font, WHITE, width, int(height * 0.60))
    draw_centered_text(draw, "Full Screen Experience", subtitle_font, ACCENT_LIGHT, width, int(height * 0.69))

    save_asset(image, "grid_cover_600x900.png", final_size)


def generate_hero_banner() -> None:
    final_size = (1920, 620)
    render_size = (final_size[0] * RENDER_SCALE, final_size[1] * RENDER_SCALE)
    width, height = render_size

    image = make_brand_canvas(render_size)
    add_glow(image, (int(width * 0.88), int(height * 0.35)), int(height * 0.58), ACCENT, 66)
    add_glow(image, (int(width * 0.22), int(height * 0.50)), int(height * 0.32), WHITE, 14)

    watermark = render_music_icon(int(height * 0.72), opacity=26)
    paste_centered(image, watermark, (int(width * 0.82), int(height * 0.50)))

    icon = render_music_icon(int(height * 0.34))

    draw = ImageDraw.Draw(image)
    title_font = load_font("bold", 176)
    title = "Music FSE"
    title_width, title_height = measure_text(draw, title, title_font)
    gap = 84
    group_width = icon.width + gap + title_width
    group_height = max(icon.height, title_height)
    group_left = round((width - group_width) / 2)
    group_top = round((height - group_height) / 2)
    icon_top = group_top + round((group_height - icon.height) / 2)
    title_x = group_left + icon.width + gap
    title_y = group_top + round((group_height - title_height) / 2) - 8

    image.alpha_composite(icon, dest=(group_left, icon_top))
    draw.text((title_x, title_y), title, font=title_font, fill=WHITE)

    save_asset(image, "hero_banner_1920x620.png", final_size)


def generate_logo_transparent() -> None:
    final_size = (960, 540)
    render_size = (final_size[0] * RENDER_SCALE, final_size[1] * RENDER_SCALE)
    width, height = render_size

    image = Image.new("RGBA", render_size, TRANSPARENT)
    icon = render_music_icon(320)
    draw = ImageDraw.Draw(image)
    title_font = load_font("bold", 148)

    title = "Music FSE"
    title_width, title_height = measure_text(draw, title, title_font)
    gap = 46
    group_width = icon.width + gap + title_width
    left = round((width - group_width) / 2)
    icon_y = round((height - icon.height) / 2)
    text_y = round((height - title_height) / 2) - 8

    image.alpha_composite(icon, dest=(left, icon_y))
    draw.text((left + icon.width + gap, text_y), title, font=title_font, fill=WHITE)

    save_asset(image, "logo_960x540.png", final_size)


def generate_background() -> None:
    final_size = (1920, 1080)
    render_size = (final_size[0] * RENDER_SCALE, final_size[1] * RENDER_SCALE)
    width, height = render_size

    image = make_brand_canvas(render_size)
    add_glow(image, (int(width * 0.76), int(height * 0.24)), int(height * 0.52), ACCENT, 42)
    add_glow(image, (int(width * 0.10), int(height * 0.18)), int(height * 0.28), ACCENT, 34)

    watermark = render_music_icon(int(height * 0.44), opacity=18)
    paste_centered(image, watermark, (int(width * 0.82), int(height * 0.56)))

    save_asset(image, "background_1920x1080.png", final_size)


def generate_square_capsule() -> None:
    final_size = (600, 600)
    render_size = (final_size[0] * RENDER_SCALE, final_size[1] * RENDER_SCALE)
    width, height = render_size

    image = make_brand_canvas(render_size)
    add_glow(image, (width // 2, int(height * 0.34)), int(width * 0.22), ACCENT, 86)

    icon = render_music_icon(int(width * 0.34))
    paste_centered(image, icon, (width // 2, int(height * 0.40)))

    draw = ImageDraw.Draw(image)
    title_font = load_font("semibold", 76)
    subtitle_font = load_font("medium", 28)

    draw_centered_text(draw, "Music FSE", title_font, WHITE, width, int(height * 0.69))
    draw_centered_text(draw, "Full Screen Experience", subtitle_font, ACCENT_LIGHT, width, int(height * 0.79))

    save_asset(image, "square_capsule_600x600.png", final_size)


def generate_playnite_icon() -> None:
    final_size = (256, 256)
    image = Image.new("RGBA", final_size, TRANSPARENT)
    icon = render_music_icon(220)
    paste_centered(image, icon, (final_size[0] // 2, final_size[1] // 2))
    save_asset(image, "playnite_icon_256x256.png", final_size)


def main() -> None:
    print("=== Music FSE Launcher Asset Generator ===")
    print(f"Fonts:    {FONT_DIR}")
    print(f"Output:   {LAUNCHER_DIR}\n")

    print("Launcher assets:")
    generate_grid_cover()
    generate_hero_banner()
    generate_logo_transparent()
    generate_background()
    generate_square_capsule()
    generate_playnite_icon()

    print("\nDone.")


if __name__ == "__main__":
    main()
