"""Build the OMA/NOMA/RSMA code-explanation deck.
Every slide body is rendered from HTML (KaTeX for math, Pygments for MATLAB)
to PNG; the .pptx places that image under an editable title + kicker and adds
speaker notes. Code line numbers are read from the repo, so re-running after a
code change updates them.
"""
import asyncio, html, json, sys
from pathlib import Path
from pygments import highlight
from pygments.lexers import MatlabLexer
from pygments.formatters import HtmlFormatter

ROOT = Path(__file__).parent
REPO = Path('/home/claude/rsma-istn-outage')
A = ROOT / 'assets'
KATEX = (ROOT / 'node_modules/katex/dist').as_uri()
W, H = 1600, 900
TOP = 150          # title band left empty in the body image (pptx puts editable text there)

C = dict(A='#2563eb', B='#7c3aed', C='#059669', D='#d97706', E='#dc2626', F='#0891b2')
SCHEME = dict(oma='#d42a2a', noma='#15803d', rsma='#1d4ed8')

def L(rel, a, b):
    t = (REPO / rel).read_text().split('\n')
    return [[i, t[i - 1]] for i in range(a, b + 1)]

def gap():
    return [[0, '   ...']]

# ---------------------------------------------------------------- renderers
def code_html(lines, groups, fs=15.5):
    lexer, fmt = MatlabLexer(), HtmlFormatter(nowrap=True)
    tagof = {}
    for g in groups:
        for ln in g['lines']:
            tagof[ln] = g
    out = []
    for ln, txt in lines:
        h = highlight(txt, lexer, fmt).rstrip('\n') if txt.strip() else '&nbsp;'
        g = tagof.get(ln)
        st = f'style="background:{g["color"]}22;border-left:5px solid {g["color"]}"' if g else 'style="border-left:5px solid transparent"'
        bd = f'<span class="badge" style="background:{g["color"]}">{g["tag"]}</span>' if g and ln == g['lines'][0] else '<span class="badge ghost"></span>'
        out.append(f'<div class="ln" {st}><span class="no">{ln if ln else ""}</span>{bd}<span class="src">{h}</span></div>')
    return f'<div class="code" style="font-size:{fs}px">' + ''.join(out) + '</div>'

def esc(t):
    return t.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')

def card(g):
    rng = g['lines']
    lab = g.get('lab') or (f'line {rng[0]}' if len(rng) == 1 else f'lines {rng[0]}–{rng[-1]}')
    m = f'<div class="math">$${esc(g["latex"])}$$</div>' if g.get('latex') else ''
    return f'''<div class="eq" style="border-color:{g["color"]}">
      <div class="eqhead"><span class="badge" style="background:{g["color"]}">{g["tag"]}</span>
      <span class="lab">{lab}</span><span class="src2">{g.get("ref","")}</span></div>{m}
      <div class="cap">{g["caption"]}</div></div>'''

def body_code(s):
    files = s['files'] if 'files' in s else [(s['file'], s['code'])]
    boxes = ''.join(f'<div class="codebox"><div class="fname">{f}</div>{code_html(c, s["groups"], s.get("fs",15.5))}</div>' for f, c in files)
    return f'''<div class="grid" style="grid-template-columns:{s.get("split","55% 45%")}">
      <div class="left">{boxes}</div><div class="right">{"".join(card(g) for g in s["groups"])}</div></div>'''

def tcard(c):
    col = c.get('color', '#334155')
    m = ''.join(f'<div class="math">$${esc(x)}$$</div>' for x in c.get('math', []))
    return f'''<div class="tc" style="border-top:5px solid {col};{c.get("style","")}">
      <div class="th" style="color:{col}">{c["h"]}</div>{m}<div class="tb">{c.get("b","")}</div></div>'''

def body_theory(s):
    cols = s.get('cols', '1fr 1fr')
    cards = ''.join(tcard(c) for c in s['cards'])
    img = ''
    if s.get('img'):
        img = f'<div class="imgcell"><img src="{(A / s["img"]).as_uri()}" style="max-width:100%;max-height:{s.get("imgh",600)}px"></div>'
    if s.get('img_side'):
        return f'''<div class="grid" style="grid-template-columns:{s.get("split","52% 48%")}">
          <div class="tgrid" style="grid-template-columns:1fr">{cards}</div>{img}</div>'''
    return f'<div class="tgrid" style="grid-template-columns:{cols}">{cards}</div>{img}'

