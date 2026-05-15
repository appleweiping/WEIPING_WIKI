---
title: "Context Summarization With Realtime Api"
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
  - https://developers.openai.com/cookbook/examples/context_summarization_with_realtime_api
  - https://github.com/openai/openai-cookbook/blob/main/examples/Context_summarization_with_realtime_api.ipynb
---

# Context Summarization With Realtime Api

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/context_summarization_with_realtime_api
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Context_summarization_with_realtime_api.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Context_summarization_with_realtime_api.ipynb
- Source path: `examples/Context_summarization_with_realtime_api.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `a44e3a72309265156c993137d6f16cfbdaa0b0b155ebec41d5d1d5aeee16c606`

## Classification

- Primary category: Realtime / voice / transcription
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Context Summarization with Realtime API 1. Overview Build an end‑to‑end voice bot that listens to your mic, speaks back in real time and summarises long conversations so quality never drops. What You’ll Learn 1. Live microphone streaming → OpenAI Realtime (voice‑to‑voice) endpoint. 2. Instant transcripts & speech playback on every turn. 3. Conversation state...

## What This Teaches

- How to build low-latency speech, transcription, or voice interaction pipelines.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Context Summarization with Realtime API
## 1. Overview
Build an end‑to‑end **voice bot** that listens to your mic, speaks back in real time and **summarises long conversations** so quality never drops.

### What You’ll Learn
1. **Live microphone streaming** → OpenAI *Realtime* (voice‑to‑voice) endpoint.
2. **Instant transcripts & speech playback** on every turn.
3. **Conversation state container** that stores **every** user/assistant message.
4. **Automatic “context trim”** – when the token window becomes very large (configurable), older turns are compressed into a summary.
5. **Extensible design** you can adapt to support customer‑support bots, kiosks, or multilingual assistants.


### Prerequisites

| Requirement | Details |
|-------------|---------|
| **Python ≥ 3.10** | Will ensure that you don't hit any issues |
| **OpenAI API key** | Set `OPENAI_API_KEY` in your shell or paste inline (*not ideal for prod*) |
| Mic + speakers | Grant OS permission if prompted |


**Need help setting up the key?**
> Follow the [official quick‑start guide](https://platform.openai.com/docs/quickstart#step-2-set-your-api-key).


*Notes:*
> 1. gpt-realtime supports a 32k token context window, though in certain use cases, you may notice performance degrade as you stuff more tokens into the context window.
> 2. Token window = all tokens (words and audio tokens) the model currently keeps in memory for the session.x

### One‑liner install (run in a fresh cell)

*New API Parameters:*
> 1. The Realtime API GA has releases a new parameter [`truncation`](https://platform.openai.com/docs/api-reference/realtime-client-events/session/update#realtime-client-events/session/update-session-realtime-session-configuration-truncation). This parameter automatically optimizes context truncation, preserving relevant information while maximizing cache hit rates.

```python
# Run once to install or upgrade dependencies (comment out if already installed)
# !pip install --upgrade openai websockets sounddevice simpleaudio
```

```python
# Standard library imports
import os
import sys
import io
import json
import base64
import pathlib
import wave
from dataclasses import dataclass, field
from typing import List, Literal

# Third-party imports
import asyncio
import numpy as np
import sounddevice as sd         # microphone capture
import simpleaudio               # speaker playback
import websockets                # WebSocket client
import openai                    # OpenAI Python SDK >= 1.14.0
```

```python
# Set your API key safely
openai.api_key = os.getenv("OPENAI_API_KEY", "")
if not openai.api_key:
    raise ValueError("OPENAI_API_KEY not found – please set env var or edit this cell.")
