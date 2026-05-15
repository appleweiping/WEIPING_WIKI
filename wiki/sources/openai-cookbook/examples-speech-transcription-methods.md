---
title: "Speech Transcription Methods"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - example
  - notebook
  - openai
  - realtime
  - voice
source_pages:
  - https://developers.openai.com/cookbook/examples/speech_transcription_methods
  - https://github.com/openai/openai-cookbook/blob/main/examples/Speech_transcription_methods.ipynb
---

# Speech Transcription Methods

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/speech_transcription_methods
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Speech_transcription_methods.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Speech_transcription_methods.ipynb
- Source path: `examples/Speech_transcription_methods.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `5fe9d2dc2f365e64e7e671d2f6e5ebab5009bdec342938e8a457baaea2f5bb65`

## Classification

- Primary category: Realtime / voice / transcription
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

🗣️ Comparing Speech-to-Text Methods with the OpenAI API Overview This notebook provides a clear, hands-on guide for beginners to quickly get started with Speech-to-Text (STT) using the OpenAI API. You'll explore multiple practical methods, their use cases, and considerations. By the end you will be able to select and use the appropriate transcription method...

## What This Teaches

- How to build low-latency speech, transcription, or voice interaction pipelines.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# 🗣️ Comparing Speech-to-Text Methods with the OpenAI API

## Overview

This notebook provides a clear, hands-on guide for beginners to quickly get started with Speech-to-Text (STT) using the OpenAI API. You'll explore multiple practical methods, their use cases, and considerations.

By the end you will be able to select and use the appropriate transcription method for your use use cases.

*Note:*
- *This notebook uses WAV audio files for simplicity. It does **not** demonstrate real-time microphone streaming (such as from a web app or direct mic input).*
- *This notebook uses WebSockets to connect to the Realtime API. Alternatively, you can use WebRTC, see the [OpenAI docs](https://platform.openai.com/docs/guides/realtime#connect-with-webrtc) for details.*

### 📊 Quick-look
| Mode                           | Latency to **first token** | Best for (real examples)                                     | Advantages | Key limitations                |
|--------------------------------|---------------------------|--------------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|
| File upload + `stream=False` (blocking) | seconds  | Voicemail, meeting recordings | Simple to set up | • No partial results, users see nothing until file finishes <br>• Max 25 MB per request (you must chunk long audio) |
| File upload + `stream=True`    | subseconds | Voice memos in mobile apps | Simple to set up & provides a “live” feel via token streaming | • Still requires a completed file <br>• You implement progress bars / chunked uploads |
| Realtime WebSocket             | subseconds | Live captions in webinars | True real-time; accepts a continuous audio stream | • Audio must be pcm16, g711_ulaw, or g711_alaw <br>• Session ≤ 30 min, reconnect & stitch <br>• You handle speaker-turn formatting to build the full transcript |
| Agents SDK VoicePipeline       | subseconds | Internal help-desk assistant | Real-time streaming and easy to build agentic workflows | • Python-only beta <br>• API surface may change |

## Installation (one‑time)

To set up your environment, uncomment and run the following cell in a new Python environment:

```python
!pip install --upgrade -q openai openai-agents websockets sounddevice pyaudio nest_asyncio resampy httpx websocket-client
```

This installs the necessary packages required to follow along with the notebook.

## Authentication
Before proceeding, ensure you have set your OpenAI API key as an environment variable named OPENAI_API_KEY. You can typically set this in your terminal or notebook environment: `export OPENAI_API_KEY="your-api-key-here"`

Verify that your API key is set correctly by running the next cell.

```python
# ─── Standard Library ──────────────────────────────────────────────────────────
import asyncio
import struct
import base64          # encode raw PCM bytes → base64 before sending JSON
import json            # compose/parse WebSocket messages
import os
import time
from typing import List
from pathlib import Path

# ─── Third-Party ───────────────────────────────────────────────────────────────
import nest_asyncio
import numpy as np
from openai import OpenAI
import resampy         # high-quality sample-rate conversion
import soundfile as sf # reads many audio formats into float32 arrays
import websockets      # asyncio-based WebSocket client
from agents import Agent
from agents.voice import (
    SingleAgentVoiceWorkflow,
    StreamedAudioInput,
    VoicePipeline,
    VoicePipelineConfig,
)
from IPython.display import Audio, display
# ───────────────────────────────────────────────────────────────────────────────
nest_asyncio.apply()