def body_plot(s):
    imgs = ''.join(f'<div class="imgcell"><img src="{(A / i).as_uri()}" style="max-width:100%;max-height:{s.get("imgh",640)}px">'
                   f'{"<div class=icap>"+c+"</div>" if c else ""}</div>' for i, c in s['imgs'])
    side = ''.join(tcard(c) for c in s.get('cards', []))
    row = 'flex-direction:row;justify-content:center;align-items:flex-start' if s.get('row') else ''
    return f'''<div class="grid" style="grid-template-columns:{s.get("split","62% 38%")}">
      <div class="imgs" style="{row}">{imgs}</div><div class="tgrid" style="grid-template-columns:1fr;align-content:start">{side}</div></div>'''

def body_title(s):
    return f'''<div class="titlepg"><div class="tk">{s["kicker"]}</div><div class="tt">{s["title"]}</div>
      <div class="ts">{s["sub"]}</div><div class="tm">{s["meta"]}</div></div>'''

CSS_BASE = '''
*{box-sizing:border-box}
body{margin:0;width:1600px;height:900px;font-family:Inter,sans-serif;background:#ffffff;color:#1d2433;position:relative;overflow:hidden}
.top{padding:30px 56px 0 56px;height:150px}
.kicker{font-size:17px;letter-spacing:.08em;text-transform:uppercase;color:#6b7280;font-weight:600}
h1{font-size:36px;margin:6px 0 0 0;font-weight:700;letter-spacing:-.01em;line-height:1.15}
.grid{display:grid;gap:26px;padding:0 56px;height:660px}
.left{display:flex;flex-direction:column;gap:12px;overflow:hidden}
.codebox{background:#fbfaf7;border:1px solid #e5e2da;border-radius:12px;overflow:hidden}
.fname{font:600 15px 'DejaVu Sans Mono',monospace;color:#374151;background:#f1efe9;padding:8px 16px;border-bottom:1px solid #e5e2da}
.code{font-family:'DejaVu Sans Mono',monospace;line-height:1.55;padding:8px 0;white-space:pre}
.ln{display:flex;align-items:center;padding-right:12px}
.no{width:44px;text-align:right;color:#9ca3af;padding-right:10px;flex:none}
.badge{display:inline-block;min-width:24px;height:24px;line-height:24px;border-radius:6px;color:#fff;font:700 14px Inter,sans-serif;text-align:center;margin-right:10px;flex:none}
.ghost{background:transparent}
.right{display:flex;flex-direction:column;gap:10px;overflow:hidden}
.eq{background:#fff;border:1px solid #e5e2da;border-left:6px solid;border-radius:10px;padding:8px 16px}
.eqhead{display:flex;align-items:center;gap:6px;font-size:15px;color:#4b5563}
.lab{font-weight:600}.src2{margin-left:auto;font-size:14px;color:#6b7280}
.math{font-size:20px;margin:2px 0}.math .katex-display{margin:5px 0}
.cap{font-size:15.5px;color:#374151;line-height:1.35}
.foot{position:absolute;left:56px;right:56px;bottom:20px;font-size:17px;background:#eef2ff;border-radius:10px;padding:11px 18px;line-height:1.35}
.foot b{color:#3730a3}
.tgrid{display:grid;gap:16px;padding:0 56px}
.grid .tgrid{padding:0}
.tc{background:#fbfaf7;border:1px solid #e5e2da;border-radius:12px;padding:14px 20px}
.th{font-size:21px;font-weight:700;margin-bottom:4px}
.tb{font-size:18.5px;line-height:1.45;color:#1f2937}
.tc .math{font-size:23px}
.tb table{border-collapse:collapse;width:100%;font-size:17px;margin-top:4px}
.tb td,.tb th{border-bottom:1px solid #e5e2da;padding:4px 6px;text-align:left}
.tb th{color:#4b5563;font-weight:600}
.tb ul{margin:4px 0 0 0;padding-left:20px}.tb li{margin:2px 0}
.imgs{display:flex;flex-direction:column;gap:10px;align-items:center;justify-content:flex-start}
.imgcell{text-align:center}.icap{font-size:14px;color:#6b7280}
.titlepg{padding:200px 90px}.tk{font-size:20px;letter-spacing:.1em;text-transform:uppercase;color:#4f46e5;font-weight:700}
.tt{font-size:58px;font-weight:800;line-height:1.1;margin:14px 0 18px 0;max-width:1300px}
.ts{font-size:24px;color:#374151;max-width:1250px;line-height:1.4}.tm{font-size:19px;color:#6b7280;margin-top:40px}
.pg{position:absolute;right:56px;bottom:4px;font-size:13px;color:#9ca3af}
code{font-family:'DejaVu Sans Mono',monospace;font-size:.92em;background:#f1efe9;padding:0 4px;border-radius:4px}
.ok{color:#15803d;font-weight:700}.bad{color:#dc2626;font-weight:700}
'''

