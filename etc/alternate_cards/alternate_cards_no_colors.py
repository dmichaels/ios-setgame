from PIL import Image, ImageDraw, ImageFont
from draw import _draw_rectangle, _draw_circle, _draw_diamond, _draw_triangle, _draw_diamond
from draw import _get_image_width, _get_image_height, _lighten_color, _normalize_code, _scale_image
from functools import partial

CARD_WIDTH              = 210
CARD_HEIGHT             = 220
CARD_BACKGROUND_COLOR   = "white"
CARD_BORDER_COLOR       = "black"
NUMBERS                 = [ "0", "2", "1" ] # sic - not 123 - see HelpView.swift
COLUMNS                 = [ "0", "1", "2" ]
SHAPES                  = [ "oval", "diamond", "squiggle" ]
FILLINGS                = [ "hollow", "stripe", "solid" ]
FIGURE_WIDTH            = 55
FIGURE_HEIGHT           = 55
FIGURE_SPACING          = 7
FIGURE_COLOR            = "#0B1280" # blue-ish
FIGURE_COLOR            = "#1B501B" # green-ish
FIGURE_COLOR            = "#0A0170" # blue-ish
TRIANGLE_NOT_DIAMOND    = False
TRIANGLE_FLIP           = False
BORDER_THICKNESS        = 6

IMAGE_PREFIX            = "ALTNC_"
TEST_DIRECTORY          = lambda code: f"/tmp/set"
LIVE_DIRECTORY          = lambda code: f"/Users/dmichaels/repos/ios-setgame/SetGame/Assets.xcassets/{code}.imageset"
DIRECTORY               = TEST_DIRECTORY
DIRECTORY               = LIVE_DIRECTORY

def create_card_image():
    cx, cy = CARD_WIDTH // 2, CARD_HEIGHT // 2
    image = Image.new("RGB", (CARD_WIDTH, CARD_HEIGHT), CARD_BACKGROUND_COLOR)
    _draw_rectangle(image, cx, cy, CARD_WIDTH, CARD_HEIGHT,  "white", border=1, border_color=CARD_BORDER_COLOR)
    return image

def draw_rectangle(image, x, y, width, height, color, border_thickness=0, border_color=""):
    _draw_rectangle(image, x,  y, width, height,  color, rounding=0.2, border=border_thickness, border_color=border_color)

def draw_circle(image, x, y, width, height, color, border_thickness=0, border_color=""):
    _draw_circle(image, x, y, width // 2, color, border=border_thickness, border_color=border_color)

def draw_triangle(image, x, y, width, height, color, border_thickness=0, border_color=""):
    fudge_width = 8
    fudge_border_thickness = 4
    if border_thickness > 0:
        border_thickness -= fudge_border_thickness
    _draw_triangle(image, x, y, width // 2 + fudge_width, color, border=border_thickness, border_color=border_color, flip=TRIANGLE_FLIP)

def draw_diamond(image, x, y, width, height, color, border_thickness=0, border_color=""):
    fudge_width = 3
    fudge_border_thickness = 2
    if border_thickness > 0:
        border_thickness += fudge_border_thickness
    _draw_diamond(image, x, y, width + fudge_width, height, color, border=border_thickness, border_color=border_color)

def get_figure_coordinates():

    x         = CARD_WIDTH // 2
    y         = CARD_HEIGHT // 2
    x_spacing = FIGURE_SPACING
    y_spacing = FIGURE_SPACING # + 2
    x_left    = x - FIGURE_WIDTH - x_spacing
    x_center  = x
    x_right   = x + FIGURE_WIDTH + x_spacing
    y_top     = y - FIGURE_HEIGHT - y_spacing
    y_center  = y
    y_bottom  = y + FIGURE_HEIGHT + y_spacing

    return [
        [
            [
                (x_left, y_top)
            ],
            [
                (x_left, y_top), (x_center, y_top)
            ],
            [
                (x_left, y_top), (x_center, y_top), (x_right, y_top)
            ],
        ],
        [
            [
                (x_left, y_top),
                (x_left, y_center)
            ],
            [
                (x_left, y_top),    (x_center, y_top),
                (x_left, y_center), (x_center, y_center)
            ],
            [
                (x_left, y_top),    (x_center, y_top),    (x_right, y_top),
                (x_left, y_center), (x_center, y_center), (x_right, y_center)
            ],
        ],
        [
            [
                (x_left, y_top),
                (x_left, y_center),
                (x_left, y_bottom)
            ],
            [
                (x_left, y_top),    (x_center, y_top),
                (x_left, y_center), (x_center, y_center),
                (x_left, y_bottom), (x_center, y_bottom)
            ],
            [
                (x_left, y_top),    (x_center, y_top),    (x_right, y_top),
                (x_left, y_center), (x_center, y_center), (x_right, y_center),
                (x_left, y_bottom), (x_center, y_bottom), (x_right, y_bottom)
            ]
        ]
    ]

def draw_card(number, column, shape, filling):

    def get_draw_function(shape):
        if shape == "diamond":
            return draw_circle
        elif shape == "squiggle":
            if TRIANGLE_NOT_DIAMOND:
                return draw_triangle
            else:
                return draw_diamond
        else:
            return draw_rectangle

    def get_draw_with_filling_function(draw_function, filling):
        if filling == "hollow":
            return partial(draw_function, color=CARD_BACKGROUND_COLOR, border_thickness=BORDER_THICKNESS, border_color=FIGURE_COLOR)
        elif filling == "stripe":
            return partial(draw_function, color=_lighten_color(FIGURE_COLOR), border_thickness=BORDER_THICKNESS, border_color=FIGURE_COLOR)
        else:
            return partial(draw_function, color=FIGURE_COLOR, border_thickness=0, border_color="")

    image = create_card_image()
    draw = get_draw_with_filling_function(get_draw_function(shape), filling)
    coordinates = get_figure_coordinates()[int(number)][int(column)]

    for coordinate in coordinates:
        draw(image, coordinate[0], coordinate[1], FIGURE_WIDTH, FIGURE_HEIGHT)

    return image

def draw_figures():
    for inumber, number in enumerate(NUMBERS):
        for icolumn, column in enumerate(COLUMNS):
            for ishape, shape in enumerate(SHAPES):
                for ifilling, filling in enumerate(FILLINGS):
                    image = draw_card(number, column, shape, filling)
                    code = _normalize_code(f"{inumber}{icolumn}{ishape}{ifilling}", prefix=IMAGE_PREFIX)
                    directory = DIRECTORY(code)
                    file = (f"{directory}/{code}.png")
                    image.save(file)
                    print(file)
                    pass

draw_figures()
