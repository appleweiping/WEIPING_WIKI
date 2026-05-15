---
title: "Fine Tune Korean"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - article
  - cookbook
  - fine-tuning
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/articles/gpt-oss/fine-tune-korean
  - https://github.com/openai/openai-cookbook/blob/main/articles/gpt-oss/fine-tune-korean.ipynb
---

# Fine Tune Korean

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/articles/gpt-oss/fine-tune-korean
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/articles/gpt-oss/fine-tune-korean.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/articles/gpt-oss/fine-tune-korean.ipynb
- Source path: `articles/gpt-oss/fine-tune-korean.ipynb`
- Source kind: `articles`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `41a61d098c8d230b84e597fd97169996726f3a9f4bc217604fc97007f3a42076`

## Classification

- Primary category: Fine-tuning / reinforcement fine-tuning
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

이 노트북은 OpenAI의 gpt-oss (open‑weight) 모델을 한국 뉴스 문체 + 최신 대화체 로 세밀 튜닝하는 방법을 한국어/영어 이중 언어 로 제공합니다. This notebook shows how to fine‑tune OpenAI's gpt-oss (open‑weight) models for Korean news style + modern chat tone , in Korean & English . --- MXFP4 workflow clarifications · MXFP4 워크플로 정리 EN: - Training or fine-tuning directly in MXFP4 is not supported by public...

## What This Teaches

- How to prepare data or workflows for model adaptation and fine-tuning.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

이 노트북은 OpenAI의  **gpt-oss (open‑weight)** 모델을 **한국 뉴스 문체 + 최신 대화체**로 세밀 튜닝하는 방법을
한국어/영어 **이중 언어**로 제공합니다.
This notebook shows how to fine‑tune OpenAI's **gpt-oss (open‑weight)** models for **Korean news style + modern chat tone**, in **Korean & English**.

---

### MXFP4 workflow clarifications · MXFP4 워크플로 정리

**EN:**
- Training or fine-tuning **directly in MXFP4 is not supported** by public frameworks today.
- Recommended path: train in **BF16** (or **QLoRA 4‑bit nf4**) → **merge LoRA** → **post‑training quantize to MXFP4** → `save_pretrained()` for deployment.
- If you need an MXFP4 artifact, you must **re‑quantize from BF16** after merging adapters. (Export utilities are evolving; if your toolchain already supports MXFP4 serialization, that’s ideal.)

**KR:**
- 현재 공개 프레임워크에서는 **MXFP4로 직접 학습/파인튜닝**이 지원되지 않습니다.
- 권장 경로: **BF16**(또는 **QLoRA 4‑bit nf4**)로 학습 → **LoRA 병합** → **사후(MXFP4) 양자화** → 배포용으로 `save_pretrained()` 저장.
- MXFP4 아티팩트가 필요하면, 어댑터 병합 후 **BF16 → MXFP4 재양자화**가 필요합니다. (직렬화 유틸은 진화 중이며, 툴체인에서 MXFP4 저장을 지원하면 가장 좋습니다.)

---

### LoRA targets (MoE) · LoRA 타깃(MoE 포함)

**EN:**
- Minimal config (fast, low VRAM): target attention only, e.g. `["q_proj","v_proj"]`.
- MoE‑aware config (better domain adaptation, more VRAM/time): include **expert projection layers** in addition to attention.

```python
from peft import LoraConfig

TARGET_MODULES = ["q_proj", "v_proj"]  # baseline
MOE_TARGET_PARAMETERS = [
    # example expert layers; adjust indices to your model depth
    "mlp.experts.gate_up_proj",
    "mlp.experts.down_proj",
]

lora_cfg = LoraConfig(
    r=16, lora_alpha=32, lora_dropout=0.05,
    target_modules="all-linear",              # cover all linear layers
    target_parameters=MOE_TARGET_PARAMETERS,  # add expert projections
    bias="none", task_type="CAUSAL_LM",
)
```

- Start with attention‑only; if KR domain fit is insufficient, enable MoE targets and re‑eval.

**KR:**
- 최소 구성(빠르고 VRAM 절약): `["q_proj","v_proj"]` 등 **어텐션만** 적용.
- **MoE 인지 구성**(도메인 적합성↑, 자원 소모↑): 어텐션에 **전문가(Expert) 투영 레이어**를 추가로 포함.
- 먼저 어텐션만으로 시도한 뒤, 한국어 도메인 적합성이 부족하면 MoE 타깃을 켜고 재평가하세요.