```

## 2. Token Utilisation – Text vs Voice

Large‑token windows are precious, every extra token you use costs latency + money.
For **audio** the input token window increases much faster than for plain text because amplitude, timing, and other acoustic details must be represented.

In practice you’ll often see **≈ 10 ×** more tokens for the *same* sentence in audio versus text.


* gpt-realtime accepts up to **32k tokens** and as the token size increases, instruction adherence can drift.
* Every user/assistant turn consumes tokens → the window **only grows**.
* **Strategy**: Summarise older turns into a single assistant message, keep the last few verbatim turns, and continue.

<img src="../images/text-vs-audio-tokens.png" alt="drawing" width="800"/>

## 3. Helper Functions
The following helper functions will enable us to run the full script.

### 3.1 Conversation State
Unlike HTTP-based Chat Completions, the Realtime API maintains an open, **stateful** session with two key components:

| Component       | Purpose |
|----------------|---------|
| **Session**     | Controls global settings — model, voice, modalities, VAD, etc. |
| **Conversation** | Stores turn-by-turn messages between user and assistant — both audio and text. |

This notebook wraps these components inside a simple `ConversationState` object to keep your logic clean, track history, and manage summarization when context windows fill up.

```python
@dataclass
class Turn:
    """One utterance in the dialogue (user **or** assistant)."""
    role: Literal["user", "assistant"]
    item_id: str                    # Server‑assigned identifier
    text: str | None = None         # Filled once transcript is ready

@dataclass
class ConversationState:
    """All mutable data the session needs — nothing more, nothing less."""
    history: List[Turn] = field(default_factory=list)         # Ordered log
    waiting: dict[str, asyncio.Future] = field(default_factory=dict)  # Pending transcript fetches
    summary_count: int = 0

    latest_tokens: int = 0          # Window size after last reply
    summarising: bool = False       # Guard so we don’t run two summaries at once
```

A quick helper to peek at the transcript:

```python
def print_history(state) -> None:
    """Pretty-print the running transcript so far."""
    print("—— Conversation so far ———————————————")
    for turn in state.history:
        text_preview = (turn.text or "").strip().replace("\n", " ")
        print(f"[{turn.role:<9}] {text_preview}  ({turn.item_id})")
    print("——————————————————————————————————————————")
```

### 3.2 · Streaming Audio
We’ll stream raw PCM‑16 microphone data straight into the Realtime API.

The pipeline is: mic ─► async.Queue ─► WebSocket ─► Realtime API

#### 3.2.1 Capture Microphone Input
We’ll start with a coroutine that:

* Opens the default mic at **24 kHz, mono, PCM‑16** (one of the [format](https://platform.openai.com/docs/api-reference/realtime-sessions/create#realtime-sessions-create-input_audio_format) Realtime accepts).
* Slices the stream into **≈ 40 ms** blocks.
* Dumps each block into an `asyncio.Queue` so another task (next section) can forward it to OpenAI.

```python
async def mic_to_queue(pcm_queue: asyncio.Queue[bytes]) -> None:
    """
    Capture raw PCM‑16 microphone audio and push ~CHUNK_DURATION_MS chunks
    to *pcm_queue* until the surrounding task is cancelled.

    Parameters
    ----------
    pcm_queue : asyncio.Queue[bytes]
        Destination queue for PCM‑16 frames (little‑endian int16).
    """
    blocksize = int(SAMPLE_RATE_HZ * CHUNK_DURATION_MS / 1000)

    def _callback(indata, _frames, _time, status):
        if status:                               # XRuns, device changes, etc.
            print("⚠️", status, file=sys.stderr)
        try:
            pcm_queue.put_nowait(bytes(indata))  # 1‑shot enqueue
        except asyncio.QueueFull:
            # Drop frame if upstream (WebSocket) can’t keep up.
            pass

    # RawInputStream is synchronous; wrap in context manager to auto‑close.
    with sd.RawInputStream(
        samplerate=SAMPLE_RATE_HZ,
        blocksize=blocksize,
        dtype="int16",
        channels=1,
        callback=_callback,
    ):
        try:
            # Keep coroutine alive until cancelled by caller.
            await asyncio.Event().wait()
        finally:
            print("⏹️  Mic stream closed.")
```

#### 3.2.2 Send Audio Chunks to the API

Our mic task is now filling an `asyncio.Queue` with raw PCM‑16 blocks.
Next step: pull chunks off that queue, **base‑64 encode** them (the protocol requires JSON‑safe text), and ship each block to the Realtime WebSocket as an `input_audio_buffer.append` event.

```python
# Helper function to encode audio chunks in base64
b64 = lambda blob: base64.b64encode(blob).decode()

async def queue_to_websocket(pcm_queue: asyncio.Queue[bytes], ws):
    """Read audio chunks from queue and send as JSON events."""
    try:
        while (chunk := await pcm_queue.get()) is not None:
            await ws.send(json.dumps({
                "type": "input_audio_buffer.append",
                "audio": b64(chunk),
            }))
    except websockets.ConnectionClosed:
        print("WebSocket closed – stopping uploader")
