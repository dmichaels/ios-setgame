from PIL import Image, ImageDraw, ImageFont
from draw import _get_image_width, _get_image_height, _draw_rectangle, _draw_diamond, _lighten_color, _normalize_code

CARD_WIDTH              = 200
CARD_HEIGHT             = 290
CARD_BACKGROUND_COLOR   = "white"
CARD_BORDER_COLOR       = "red"
CARD_VERTICAL_OFFSETS   = [ [ 0 ], [-45, 45 ], [ -80, 0, 80 ] ]
CARD_VERTICAL_OFFSETS   = [ [ 0 ], [-43, 43 ], [ -74, 0, 74 ] ]
NUMBERS                 = [ 0, 1, 2 ]
COLORS                  = [ "#9C3327", "#2D34A1", "#4E824E" ] # red, blue, green
COLORS                  = [ "#9C3327", "#2D34A1", "#3D713D" ] # red, blue, green
SHAPES                  = [ "oval", "diamond", "squiggle" ]
FILLINGS                = [ "hollow", "stripe", "solid" ]
BORDER_THICKNESS_HOLLOW = 10
BORDER_THICKNESS_STRIPE = 8
SQUIGGLE_IS_DIAMOND     = False

def create_card_image():
    cx, cy = CARD_WIDTH // 2, CARD_HEIGHT // 2
    image = Image.new("RGB", (CARD_WIDTH, CARD_HEIGHT), CARD_BACKGROUND_COLOR)
    _draw_rectangle(image, cx, cy, CARD_WIDTH, CARD_HEIGHT,  "white", border=1, border_color=CARD_BORDER_COLOR)
    return image

def get_vertical_offsets(number):
    if number < 0:
        number = 1
    elif number > 3:
        number = 3
    return CARD_VERTICAL_OFFSETS[number - 1]

def get_draw_function(shape, filling):
    if shape == "oval":
        if filling == "hollow":
            return draw_oval_hollow
        elif filling == "solid":
            return draw_oval_solid
        elif filling == "stripe":
            return draw_oval_stripe
    elif shape in ["diamond"]:
        # DIAMOND is RECTANGLE (always)
        if filling == "hollow":
            return draw_rectangle_hollow
        elif filling == "solid":
            return draw_rectangle_solid
        elif filling == "stripe":
            return draw_rectangle_stripe
    elif shape in ["squiggle"]:
        if SQUIGGLE_IS_DIAMOND:
            # SQUIGGLE is DIAMOND (or optionally/alternatively BARBELL)
            if filling == "hollow":
                return draw_diamond_hollow
            elif filling == "solid":
                return draw_diamond_solid
            elif filling == "stripe":
                return draw_diamond_stripe
        else:
            # SQUIGGLE is BARBELL (or optionally/alternatively DIAMOND)
            if filling == "hollow":
                return draw_barbell_hollow
            elif filling == "solid":
                return draw_barbell_solid
            elif filling == "stripe":
                return draw_barbell_stripe

def draw_rectangle(image, y, color, border_thickness=0, border_color=""):

    card_width = _get_image_width(image)
    card_height = _get_image_height(image)
    cx, cy = card_width // 2, card_height // 2 + y
    sw = 142
    sh = 51
    _draw_rectangle(image, cx,  cy, sw, sh,  color, rounding=0.2, border=border_thickness, border_color=border_color)

def draw_rectangle_hollow(image, y, color):
    return draw_rectangle(image, y, CARD_BACKGROUND_COLOR, border_thickness=BORDER_THICKNESS_HOLLOW, border_color=color)

def draw_rectangle_stripe(image, y, color):
    return draw_rectangle(image, y, _lighten_color(color), border_thickness=BORDER_THICKNESS_STRIPE, border_color=color)

def draw_rectangle_solid(image, y, color):
    return draw_rectangle(image, y, color)

def draw_diamond(image, y, color, border_thickness=0, border_color=""):
    card_width = _get_image_width(image)
    card_height = _get_image_height(image)
    cx, cy = card_width // 2, card_height // 2 + y
    sw = 144
    sh = 60
    _draw_diamond(image, cx, cy, sw, sh, color=color, border=border_thickness, border_color=border_color)

def draw_diamond_hollow(image, y, color):
    return draw_diamond(image, y, CARD_BACKGROUND_COLOR, border_thickness=BORDER_THICKNESS_HOLLOW + 5, border_color=color)

def draw_diamond_stripe(image, y, color):
    return draw_diamond(image, y, _lighten_color(color), border_thickness=BORDER_THICKNESS_STRIPE + 3, border_color=color)

def draw_diamond_solid(image, y, color):
    return draw_diamond(image, y, color)

def draw_oval(image, y, color, border_thickness=0, border_color=""):

    card_width = _get_image_width(image)
    card_height = _get_image_height(image)
    cx, cy = card_width // 2, card_height // 2 + y
    sw = 142
    sh = 58
    _draw_rectangle(image, cx,  cy, sw, sh,  color, rounding=1.0, border=border_thickness, border_color=border_color)

