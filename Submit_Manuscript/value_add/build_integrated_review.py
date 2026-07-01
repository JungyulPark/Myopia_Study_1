#!/usr/bin/env python3
import base64, os, re, html

ROOT = "/home/user/Myopia_Study_1"
OUT  = os.path.join(ROOT, "Submit_Manuscript", "M-LIGHT_Integrated_Review.html")

def img_b64(path):
    p = os.path.join(ROOT, path)
    if not os.path.exists(p): return None
    with open(p, "rb") as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode()

def fig(path, title, caption, tag=""):
    d = img_b64(path)
    if not d: return f'<div class="fig missing">[missing figure: {html.escape(path)}]</div>'
    badge = f'<span class="badge {tag}">{tag}</span>' if tag else ""
    return (f'<figure>{badge}<img src="{d}"/>'
            f'<figcaption><b>{html.escape(title)}</b> — {html.escape(caption)}</figcaption></figure>')

# ---------- minimal markdown -> html ----------
def md2html(md):
    out, i, lines = [], 0, md.split("\n")
    def inline(s):
        s = html.escape(s)
        s = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', s)
        s = re.sub(r'(?<!\*)\*(?!\*)(.+?)\*(?!\*)', r'<i>\1</i>', s)
        s = re.sub(r'`(.+?)`', r'<code>\1</code>', s)
        s = re.sub(r'\[(.+?)\]\((.+?)\)', r'<a href="\2">\1</a>', s)
        s = s.replace("‹","&lsaquo;").replace("›","&rsaquo;")
        return s
    while i < len(lines):
        ln = lines[i]
        if re.match(r'^\s*\|.*\|\s*$', ln) and i+1 < len(lines) and re.match(r'^\s*\|[\s:\-\|]+\|\s*$', lines[i+1]):
            hdr = [c.strip() for c in ln.strip().strip('|').split('|')]
            i += 2; body = []
            while i < len(lines) and re.match(r'^\s*\|.*\|\s*$', lines[i]):
                body.append([c.strip() for c in lines[i].strip().strip('|').split('|')]); i += 1
            t = '<table><thead><tr>' + ''.join(f'<th>{inline(c)}</th>' for c in hdr) + '</tr></thead><tbody>'
            for r in body:
                t += '<tr>' + ''.join(f'<td>{inline(c)}</td>' for c in r) + '</tr>'
            out.append(t + '</tbody></table>'); continue
        if ln.startswith('#'):
            m = re.match(r'(#+)\s*(.*)', ln); lvl=len(m.group(1)); out.append(f'<h{lvl}>{inline(m.group(2))}</h{lvl}>'); i+=1; continue
        if ln.strip()=='---': out.append('<hr/>'); i+=1; continue
        if ln.startswith('>'): out.append(f'<blockquote>{inline(ln.lstrip("> "))}</blockquote>'); i+=1; continue
        if re.match(r'^\s*[-*]\s+', ln):
            items=[]
            while i<len(lines) and re.match(r'^\s*[-*]\s+', lines[i]):
                itxt = re.sub(r"^\s*[-*]\s+","",lines[i])
                items.append('<li>'+inline(itxt)+'</li>'); i+=1
            out.append('<ul>'+''.join(items)+'</ul>'); continue
        if ln.strip()=='': i+=1; continue
        out.append(f'<p>{inline(ln)}</p>'); i+=1
    return '\n'.join(out)

