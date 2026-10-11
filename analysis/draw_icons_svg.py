"""Hand-drawn vector silhouettes (side views, facing right) rendered to PNG for the alignment rows."""
import os, cairosvg
C = '#2F3640'
os.makedirs('icons_sci', exist_ok=True)

S = {}
# 1 Human: standing, arms slightly away from body
S[1] = ('0 0 100 220', '''
<circle cx="50" cy="18" r="14"/>
<path d="M50 34 C38 34 31 38 29 46 L22 100 C21 106 27 107 28 101 L35 58 L37 110 L34 205 C34 212 44 212 44 205 L48 128 L52 128 L56 205 C56 212 66 212 66 205 L63 110 L65 58 L72 101 C73 107 79 106 78 100 L71 46 C69 38 62 34 50 34 Z"/>''')
# 2 Chimpanzee: knuckle-walking quadruped, sloping back, long arms
S[2] = ('0 0 240 170', '''
<path d="M30 70 C40 52 75 42 110 46 C140 48 165 40 185 34 C196 30 206 30 212 36 C222 34 232 42 230 52 C236 56 236 66 228 70 C222 76 212 76 206 72 L198 78 C196 96 200 118 204 150 C206 160 196 162 192 154 L182 110 L172 152 C170 162 158 160 160 150 L164 100 C150 102 130 102 108 98 L96 140 C94 150 82 150 84 140 L86 104 C76 106 68 108 60 108 L56 150 C54 160 42 160 44 150 L42 104 C30 96 24 84 30 70 Z"/>
<circle cx="214" cy="46" r="3" fill="#fff"/>''')
# 3 Mouse
S[3] = ('0 0 260 130', '''
<path d="M70 92 C64 64 90 40 130 38 C152 36 170 40 186 50 C194 40 210 38 214 50 C216 56 212 62 208 64 C220 70 236 78 246 84 C250 88 246 92 240 92 L214 96 C206 104 194 108 182 108 L178 118 C176 124 168 124 170 116 L170 108 L118 110 L112 120 C110 126 102 124 104 118 L106 110 C88 108 74 104 70 92 Z"/>
<path d="M72 94 C50 100 30 96 14 84 C8 80 4 86 10 90 C26 104 52 108 74 100 Z"/>
<circle cx="214" cy="74" r="3.2" fill="#fff"/>''')
# 4 Chicken
S[4] = ('0 0 200 200', '''
<path d="M136 34 C134 22 142 12 150 18 C152 10 160 10 160 18 C166 14 172 20 166 28 C176 30 182 38 186 44 L174 46 C176 52 172 58 166 58 C160 66 160 76 166 88 C172 104 168 126 150 138 C132 150 104 150 84 142 C60 132 40 112 32 86 L18 50 C14 40 26 36 30 44 L46 74 C54 84 66 88 80 86 C96 84 112 76 124 64 C130 56 132 46 136 34 Z"/>
<path d="M98 146 L96 180 L84 186 L100 184 L108 188 L104 180 L106 146 Z"/>
<path d="M120 144 L122 180 L110 186 L126 184 L134 188 L130 180 L128 144 Z"/>
<circle cx="158" cy="34" r="3" fill="#fff"/>''')
# 5 Frog (sitting, side view)
S[5] = ('0 0 230 150', '''
<path d="M36 112 C30 90 44 66 74 56 C104 46 140 44 166 46 C178 40 192 40 200 50 C212 56 222 66 222 76 C222 84 214 88 206 90 C196 94 186 100 178 108 L188 134 C190 140 182 142 178 136 L164 116 C150 120 132 124 112 124 C140 126 156 132 160 138 C162 144 150 144 130 140 L72 132 C50 130 40 124 36 112 Z"/>
<circle cx="190" cy="54" r="12"/><circle cx="192" cy="54" r="4" fill="#fff"/>''')
# 6 Coelacanth (lobed fins, three-lobed tail)
S[6] = ('0 0 280 140', '''
<path d="M262 74 C258 60 240 48 214 44 C190 40 150 40 120 46 L104 26 C100 20 92 24 96 32 L104 48 C84 54 66 60 52 66 L30 44 C24 38 16 44 20 52 L34 70 L14 70 C8 70 8 78 14 78 L34 78 L20 96 C16 104 24 110 30 104 L52 82 C70 90 96 98 124 102 C160 106 210 104 236 96 C254 90 264 84 262 74 Z"/>
<path d="M150 104 C146 118 138 126 128 128 C122 128 124 120 130 116 C134 110 136 104 140 100 Z"/>
<path d="M190 102 C190 116 184 126 174 130 C168 130 168 122 174 118 C178 112 178 106 180 100 Z"/>
<path d="M174 44 C170 32 160 22 150 20 C144 20 146 28 152 32 C156 36 158 40 160 46 Z"/>
<circle cx="236" cy="66" r="4" fill="#fff"/>''')
# 7/8 Zebrafish (slender, forked tail)
S[7] = ('0 0 280 110', '''
<path d="M262 56 C256 46 236 38 206 36 C170 34 120 38 84 46 L44 22 C36 18 30 24 34 32 L54 56 L34 80 C30 88 36 94 44 90 L84 66 C120 74 170 78 206 76 C236 74 256 66 262 56 Z"/>
<path d="M150 38 L162 18 C164 14 170 16 168 22 L170 38 Z"/>
<path d="M128 74 L118 96 C116 100 122 102 126 98 L144 76 Z"/>
<circle cx="238" cy="52" r="4" fill="#fff"/>''')
S[8] = S[7]
# 9 Fugu (pufferfish, slightly inflated)
S[9] = ('0 0 240 170', '''
<path d="M216 88 C216 52 182 26 140 26 C98 26 66 52 60 80 L26 52 C20 48 14 54 18 62 L34 88 L18 114 C14 122 20 128 26 124 L60 98 C68 126 100 150 140 150 C182 150 216 124 216 88 Z"/>
<path d="M150 28 L156 8 L164 30 Z"/><path d="M120 148 L124 166 L134 148 Z"/>
<circle cx="188" cy="74" r="7" fill="#fff"/><circle cx="190" cy="74" r="3"/>''')
# 10 Shark
S[10] = ('0 0 300 140', '''
<path d="M292 76 C284 64 260 58 230 56 L196 54 L178 14 C176 8 168 10 168 16 L162 54 C130 56 96 62 70 68 L36 22 C30 14 22 20 24 28 L42 76 L20 120 C18 128 26 132 32 126 L66 90 C100 96 140 100 180 100 L196 124 C200 130 206 126 204 120 L198 100 C230 98 262 94 280 88 C290 84 296 80 292 76 Z"/>
<path d="M100 92 L90 112 L112 96 Z"/>
<circle cx="258" cy="68" r="3.5" fill="#fff"/>''')
# 11 Sea lamprey (eel-like, oral disc, gill pores)
S[11] = ('0 0 320 100', '''
<path d="M10 58 C40 40 70 70 110 56 C150 42 180 34 220 40 C250 44 274 38 294 36 C310 34 316 46 312 56 C308 66 296 68 286 64 C262 60 240 62 216 64 C180 68 150 74 112 76 C72 78 40 82 10 58 Z"/>
<path d="M150 42 C160 30 180 30 196 40 Z"/><path d="M90 60 C100 50 120 50 130 56 Z"/>
<g fill="#fff"><circle cx="258" cy="50" r="2.4"/><circle cx="249" cy="51" r="2.2"/><circle cx="240" cy="52" r="2.2"/><circle cx="231" cy="53" r="2.2"/><circle cx="222" cy="54" r="2.2"/><circle cx="213" cy="55" r="2.2"/><circle cx="204" cy="56" r="2.2"/><circle cx="278" cy="46" r="3.5"/></g>''')
# 12 Amphioxus (lancelet: laterally flattened, pointed, oral cirri)
S[12] = ('0 0 300 80', '''
<path d="M6 44 C30 30 70 26 120 26 C180 26 240 30 278 38 C286 40 292 44 290 48 C286 52 278 54 268 56 L270 64 L262 58 C230 62 180 64 120 62 C70 60 30 56 6 44 Z"/>
<path d="M60 30 C90 22 150 20 220 26 L220 30 C150 26 90 28 60 34 Z"/>
<g stroke="#fff" stroke-width="1.2" fill="none"><path d="M110 32 l8 12 l-8 12"/><path d="M130 32 l8 12 l-8 12"/><path d="M150 32 l8 12 l-8 12"/><path d="M170 32 l8 12 l-8 12"/><path d="M190 32 l8 12 l-8 12"/><path d="M210 33 l8 12 l-8 11"/></g>''')
# 13 Sea urchin (test with spines, slightly flattened)
spines = ''.join(
    f'<path d="M{110+60*__import__("math").cos(a)} {90+48*__import__("math").sin(a)} L{110+(100 + (i%2)*14)*__import__("math").cos(a)} {90+(84 + (i%2)*12)*__import__("math").sin(a)}" stroke="{C}" stroke-width="{3 if i%2 else 4.5}" stroke-linecap="round"/>'
    for i, a in enumerate([k*3.14159*2/40 for k in range(40)]))