# ✏️  Put your key in an env-var or just replace the call below.
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

client = OpenAI(api_key=OPENAI_API_KEY)
print("✅ OpenAI client ready")
```

---
## 1 · Speech-to-Text with Audio File
*model = gpt-4o-transcribe*

### When to use
* You have a completed audio file (up to 25 MB).The following input file types are supported: mp3, mp4, mpeg, mpga, m4a, wav, and webm.
* Suitable for batch processing tasks like podcasts, call-center recordings, or voice memos.
* Real-time feedback or partial results are not required.

### How it works


![STT Not Streaming Transcription flow](../images/speech-to-text-not-streaming.png)

#### Benefits

- **Ease of use:** Single HTTP request – perfect for automation or backend scripts.
- **Accuracy:** Processes the entire audio in one go, improving context and transcription quality.
- **File support:** Handles WAV, MP3, MP4, M4A, FLAC, Ogg, and more.

#### Limitations

- **No partial results:** You must wait until processing finishes before seeing any transcript.
- **Latency scales with duration:** Longer recordings mean longer wait times.
- **File-size cap:** Up to 25 MB (≈ 30 min at 16-kHz mono WAV).
- **Offline use only:** Not intended for real-time scenarios such as live captioning or conversational AI.

Let's first preview the audio file. I've downloaded the audio file from [here](https://pixabay.com/sound-effects/search/male-speech/).

```python
AUDIO_PATH = Path('./data/sample_audio_files/lotsoftimes-78085.mp3')  # change me
MODEL_NAME = "gpt-4o-transcribe"

if AUDIO_PATH.exists():
    display(Audio(str(AUDIO_PATH)))
else:
    print('⚠️ Provide a valid audio file')
```

Now, we can call the STT endpoint to transcribe the audio.

```python
if AUDIO_PATH.exists():
    with AUDIO_PATH.open('rb') as f:
        transcript = client.audio.transcriptions.create(
            file=f,
            model=MODEL_NAME,
            response_format='text',
        )
    print('\n--- TRANSCRIPT ---\n')
    print(transcript)
```

## 2 · Speech-to-Text with Audio File: Streaming
*model = gpt-4o-transcribe*
### When to use
- You already have a fully recorded audio file.
- You need immediate transcription results (partial or final) as they arrive.
- Scenarios where partial feedback improves UX, e.g., uploading a long voice memo.

![STT Streaming Transcription flow](../images/speech-to-text-streaming.png)

#### Benefits
- **Real-time feel:** Users see transcription updates almost immediately.
- **Progress visibility:** Intermediate transcripts show ongoing progress.
- **Improved UX:** Instant feedback keeps users engaged.

#### Limitations
- **Requires full audio file upfront:** Not suitable for live audio feeds.
- **Implementation overhead:** You must handle streaming logic and progress updates yourself.

```python
if AUDIO_PATH.exists():
    with AUDIO_PATH.open('rb') as f:
        stream = client.audio.transcriptions.create(
            file=f,
            model=MODEL_NAME,
            response_format='text',
              stream=True
)

for event in stream:
    # If this is an incremental update, you can get the delta using `event.delta`
    if getattr(event, "delta", None):
        print(event.delta, end="", flush=True)
        time.sleep(0.05) # simulate real-time pacing

    # When transcription is complete, you can get the final transcript using `event.text`
    elif getattr(event, "text", None):
        print()
        print("\n" + event.text)
```

---
## 3 · Realtime Transcription API
*model = gpt-4o-transcribe*
### When to use
* Live captioning for real-time scenarios (e.g., meetings, demos).
* Need built-in voice-activity detection, noise suppression, or token-level log probabilities.
* Comfortable handling WebSockets and real-time event streams.

### How it works

![Realtime Transcription flow](../images/realtime_api_transcription.png)

#### Benefits
- **Ultra-low latency:** Typically 300–800 ms, enabling near-instant transcription.
- **Dynamic updates:** Supports partial and final transcripts, enhancing the user experience.
- **Advanced features:** Built-in turn detection, noise reduction, and optional detailed log-probabilities.

#### Limitations
- **Complex integration:** Requires managing WebSockets, Base64 encoding, and robust error handling.
- **Session constraints:** Limited to 30-minute sessions.
- **Restricted formats:** Accepts only raw PCM (no MP3 or Opus); For pcm16, input audio must be 16-bit PCM at a 24kHz sample rate, single channel (mono), and little-endian byte order.

```python
TARGET_SR     = 24_000
PCM_SCALE     = 32_767
CHUNK_SAMPLES = 3_072                 # ≈128 ms at 24 kHz
RT_URL        = "wss://api.openai.com/v1/realtime?intent=transcription"