def draw_oval_hollow(image, y, color):
    draw_oval(image, y, CARD_BACKGROUND_COLOR, border_thickness=BORDER_THICKNESS_HOLLOW, border_color=color)

def draw_oval_stripe(image, y, color):
    draw_oval(image, y, _lighten_color(color), border_thickness=BORDER_THICKNESS_STRIPE, border_color=color)

def draw_oval_solid(image, y, color):
    draw_oval(image, y, color)

def old_draw_barbell(image, y, color, border_thickness=0, border_color=""):

    card_width = _get_image_width(image)
    card_height = _get_image_height(image)
    cx, cy = card_width // 2, card_height // 2 + y

    # Draw barbell shape as our standin for squiggle.

    sw      = 60
    sh      = 60
    barh    = 16
    between = 30
    leftx   = cx - (sw / 2) - (between / 2)
    rightx  = cx + (sw / 2) + (between / 2)

    # Draw left and right squares.
    _draw_rectangle(image, leftx,  cy, sw, sh,  color,   rounding=0.1, border=border_thickness, border_color=border_color)
    _draw_rectangle(image, rightx, cy, sw, sh,  color,   rounding=0.1, border=border_thickness, border_color=border_color)
    # Draw connecting bar.
    _draw_rectangle(image, cx, cy, between + border_thickness * 2 + 4, barh,  color)
    # Draw top border of connecting bar.
    if border_thickness > 0:
        if True:
            border_thickness /= 2
            if border_thickness < 0:
                border_thickness = 1
        _draw_rectangle(image, cx, cy - (barh / 2) - (border_thickness / 2), between, border_thickness,  border_color)
        # Draw bottom border of connecting bar.
        _draw_rectangle(image, cx, cy + (barh / 2) + (border_thickness / 2), between, border_thickness,  border_color)

def draw_barbell(image, y, color, border_thickness=0, border_color=""):

    card_width = _get_image_width(image)
    card_height = _get_image_height(image)
    cx, cy = card_width // 2, card_height // 2 + y

    # Draw barbell shape as our standin for squiggle.

    sw      = 56
    sh      = 56
    barh    = 16
    between = 30
    leftx   = cx - (sw / 2) - (between / 2)
    rightx  = cx + (sw / 2) + (between / 2)

    # Draw left and right squares.
    _draw_rectangle(image, leftx,  cy, sw, sh,  color,   rounding=0.1, border=border_thickness, border_color=border_color)
    _draw_rectangle(image, rightx, cy, sw, sh,  color,   rounding=0.1, border=border_thickness, border_color=border_color)
    # Draw connecting bar.
    _draw_rectangle(image, cx, cy, between + border_thickness * 2 + 4, barh,  color)
    # Draw top border of connecting bar.
    if border_thickness > 0:
        if True:
            border_thickness /= 2
            border_thickness += 1
            if border_thickness < 0:
                border_thickness = 1
        _draw_rectangle(image, cx, cy - (barh / 2) - (border_thickness / 2), between, border_thickness,  border_color)
        # Draw bottom border of connecting bar.
        _draw_rectangle(image, cx, cy + (barh / 2) + (border_thickness / 2), between, border_thickness,  border_color)

def draw_barbell_hollow(image, y, color):
    draw_barbell(image, y, CARD_BACKGROUND_COLOR, border_thickness=BORDER_THICKNESS_HOLLOW, border_color=color)

def draw_barbell_stripe(image, y, color):
    draw_barbell(image, y, _lighten_color(color), border_thickness=BORDER_THICKNESS_STRIPE, border_color=color)

def draw_barbell_solid(image, y, color):
    draw_barbell(image, y, color)

def draw_card(number, color, shape, filling):
    image = create_card_image()
    vertical_offsets = get_vertical_offsets(number)
    draw_function = get_draw_function(shape, filling)
    for vertical_offset in vertical_offsets:
        draw_function(image, vertical_offset, color)
    return image

def filepath(code):
    # directory = "/tmp/setc"
    directory = f"/Users/dmichaels/repos/ios-setgame/SetGame/Assets.xcassets/{code}.imageset"
    return f"{directory}/{code}.png"

for inumber, number in enumerate(NUMBERS):
    for icolor, color in enumerate(COLORS):
        for ishape, shape in enumerate(SHAPES):
            for ifilling, filling in enumerate(FILLINGS):
                image = draw_card(number=number, color=color, shape=shape, filling=filling)
                code = _normalize_code(f"{icolor}{ishape}{ifilling}{inumber}", prefix="ALTC_")
                file = filepath(code)
                print(file)
                image.save(file)
                # TODO
                image.save(f"/tmp/setc/{code}.png")

#image = create_card_image()
#draw_rectangle(image, 20, "#4E824E")
#image.save(f"/tmp/setc/a.png")