## Contents · 목차
0) Goals & Scope · 목표 & 범위
1) Environment check · 환경 점검
2) 설정값 · Config
3) 패키지 설치 · Install Deps
4) 데이터 소싱(한국형) · KR‑Context Data Sourcing
5) 샘플 데이터 생성 · Create Sample Data
6) 전처리(PIPA) & 스타일 라벨 · PII Scrubbing & Style Tags
7) 데이터 로딩/포맷팅 · Load & Format
8) 모델/토크나이저 로드 · Load Model & Tokenizer
9) Fine‑Tuning (LoRA/QLoRA) · 세밀 튜닝
   9a) Data curation & splits
   9b) Hyperparameters (r/alpha/dropout)
   9c) Merge adapters (BF16)
   9d) Save merged BF16 (`save_pretrained`)
   9e) Export & Quantize (BF16 → MXFP4) · 내보내기 & 양자화
10) 평가(뉴스/대화) · Evaluation (News/Chat)
11) Inference Prompt Templates · 추론 프롬프트 템플릿
12) 최신성 유지 · Freshness Strategy
13) 안전/컴플라이언스 · Safety & Compliance
14) 문제해결 & 다음 단계 · Troubleshooting & Next Steps

### ⚙️ Training vs Quantization — What’s supported
- **Do:** Train with BF16/FP16 or QLoRA; export merged weights.
- **Then:** Quantize to **MXFP4** for inference using provided conversion scripts/utilities.
- **Don’t:** Attempt to run an end‑to‑end “train in MXFP4” pipeline — not supported today.

> **PII & Compliance Reminder:** For KR data, follow your enterprise policy (mask RRN/phone/account IDs, remove emails) **before** training & logging. Keep train/val/test splits stratified by source and style tags.

### 🧪 MoE adapters (optional)
You can target MoE layers with adapters, but treat this as **advanced/experimental**. Start with attention projections first and validate KR benchmarks before expanding scope.

> **Note:** Keep `transformers`, `peft`, `accelerate`, and `trl` at versions known to support BF16/4‑bit LoRA.
If you pin `safetensors`, remember that **native MXFP4 serialization is not yet standardized**; loaders may upcast internally.

### 🔎 Support Matrix — At a glance
- **Fine‑tuning precision:** BF16/FP16 ✅ · QLoRA 4‑bit ✅ · **MXFP4 FT ❌**
- **Quantization target:** MXFP4 ✅ (post‑training)
- **API FT (hosted) for OSS models:** ❌
- **Open‑source FT (Transformers/TRL/PEFT):** ✅
- **LoRA targets:** `q_proj`, `k_proj`, `v_proj`, `o_proj` ✅; MoE expert adapters **experimental** ⚠️

---

## 0) Goals & Scope · 목표 & 범위
- **KR**: 한국어 일반 뉴스 + 일상/상담 대화체에 최적화. `style=news_headline|news_lead|news_body|kakao_casual|kakao_formal` 제어.
- **EN**: Optimize for Korean news writing and modern chat tone; control output via style tags above.
- **Stack**: `transformers`, `trl(SFTTrainer)`, `peft(LoRA/QLoRA)`, `datasets`.
- **Hardware**: Single/few GPUs (BF16 preferred). CPU/Mac for lightweight tests.

## 1) Environment check · 환경 점검

```python
import os, sys, platform
print("Python:", sys.version)
print("OS/Platform:", platform.platform())
print("CUDA_VISIBLE_DEVICES:", os.environ.get("CUDA_VISIBLE_DEVICES", ""))

try:
    import torch
    print("Torch:", torch.__version__, "CUDA:", torch.cuda.is_available())
    if torch.cuda.is_available():
        print("GPU:", torch.cuda.get_device_name(0))
except Exception as e:
    print("Torch not installed or GPU not detected:", e)
```

## 2) 설정값 · Config

