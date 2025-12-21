import math
from PIL import Image, ImageDraw, ImageFont

def _get_image_width(image):
    return image.size[0]

def _get_image_height(image):
    return image.size[1]

def _draw_circle(image, x, y, radius, color, border=0, border_color=None, aa=4):

    r_hi = radius * aa
    size = r_hi * 2

    # High-res temporary image
    tmp = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(tmp)

    # Filled circle
    d.ellipse(
        [0, 0, size - 1, size - 1],
        fill=color
    )

    # Inner border
    if border > 0 and border_color is not None:
        for i in range(border * aa):
            d.ellipse(
                [
                    i,
                    i,
                    size - 1 - i,
                    size - 1 - i
                ],
                outline=border_color
            )

    # Downsample for antialiasing
    tmp = tmp.resize(
        (radius * 2, radius * 2),
        resample=Image.LANCZOS
    )

    # Paste using alpha channel
    image.paste(
        tmp,
        (x - radius, y - radius),
        tmp
    )

def _draw_square(image, x, y, radius, color, border=0, border_color=None, aa=4):
    """
    Draw an antialiased filled square with optional INSIDE border.
    """

    r_hi = radius * aa
    size = r_hi * 2

    # High-res temporary image
    tmp = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(tmp)

    # Filled square
    d.rectangle(
        [0, 0, size - 1, size - 1],
        fill=color
    )

    # Inner border (draw inward)
    if border > 0 and border_color is not None:
        for i in range(border * aa):
            d.rectangle(
                [
                    i,
                    i,
                    size - 1 - i,
                    size - 1 - i
                ],
                outline=border_color
            )

    # Downsample for antialiasing
    tmp = tmp.resize(
        (radius * 2, radius * 2),
        resample=Image.LANCZOS
    )

    # Paste using alpha channel
    image.paste(
        tmp,
        (x - radius, y - radius),
        tmp
    )

def _draw_triangle(image, x, y, radius, color, border=0, border_color=None, aa=4):
    """
    Draw an antialiased filled equilateral triangle centered at (x, y),
    with circumradius = radius (triangle is inscribed in that circle).

    Optional border is drawn INSIDE (outer size unchanged).
    """

    r_hi = radius * aa
    size = r_hi * 2

    tmp = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(tmp)

    cx = cy = r_hi  # center of the high-res temp canvas

    def tri_points(R):
        # Choose a "point-up" triangle: top vertex at -90 degrees
        angles = [-90, 30, 150]
        pts = []
        for deg in angles:
            t = math.radians(deg)
            pts.append((cx + R * math.cos(t), cy + R * math.sin(t)))
        return pts

    # If border requested, draw outer triangle in border_color, then inner in fill color
    if border > 0 and border_color is not None:
        d.polygon(tri_points(r_hi), fill=border_color)

        inner_R = r_hi - border * aa
        if inner_R > 0:
            d.polygon(tri_points(inner_R), fill=color)
    else:
        d.polygon(tri_points(r_hi), fill=color)

    # Downsample for antialiasing
    tmp = tmp.resize((radius * 2, radius * 2), resample=Image.LANCZOS)

    # Paste onto main image using alpha
    image.paste(tmp, (x - radius, y - radius), tmp)

