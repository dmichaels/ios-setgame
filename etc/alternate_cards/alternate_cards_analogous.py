from PIL import Image, ImageDraw, ImageFont
from draw import draw_rectangle, normalize_code

CARD_WIDTH       = 200
CARD_HEIGHT      = 300

card_background_color = "white"
card_border_color = "red"

colors_one       = [ "red", "purple", "green" ]
colors_two       = [ "red", "purple", "green" ]
colors_three     = [ "red", "purple", "green" ]
colors_four      = [ "red", "purple", "green" ]

def draw_squiggle(color, border_thickness, border_color):

    # Draw barbell shape as our standin for squiggle.

    cx, cy = CARD_WIDTH // 2, CARD_HEIGHT // 2
    image = Image.new("RGB", (CARD_WIDTH, CARD_HEIGHT), card_background_color)
    draw_rectangle(image, cx, cy, CARD_WIDTH, CARD_HEIGHT,  "white", border=1, border_color=card_border_color)

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

    return image

def draw_squiggle_hollow(color, border_thickness):
    return draw_squiggle(card_background_color, border_thickness, color)

def draw_squiggle_solid(color, border_thickness):
    return draw_squiggle(color, border_thickness, color)

def draw_figure():
    # return draw_squiggle("green", 3, "green")
    # return draw_squiggle_solid("green", 3)
    return draw_squiggle_hollow("blue", 3)

image = draw_figure()
image.save("/tmp/a.png")