# ---------- master results table ----------
anchor_rows = [
    # gene, role, nIV, F, UKB, Egger int(P), WM b(P), Q P, coloc, Tedja/CREAM, FinnGen, verdict
    ("RDH5","positive control","2","814.2","β=+0.0089","–","–","0.125","<b>0.991</b>/0.916/0.999","β=−0.0935, P=3.3e-33 ✓","OR=1.22, P=0.013 ✓","<b>MR+coloc+replication — recovered known locus</b>"),
    ("CD55","robust MR / prior-sens.","5","1987.9","–","−1.85e-4 (0.741)","−0.00284 (7.5e-6)","0.280","0.801/0.287/0.976","β=+0.0286, P=0.008 ✓","OR=0.98, P=0.54 ✗","robust MR, prior-sensitive coloc; = Wang-2024 target"),
    ("CTNNB1","candidate only","3","454.0","–","+3.41e-3 (0.490)","−0.00562 (5.6e-5)","0.488","<b>0.037</b> (H3 distinct)","β=+0.0493, P=6.9e-8 ✓","OR=0.96, P=0.68 ✗","known locus; MR+replication but coloc FAIL → LD"),
    ("FBN1","candidate only","1","543.1","–","N/A","N/A","N/A","<b>0.165</b> (H1 distinct)","β=−0.0440, P=5.8e-4 ✓","OR=0.93, P=0.54 ✗","known locus; coloc FAIL → candidate"),
    ("TGFB1","EXCLUDED","1","27.2","β=−0.0271, P=3.1e-3","N/A","N/A","N/A","<b>0.018</b> (H1 distinct)","β=−0.159, P=0.005 ✗ DISCORDANT","OR=1.35, P=0.62 ✗","single IV + coloc fail + discordant → excluded as positive"),
]
module_rows = [
    ("CHRM3","muscarinic (atropine target)","Wald","1","−0.0088","0.403","NULL — atropine's own receptor not causal"),
    ("LATS2","Hippo","Wald","1","+0.0179","0.040","exploratory; single IV, no coloc support"),
    ("COMT","dopamine","IVW","11","−0.0014","0.258","null"),
    ("ADRA2A","adrenergic","IVW","5","+0.0010","0.796","null"),
    ("HIF1A","hypoxia","IVW","4","−0.0039","0.154","null"),
    ("VEGFA","hypoxia/angio","IVW","5","+0.0005","0.805","null"),
    ("LOX","scleral ECM","Wald","1","+0.0023","0.743","null"),
]

def table(headers, rows):
    t = '<table><thead><tr>'+''.join(f'<th>{h}</th>' for h in headers)+'</tr></thead><tbody>'
    for r in rows:
        t += '<tr>'+''.join(f'<td>{c}</td>' for c in r)+'</tr>'
    return t+'</tbody></table>'

anchor_tbl = table(
    ["Gene","Role","n_IV","F","UKB MR","Egger int (P)","Weighted-median β (P)","Q P","coloc PP.H4 (3 priors)","Tedja/CREAM","FinnGen high-myopia","Verdict"],
    anchor_rows)
module_tbl = table(
    ["Gene","Pathway","Method","n_IV","β (UKB)","P","Note"],
    module_rows)

# ---------- manuscript ----------
with open(os.path.join(ROOT,"Submit_Manuscript","MANUSCRIPT_honest_v1.md")) as f:
    manuscript_html = md2html(f.read())

figs_main = "\n".join([
    fig("CP5_figures/Figure2A_MR_Forest.png","Figure 2. MR forest","cis-MR of anchors across cohorts.","MAIN"),
    fig("CP5_figures/Fig5_MR_forest_replication.png","Figure. Replication forest","Anchor replication across independent cohorts.","MAIN"),
    fig("CP5_figures/Figure3_Triangulation_Heatmap.png","Figure 3. Triangulation / colocalization","Evidence convergence; RDH5 robust vs others.","MAIN"),
    fig("Submit_Manuscript/Stage2_Figures/Figure4_schematic_bw.png","Figure 4. Biological schematic","Anchor context (monochrome).","MAIN"),
])
figs_suppl = "\n".join([
    fig("CP1/figures/Fig2_PPI_Network.png","Suppl. S1. PPI network","Atropine–myopia intersection network.","EXPLORATORY"),
    fig("CP5_figures/Figure4_Docking_Bar.png","Suppl. S2. Docking","Atropine binding energies — tropane-scaffold-dependent, NOT atropine-specific.","EXPLORATORY"),
])

