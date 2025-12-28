from PIL import Image, ImageDraw, ImageFont
from draw import _get_image_width, _get_image_height, _draw_rectangle, _draw_diamond, _lighten_color, _normalize_code, _scale_image

CARD_WIDTH              = 200
CARD_HEIGHT             = 240
CARD_BACKGROUND_COLOR   = "white"
CARD_BORDER_COLOR       = "black"
CARD_VERTICAL_OFFSETS   = [ [ 0 ], [-45, 45 ], [ -80, 0, 80 ] ]
CARD_VERTICAL_OFFSETS   = [ [ 0 ], [-43, 43 ], [ -74, 0, 74 ] ]
CARD_VERTICAL_OFFSETS   = [ [ 0 ], [-30, 30 ], [ -60, 0, 60 ] ]
ROW_NUMBERS             = [ "1", "2", "3" ]
COLUMN_NUMBERS          = [ "1", "2", "3" ]
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

def draw_rectangle(image, x, y, width, height, color, border_thickness=0, border_color=""):
    _draw_rectangle(image, x,  y, width, height,  color, rounding=0.2, border=border_thickness, border_color=border_color)

x = CARD_WIDTH // 2
y = CARD_HEIGHT // 2
width = 50
height = 50
spacing = 5
x_spacing = spacing
y_spacing = spacing
color = "red"
image = create_card_image()

x_left   = x - width - x_spacing
x_center = x
x_right  = x + width + x_spacing

y_top    = y - height - y_spacing
y_center = y
y_bottom = y + height + y_spacing

draw_rectangle(image, x_left,   y_top, width, height, "red", border_thickness=0, border_color="")
draw_rectangle(image, x_center, y_top, width, height, "blue", border_thickness=0, border_color="")
draw_rectangle(image, x_right,  y_top, width, height, "green", border_thickness=0, border_color="")

draw_rectangle(image, x_left,   y_center, width, height, "red", border_thickness=0, border_color="")
draw_rectangle(image, x_center, y_center, width, height, "blue", border_thickness=0, border_color="")
draw_rectangle(image, x_right,  y_center, width, height, "green", border_thickness=0, border_color="")

draw_rectangle(image, x_left,   y_bottom, width, height, "red", border_thickness=0, border_color="")
draw_rectangle(image, x_center, y_bottom, width, height, "blue", border_thickness=0, border_color="")
draw_rectangle(image, x_right,  y_bottom, width, height, "green", border_thickness=0, border_color="")

# draw_rectangle(image, x - width - spacing, y - height - spacing, width, height, "red", border_thickness=0, border_color="")
# draw_rectangle(image, x,                   y - height - spacing, width, height, "green",   border_thickness=0, border_color="")
# draw_rectangle(image, x + width + spacing, y - height - spacing, width, height, "blue",  border_thickness=0, border_color="")
# draw_rectangle(image, x - width - spacing, y,                    width, height, "red", border_thickness=0, border_color="")
# draw_rectangle(image, x,                   y,                    width, height, "green",    border_thickness=0, border_color="")
# draw_rectangle(image, x + width + spacing, y,                    width, height, "blue", border_thickness=0, border_color="")
# draw_rectangle(image, x - width - spacing, y + height + spacing, width, height, "red",  border_thickness=0, border_color="")
# draw_rectangle(image, x,                   y + height + spacing, width, height, "green",  border_thickness=0, border_color="")
# draw_rectangle(image, x + width + spacing, y + height + spacing, width, height, "blue",  border_thickness=0, border_color="")

image.save(f"/tmp/set/a.png")

coordinates = [
    [ (x_left, y_top) ],
    [ (x_left, y_top), (x_center, y_top) ],
    [ (x_left, y_top), (x_center, y_top), (x_right, y_top) ],

    [ (x_left, y_top), (x_left, y_center) ],
    [ (x_left, y_top), (x_left, y_center), (x_center, y_top), (x_center, y_center) ],
    [ (x_left, y_top), (x_left, y_center), (x_center, y_top), (x_center, y_center), (x_right, y_top), (x_right, y_center) ],

    [ (x_left, y_top), (x_left, y_center), (x_left, y_bottom) ],
    [ (x_left, y_top), (x_left, y_center), (x_left, y_bottom), (x_center, y_top), (x_center, y_center), (x_center, y_bottom) ],
    [ (x_left, y_top), (x_left, y_center), (x_left, y_bottom), (x_center, y_top), (x_center, y_center), (x_center, y_bottom), (x_right, y_top), (x_right, y_center), (x_right, y_bottom) ]
]

coordinates = [
  [
    [ (x_left, y_top), (),                 (),                 (),                   (),                   (),                   (),               (),                  (),                ],
    [ (x_left, y_top), (x_center, y_top),  (),                 (),                   (),                   (),                   (),               (),                  (),                ],
    [ (x_left, y_top), (x_center, y_top),  (x_right, y_top),   (),                   (),                   (),                   (),               (),                  (),                ],
  ],
  [
    [ (x_left, y_top), (x_left, y_center), (),                 (),                   (),                   (),                   (),               (),                  (),                ],
    [ (x_left, y_top), (x_left, y_center), (x_center, y_top),  (x_center, y_center), (),                   (),                   (),               (),                  (),                ],
    [ (x_left, y_top), (x_left, y_center), (x_center, y_top),  (x_center, y_center), (x_right, y_top),     (x_right, y_center),  (),               (),                  (),                ],
  ],
  [
    [ (x_left, y_top), (x_left, y_center), (x_left, y_bottom), (),                   (),                   (),                   (),               (),                  (),                ],
    [ (x_left, y_top), (x_left, y_center), (x_left, y_bottom), (x_center, y_top),    (x_center, y_center), (x_center, y_bottom), (),               (),                  ()                 ],
    [ (x_left, y_top), (x_left, y_center), (x_left, y_bottom), (x_center, y_top),    (x_center, y_center), (x_center, y_bottom), (x_right, y_top), (x_right, y_center), (x_right, y_bottom) ]
  ]
]

x_left   = x - width - x_spacing
x_center = x
x_right  = x + width + x_spacing

y_top    = y - height - y_spacing
y_center = y
y_bottom = y + height + y_spacing

def draw_figures():
    for icolumn, column in enumerate(COLUMN_NUMBERS):
        for irow, row in enumerate(ROW_NUMBERS):
            for ishape, shape in enumerate(SHAPES):
                for ifilling, filling in enumerate(FILLINGS):
                    # image = draw_card(row=row, column=column, shape=shape, filling=filling)
                    print(f"{column},{row}: {shape} {filling} -> {coordinates[icolumn][irow]}")
                    pass

# main()
draw_figures()
