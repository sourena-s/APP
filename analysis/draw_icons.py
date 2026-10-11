"""Simple monochrome organism silhouettes (scientific-figure style), one per alignment row."""
from PIL import Image, ImageDraw
import math, os
W, H = 480, 320
COL = (55, 65, 81, 255)
os.makedirs('icons_sci', exist_ok=True)

def canvas():
    im = Image.new('RGBA', (W, H), (0, 0, 0, 0)); return im, ImageDraw.Draw(im)

def E(d, cx, cy, rx, ry, **k): d.ellipse([cx-rx, cy-ry, cx+rx, cy+ry], fill=COL, **k)
def P(d, pts): d.polygon(pts, fill=COL)
def L(d, pts, w): d.line(pts, fill=COL, width=w, joint='curve')
def rot(pts, cx, cy, a):
    c, s = math.cos(a), math.sin(a)
    return [(cx + (x-cx)*c - (y-cy)*s, cy + (x-cx)*s + (y-cy)*c) for x, y in pts]

def save(im, n):
    im = im.crop(im.getbbox()); im.save(f'icons_sci/{n:02d}.png')

# 1 human (standing figure)
im, d = canvas()
E(d, 240, 40, 26, 28); P(d, [(205,75),(275,75),(290,175),(270,175),(262,110),(258,180),(222,180),(218,110),(210,175),(190,175)])
P(d, [(222,178),(240,178),(238,300),(218,300)]); P(d, [(240,178),(258,178),(262,300),(242,300)]); save(im, 1)
# 2 chimpanzee (knuckle-walking)
im, d = canvas()
E(d, 250, 150, 110, 55); E(d, 375, 115, 38, 36); E(d, 405, 125, 18, 14)
L(d, [(170,170),(150,240),(160,300)], 30); L(d, [(220,190),(215,300)], 28)
L(d, [(310,160),(340,230),(345,300)], 30); L(d, [(280,180),(290,300)], 26); save(im, 2)
# 3 mouse
im, d = canvas()
E(d, 230, 180, 120, 70); E(d, 345, 165, 60, 45); P(d, [(390,150),(440,175),(390,190)])
E(d, 330, 112, 30, 30); L(d, [(115,190),(60,230),(30,200),(10,215)], 10)
L(d, [(190,240),(185,270)], 14); L(d, [(290,235),(300,265)], 14); save(im, 3)
# 4 chicken
im, d = canvas()
E(d, 220, 170, 110, 75); P(d, [(120,150),(70,70),(110,90),(150,130)])
L(d, [(290,140),(320,80)], 40); E(d, 330, 70, 32, 30); P(d, [(358,62),(395,75),(358,85)])
P(d, [(318,40),(330,22),(340,40),(350,26),(355,45)]); L(d, [(200,240),(195,300),(175,305)], 9)
L(d, [(240,240),(245,300),(265,305)], 9); save(im, 4)
# 5 frog (crouched, side view)
im, d = canvas()
P(d, [(100,230),(170,140),(300,120),(380,150),(410,190),(380,215),(250,240)])
E(d, 330, 125, 22, 20); L(d, [(170,225),(110,280),(190,285)], 22)
L(d, [(330,205),(350,280),(380,285)], 14); save(im, 5)

def fish(d, body, tail_h, dorsal=True, pect=True, lobed=False, cy=160):
    x0, x1 = 90, 420
    pts = []
    for i in range(41):
        t = i/40; x = x0 + (x1-x0)*t; h = body*math.sin(math.pi*t**0.8)
        pts.append((x, cy - h))
    for i in range(40, -1, -1):
        t = i/40; x = x0 + (x1-x0)*t; h = body*0.85*math.sin(math.pi*t**0.8)
        pts.append((x, cy + h))
    P(d, pts)
    P(d, [(x0+10, cy), (30, cy - tail_h), (55, cy), (30, cy + tail_h)])
    if dorsal: P(d, [(220, cy - body*0.95), (250, cy - body - 40), (285, cy - body*0.9)])
    if lobed:
        for x in (210, 300):
            E(d, x, cy + body*0.9 + 10, 22, 14)
        E(d, 255, cy - body - 15, 20, 12)