def page(s, idx, mode):
    body = {'code': body_code, 'theory': body_theory, 'plot': body_plot, 'title': body_title}[s['type']](s)
    head = ''
    if s['type'] != 'title':
        if mode == 'full':
            head = f'<div class="top"><div class="kicker">{s["kicker"]}</div><h1>{s["title"]}</h1></div>'
        else:
            head = '<div class="top"></div>'
    foot = f'<div class="foot">{s["foot"]}</div>' if s.get('foot') else ''
    css = (ROOT / 'pyg.css').read_text() + CSS_BASE
    return f'''<!doctype html><html><head><meta charset="utf-8">
<link rel="stylesheet" href="{KATEX}/katex.min.css"><script src="{KATEX}/katex.min.js"></script>
<script src="{KATEX}/contrib/auto-render.min.js"></script><style>{css}</style></head><body>
{head}{body}{foot}<div class="pg">Hu et al., IEEE TVT 2025 · OMA / NOMA / RSMA code walkthrough · {idx}</div>
<script>renderMathInElement(document.body,{{delimiters:[{{left:"$$",right:"$$",display:true}},{{left:"\\\\(",right:"\\\\)",display:false}}]}});</script>
</body></html>'''

async def shoot(jobs):
    from playwright.async_api import async_playwright
    async with async_playwright() as p:
        b = await p.chromium.launch(executable_path='/usr/bin/google-chrome')
        pg = await b.new_page(viewport={'width': W, 'height': H}, device_scale_factor=1.5)
        for hf, png in jobs:
            await pg.goto(Path(hf).resolve().as_uri())
            await pg.wait_for_timeout(350)
            await pg.screenshot(path=png)
        await b.close()

def build(slides, only=None):
    (ROOT / 'pyg.css').write_text(HtmlFormatter(style='friendly').get_style_defs('.code'))
    out = ROOT / 'out'; out.mkdir(exist_ok=True)
    jobs = []
    for i, s in enumerate(slides, 1):
        if only and i not in only:
            continue
        for mode in ('full', 'body'):
            hf = out / f's{i:02d}_{mode}.html'
            hf.write_text(page(s, i, mode))
            jobs.append((str(hf), str(out / f's{i:02d}_{mode}.png')))
    asyncio.run(shoot(jobs))

def pptx(slides, path):
    from pptx import Presentation
    from pptx.util import Emu, Pt
    from pptx.dml.color import RGBColor
    from pptx.enum.text import PP_ALIGN
    prs = Presentation()
    prs.slide_width, prs.slide_height = Emu(12192000), Emu(6858000)
    sx = 12192000 / W
    blank = prs.slide_layouts[6]
    for i, s in enumerate(slides, 1):
        sl = prs.slides.add_slide(blank)
        img = ROOT / 'out' / f's{i:02d}_body.png'
        sl.shapes.add_picture(str(img), 0, 0, width=prs.slide_width, height=prs.slide_height)
        if s['type'] != 'title':
            tb = sl.shapes.add_textbox(Emu(int(56 * sx)), Emu(int(26 * sx)), Emu(int(1488 * sx)), Emu(int(34 * sx)))
            tb.text_frame.word_wrap = True; tb.text_frame.paragraphs[0].alignment = PP_ALIGN.LEFT
            r = tb.text_frame.paragraphs[0].add_run(); r.text = s['kicker'].upper()
            r.font.size = Pt(11); r.font.bold = True; r.font.color.rgb = RGBColor(0x6b, 0x72, 0x80); r.font.name = 'Inter'
            tb2 = sl.shapes.add_textbox(Emu(int(56 * sx)), Emu(int(58 * sx)), Emu(int(1488 * sx)), Emu(int(90 * sx)))
            tf = tb2.text_frame; tf.word_wrap = True; tf.paragraphs[0].alignment = PP_ALIGN.LEFT
            r = tf.paragraphs[0].add_run(); r.text = html.unescape(s['title_plain'] if 'title_plain' in s else s['title'])
            r.font.size = Pt(21) if len(s['title']) < 85 else Pt(18); r.font.bold = True; r.font.color.rgb = RGBColor(0x1d, 0x24, 0x33); r.font.name = 'Inter'
        sl.notes_slide.notes_text_frame.text = s.get('notes', '')
    prs.save(path)