```python
from pathlib import Path
import os

# === Model & Training Params ===
BASE_URL = "http://localhost:8000/v1"     # vLLM OpenAI-compatible endpoint
API_KEY  = "dummy-key"                     # vLLM ignores; SDK requires a value
MODEL    = "openai/gpt-oss-120b"           # must match the model vLLM loaded
OUTPUT_DIR = "ft-oss-kr-news-chat-bilingual"

# Data mix (news : chat)
MIX_NEWS = 0.6
MIX_CHAT = 0.4

# LoRA
LORA_R = 8
LORA_ALPHA = 16
LORA_DROPOUT = 0.05
TARGET_MODULES = ["q_proj", "v_proj"]  # adjust per model

# Training
EPOCHS = 1
PER_DEVICE_BS = 2
GRAD_ACCUM = 8
LEARNING_RATE = 2e-4
BF16 = True
LOG_STEPS = 20
SAVE_STEPS = 200
SAVE_TOTAL_LIMIT = 2

print("Config ready.")
```

## 3) 패키지 설치 · Install Deps

```python
# %pip install --upgrade pip
# %pip install transformers accelerate datasets peft trl bitsandbytes sentencepiece
# (optional) serving/runtimes
# %pip install vllm
# %pip install llama-cpp-python

import importlib, pip

for dep in ["transformers","accelerate","datasets","peft","trl",
            "bitsandbytes","sentencepiece","vllm","llama_cpp"]:
    try:
        print(f"{dep}: {importlib.import_module(dep).__version__}")
    except Exception:
        print(f"{dep}: not installed")

print(f"pip: {pip.__version__}")

print("Install cells are commented. Un-comment in your environment.")
```

## 4) 데이터 소싱(한국형) · KR‑Context Data Sourcing

**KR**
- 공개 벤치마크(주제 분류/요약/QA) + **허용된 뉴스 API의 메타데이터(제목/요약/섹션)** 중심으로 스타일 보정.
- 기사 **원문 대량 재학습은 저작권/약관 이슈** → 메타데이터·공개 코퍼스 위주.
- 대화체는 합법 공개 코퍼스(반말/존댓말/이모티콘/축약어 라벨 포함) 우선.
- PIPA: 주민번호/연락처/이메일/계좌 등 개인정보는 **훈련 전/로그 전** 스크러빙.

**EN**
- Prefer public KR benchmarks (topic classification / summarization / QA) and **allowed news API metadata** for style calibration.
- Avoid mass training on news full texts due to license/ToS constraints; use metadata + open corpora.
- For chat, use lawful open corpora with tone/emoji/informal‑formal annotations.
- Scrub PII (phone, RRNs, emails, accounts) before training/logging.

## 5) 샘플 데이터 생성 · Create Sample Data

```python
import json, pathlib
pathlib.Path("data").mkdir(exist_ok=True)

news_samples = [
  {"style":"news_lead","topic":"경제","title":"반도체 수출 호조… 7월 수출액 20% 증가","summary":"수출 개선세가 이어지며 경기 회복 기대가 커졌다."},
  {"style":"news_headline","topic":"정치","title":"국회, 데이터 산업 육성법 본회의 통과","summary":"데이터 활용 촉진과 개인정보 보호를 강화하는 내용."},
  {
    "style": "news_lead",
    "topic": "경제",
    "title": "카카오페이 보안 점검… 고객문의: help+vip@corp.co.kr",
    "summary": "고객센터 010-1234-5678로 문의 폭주. 계좌 110-123-456789 관련 결제 오류 논란."
  },
  {
    "style": "news_headline",
    "topic": "사회",
    "title": "개인정보 유출 의혹… 주민번호 901010-1234567 유통 주장",
    "summary": "서울특별시 강남구 테헤란로 123에서 자료 확보… 담당자 john.doe+news@example.com"
  }
]

chat_samples = [
  {"style":"kakao_casual","dialog":["주말에 비 온대?","응 일요일에 꽤 온다더라 ☔","헐 우산 챙겨야겠다"]},
  {"style":"kakao_formal","dialog":["안녕하세요. 배송 일정 확인 부탁드립니다.","내일 중 도착 예정입니다.","안내 감사합니다."]},
  {
    "style": "kakao_formal",
    "dialog": [
      "배송 확인 부탁드립니다. 주문번호 ORD-2025-0001 입니다.",
      "연락처는 010-2222-3333 입니다. (유니코드 하이픈)",
      "주민등록번호는 제공할 수 없습니다."
    ]
  }
]

with open("data/news.jsonl","w",encoding="utf-8") as f:
    for ex in news_samples: f.write(json.dumps(ex, ensure_ascii=False)+"\n")
with open("data/chat.jsonl","w",encoding="utf-8") as f:
    for ex in chat_samples: f.write(json.dumps(ex, ensure_ascii=False)+"\n")

print("Created: data/news.jsonl, data/chat.jsonl")
```