CSS = """
body{font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;max-width:1000px;margin:0 auto;padding:28px;color:#1a1a1a;line-height:1.5}
h1{font-size:1.6em;border-bottom:3px solid #2b6cb0;padding-bottom:.3em}
h2{font-size:1.3em;color:#2b6cb0;border-bottom:1px solid #cbd5e0;padding-bottom:.2em;margin-top:1.6em}
h3{font-size:1.08em;color:#2c5282}
table{border-collapse:collapse;width:100%;margin:14px 0;font-size:12.5px}
th,td{border:1px solid #cbd5e0;padding:6px 8px;text-align:left;vertical-align:top}
th{background:#ebf4ff;font-weight:600}
tr:nth-child(even){background:#f7fafc}
code{background:#edf2f7;padding:1px 5px;border-radius:3px;font-size:.9em}
blockquote{background:#fffaf0;border-left:4px solid #dd6b20;margin:10px 0;padding:8px 14px;color:#4a5568;font-size:.93em}
figure{margin:18px 0;text-align:center;border:1px solid #e2e8f0;border-radius:8px;padding:12px;position:relative}
figure img{max-width:100%;height:auto}
figcaption{font-size:.9em;color:#4a5568;margin-top:8px}
.badge{position:absolute;top:8px;right:8px;font-size:10px;font-weight:700;padding:2px 8px;border-radius:10px;color:#fff}
.badge.MAIN{background:#2b6cb0}.badge.EXPLORATORY{background:#a0aec0}
.banner{background:#fffff0;border:2px solid #d69e2e;border-radius:8px;padding:12px 16px;margin:16px 0}
.toc{background:#f7fafc;border:1px solid #e2e8f0;border-radius:8px;padding:10px 20px}
.verdict-pos{color:#276749;font-weight:600}
"""

HTML = f"""<!doctype html><html lang="ko"><head><meta charset="utf-8">
<title>M-LIGHT — Integrated Review Document</title><style>{CSS}</style></head><body>
<h1>M-LIGHT — Integrated Review Document (honest v1)</h1>
<div class="banner">
<b>목적:</b> 검토·정리용 통합문서. 원고(honest v1) + 유전자 결과표 + Figure를 한 파일에 담았습니다.<br>
<b>⚠️ 완전성 고지:</b> 아래 anchor 표(5개)와 exploratory 모듈 유전자(7개)는 이 리포에서 확보된 <b>검증 수치</b>입니다.
<b>전체 113-유전자 denominator 표</b>는 PI 머신의 <code>Suppl_TableS_full_denominator_v2.csv</code>에만 있어, 그 CSV를 주시면 이 문서에 그대로 통합하겠습니다.<br>
<b>⚠️ Figure 고지:</b> 아래 Figure 중 일부는 <b>이전(과대주장) 분석용</b>으로 생성된 것이라, honest 프레임(RDH5 positive control, TGFB1 제외 등)에 맞게 <b>재생성이 필요할 수 있습니다</b>. 네트워크·도킹은 Supplementary(exploratory)로 강등.
</div>

<h2>A. 유전자 결과 마스터 표</h2>
<h3>A-1. Primary anchors (검증 완료 — MR·robustness·coloc·복제 전부)</h3>
{anchor_tbl}
<p style="font-size:12px;color:#4a5568">✓ = 복제/통과, ✗ = null/실패. coloc PP.H4는 3-prior. <b>핵심:</b> RDH5만 MR+coloc+복제 모두 통과(positive control). CTNNB1은 MR·복제 통과하나 coloc 실패 → MR robustness ≠ colocalization.</p>
<h3>A-2. Exploratory / pathway 모듈 유전자 (UKB MR only — Supplementary)</h3>
{module_tbl}
<p style="font-size:12px;color:#4a5568"><b>주목:</b> 아트로핀의 직접 표적 <b>CHRM3는 null(P=0.40)</b> — 유전학이 아트로핀 기전을 지지하지 못함을 보여주는 핵심 음성 결과.</p>

<h2>B. Figures</h2>
<h3>B-1. Main figures</h3>
{figs_main}
<h3>B-2. Supplementary (exploratory — no main-text causal claim)</h3>
{figs_suppl}

<h2>C. Manuscript (honest v1 전문)</h2>
<div style="border-top:2px solid #2b6cb0;padding-top:8px">
{manuscript_html}
</div>
</body></html>"""

with open(OUT,"w") as f:
    f.write(HTML)
print("WROTE", OUT, "size(KB)=", round(os.path.getsize(OUT)/1024))