```

#### 3.2.3 Handle Incoming Events
Once audio reaches the server, the Realtime API pushes a stream of JSON events back over the **same** WebSocket.
Understanding these events is critical for:

* Printing live transcripts
* Playing incremental audio back to the user
* Keeping an accurate [`Conversation State`](https://platform.openai.com/docs/api-reference/realtime-server-events/conversation/created) so context trimming works later


| Event type | When it arrives | Why it matters | Typical handler logic |
|------------|-----------------|---------------|-----------------------|
| **`session.created`** | Immediately after the WebSocket handshake | Confirms the session is open and provides the `session.id`. | Log the ID for traceability and verify the connection. |
| **`session.updated`** | After you send a `session.update` call | Acknowledges that the server applied new session settings. | Inspect the echoed settings and update any local cache. |
| **`conversation.item.created`** (user) | A few ms after the user stops speaking (client VAD fires) | Reserves a timeline slot; transcript may still be **`null`**. | Insert a *placeholder* user turn in `state.history` marked “pending transcript”. |
| **`conversation.item.retrieved`** | ~100 – 300 ms later, once audio transcription is complete | Supplies the final user transcript (with timing). | Replace the placeholder with the transcript and print it if desired. |
| **`response.audio.delta`** | Every 20 – 60 ms while the assistant is speaking | Streams PCM‑16 audio chunks (and optional incremental text). | Buffer each chunk and play it; optionally show partial text in the console. |
| **`response.done`** | After the assistant’s last token | Signals both audio & text are complete; includes usage stats. | Finalize the assistant turn, update `state.latest_tokens`, and log usage. |
| **`conversation.item.deleted`** | Whenever you prune with `conversation.item.delete` | Confirms a turn was removed, freeing tokens on the server. | Mirror the deletion locally so your context window matches the server’s. |

### 3.3 Detect When to Summarise
The Realtime model keeps a **large 32 k‑token window**, but quality can drift long before that limit as you stuff more context into the model.

Our goal: **auto‑summarise** once the running window nears a safe threshold (default **2 000 tokens** for the notebook), then prune the superseded turns both locally *and* server‑side.

We monitor latest_tokens returned in `response.done`. When it exceeds SUMMARY_TRIGGER and we have more than KEEP_LAST_TURNS, we spin up a background summarization coroutine.

We compress everything except the last 2 turns into a single French paragraph, then:

1. Insert that paragraph as a new assistant message at the top of the conversation.

2. Delete the message items that was used for the summary.

We will later ask the Voice agent what language was the summary to test if the Summary insertion into Realtime API Conversation Context was successful.

```python
async def run_summary_llm(text: str) -> str:
    """Call a lightweight model to summarise `text`."""
    resp = await asyncio.to_thread(lambda: openai.chat.completions.create(
        model=SUMMARY_MODEL,
        temperature=0,
        messages=[
            {"role": "system", "content": "Summarise in French the following conversation "
                            "in one concise paragraph so it can be used as "
                            "context for future dialogue."},
            {"role": "user", "content": text},
        ],
    ))
    return resp.choices[0].message.content.strip()
```

Important implementation detail:
- The summary is appended as a SYSTEM message rather than an ASSISTANT message. Testing revealed that, during extended conversations, using ASSISTANT messages for summaries can cause the model to mistakenly switch from audio responses to text responses. By using SYSTEM messages for summaries (which can also include additional custom instructions), we clearly signal to the model that these are context-setting instructions, preventing it from incorrectly adopting the modality of the ongoing user-assistant interaction.

```python
async def summarise_and_prune(ws, state):
    """Summarise old turns, delete them server‑side, and prepend a single summary
    turn locally + remotely."""
    state.summarising = True
    print(
        f"⚠️  Token window ≈{state.latest_tokens} ≥ {SUMMARY_TRIGGER}. Summarising…",
    )
    old_turns, recent_turns = state.history[:-KEEP_LAST_TURNS], state.history[-KEEP_LAST_TURNS:]
    convo_text = "\n".join(f"{t.role}: {t.text}" for t in old_turns if t.text)

    if not convo_text:
        print("Nothing to summarise (transcripts still pending).")
        state.summarising = False

    summary_text = await run_summary_llm(convo_text) if convo_text else ""
    state.summary_count += 1
    summary_id = f"sum_{state.summary_count:03d}"
    state.history[:] = [Turn("assistant", summary_id, summary_text)] + recent_turns

    print_history(state)

    # Create summary on server
    await ws.send(json.dumps({
        "type": "conversation.item.create",
        "previous_item_id": "root",
        "item": {
            "id": summary_id,
            "type": "message",
            "role": "system",
            "content": [{"type": "input_text", "text": summary_text}],
        },
    }))

    # Delete old items
    for turn in old_turns:
        await ws.send(json.dumps({
            "type": "conversation.item.delete",
            "item_id": turn.item_id,
        }))

    print(f"✅ Summary inserted ({summary_id})")

    state.summarising = False