## 6) 전처리(PIPA) & 스타일 라벨 · PII Scrubbing & Style Tags

```python
# Step 6 — PII scrubbing + style tags (no Harmony here)
import json, re, unicodedata
from pathlib import Path

# --- Normalization helpers ---
HYPHENS = dict.fromkeys(map(ord, "‐-‒–—―﹘﹣－"), ord("-"))  # map unicode hyphens → ASCII
def normalize(s: str) -> str:
    if not isinstance(s, str): return s
    s = unicodedata.normalize("NFKC", s)
    s = s.translate(HYPHENS)
    return s

# --- PII patterns (illustrative; tune for production) ---
RE_EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
# KR mobile numbers with spaces/hyphens: 010-1234-5678, 010 1234 5678, etc.
RE_PHONE = re.compile(r"\b01[016789][-\s]?\d{3,4}[-\s]?\d{4}\b")
# Korean RRN (주민등록번호) basic pattern
RE_RRN = re.compile(r"\b\d{6}-\d{7}\b")
# Bank-ish account numbers: strictly digits in groups (avoid codes with letters)
RE_ACCOUNT = re.compile(r"\b\d{2,3}-\d{2,4}-\d{3,6}\b")
# Very simple postal address cue (city names) – conservative, just redact the token (optional)
RE_CITY = re.compile(r"(서울특별시|부산광역시|대구광역시|인천광역시|광주광역시|대전광역시|울산광역시|세종특별자치시|경기도|강원도|충청북도|충청남도|전라북도|전라남도|경상북도|경상남도|제주특별자치도)")

# Allowlist: things that look like PII but aren’t (e.g., bill/order codes w/ letters)
def looks_like_code(s: str) -> bool:
    return bool(re.search(r"[A-Za-z]", s))  # if letters present, treat as code, not account/phone

# Order of application matters (longest/most specific first sometimes helps)
SCRUBBERS = [
    ("[RRN]", RE_RRN),
    ("[EMAIL]", RE_EMAIL),
    ("[PHONE]", RE_PHONE),
    ("[ACCOUNT]", RE_ACCOUNT),
    ("[CITY]", RE_CITY),  # optional; comment out if you don't want to redact city tokens
]

def scrub_text(text: str) -> tuple[str, dict]:
    """Return (scrubbed_text, hits_dict). Avoid false positives with basic allowlisting."""
    if not isinstance(text, str) or not text:
        return text, {}
    orig = text
    text = normalize(text)
    hits = {}

    # Guard account-like and phone-like strings that contain letters (likely codes)
    guarded = set()
    for m in RE_ACCOUNT.finditer(text):
        if looks_like_code(m.group(0)):
            guarded.add(m.span())
    for m in RE_PHONE.finditer(text):
        if looks_like_code(m.group(0)):
            guarded.add(m.span())

    # Apply scrubs
    for label, pattern in SCRUBBERS:
        out = []
        last = 0
        count = 0
        for m in pattern.finditer(text):
            span = m.span()
            if pattern in (RE_ACCOUNT, RE_PHONE) and span in guarded:
                continue
            out.append(text[last:span[0&#93;&#93;)
            out.append(label)
            last = span[1]
            count += 1
        out.append(text[last:])
        text = "".join(out)
        if count:
            hits[label] = hits.get(label, 0) + count

    return text, hits if text != orig else {}

def scrub_record(rec: dict, kind: str) -> tuple[dict, dict]:
    """Scrub fields in a news/chat record; return (new_rec, hits)."""
    rec = dict(rec)  # shallow copy
    total_hits = {}

    def scrub_field(key):
        val = rec.get(key)
        new, hits = scrub_text(val) if isinstance(val, str) else (val, {})
        rec[key] = new
        for k, v in hits.items():
            total_hits[k] = total_hits.get(k, 0) + v

    if kind == "news":
        for key in ("title", "summary", "topic"):
            scrub_field(key)
    elif kind == "chat":
        scrub_field("style")
        if isinstance(rec.get("dialog"), list):
            cleaned_dialog = []
            for turn in rec["dialog"]:
                new, hits = scrub_text(turn) if isinstance(turn, str) else (turn, {})
                cleaned_dialog.append(new)
                for k, v in hits.items():
                    total_hits[k] = total_hits.get(k, 0) + v
            rec["dialog"] = cleaned_dialog

    return rec, total_hits

# --- Style tagger (lightweight labels for later routing/metrics) ---
def build_style_tags(rec: dict, kind: str) -> list[str]:
    tags = []
    if kind == "news":
        tags.append("domain:" + (rec.get("topic") or "unknown"))
        tags.append("style:" + (rec.get("style") or "news"))
        tags.append("tone:formal")
        tags.append("medium:news")
    elif kind == "chat":
        style = (rec.get("style") or "").lower()
        tags.append("style:" + (style or "chat"))
        tags.append("tone:" + ("formal" if "formal" in style else "casual"))
        tags.append("medium:kakao")
    return [t.replace(" ", "_") for t in tags]

# --- Process files ---
def process_file(src: str, dst: str, kind: str):
    total = 0
    redacted = 0
    counters = {}
    with open(src, encoding="utf-8") as fin, open(dst, "w", encoding="utf-8") as fout:
        for line in fin:
            if not line.strip(): continue
            rec = json.loads(line)
            total += 1
            cleaned, hits = scrub_record(rec, kind)
            cleaned["style_tags"] = build_style_tags(cleaned, kind)
            cleaned["_pii_hits"] = hits  # keep for inspection; drop later if you want
            if hits: redacted += 1
            for k, v in hits.items():
                counters[k] = counters.get(k, 0) + v
            fout.write(json.dumps(cleaned, ensure_ascii=False) + "\n")
    print(f"{src} -> {dst} | rows: {total}, redacted_rows: {redacted}, hits: {counters}")

process_file("data/news.jsonl", "data/news_clean.jsonl", kind="news")
process_file("data/chat.jsonl", "data/chat_clean.jsonl", kind="chat")
```

