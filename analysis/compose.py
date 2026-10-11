from PIL import Image, ImageDraw, ImageFont
FULL = Image.open('fig5_conservation_map.png').convert('RGB')
W_MAP = FULL.crop((0, 0, FULL.width, FULL.height - 150))
import numpy as np
_a = np.array(FULL).astype(int)
_red = (abs(_a[:,:,0]-0xB2)<6)&(abs(_a[:,:,1]-0x18)<6)&(abs(_a[:,:,2]-0x2B)<6)
_ys, _xs = np.where(_red)
X0, X1 = _xs.min(), _xs.max()                    # human row spans residues 1..770
YT = _ys.min() - 15
_col = _a[:, (X0 + X1)//2]; _nw = np.where(_col.sum(1) < 740)[0]; _nw = _nw[_nw > _ys.max()]
YB = _nw[np.where(np.diff(_nw) > 30)[0][0]] + 5 if (np.diff(_nw) > 30).any() else _nw.max()
px = lambda pos: X0 + (pos - 0.5) * (X1 - X0) / 770

panels = [('zoomB_CCP.png', 148, 'A'), ('zoomF_GYENPTY.png', 728, 'B')]
cols = ['#E69F00', '#D55E00']

S = 0.9                                     # scale zoom panels (3900x2040 -> ~2418x1265)
_w, _h = Image.open('zoomB_CCP.png').size
pw, ph = int(_w * S), int(_h * S)
sizes = {f: Image.open(f).size for f, _, _ in panels}
gx, gap_y = 150, 420
pw2 = int(sizes['zoomF_GYENPTY.png'][0] * S)
W = pw + pw2 + 3 * gx
mapW = W - 2 * gx; ms = mapW / W_MAP.width
mapH = int(W_MAP.height * ms)
top = 40
row1 = top + mapH + gap_y
H = row1 + ph + 60
C = Image.new('RGB', (W, H), 'white'); d = ImageDraw.Draw(C)
C.paste(W_MAP.resize((mapW, mapH), Image.LANCZOS), (gx, top))
M = lambda x, y: (gx + x * ms, top + y * ms)

mag = Image.open('icons/mag.png').convert('RGBA')
font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 70)
for i, (f, start, lab) in enumerate(panels):
    r, c = 0, i
    x = gx + c * (pw + gx); y = row1
    pwi = pw if c == 0 else pw2
    a = M(px(start), YT); b = M(px(start + 43), YB)
    col = cols[i]
    # window on map
    d.rectangle([a[0], a[1], b[0], b[1]], outline=col, width=7)
    cx = (a[0] + b[0]) / 2 if lab == 'A' else b[0] - 25   # keep connector clear of axis tick labels
    bx = x + pwi / 2
    if r == 0:
        lane = top + mapH + 230 + i * 60
        pts = [(cx, b[1]), (cx, lane), (bx, lane), (bx, y)]
    else:  # route through left gutter of the panel, down past row 1
        lane = top + mapH + 25 + i * 30
        gxl = x - gx / 2 + (i - 3) * 0
        pts = [(cx, b[1]), (cx, lane), (gxl, lane), (gxl, y - 130), (bx, y - 130), (bx, y)]
    pts[-1] = (bx, y - 175)
    d.line(pts, fill=col, width=7, joint='curve')
    d.line([(bx, y - 65), (bx, y)], fill=col, width=7)
    # magnifier at panel entry
    mx, my = pts[-2] if r == 0 else pts[-2]
    m = mag.resize((110, 110))
    C.paste(m, (int(bx - 55), int(y - 175)), m)
    P = Image.open(f).convert('RGB').resize((pwi, ph), Image.LANCZOS)
    C.paste(P, (int(x), int(y)))
    d.rectangle([x, y, x + pwi, y + ph], outline=col, width=8)
    d.text((x - 10, y - 95), lab, fill=col, font=font)
    d.text((cx + 18, b[1] + 70), lab, fill=col, font=font)
C.save('fig7_overview_with_zooms.png', dpi=(300, 300))
print(C.size)