```

The following function lets us poll for transcripts over time. This is useful in cases where the user's audio hasn't been transcribed immediately, so we can retrieve the final result later.

```python
async def fetch_full_item(
    ws, item_id: str, state: ConversationState, attempts: int = 1
):
    """
    Ask the server for a full conversation item; retry up to 5× if the
    transcript field is still null.  Resolve the waiting future when done.
    """
    # If there is already a pending fetch, just await it
    if item_id in state.waiting:
        return await state.waiting[item_id]

    fut = asyncio.get_running_loop().create_future()
    state.waiting[item_id] = fut

    await ws.send(json.dumps({
        "type": "conversation.item.retrieve",
        "item_id": item_id,
    }))
    item = await fut

    # If transcript still missing retry (max 5×)
    if attempts < 5 and not item.get("content", [{}])[0].get("transcript"):
        await asyncio.sleep(0.4 * attempts)
        return await fetch_full_item(ws, item_id, state, attempts + 1)

    # Done – remove the marker
    state.waiting.pop(item_id, None)
    return item
```

## 4. End‑to‑End Workflow Demonstration

Run the two cells below to launch an interactive session. Interrupt the cell stop recording.

> **Note:**
> This notebook uses `SUMMARY_TRIGGER = 2000` and `KEEP_LAST_TURNS = 2` to make summarization easier to demo quickly.
> In production, you should tune these values based on your application's needs.
> - A typical `SUMMARY_TRIGGER` falls between **20,000–32,000 tokens**, depending on how performance degrades with larger context for your use case.

```python
# Audio/config knobs
SAMPLE_RATE_HZ    = 24_000   # Required by pcm16
CHUNK_DURATION_MS = 40       # chunk size for audio capture
BYTES_PER_SAMPLE  = 2        # pcm16 = 2 bytes/sample
SUMMARY_TRIGGER   = 2_000    # Summarise when context ≥ this
KEEP_LAST_TURNS   = 2       # Keep these turns verbatim
SUMMARY_MODEL     = "gpt-4o-mini"  # Cheaper, fast summariser
```

```python
# --------------------------------------------------------------------------- #
# Realtime session                                                          #
# --------------------------------------------------------------------------- #
async def realtime_session(model="gpt-realtime", voice="shimmer", enable_playback=True):
    """
    Main coroutine: connects to the Realtime endpoint, spawns helper tasks,
    and processes incoming events in a big async‑for loop.
    """
    state = ConversationState()  # Reset state for each run

    pcm_queue: asyncio.Queue[bytes] = asyncio.Queue()
    assistant_audio: List[bytes] = []

    # ----------------------------------------------------------------------- #
    # Open the WebSocket connection to the Realtime API                       #
    # ----------------------------------------------------------------------- #
    url = f"wss://api.openai.com/v1/realtime?model={model}"
    headers = {"Authorization": f"Bearer {openai.api_key}"}

    async with websockets.connect(url, extra_headers=headers, max_size=1 << 24) as ws:
        # ------------------------------------------------------------------- #
        # Wait until server sends session.created                             #
        # ------------------------------------------------------------------- #
        while json.loads(await ws.recv())["type"] != "session.created":
            pass
        print("session.created ✅")

        # ------------------------------------------------------------------- #
        # Configure session: voice, modalities, audio formats, transcription  #
        # ------------------------------------------------------------------- #
        await ws.send(json.dumps({
            "type": "session.update",
            "session": {
                "type": "realtime",
                model: "gpt-realtime",
                "voice": voice,
                "modalities": ["audio", "text"],
                "input_audio_format": "pcm16",
                "output_audio_format": "pcm16",
                "input_audio_transcription": {"model": "gpt-4o-transcribe"},
            },
        }))

        # ------------------------------------------------------------------- #
        # Launch background tasks: mic capture → queue → websocket            #
        # ------------------------------------------------------------------- #
        mic_task = asyncio.create_task(mic_to_queue(pcm_queue))
        upl_task = asyncio.create_task(queue_to_websocket(pcm_queue, ws))

        print("🎙️ Speak now (Ctrl‑C to quit)…")

        try:
            # ------------------------------------------------------------------- #
            # Main event loop: process incoming events from the websocket         #
            # ------------------------------------------------------------------- #
            async for event_raw in ws:
                event = json.loads(event_raw)
                etype = event["type"]

                # --------------------------------------------------------------- #
                # User just spoke ⇢ conversation.item.created (role = user)        #
                # --------------------------------------------------------------- #
                if etype == "conversation.item.created" and event["item"]["role"] == "user":
                    item = event["item"]
                    text = None
                    if item["content"]:
                        text = item["content"][0].get("transcript")

                    state.history.append(Turn("user", event["item"]["id"], text))

                    # If transcript not yet available, fetch it later
                    if text is None:
                        asyncio.create_task(fetch_full_item(ws, item["id"], state))

                # --------------------------------------------------------------- #
                # Transcript fetched ⇢ conversation.item.retrieved                 #
                # --------------------------------------------------------------- #
                elif etype == "conversation.item.retrieved":
                    content = event["item"]["content"][0]
                    # Fill missing transcript in history
                    for t in state.history:
                        if t.item_id == event["item"]["id"]:
                            t.text = content.get("transcript")
                            break

                # --------------------------------------------------------------- #
                # Assistant audio arrives in deltas                               #
                # --------------------------------------------------------------- #
                elif etype == "response.audio.delta":
                    assistant_audio.append(base64.b64decode(event["delta"]))

                # --------------------------------------------------------------- #
                # Assistant reply finished ⇢ response.done                        #
                # --------------------------------------------------------------- #
                elif etype == "response.done":
                    for item in event["response"]["output"]:
                        if item["role"] == "assistant":
                            txt = item["content"][0]["transcript"]
                            state.history.append(Turn("assistant", item["id"], txt))
                            # print(f"\n🤖 {txt}\n")
                    state.latest_tokens = event["response"]["usage"]["total_tokens"]
                    print(f"—— response.done  (window ≈{state.latest_tokens} tokens) ——")
                    print_history(state)

                    # Fetch any still‑missing user transcripts
                    for turn in state.history:
                        if (turn.role == "user"
                            and turn.text is None
                            and turn.item_id not in state.waiting):
                            asyncio.create_task(
                                fetch_full_item(ws, turn.item_id, state)
                            )

                    # Playback collected audio once reply completes
                    if enable_playback and assistant_audio:
                        simpleaudio.play_buffer(b"".join(assistant_audio), 1, BYTES_PER_SAMPLE, SAMPLE_RATE_HZ)
                        assistant_audio.clear()

                    # Summarise if context too large – fire in background so we don't block dialogue
                    if state.latest_tokens >= SUMMARY_TRIGGER and len(state.history) > KEEP_LAST_TURNS and not state.summarising:
                        asyncio.create_task(summarise_and_prune(ws, state))

        except KeyboardInterrupt:
            print("\nStopping…")
        finally:
            mic_task.cancel()
            await pcm_queue.put(None)
            await upl_task
