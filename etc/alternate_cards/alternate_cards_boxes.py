from PIL import Image, ImageDraw, ImageFont
from draw import _get_image_width, _get_image_height, _draw_rectangle, _draw_diamond, _lighten_color, _normalize_code, _scale_image

CARD_WIDTH              = 200
CARD_HEIGHT             = 240
CARD_BACKGROUND_COLOR   = "white"
CARD_BORDER_COLOR       = "white"
CARD_VERTICAL_OFFSETS   = [ [ 0 ], [-45, 45 ], [ -80, 0, 80 ] ]
CARD_VERTICAL_OFFSETS   = [ [ 0 ], [-43, 43 ], [ -74, 0, 74 ] ]
CARD_VERTICAL_OFFSETS   = [ [ 0 ], [-30, 30 ], [ -60, 0, 60 ] ]
NUMBERS                 = [ 0, 1, 2 ]
COLORS                  = [ "#9C3327", "#2D34A1", "#4E824E" ] # red, blue, green
COLORS                  = [ "#9C3327", "#2D34A1", "#3D713D" ] # red, blue, green
SHAPES                  = [ "oval", "diamond", "squiggle" ]
FILLINGS                = [ "hollow", "stripe", "solid" ]
BORDER_THICKNESS_HOLLOW = 10
BORDER_THICKNESS_STRIPE = 8

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
    return CARD_VERTICAL_OFFSETS[number - 0]

def get_draw_function(shape, filling):
    if shape == "oval":
        if filling == "hollow":
            return draw_rectangle_hollow
        elif filling == "solid":
            return draw_rectangle_solid
        elif filling == "stripe":
            return draw_rectangle_stripe
    elif shape in ["diamond"]:
        if filling == "hollow":
            return draw_rectangle_two_hollow
        elif filling == "solid":
            return draw_rectangle_two_solid
        elif filling == "stripe":
            return draw_rectangle_two_stripe
    elif shape in ["squiggle"]:
        if filling == "hollow":
            return draw_rectangle_three_hollow
        elif filling == "solid":
            return draw_rectangle_three_solid
        elif filling == "stripe":
            return draw_rectangle_three_stripe

FIGURE_WIDTH = CARD_WIDTH * 0.71

def draw_rectangle(image, y, color, border_thickness=0, border_color=""):
    card_width = _get_image_width(image)
    card_height = _get_image_height(image)
    cx, cy = card_width // 2, card_height // 2 + y
    sw = FIGURE_WIDTH + 8 # sw = 142
    sh = 51
    _draw_rectangle(image, cx,  cy, sw, sh,  color, rounding=0.2, border=border_thickness, border_color=border_color)

def draw_rectangle_hollow(image, y, color):
    return draw_rectangle(image, y, CARD_BACKGROUND_COLOR, border_thickness=BORDER_THICKNESS_HOLLOW, border_color=color)

def draw_rectangle_stripe(image, y, color):
    return draw_rectangle(image, y, _lighten_color(color), border_thickness=BORDER_THICKNESS_STRIPE, border_color=color)

def draw_rectangle_solid(image, y, color):
    return draw_rectangle(image, y, color)

def draw_rectangle_two(image, y, color, border_thickness=0, border_color=""):
    card_width = _get_image_width(image)
    card_height = _get_image_height(image)
    cx, cy = card_width // 2, card_height // 2 + y
    sw = FIGURE_WIDTH // 2 # sw = 142 // 2
    sh = 51
    cx_one = cx - 40
    cx_two = cx + 40
    _draw_rectangle(image, cx_one,  cy, sw, sh,  color, rounding=0.2, border=border_thickness, border_color=border_color)
  # _draw_rectangle(image, cx,      cy, 10, max(border_thickness * 2, 2), border_color if border_color else color) # connector
    _draw_rectangle(image, cx,      cy, 9, 14, border_color if border_color else color) # connector
    _draw_rectangle(image, cx_two,  cy, sw, sh,  color, rounding=0.2, border=border_thickness, border_color=border_color)

def draw_rectangle_two_hollow(image, y, color):
    return draw_rectangle_two(image, y, CARD_BACKGROUND_COLOR, border_thickness=BORDER_THICKNESS_HOLLOW, border_color=color)

def draw_rectangle_two_stripe(image, y, color):
    return draw_rectangle_two(image, y, _lighten_color(color), border_thickness=BORDER_THICKNESS_STRIPE, border_color=color)

def draw_rectangle_two_solid(image, y, color):
    return draw_rectangle_two(image, y, color)

