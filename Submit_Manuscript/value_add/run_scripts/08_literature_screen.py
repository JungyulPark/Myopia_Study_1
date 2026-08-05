import json,glob,re,csv
D="/root/.claude/projects/-home-user-Myopia-Study-1/d98b3afe-25e3-5cba-82eb-574347f6b136/tool-results/"
recs={}
for f in glob.glob(D+"*get_article_metadata*.txt"):
    try: d=json.load(open(f))
    except Exception: continue
    for a in d.get("articles",[]):
        ids=a.get("identifiers");  ids=eval(ids) if isinstance(ids,str) else ids
        p=ids.get("pmid")
        if p: recs[p]=a
print("unique records collected:",len(recs))

def txt(a):
    return ((a.get("title") or "")+" "+(a.get("abstract") or "")).lower()
def yr(a):
    j=a.get("publication_date"); j=eval(j) if isinstance(j,str) else (j or {})
    return j.get("year","")
def jnl(a):
    j=a.get("journal"); j=eval(j) if isinstance(j,str) else (j or {})
    return j.get("iso_abbreviation","")

# Protocol sec.4 criteria
METHOD=["mendelian randomi","summary-data-based","smr","colocali","coloc","eqtl","expression quantitative trait","transcriptome-wide","twas","drug target","druggable"]
CIS   =["cis-eqtl","cis eqtl","eqtl","smr","colocali","twas","transcriptome-wide","druggable","drug target"]
OUTCOME=["myopia","refractive error","axial length","spherical equivalent","refractive"]
PQTL  =["pqtl","proteome-wide","plasma protein","protein quantitative trait","proteomic"]
GENEY =["gene","genes","target","targets","expression","transcript"]
EXCL_TYPE=["review","editorial","comment","letter","news"]

rows=[]
for p,a in recs.items():
    t=txt(a)
    at=str(a.get("article_types","")).lower()
    has_out=any(k in t for k in OUTCOME)
    has_meth=any(k in t for k in METHOD)
    has_cis=any(k in t for k in CIS)
    has_pqtl=any(k in t for k in PQTL)
    is_rev=("review" in at and "journal article" not in at) or "systematic review" in t or "meta-analysis" in t and not has_cis
    if not has_out:            v,why="EXCLUDE","no myopia/refractive outcome"
    elif not has_meth:         v,why="EXCLUDE","no MR/eQTL/coloc method"
    elif is_rev:               v,why="EXCLUDE","review/meta-analysis, no extractable targets"
    elif has_pqtl and not has_cis: v,why="EXCLUDE_pQTL","pQTL/proteome nomination - method mismatch (see protocol 4)"
    elif has_cis:              v,why="INCLUDE_candidate","gene-level cis-eQTL/SMR/coloc/TWAS nomination"
    else:                      v,why="MAYBE","MR present but gene-level nomination unclear"
    rows.append(dict(pmid=p,year=yr(a),journal=jnl(a),verdict=v,reason=why,
                     pqtl=has_pqtl,title=(a.get("title") or "").strip()))

rows.sort(key=lambda r:(r["verdict"],-int(r["year"] or 0)))
with open("screen1.csv","w",newline="") as f:
    w=csv.DictWriter(f,fieldnames=["pmid","year","journal","verdict","reason","pqtl","title"]);w.writeheader();w.writerows(rows)

from collections import Counter
print("\n=== 1차 선별 결과 ===")
for k,v in Counter(r["verdict"] for r in rows).most_common(): print(f"  {k:20s} {v}")
print("\n=== INCLUDE_candidate + MAYBE (전문 검토 대상) ===")
for r in rows:
    if r["verdict"] in ("INCLUDE_candidate","MAYBE"):
        print(f"{r['pmid']}  {r['year']}  {r['verdict'][:9]:9s} {r['title'][:105]}")