```

```python
# Run the realtime session (this cell blocks until you stop it)
await realtime_session()
```

```raw
session.created ✅
🎙️ Speak now (Ctrl‑C to quit)…
—— response.done  (window ≈979 tokens) ——
—— Conversation so far ———————————————
[user     ] Can you tell me a quick story?  (item_BTuMOcpUqp8qknKhLzlkA)
[assistant] Once upon a time, in a cozy little village, there was a cat named Whiskers who was always getting into trouble. One sunny day, Whiskers found a mysterious glowing stone in the garden. Curious, he pawed at it, and poof! The stone granted him the ability to talk to birds. Whiskers and his new bird friends had grand adventures, solving mysteries and exploring the village. And from that day on, Whiskers was known as the most adventurous cat in the village. The end.  (item_BTuMPRWxqpv0ph6QM46DK)
——————————————————————————————————————————
—— response.done  (window ≈2755 tokens) ——
—— Conversation so far ———————————————
[user     ] Can you tell me a quick story?  (item_BTuMOcpUqp8qknKhLzlkA)
[assistant] Once upon a time, in a cozy little village, there was a cat named Whiskers who was always getting into trouble. One sunny day, Whiskers found a mysterious glowing stone in the garden. Curious, he pawed at it, and poof! The stone granted him the ability to talk to birds. Whiskers and his new bird friends had grand adventures, solving mysteries and exploring the village. And from that day on, Whiskers was known as the most adventurous cat in the village. The end.  (item_BTuMPRWxqpv0ph6QM46DK)
[user     ] Can you tell me three extremely funny stories?  (item_BTuNN64LdULM21OyC4vzN)
[assistant] Sure, let's dive into some giggle-worthy tales:  **Story One:** There was a forgetful baker named Benny who baked a hundred cakes for a big wedding. But on the big day, he forgot where he put them! The entire town joined in to find the missing cakes, only to discover Benny had stored them in his neighbor's garage, thinking it was his pantry. The wedding turned into a town-wide cake feast!  **Story Two:** A mischievous dog named Sparky loved to play pranks. One day, he swapped his owner's phone with a squeaky toy, causing a hilarious mix-up of barks, squeaks, and confused calls. Sparky's owner ended up having a full conversation with the mailman, all in squeaks!  **Story Three:** In a small town, a parrot named Polly became a local celebrity for reciting tongue twisters. One day, Polly challenged the mayor to a tongue twister duel. The mayor, tongue-tied and laughing, declared Polly the official town jester. Polly squawked with pride, and the town rang with laughter for days.  (item_BTuNNpNxki5ynSQ5c3Xsa)
——————————————————————————————————————————
⚠️  Token window ≈2755 ≥ 2000. Summarising…
—— Conversation so far ———————————————
[assistant] L'utilisateur a demandé une histoire rapide, et l'assistant a raconté celle d'un chat nommé Whiskers qui, après avoir trouvé une pierre mystérieuse dans son jardin, a obtenu le pouvoir de parler aux oiseaux. Avec ses nouveaux amis oiseaux, Whiskers a vécu de grandes aventures, résolvant des mystères et explorant le village, devenant ainsi le chat le plus aventurier du village.  (sum_001)
[user     ] Can you tell me three extremely funny stories?  (item_BTuNN64LdULM21OyC4vzN)
[assistant] Sure, let's dive into some giggle-worthy tales:  **Story One:** There was a forgetful baker named Benny who baked a hundred cakes for a big wedding. But on the big day, he forgot where he put them! The entire town joined in to find the missing cakes, only to discover Benny had stored them in his neighbor's garage, thinking it was his pantry. The wedding turned into a town-wide cake feast!  **Story Two:** A mischievous dog named Sparky loved to play pranks. One day, he swapped his owner's phone with a squeaky toy, causing a hilarious mix-up of barks, squeaks, and confused calls. Sparky's owner ended up having a full conversation with the mailman, all in squeaks!  **Story Three:** In a small town, a parrot named Polly became a local celebrity for reciting tongue twisters. One day, Polly challenged the mayor to a tongue twister duel. The mayor, tongue-tied and laughing, declared Polly the official town jester. Polly squawked with pride, and the town rang with laughter for days.  (item_BTuNNpNxki5ynSQ5c3Xsa)
——————————————————————————————————————————
✅ Summary inserted (sum_001)
—— response.done  (window ≈2147 tokens) ——
—— Conversation so far ———————————————
[assistant] L'utilisateur a demandé une histoire rapide, et l'assistant a raconté celle d'un chat nommé Whiskers qui, après avoir trouvé une pierre mystérieuse dans son jardin, a obtenu le pouvoir de parler aux oiseaux. Avec ses nouveaux amis oiseaux, Whiskers a vécu de grandes aventures, résolvant des mystères et explorant le village, devenant ainsi le chat le plus aventurier du village.  (sum_001)
[user     ] Can you tell me three extremely funny stories?  (item_BTuNN64LdULM21OyC4vzN)
[assistant] Sure, let's dive into some giggle-worthy tales:  **Story One:** There was a forgetful baker named Benny who baked a hundred cakes for a big wedding. But on the big day, he forgot where he put them! The entire town joined in to find the missing cakes, only to discover Benny had stored them in his neighbor's garage, thinking it was his pantry. The wedding turned into a town-wide cake feast!  **Story Two:** A mischievous dog named Sparky loved to play pranks. One day, he swapped his owner's phone with a squeaky toy, causing a hilarious mix-up of barks, squeaks, and confused calls. Sparky's owner ended up having a full conversation with the mailman, all in squeaks!  **Story Three:** In a small town, a parrot named Polly became a local celebrity for reciting tongue twisters. One day, Polly challenged the mayor to a tongue twister duel. The mayor, tongue-tied and laughing, declared Polly the official town jester. Polly squawked with pride, and the town rang with laughter for days.  (item_BTuNNpNxki5ynSQ5c3Xsa)
[user     ]   (item_BTuPLaCv8ATdIwAQ2rLgO)
[assistant] Sure! The first summary I provided between us was in French.  (item_BTuPLa7BaSQToGCVOmfBK)
```

---
We had a conversation with our Voice AI. After several turns, the total token count reached SUMMARY_MAX, which triggered the conversation summarization step. This generated a summary of the earlier messages.

Since there were N = 4 total messages, we summarized the first N - 2 = 2 messages:
```txt
—— Conversation so far ———————————————
[user     ] Can you tell me a quick story?  (item_BTuMOcpUqp8qknKhLzlkA)
[assistant] Once upon a time, in a cozy little village, there was a cat named Whiskers who was always getting into trouble. One sunny day, Whiskers found a mysterious glowing stone in the garden. Curious, he pawed at it, and poof! The stone granted him the ability to talk to birds. Whiskers and his new bird friends had grand adventures, solving mysteries and exploring the village. And from that day on, Whiskers was known as the most adventurous cat in the village. The end.  (item_BTuMPRWxqpv0ph6QM46DK)
```

We then created a summary in French and inserted it into the conversation history using the root: true flag. This ensured the summary appeared as the first message in the conversation. After that, we deleted the original items, using `"type": "conversation.item.delete"`, that were summarized.

To validate the summary insertion, we asked the Voice AI what language the summary was in. It correctly responded:

```txt
[assistant] Sure! The first summary I provided between us was in French.  (item_BTuPLa7BaSQToGCVOmfBK)
```

## 5 · Real‑World Applications

Context summarisation can be useful for **long‑running voice experiences**.
Here are a use case ideas:

| Use‑case | Added Value | Why Useful |
|----------|-------------|------------|
| **Customer‑support voicebot** | 24/7 natural phone tree; auto‑generate ticket summaries | Summarizes long customer calls for efficient handoff and record-keeping, reducing agent workload and improving response quality. |
| **Language tutor** | Real‑time conversation practice with corrective feedback | Helps track learner progress and highlights recurring mistakes, enabling personalized feedback and more effective language acquisition. |
| **AI therapist / coach** | Safe, always‑available listener that remembers sessions | Maintains continuity across sessions by recalling key topics and emotional tone, supporting a more empathetic and effective experience. |
| **Meeting assistant** | Live transcripts + concise action‑item recap in Slack | Distills lengthy meetings into actionable summaries, saving team members time and ensuring important points are not missed. |

## 6 · Next Steps & Further Reading
Try out the notebook and try integrating context summary into your application.

Few things you can try:
| Try this… | What you’ll learn |
|-----------|------------------|
| **A/B test summarisation**<br/>Run your eval suite with summarisation *on* vs *off*. | Whether trimming actually improves quality for your domain—and how it affects latency & cost. |
| **Swap summary styles**<br/>Change the system prompt to bullet points, JSON, English vs French, etc. | Which format the downstream assistant absorbs best; how language choice influences follow‑up answers. |
| **Vary thresholds**<br/>Play with `SUMMARY_TRIGGER_TOKENS` (2 k → 8 k). | The sweet spot between model drift and summarisation overhead. |
| **Cost tracing**<br/>Log `usage.total_tokens` before/after summarisation. | Concrete ROI: token savings per hour of conversation. |


### Resources:
- [OpenAI Realtime Guide](https://platform.openai.com/docs/guides/realtime)
- [OpenAI Realtime Conversations](https://platform.openai.com/docs/guides/realtime-conversations)
- [OpenAI Realtime API Reference](https://platform.openai.com/docs/api-reference/realtime)
- [Voice AI and Voice Agents](https://voiceaiandvoiceagents.com/)