## 7) 데이터 로딩/포맷팅 · Load & Format

```python
# Step 7 — Harmony conversion + dataset loading & tokenization
import json, math
from pathlib import Path
from datasets import load_dataset, Dataset, concatenate_datasets
from transformers import AutoTokenizer

DATA = Path("data")
assert (DATA / "news_clean.jsonl").exists(), "Run Step 6 first"
assert (DATA / "chat_clean.jsonl").exists(), "Run Step 6 first"

# ---------- 7A) Convert cleaned → Harmony messages ----------

def news_to_messages(rec):
    # system style from Step 6 tags; default to KR news tone
    system = "한국 뉴스 문체로 간결하고 사실 위주로 작성."
    # user asks for a headline+lead from topic; assistant is the expected formatted answer
    user = f"주제: {rec.get('topic','알수없음')}. 기사 제목과 요약을 생성해줘."
    assistant = f"{rec.get('title','')} — {rec.get('summary','')}"
    return [{"role":"system","content":system},
            {"role":"user","content":user},
            {"role":"assistant","content":assistant}]

def chat_to_messages(rec):
    # Keep style hint (casual/formal) in system
    style = (rec.get("style") or "").lower()
    system = f"카카오톡 대화 스타일. style={style or 'chat'}"
    dialog = rec.get("dialog") or []
    msgs = [{"role":"system","content":system}]
    # Alternate user/assistant turns; if odd length, last user stays without assistant label
    roles = ["user","assistant"]
    for i, turn in enumerate(dialog[:6]):  # cap tiny demos to avoid runaway
        msgs.append({"role": roles[i % 2], "content": str(turn)})
    # Ensure there is at least one assistant turn for SFT
    if not any(m["role"]=="assistant" for m in msgs):
        msgs.append({"role":"assistant","content":"네, 확인했습니다."})
    return msgs

def write_harmony(src, dst, kind):
    convert = news_to_messages if kind=="news" else chat_to_messages
    with open(src, encoding="utf-8") as fin, open(dst, "w", encoding="utf-8") as fout:
        for line in fin:
            if not line.strip(): continue
            rec = json.loads(line)
            msgs = convert(rec)
            fout.write(json.dumps({"messages": msgs}, ensure_ascii=False) + "\n")

write_harmony(DATA/"news_clean.jsonl", DATA/"news_harmony.jsonl", "news")
write_harmony(DATA/"chat_clean.jsonl", DATA/"chat_harmony.jsonl", "chat")
print("Created:", DATA/"news_harmony.jsonl", DATA/"chat_harmony.jsonl")

# ---------- 7B) Load Harmony JSONL with 🤗 Datasets ----------
raw = load_dataset(
    "json",
    data_files={"news": str(DATA/"news_harmony.jsonl"),
                "chat": str(DATA/"chat_harmony.jsonl")}
)

# Mix train split using your Step-2 mix ratios
news = raw["news"]
chat = raw["chat"]

def take_portion(ds, frac):
    n = max(1, int(round(len(ds) * frac)))
    return ds.select(range(n)) if n < len(ds) else ds

news_part = take_portion(news, MIX_NEWS if 'MIX_NEWS' in globals() else 0.5)
chat_part = take_portion(chat, MIX_CHAT if 'MIX_CHAT' in globals() else 0.5)
train_ds = concatenate_datasets([news_part, chat_part]).shuffle(seed=42)

# Tiny validation built from remaining examples (if any)
remaining_news = news.select(range(len(news_part), len(news))) if len(news) > len(news_part) else news_part
remaining_chat = chat.select(range(len(chat_part), len(chat))) if len(chat) > len(chat_part) else chat_part
val_candidates = concatenate_datasets([remaining_news, remaining_chat])
val_ds = val_candidates.shuffle(seed=43).select(range(min(64, len(val_candidates)))) if len(val_candidates) else train_ds.select(range(min(32, len(train_ds))))

dataset = {"train": train_ds, "validation": val_ds}
print({k: len(v) for k, v in dataset.items()})
```

