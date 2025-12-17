from PIL import Image, ImageDraw, ImageFont
from draw import draw_rectangle, normalize_code

CARD_WIDTH       = 200
CARD_HEIGHT      = 300

background_color = "gray"
colors_one       = [ "red", "purple", "green" ]
colors_two       = [ "red", "purple", "green" ]
colors_three     = [ "red", "purple", "green" ]
colors_four      = [ "red", "purple", "green" ]

def xdraw_figure(color_one, color_two, color_three, color_four):
    x, y = CARD_WIDTH // 2, CARD_HEIGHT // 2
    w, h = CARD_HEIGHT // 2, CARD_WIDTH // 4
    image = Image.new("RGB", (CARD_WIDTH, CARD_HEIGHT), background_color)
    draw_rectangle(image, x, y, CARD_WIDTH, CARD_HEIGHT,  "white", border=1, border_color="black")
    draw_rectangle(image, x, y - 85, w, h,  color_one,   rounding=0.5, border=1, border_color="black")
    draw_rectangle(image, x, y - 25, w, h,  color_two,   rounding=0.5, border=1, border_color="black")
    draw_rectangle(image, x, y + 40, w, h,  color_three, rounding=0.5, border=1, border_color="black")
    draw_rectangle(image, x, y + 100, w, h,  color_four,  rounding=0.5, border=1, border_color="black")
    return image

def draw_figure(color_one, color_two, color_three, color_four):
    cx, cy = CARD_WIDTH // 2, CARD_HEIGHT // 2
    rw, rh = CARD_WIDTH - 20 * 2, CARD_HEIGHT // 5
    sy = 10
    image = Image.new("RGB", (CARD_WIDTH, CARD_HEIGHT), background_color)
    draw_rectangle(image, cx, cy, CARD_WIDTH, CARD_HEIGHT,  "white", border=1, border_color="black")
    draw_rectangle(image, cx, cy -  90 - 14, rw, rh,  color_one,   rounding=0.4, border=1, border_color="black")
    draw_rectangle(image, cx, cy -  20 - 14, rw, rh,  color_two,   rounding=0.4, border=1, border_color="black")
    draw_rectangle(image, cx, cy +  50 - 14, rw, rh,  color_three, rounding=0.4, border=1, border_color="black")
    draw_rectangle(image, cx, cy + 120 - 14, rw, rh,  color_four,  rounding=0.4, border=1, border_color="black")
    return image

def filepath(code):
    # directory = "/Users/dmichaels/repos/ios-setgame/SetGame/Assets.xcassets"
    # return f"{directory}/{code}.imageset/{code}.png"
    directory = "/tmp/set"
    return f"{directory}/{code}.png"

image = draw_figure("red", "blue", "green", "purple")
image.save("/tmp/a.png")

for icolor_one, color_one in enumerate(colors_one):
    for icolor_two, color_two in enumerate(colors_two):
        for icolor_three, color_three in enumerate(colors_three):
            for icolor_four, color_four in enumerate(colors_four):
                image = draw_figure(color_one, color_two, color_three, color_four)
                code = normalize_code(f"{icolor_one}{icolor_two}{icolor_three}{icolor_four}")
                file = filepath(code)
                image.save(file)
                print(file)