EV_DELTA      = "conversation.item.input_audio_transcription.delta"
EV_DONE       = "conversation.item.input_audio_transcription.completed"
# ── helpers ────────────────────────────────────────────────────────────────
def float_to_16bit_pcm(float32_array):
    clipped = [max(-1.0, min(1.0, x)) for x in float32_array]
    pcm16 = b''.join(struct.pack('<h', int(x * 32767)) for x in clipped)
    return pcm16

def base64_encode_audio(float32_array):
    pcm_bytes = float_to_16bit_pcm(float32_array)
    encoded = base64.b64encode(pcm_bytes).decode('ascii')
    return encoded

def load_and_resample(path: str, sr: int = TARGET_SR) -> np.ndarray:
    """Return mono PCM-16 as a NumPy array."""
    data, file_sr = sf.read(path, dtype="float32")
    if data.ndim > 1:
        data = data.mean(axis=1)
    if file_sr != sr:
        data = resampy.resample(data, file_sr, sr)
    return data

async def _send_audio(ws, pcm: np.ndarray, chunk: int, sr: int) -> None:
    """Producer: stream base-64 chunks at real-time pace, then signal EOF."""
    dur = 0.025 # Add pacing to ensure real-time transcription
    t_next = time.monotonic()

    for i in range(0, len(pcm), chunk):
        float_chunk = pcm[i:i + chunk]
        payload = {
            "type":  "input_audio_buffer.append",
            "audio": base64_encode_audio(float_chunk),
        }
        await ws.send(json.dumps(payload))
        t_next += dur
        await asyncio.sleep(max(0, t_next - time.monotonic()))

    await ws.send(json.dumps({"type": "input_audio_buffer.end"}))

async def _recv_transcripts(ws, collected: List[str]) -> None:
    """
    Consumer: build `current` from streaming deltas, promote it to `collected`
    whenever a …completed event arrives, and flush the remainder on socket
    close so no words are lost.
    """
    current: List[str] = []

    try:
        async for msg in ws:
            ev = json.loads(msg)

            typ = ev.get("type")
            if typ == EV_DELTA:
                delta = ev.get("delta")
                if delta:
                    current.append(delta)
                    print(delta, end="", flush=True)
            elif typ == EV_DONE:
                # sentence finished → move to permanent list
                collected.append("".join(current))
                current.clear()
    except websockets.ConnectionClosedOK:
        pass

    # socket closed → flush any remaining partial sentence
    if current:
        collected.append("".join(current))

def _session(model: str, vad: float = 0.5) -> dict:
    return {
        "type": "transcription_session.update",
        "session": {
            "input_audio_format": "pcm16",
            "turn_detection": {"type": "server_vad", "threshold": vad},
            "input_audio_transcription": {"model": model},
        },
    }

async def transcribe_audio_async(
    wav_path,
    api_key,
    *,
    model: str = MODEL_NAME,
    chunk: int = CHUNK_SAMPLES,
) -> str:
    pcm = load_and_resample(wav_path)
    headers = {"Authorization": f"Bearer {api_key}", "OpenAI-Beta": "realtime=v1"}

    async with websockets.connect(RT_URL, additional_headers=headers, max_size=None) as ws:
        await ws.send(json.dumps(_session(model)))

        transcripts: List[str] = []
        await asyncio.gather(
            _send_audio(ws, pcm, chunk, TARGET_SR),
            _recv_transcripts(ws, transcripts),
        )  # returns when server closes

    return " ".join(transcripts)