# 6 coelacanth (lobed fins, three-lobed tail)
im, d = canvas(); fish(d, 70, 60, dorsal=False, lobed=True); E(d, 50, 160, 14, 10); save(im, 6)
# 7/8 zebrafish (slender, forked tail, stripes left as body)
for n in (7, 8):
    im, d = canvas(); fish(d, 42, 45); P(d, [(240,200),(270,230),(300,200)]); save(im, n)
# 9 fugu (round pufferfish)
im, d = canvas(); E(d, 245, 160, 125, 105)
P(d, [(125,160),(60,105),(75,160),(60,215)])
for a in range(0, 360, 30):
    r = math.radians(a); x, y = 245 + 125*math.cos(r), 160 + 105*math.sin(r)
    if 120 < a < 240: continue
    P(d, [(x, y), (x + 22*math.cos(r) - 6*math.sin(r), y + 22*math.sin(r) + 6*math.cos(r)), (x + 8*math.cos(r+1.5), y + 8*math.sin(r+1.5))])
save(im, 9)
# 10 shark
im, d = canvas()
P(d, [(450,170),(390,135),(250,125),(110,150),(40,95),(60,165),(30,215),(115,185),(250,200),(380,195)])
P(d, [(240,128),(285,55),(300,128)]); P(d, [(300,195),(270,250),(340,195)]); save(im, 11 - 1)
# 11 lamprey (eel-like, oral disc)
im, d = canvas()
pts = [(60 + i*9, 160 + 30*math.sin(i/6)) for i in range(42)]
L(d, pts, 34); E(d, 440, 160 + 30*math.sin(41/6), 24, 24)
P(d, [(250,140),(300,120),(340,140)]); save(im, 11)
# 12 amphioxus (lancelet: pointed both ends, chevron hint)
im, d = canvas()
P(d, [(20,170),(120,140),(330,130),(460,165),(330,185),(120,190)])
P(d, [(100,148),(80,120),(160,140)]); save(im, 12)
# 13 sea urchin (spiny sphere)
im, d = canvas(); E(d, 240, 170, 80, 70)
for a in range(0, 360, 15):
    r = math.radians(a); L(d, [(240 + 75*math.cos(r), 170 + 65*math.sin(r)), (240 + 140*math.cos(r), 170 + 130*math.sin(r))], 7)
save(im, 13)
# 14 sea hare (Aplysia: slug with rhinophores and parapodia)
im, d = canvas()
P(d, [(30,230),(120,150),(220,110),(320,130),(390,170),(430,230)])
L(d, [(370,160),(395,95)], 12); L(d, [(395,165),(430,105)], 12); E(d, 230, 140, 75, 45); save(im, 14)
# 15 squid
im, d = canvas()
P(d, [(20,160),(80,110),(110,130),(300,135),(330,160),(300,185),(110,190),(80,210)])
E(d, 320, 160, 30, 30)
for k, dy in enumerate((-30, -15, 0, 15, 30)):
    L(d, [(340,160+dy*0.3),(400,160+dy),(460,160+dy*1.3)], 7)
save(im, 15)
# 16 fruit fly (top view)
im, d = canvas()
E(d, 240, 210, 40, 75); E(d, 240, 125, 34, 28); E(d, 240, 85, 26, 20)
E(d, 222, 75, 9, 9, outline=None); E(d, 258, 75, 9, 9)
for side in (-1, 1):
    P(d, [(240 + side*25, 120), (240 + side*150, 190), (240 + side*120, 260), (240 + side*30, 170)])
    for y0, y1 in ((115, 70), (130, 150), (145, 230)):
        L(d, [(240 + side*30, y0), (240 + side*95, y1)], 6)
save(im, 16)
# 17 C. elegans (thin sinusoidal worm)
im, d = canvas()
pts = [(30 + i*10, 160 + 55*math.sin(i/5.5)) for i in range(43)]
L(d, pts, 22); save(im, 17)
print('done', len(os.listdir('icons_sci')))
