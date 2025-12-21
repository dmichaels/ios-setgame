from PIL import Image, ImageDraw, ImageFont
from draw import draw_rectangle, normalize_code

CARD_WIDTH            = 200
CARD_HEIGHT           = 300
CARD_BACKGROUND_COLOR = "white"
CARD_BORDER_COLOR     = "red"
CARD_VERTICAL_OFFSETS = [ [ 0 ], [-45, 45 ], [ -80, 0, 80 ] ]

SHAPES = ["rectangle", "oval", ""]

def create_card_image():
    cx, cy = CARD_WIDTH // 2, CARD_HEIGHT // 2
    image = Image.new("RGB", (CARD_WIDTH, CARD_HEIGHT), CARD_BACKGROUND_COLOR)
    draw_rectangle(image, cx, cy, CARD_WIDTH, CARD_HEIGHT,  "white", border=1, border_color=CARD_BORDER_COLOR)
    return image

def get_image_width(image):
    return image.size[0]

def get_image_height(image):
    return image.size[1]

def get_vertical_offsets(number):
    if number < 0:
        number = 1
    elif number > 3:
        number = 3
    return CARD_VERTICAL_OFFSETS[number - 1]

def get_draw_function(shape, filling):
    if shape == "squiggle":
        if filling == "hollow":
            return draw_squiggle_hollow
        elif filling == "solid":
            return draw_squiggle_solid
    elif shape == "rectangle":
        if filling == "hollow":
            return draw_rectangle_hollow
        elif filling == "solid":
            return draw_rectangle_solid
    elif shape == "oval":
        if filling == "hollow":
            return draw_oval_hollow
        elif filling == "solid":
            return draw_oval_solid

def _draw_rectangle(image, y, color, border_thickness=0, border_color=""):

    card_width = get_image_width(image)
    card_height = get_image_height(image)
    cx, cy = card_width // 2, card_height // 2 + y
    sw = 142
    sh = 56
    draw_rectangle(image, cx,  cy, sw, sh,  color,   rounding=0.2, border=border_thickness, border_color=border_color)

def draw_oval(image, y, color, border_thickness=0, border_color=""):

    card_width = get_image_width(image)
    card_height = get_image_height(image)
    cx, cy = card_width // 2, card_height // 2 + y
    sw = 142
    sh = 56
    draw_rectangle(image, cx,  cy, sw, sh,  color,   rounding=1.0, border=border_thickness, border_color=border_color)

def draw_oval_hollow(image, y, color, border_thickness):
    draw_oval(image, y, CARD_BACKGROUND_COLOR, border_thickness, color)

def draw_oval_solid(image, y, color, border_thickness):
    draw_oval(image, y, color)

def draw_squiggle(image, y, color, border_thickness, border_color):

    card_width = get_image_width(image)
    card_height = get_image_height(image)
    cx, cy = card_width // 2, card_height // 2 + y

    # Draw barbell shape as our standin for squiggle.

    sw      = 60
    sh      = 60
    barh    = 20
    between = 30
    leftx   = cx - (sw / 2) - (between / 2)
    rightx  = cx + (sw / 2) + (between / 2)

    # Draw left and right squares.
    draw_rectangle(image, leftx,  cy, sw, sh,  color,   rounding=0.1, border=border_thickness, border_color=border_color)
    draw_rectangle(image, rightx, cy, sw, sh,  color,   rounding=0.1, border=border_thickness, border_color=border_color)
    # Draw connecting bar.
    draw_rectangle(image, cx, cy, between + border_thickness * 2 + 4, barh,  color)
    # Draw top border of connecting bar.
    draw_rectangle(image, cx, cy - (barh / 2) - (border_thickness / 2), between, border_thickness,  border_color)
    # Draw bottom border of connecting bar.
    draw_rectangle(image, cx, cy + (barh / 2) + (border_thickness / 2), between, border_thickness,  border_color)

def draw_squiggle_hollow(image, y, color, border_thickness):
    draw_squiggle(image, y, CARD_BACKGROUND_COLOR, border_thickness, color)

def draw_squiggle_solid(image, y, color, border_thickness):
    draw_squiggle(image, y, color, 1, color)

def draw_card(number, color, shape, filling):
    image = create_card_image()
    vertical_offsets = get_vertical_offsets(number)
    draw_function = get_draw_function(shape, filling)
    for vertical_offset in vertical_offsets:
        draw_function(image, vertical_offset, color, 2)
        # draw_rectangle_hollow(image, vertical_offset, color, 2)
    return image

image = draw_card(number=3, color="blue", shape="oval", filling="solid")
image.save("/tmp/a.png")