def draw_rectangle_three(image, y, color, border_thickness=0, border_color=""):
    card_width = _get_image_width(image)
    card_height = _get_image_height(image)
    cx, cy = card_width // 2, card_height // 2 + y
    sw = FIGURE_WIDTH // 3 - 2 # sw = 142 // 3 - 2
    sh = 51
    cx_one = cx - 52
    cx_two = cx +  0
    cx_tre = cx + 52
    _draw_rectangle(image, cx_one,              cy, sw, sh,  color, rounding=0.2, border=border_thickness, border_color=border_color)
    _draw_rectangle(image, cx_one + (sw // 2) + 2,  cy, 14, 14, border_color if border_color else color) # connector
    _draw_rectangle(image, cx_two,              cy, sw, sh,  color, rounding=0.2, border=border_thickness, border_color=border_color)
    _draw_rectangle(image, cx_two + (sw // 2) + 2,  cy, 14, 14, border_color if border_color else color) # connector
    _draw_rectangle(image, cx_tre,              cy, sw, sh,  color, rounding=0.2, border=border_thickness, border_color=border_color)

def draw_rectangle_three_hollow(image, y, color):
    return draw_rectangle_three(image, y, CARD_BACKGROUND_COLOR, border_thickness=BORDER_THICKNESS_HOLLOW, border_color=color)

def draw_rectangle_three_stripe(image, y, color):
    return draw_rectangle_three(image, y, _lighten_color(color), border_thickness=BORDER_THICKNESS_STRIPE, border_color=color)

def draw_rectangle_three_solid(image, y, color):
    return draw_rectangle_three(image, y, color)

def draw_card(number, color, shape, filling):
    image = create_card_image()
    vertical_offsets = get_vertical_offsets(number)
    draw_function = get_draw_function(shape, filling)
    for vertical_offset in vertical_offsets:
        draw_function(image, vertical_offset, color)
    return image

def draw_icons():
    image = create_card_image()
    draw_function_one = get_draw_function(SHAPES[0], FILLINGS[2])
    draw_function_two = get_draw_function(SHAPES[1], FILLINGS[1])
    draw_function_tre = get_draw_function(SHAPES[2], FILLINGS[0])
    card_vertical_offsets = CARD_VERTICAL_OFFSETS[2]
    card_vertical_offset_one = card_vertical_offsets[1]
    card_vertical_offset_two = card_vertical_offsets[0]
    card_vertical_offset_tre = card_vertical_offsets[2]
    color_one = COLORS[0]
    color_two = COLORS[1]
    color_tre = COLORS[2]
    draw_function_one(image, card_vertical_offset_one, color_one)
    draw_function_two(image, card_vertical_offset_two, color_two)
    draw_function_tre(image, card_vertical_offset_tre, color_tre)
    tmp_file = "/tmp/setc/tmp.png"
    image.save(tmp_file)
    icon_file_180_180 = filepath_icon(f"icon_180_180")
    icon_file_120_120 = filepath_icon(f"icon_120_120")
    # icon_ipad_app_76pt_152_152 = (f"/tmp/setc/icon_ipad_app_76pt_152_152.png")
    # icon_app_store_ios_1024pt_1024_1024 = (f"/tmp/setc/icon_app_store_ios_1024pt_1024_1024.png")
    icon_ipad_app_76pt_152_152 = filepath_icon(f"icon_ipad_app_76pt_152_152.png")
    icon_app_store_ios_1024pt_1024_1024 = filepath_icon(f"icon_app_store_ios_1024pt_1024_1024.png")
    _scale_image(tmp_file, icon_file_120_120,                   120,  120)
    _scale_image(tmp_file, icon_file_180_180,                   180,  180)
    _scale_image(tmp_file, icon_ipad_app_76pt_152_152,          152,  152)
    _scale_image(tmp_file, icon_app_store_ios_1024pt_1024_1024, 1024, 1024)
    print(icon_file_180_180)
    print(icon_file_120_120)
    print(icon_ipad_app_76pt_152_152)
    print(icon_app_store_ios_1024pt_1024_1024)

def filepath_icon(name):
    directory = "/Users/dmichaels/repos/ios-setgame/SetGame/Assets.xcassets/AppIcon.appiconset"
    return f"{directory}/{name}.png"

def filepath(code):
    # directory = "/tmp/setc"
    directory = f"/Users/dmichaels/repos/ios-setgame/SetGame/Assets.xcassets/{code}.imageset"
    return f"{directory}/{code}.png"

for icolor, color in enumerate(COLORS):
    for ishape, shape in enumerate(SHAPES):
        for ifilling, filling in enumerate(FILLINGS):
            for inumber, number in enumerate(NUMBERS):
                image = draw_card(number=number, color=color, shape=shape, filling=filling)
                code = _normalize_code(f"{icolor}{ishape}{ifilling}{inumber}", prefix="ALTD_")
                file = filepath(code)
                print(file)
                image.save(file)
draw_icons()

image = create_card_image()
image.save(filepath("DUMMY"))

#image = create_card_image()
#draw_rectangle(image, 20, "#4E824E")
#image.save(f"/tmp/setc/a.png")
