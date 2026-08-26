from PIL import Image, ImageDraw, ImageFont
import os

def make_icon(text, bg_color, filename):
    img = Image.new('RGBA', (64, 64), (255, 255, 255, 0))
    d = ImageDraw.Draw(img)
    d.ellipse((2, 2, 62, 62), fill=bg_color, outline=(255,255,255,255), width=4)
    
    if text == "H":
        d.rectangle([22, 18, 28, 46], fill="white")
        d.rectangle([36, 18, 42, 46], fill="white")
        d.rectangle([22, 28, 42, 34], fill="white")
    elif text == "P":
        # Draw a P
        d.rectangle([22, 18, 28, 46], fill="white")
        d.pieslice([22, 18, 42, 34], -90, 90, fill="white")
        d.pieslice([26, 22, 36, 30], -90, 90, fill=bg_color)
        
    img.save(filename)

os.makedirs('assets/icons', exist_ok=True)
make_icon("H", (220, 50, 50, 255), 'assets/icons/hospital.png')
make_icon("P", (40, 100, 200, 255), 'assets/icons/police.png')