def _draw_rectangle(image, x, y, width, height, color,
              border=0, border_color=None,
              rounding=0.0, aa=4):
    """
    Draw an antialiased filled rectangle centered at (x, y).

    width, height are full output dimensions (pixels).

    rounding ∈ [0.0, 1.0]:
        0.0 = sharp corners
        1.0 = maximally rounded (capsule/oval-ended)

    Border (if any) is drawn INSIDE the shape.
    """

    # Sanity / clamp
    width = int(round(width))
    height = int(round(height))
    rounding = max(0.0, min(1.0, rounding))

    # Maximum corner radius allowed (capsule limit)
    max_radius = min(width, height) / 2.0
    corner_radius = rounding * max_radius

    # Supersampled sizes
    hi_w = width * aa
    hi_h = height * aa
    r_hi = corner_radius * aa

    tmp = Image.new("RGBA", (hi_w, hi_h), (0, 0, 0, 0))
    d = ImageDraw.Draw(tmp)

    def draw_shape(bounds, fill=None, outline=None, rad=0):
        if rad > 0:
            d.rounded_rectangle(bounds, radius=rad, fill=fill, outline=outline)
        else:
            d.rectangle(bounds, fill=fill, outline=outline)

    # Outer filled shape
    outer = [0, 0, hi_w - 1, hi_h - 1]
    draw_shape(outer, fill=color, rad=r_hi)

    # Inner border (drawn inward)
    if border > 0 and border_color is not None:
        b_hi = int(round(border * aa))
        for i in range(b_hi):
            bounds = [i, i, hi_w - 1 - i, hi_h - 1 - i]
            rad_i = max(0.0, r_hi - i)
            draw_shape(bounds, outline=border_color, rad=rad_i)

    # Downsample and paste
    tmp = tmp.resize((width, height), resample=Image.LANCZOS)
    image.paste(tmp, (int(x - width // 2), int(y - height // 2)), tmp)

def _draw_diamond(image, x, y, radius, color, border=0, border_color=None, aa=4, stretch_y=1.25):
    """
    Antialiased diamond, taller than wide.

    - (x, y) is center.
    - radius controls half-width (left/right extent).
    - height = radius * stretch_y (top/bottom extent).
    - Border is drawn INSIDE.
    """

    out_w = int(round(radius * 2))
    out_h = int(round(radius * 2 * stretch_y))

    hi_w = out_w * aa
    hi_h = out_h * aa

    tmp = Image.new("RGBA", (hi_w, hi_h), (0, 0, 0, 0))
    d = ImageDraw.Draw(tmp)

    cx = hi_w / 2.0
    cy = hi_h / 2.0

    hw = radius * aa
    hh = radius * stretch_y * aa

    def pts(_hw, _hh):
        return [
            (cx,      cy - _hh),  # top
            (cx + _hw, cy),       # right
            (cx,      cy + _hh),  # bottom
            (cx - _hw, cy)        # left
        ]

    if border > 0 and border_color is not None:
        d.polygon(pts(hw, hh), fill=border_color)

        inner_hw = hw - border * aa
        inner_hh = hh - border * aa
        if inner_hw > 0 and inner_hh > 0:
            d.polygon(pts(inner_hw, inner_hh), fill=color)
    else:
        d.polygon(pts(hw, hh), fill=color)

    tmp = tmp.resize((out_w, out_h), resample=Image.LANCZOS)

    # paste centered at (x, y)
    image.paste(tmp, (x - out_w // 2, y - out_h // 2), tmp)

def _draw_number(image, x, y, radius, color, number):
    """
    Draw a bold number centered inside the circle of radius `radius`
    around (x, y). Text color = `color`.
    """

    draw = ImageDraw.Draw(image)

    # Common bold fonts on macOS (try in order)
    font_candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Helvetica Bold.ttf",
        "/System/Library/Fonts/Supplemental/Verdana Bold.ttf",
        "/System/Library/Fonts/Supplemental/Trebuchet MS Bold.ttf",
    ]

    text = str(number)

    # Target text box (a bit smaller than the circle diameter)
    # target_w = radius * 2 * 0.35
    # target_h = radius * 2 * 0.35

    target_w = radius * 2 * 1.15
    target_h = radius * 2 * 1.15

    # Load a bold TTF font and size it to fit
    font = None
    for path in font_candidates:
        try:
            # Start with a guess; we'll refine below
            font = ImageFont.truetype(path, size=10)
            break
        except OSError:
            pass

    if font is None:
        # Fallback (not bold, but at least works)
        font = ImageFont.load_default()
        # Draw centered with default font
        bbox = draw.textbbox((0, 0), text, font=font)
        tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
        draw.text((x - tw / 2, y - th / 2), text, fill=color, font=font)
        return

    # Binary search for best font size that fits target box
    lo, hi = 1, int(radius * 4)  # generous upper bound
    best = lo
    font_path = font.path  # type: ignore[attr-defined]

    while lo <= hi:
        mid = (lo + hi) // 2
        f = ImageFont.truetype(font_path, size=mid)
        bbox = draw.textbbox((0, 0), text, font=f)
        tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]

        if tw <= target_w and th <= target_h:
            best = mid
            lo = mid + 1
        else:
            hi = mid - 1

    font = ImageFont.truetype(font_path, size=best)

    # Center using bbox (accounts for font ascent/descent properly)
    bbox = draw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    ox, oy = bbox[0], bbox[1]

    draw.text(
        (x - tw / 2 - ox, y - th / 2 - oy),
        text,
        fill=color,
        font=font
    )

def _lighten_color(hex_color, amount=0.6):
    """
    Lighten a hex color by blending it toward white.

    amount: 0.0 = no change
            1.0 = white
    """
    hex_color = hex_color.lstrip("#")

    r = int(hex_color[0:2], 16)
    g = int(hex_color[2:4], 16)
    b = int(hex_color[4:6], 16)

    r = int(r + (255 - r) * amount)
    g = int(g + (255 - g) * amount)
    b = int(b + (255 - b) * amount)

    return f"#{r:02X}{g:02X}{b:02X}"

def _normalize_code(code):

    if len(code) != 4:
        return code

    normalized_code = "ALT_"

    if code[0] == "0":
        normalized_code += "R"
    elif code[0] == "1":
        normalized_code += "P"
    elif code[0] == "2":
        normalized_code += "G"

    if code[1] == "0":
        normalized_code += "O"
    elif code[1] == "1":
        normalized_code += "D"
    elif code[1] == "2":
        normalized_code += "Q"

    if code[2] == "0":
        normalized_code += "H"
    elif code[2] == "1":
        normalized_code += "T"
    elif code[2] == "2":
        normalized_code += "S"

    if code[3] == "0":
        normalized_code += "1"
    elif code[3] == "1":
        normalized_code += "2"
    elif code[3] == "2":
        normalized_code += "3"

    return normalized_code