## 8) 모델/토크나이저 로드 · Load Model & Tokenizer

```python
# ---------- 7C) Tokenizer + Harmony template fallback ----------
from transformers import AutoTokenizer

tokenizer = AutoTokenizer.from_pretrained(
    MODEL,
    use_fast=True,          # required if only tokenizer.json exists
    trust_remote_code=True,
    force_download=True     # ensures a fresh pull
)

if not getattr(tokenizer, "chat_template", None):
    # Minimal Harmony-style fallback (server already knows Harmony; this is ONLY for training tokenization)
    tokenizer.chat_template = """{% for m in messages -%}
{%- if m['role'] == 'system' -%}<|system|>
{{ m['content'] }}<|end|>
{%- elif m['role'] == 'user' -%}<|user|>
{{ m['content'] }}<|end|>
{%- elif m['role'] == 'assistant' -%}<|assistant|>
{{ m['content'] }}<|end|>
{%- endif -%}
{%- endfor -%}"""

# Ensure pad/eos are sane
tokenizer.pad_token = tokenizer.eos_token or tokenizer.pad_token

# ---------- 7D) Tokenize with assistant-only labels ----------
ASST_TOKEN = None
END_TOKEN = None
try:
    ASST_TOKEN = tokenizer.convert_tokens_to_ids("<|assistant|>")
    END_TOKEN = tokenizer.convert_tokens_to_ids("<|end|>")
except Exception:
    # If the base vocab lacks these tokens, it's okay; masking fallback below will still work heuristically
    pass

MAX_LEN = 2048  # you can raise this if you have room

def tokenize_with_labels(example):
    # 1) Render with chat template (includes assistant answer)
    text = tokenizer.apply_chat_template(example["messages"], tokenize=False, add_generation_prompt=False)
    # 2) Tokenize
    enc = tokenizer(text, truncation=True, max_length=MAX_LEN)
    input_ids = enc["input_ids"]
    labels = [-100] * len(input_ids)

    # 3) Label only assistant content
    if ASST_TOKEN is not None and END_TOKEN is not None:
        start = None
        for i, tid in enumerate(input_ids):
            if tid == ASST_TOKEN:
                start = i + 1  # learn after the tag
            elif start is not None and tid == END_TOKEN:
                start = None
            elif start is not None:
                labels[i] = input_ids[i]
    else:
        # Heuristic fallback: learn on the last third of tokens (crude but avoids total silence)
        start = int(len(input_ids) * 0.66)
        for i in range(start, len(input_ids)):
            labels[i] = input_ids[i]

    return {"input_ids": input_ids, "attention_mask": enc["attention_mask"], "labels": labels}

tokenized_train = dataset["train"].map(tokenize_with_labels, remove_columns=["messages"])
tokenized_val   = dataset["validation"].map(tokenize_with_labels, remove_columns=["messages"])

print("Tokenization done.",
      "train:", len(tokenized_train),
      "val:", len(tokenized_val),
      "example lens:", tokenized_train[0]["input_ids"][:12], "...")
```