```

```python
transcript = await transcribe_audio_async(AUDIO_PATH, OPENAI_API_KEY)
transcript
```

---
## 4 · Agents SDK Realtime Transcription
*models = gpt-4o-transcribe, gpt-4o-mini*
### When to use
* Leveraging the OpenAI Agents SDK for real-time transcription and synthesis with minimal setup.
* You want to integrate transcription directly into agent-driven workflows.
* Prefer high-level management of audio input/output, WebSockets, and buffering.

### How it works

![Agents Transcription flow](../images/agents_sdk_transcription.png)

**Benefits**

- **Minimal boilerplate:** `VoicePipeline` handles resampling, VAD, buffering, token auth, and reconnects.
- **Seamless agent integration**: Enables direct interaction with GPT agents using real-time audio transcription.

**Limitations**

- **Python-only beta:** not yet available in other languages; APIs may change.
- **Less control:** fine-tuning VAD thresholds or packet scheduling requires digging into SDK internals.

```python
# ── 1 · agent that replies in French ---------------------------------------
fr_agent = Agent(
    name="Assistant-FR",
    instructions=
        "Translate the user's words into French.",
    model="gpt-4o-mini",
)

# ── 2 · workflow that PRINTS what it yields --------------------------------
class PrintingWorkflow(SingleAgentVoiceWorkflow):
    """Subclass that prints every chunk it yields (the agent's reply)."""

    async def run(self, transcription: str):
        # Optionally: also print the user transcription
        print()
        print("[User]:", transcription)
        print("[Assistant]: ", end="", flush=True)
        async for chunk in super().run(transcription):
            print(chunk, end="", flush=True)   # <-- agent (French) text
            yield chunk                        # still forward to TTS


pipeline = VoicePipeline(
    workflow=PrintingWorkflow(fr_agent),
    stt_model=MODEL_NAME,
    config=VoicePipelineConfig(tracing_disabled=True),
)

# ── 3 · helper to stream ~40 ms chunks at 24 kHz ---------------------------
def load_and_resample(path: str, sr: int = 24_000) -> np.ndarray:
    """Return mono PCM-16 as a NumPy array."""
    data, file_sr = sf.read(path, dtype="float32")
    if data.ndim > 1:
        data = data.mean(axis=1)
    if file_sr != sr:
        data = resampy.resample(data, file_sr, sr)
    return data

def audio_chunks(path: str, target_sr: int = 24_000, chunk_ms: int = 40):
    # 1️⃣ reuse the helper
    audio = load_and_resample(path, target_sr)

    # 2️⃣ float-32 → int16 NumPy array
    pcm = (np.clip(audio, -1, 1) * 32_767).astype(np.int16)

    # 3️⃣ yield real-time sized hops
    hop = int(target_sr * chunk_ms / 1_000)
    for off in range(0, len(pcm), hop):
        yield pcm[off : off + hop]

# ── 4 · stream the file ----------------------------------------------------
async def stream_audio(path: str):
    sai = StreamedAudioInput()
    run_task = asyncio.create_task(pipeline.run(sai))

    for chunk in audio_chunks(path):
        await sai.add_audio(chunk)
        await asyncio.sleep(len(chunk) / 24_000)   # real-time pacing

    # just stop pushing; session ends automatically
    await run_task        # wait for pipeline to finish
```

```python
await stream_audio(AUDIO_PATH)
```

## Conclusion

In this notebook you explored multiple ways to convert speech to text with the OpenAI API and the Agents SDK, ranging from simple file uploads to fully-interactive, real-time streaming. Each workflow shines in a different scenario, so pick the one that best matches your product’s needs.

### Key takeaways
- **Match the method to the use-case:**
  • Offline batch jobs → file-based transcription.
  • Near-real-time updates → HTTP-streaming.
  • Conversational, low-latency experiences → WebSocket or Agents SDK.
- **Weigh trade-offs:** latency, implementation effort, supported formats, and session limits all differ by approach.
- **Stay current:** the models and SDK continue to improve; new features ship regularly.

### Next steps
1. Try out the notebook!
2. Integrate your chosen workflow into your application.
3. Send us feedback! Community insights help drive the next round of model upgrades.

## References
* Explore the [Transcriptions API docs](https://platform.openai.com/docs/api-reference/audio).
* Read the [Realtime guide](https://platform.openai.com/docs/guides/realtime?use-case=transcription).
* Explore the [Agents SDK reference](https://openai.github.io/openai-agents-python/).
* Explore the [Agents SDK Voice Pipeline reference](https://openai.github.io/openai-agents-python/voice/)
