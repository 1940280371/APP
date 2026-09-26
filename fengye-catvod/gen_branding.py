# -*- coding: utf-8 -*-
from PIL import Image, ImageDraw, ImageFont
import os

FONT = "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"
PRIMARY      = (226, 83, 59)    # E2533B 枫红
PRIMARY_DARK = (150, 46, 30)    # 962E1E
WHITE = (255, 255, 255, 255)

def vgrad(w, h, top, bottom):
    base = Image.new("RGBA", (w, h), top)
    for y in range(h):
        t = y / max(1, h - 1)
        c = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        ImageDraw.Draw(base).line([(0, y), (w, y)], fill=c + (255,))
    return base

def make_icon(size, round_icon):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    m = max(1, size // 18)
    mask = Image.new("L", (size, size), 0)
    md = ImageDraw.Draw(mask)
    if round_icon:
        md.ellipse([m, m, size - m, size - m], fill=255)
    else:
        md.rounded_rectangle([m, m, size - m, size - m], radius=size // 4, fill=255)
    tile = vgrad(size, size, PRIMARY, PRIMARY_DARK)
    img.paste(tile, (0, 0), mask)
    # 高光
    hl = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(hl).ellipse([m, m, size - m, size - m], fill=(255, 255, 255, 38))
    img = Image.alpha_composite(img, hl)
    # “枫”字
    ft = ImageFont.truetype(FONT, int(size * 0.6), index=0)
    d = ImageDraw.Draw(img)
    d.text((size / 2, size / 2), "枫", font=ft, fill=WHITE, anchor="mm")
    return img

def make_splash(w=1080, h=1920):
    img = vgrad(w, h, PRIMARY_DARK, PRIMARY).convert("RGBA")
    d = ImageDraw.Draw(img)
    cx, cy = w // 2, int(h * 0.40)
    # 白色细圆环
    r = 320
    d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(255, 255, 255, 210), width=12)
    # 枫字
    ft = ImageFont.truetype(FONT, 460, index=0)
    d.text((cx, cy), "枫", font=ft, fill=WHITE, anchor="mm")
    # 名称
    ft2 = ImageFont.truetype(FONT, 120, index=0)
    d.text((cx, cy + 430), "枫叶影视", font=ft2, fill=WHITE, anchor="mm")
    # 英文小标
    try:
        ft3 = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 44)
        d.text((cx, cy + 560), "M A P L E   V I D E O", font=ft3, fill=(255, 255, 255, 190), anchor="mm")
    except Exception:
        pass
    return img

root = "assets/branding"
densities = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
for k, s in densities.items():
    folder = f"{root}/mipmap-{k}"
    os.makedirs(folder, exist_ok=True)
    make_icon(s, False).save(f"{folder}/ic_launcher.png")
    make_icon(s, True).save(f"{folder}/ic_launcher_round.png")
    print("icon", k, s)
# splash
os.makedirs(f"{root}/drawable-xxxhdpi", exist_ok=True)
make_splash().save(f"{root}/drawable-xxxhdpi/splash.png")
os.makedirs(f"{root}/drawable-nodpi", exist_ok=True)
make_splash().save(f"{root}/drawable-nodpi/splash.png")
print("splash done")