S[13] = ('0 0 220 180', f'<ellipse cx="110" cy="90" rx="64" ry="52"/>{spines}')
# 14 Sea hare (Aplysia: rhinophores, oral tentacles, parapodia)
S[14] = ('0 0 280 140', '''
<path d="M14 116 C30 90 60 60 104 48 C140 38 180 42 208 58 L222 30 C224 24 232 26 230 32 L222 62 C228 66 234 70 238 76 L250 52 C254 46 260 50 258 56 L246 84 C258 92 268 102 272 112 C276 120 270 124 262 120 L246 112 C240 116 232 118 224 118 L36 124 C22 124 10 124 14 116 Z"/>
<path d="M90 56 C104 30 150 22 182 40 C170 44 150 42 132 46 C116 50 102 56 90 62 Z" fill="#fff" fill-opacity=".25"/>''')
# 15 Squid (mantle with fins, eye, arms)
S[15] = ('0 0 320 120', '''
<path d="M8 60 L44 30 C50 26 56 30 54 38 L58 46 C90 40 140 40 180 44 C196 46 206 50 212 56 C222 52 232 54 236 60 C232 66 222 68 212 64 C206 70 196 74 180 76 C140 80 90 80 58 74 L54 82 C56 90 50 94 44 90 Z"/>
<g fill="none" stroke="#2F3640" stroke-linecap="round"><path d="M234 56 C260 46 284 40 312 36" stroke-width="5"/><path d="M236 60 C264 58 290 58 316 62" stroke-width="5"/><path d="M234 64 C262 72 286 80 310 88" stroke-width="5"/><path d="M232 52 C254 38 270 28 286 18" stroke-width="3"/><path d="M232 68 C254 82 270 92 290 104" stroke-width="3"/></g>
<circle cx="222" cy="60" r="5" fill="#fff"/>''')
# 16 Fruit fly (side view: head with red-eye, thorax, abdomen, wing, legs)
S[16] = ('0 0 240 170', '''
<ellipse cx="186" cy="74" rx="22" ry="24"/>
<ellipse cx="140" cy="76" rx="32" ry="28"/>
<path d="M112 72 C96 60 66 60 46 70 C30 80 32 100 50 108 C70 116 96 110 112 98 Z"/>
<path d="M126 52 C104 24 60 10 22 16 C8 18 8 30 20 36 C50 50 90 58 124 64 Z" fill-opacity=".55"/>
<g fill="none" stroke="#2F3640" stroke-width="4" stroke-linecap="round"><path d="M150 100 L160 130 L172 156"/><path d="M138 102 L136 134 L140 160"/><path d="M126 100 L112 128 L100 152"/><path d="M200 48 L212 34"/></g>
<circle cx="194" cy="68" r="10" fill="#fff" fill-opacity=".35"/>''')
# 17 C. elegans (thin, tapering nematode, sinusoidal)
S[17] = ('0 0 300 100', '''
<path d="M8 52 C30 40 46 26 74 28 C104 30 118 70 150 72 C182 74 196 34 226 30 C252 26 274 38 294 46 C298 48 296 54 292 54 C272 48 252 42 228 44 C200 48 186 88 150 86 C114 84 100 44 74 42 C50 40 32 52 10 58 C4 60 4 54 8 52 Z"/>''')

for n, (vb, body) in S.items():
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{vb}" fill="{C}">{body}</svg>'
    w = int(vb.split()[2]); h = int(vb.split()[3]); k = 600 / max(w, h)
    cairosvg.svg2png(bytestring=svg.encode(), write_to=f'icons_sci/{n:02d}.png',
                     output_width=int(w * k), output_height=int(h * k))
    open(f'icons_sci/{n:02d}.svg', 'w').write(svg)
print('done')