## 9) Fine‑Tuning (LoRA/QLoRA) · 세밀 튜닝
### 9a) Data curation & splits
_(See Section 7/8 for dataset prep; move relevant snippets here if needed.)_
### 9b) Hyperparameters (r/alpha/dropout)
```python
# Example LoRA hyperparameters
LORA_R = 8
LORA_ALPHA = 16
LORA_DROPOUT = 0.05
```

### 9c) Merge adapters (BF16)
```python
# Example merge step (after training)
# model = PeftModel.from_pretrained(base_model, adapter_path)
# merged_model = model.merge_and_unload()
```

### 9d) Save merged BF16 (`save_pretrained`)
```python
# merged_model.save_pretrained(OUTPUT_DIR)
```

### 9e) Export & Quantize (BF16 → MXFP4) · 내보내기 & 양자화

**EN (neutral, framework-agnostic):**
Public libraries currently do **not** support training/fine‑tuning *directly* in MXFP4. The common pipeline is:
1) **Train/SFT** in **BF16** (or **QLoRA 4‑bit nf4**).
2) **Merge LoRA adapters** into the base model (BF16).
3) **Save** the merged BF16 checkpoint with `save_pretrained()`.
4) **Post‑training quantize** the merged BF16 tensors to **MXFP4** using a **vendor/toolchain‑provided packer**.
5) **Save/export** the MXFP4 artifact (same shape as Hugging Face `save_pretrained()` output) for deployment/serving.

> Notes:
> - If your serving stack supports **LoRA at inference**, you may skip merging and quantization and ship: **base (MXFP4 or BF16) + LoRA adapters**.
> - If your runtime requires **merged MXFP4**, you must run a **BF16 → MXFP4** quantization step after merging adapters.
> - Keep **tokenizer/config** files aligned across BF16 and MXFP4 exports.

**KR (중립적, 도구 비의존):**
현재 공개 라이브러리는 MXFP4에서 **직접 학습/파인튜닝을 지원하지 않습니다**. 일반적인 파이프라인은 다음과 같습니다:
1) **BF16**(또는 **QLoRA 4‑bit nf4**)로 **학습/파인튜닝**
2) **LoRA 어댑터 병합**(BF16 기준)
3) `save_pretrained()`로 **병합된 BF16 체크포인트 저장**
4) 벤더/툴체인에서 제공하는 **양자화 도구**로 **BF16 → MXFP4 사후 양자화**
5) 배포/서빙용 **MXFP4 아티팩트 저장/내보내기** (Hugging Face `save_pretrained()` 구조와 동일)

> 참고:
> - **서빙에서 LoRA를 지원**한다면, 병합·양자화를 생략하고 **기저( MXFP4 또는 BF16 ) + LoRA 어댑터**로 제공할 수 있습니다.
> - **병합된 MXFP4**가 필요한 런타임의 경우, 어댑터 병합 후 **BF16 → MXFP4 재양자화** 단계가 필요합니다.
> - **tokenizer/config** 파일은 BF16과 MXFP4 아티팩트 간에 일관되게 유지하세요.

```python
from trl import SFTTrainer, SFTConfig
from peft import LoraConfig, get_peft_model

lora_cfg = LoraConfig(
    task_type="CAUSAL_LM",
    r=LORA_R, lora_alpha=LORA_ALPHA, lora_dropout=LORA_DROPOUT,
    target_modules=TARGET_MODULES
)

# base_model = get_peft_model(base_model, lora_cfg)

sft_args = SFTConfig(
    output_dir=OUTPUT_DIR,
    num_train_epochs=EPOCHS,
    per_device_train_batch_size=PER_DEVICE_BS,
    gradient_accumulation_steps=GRAD_ACCUM,
    learning_rate=LEARNING_RATE,
    lr_scheduler_type="cosine",
    bf16=BF16,
    logging_steps=LOG_STEPS,
    save_steps=SAVE_STEPS,
    save_total_limit=SAVE_TOTAL_LIMIT
)

# trainer = SFTTrainer(model=base_model, args=sft_args, train_dataset=combined, tokenizer=tokenizer)
# trainer.train()
# trainer.save_model(OUTPUT_DIR)
print("Fine‑tuning skeleton ready. Un‑comment on your machine.")
```

## 10) 평가(뉴스/대화) · Evaluation (News/Chat)

**KR 지표 · KR Metrics**
- 뉴스성: 주제 분류 적합도(F1), 요약 품질(ROUGE‑1/2/L), 독해 QA(EM/F1).
- 대화성: 자연성/맥락 유지, 경어/반말 전환 정확도, 이모티콘/축약어 적절성.

**EN Notes**
- Use public KR benchmarks (e.g., topic classification, KorQuAD‑like QA) where licenses permit.
- Mix automatic metrics (F1/ROUGE) with human eval for tone & politeness.

```python
# Example helpers (stub)
def simple_accuracy(preds, labels):
    return sum(int(p==g) for p,g in zip(preds, labels)) / max(1, len(labels))

# For ROUGE:
# import evaluate
# rouge = evaluate.load("rouge")
# result = rouge.compute(predictions=pred_texts, references=ref_texts)
# print(result)

print("Eval stubs ready.")
```

## 11) Inference Prompt Templates · 추론 프롬프트 템플릿

```python
from openai_harmony import Message, ChatFormatter

# Example prompt construction using Harmony
messages = [
    Message(role="system", content="너는 한국 고객을 돕는 유능한 AI 어시스턴트다."),
    Message(role="user", content="국내 PIPA 규정을 준수하면서 사내 문서 요약기를 구성하려면 어떤 아키텍처가 좋을까?")
]

prompt = ChatFormatter.to_chat_prompt(messages)
print(prompt)  # For preview; pass to tokenizer when running inference
```

## 12) 최신성 유지 · Freshness Strategy

- **주간 보정 SFT**: 허용된 뉴스 API **메타데이터(제목/요약/섹션)** 샘플링 → 스타일 보정.
- **대화체 업데이트**: 최신 축약어/신조어/이모티콘 사전 반영(예: ㄱㄱ, ㅇㅋ, ㅋㅋ, ㄹㅇ).
- **회귀 평가**: 동일 지표로 before/after 비교 → 혼합비/온도/패널티 튜닝.

- Weekly calibration SFT using **allowed news API metadata** for style;
- Update slang/emoji lexicons;
- Regression evals to track drift and adjust data mix/decoding.

## 13) 안전/컴플라이언스 · Safety & Compliance

- 데이터 출처/라이선스 확인(벤치마크, API, 내부 데이터) · Verify dataset/API licenses.
- 개인정보 스크러빙(훈련/로그/평가 전) · Scrub PII before training/logging/eval.
- 저작권/약관 준수(기사 **원문 대량 재학습 금지**) · Avoid mass training on full news articles.
- 출력 검증(스키마/금칙어/민감도 규칙) · Output validation & forbidden‑term filters.
- 버전/평가 리포트 관리 · Version datasets/models and keep eval reports.

## 14) 문제해결 & 다음 단계 · Troubleshooting & Next Steps

- 혼합 비율 튜닝: (뉴스:대화) 6:4 → 7:3 또는 5:5로 조정
- LoRA 하이퍼파라미터: r=8~16, α=16~32, dropout=0.05~0.1
- 서비스화: vLLM/llama.cpp 서빙 + 토픽/스타일 라우팅
- RAG 결합: 최신 사실성 보강을 위해 뉴스/문서 인덱스 결합
- A/B 테스트: 톤/길이/이모티콘 사용량 등 사용자 만족도 측정

- Tune mix ratios, run A/B tests, consider vLLM serving, and pair with RAG for factuality.
