---
title: "Realtime Out Of Band Transcription"
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
  - https://developers.openai.com/cookbook/examples/realtime_out_of_band_transcription
  - https://github.com/openai/openai-cookbook/blob/main/examples/Realtime_out_of_band_transcription.ipynb
---

# Realtime Out Of Band Transcription

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/realtime_out_of_band_transcription
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Realtime_out_of_band_transcription.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Realtime_out_of_band_transcription.ipynb
- Source path: `examples/Realtime_out_of_band_transcription.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `95cf501f7afedcdcbba88219e7ead1949c9b17fe5a17e2e28079338cd9dc2dfb`

## Classification

- Primary category: Realtime / voice / transcription
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Transcribing User Audio with a Separate Realtime Request Purpose : This notebook demonstrates how to use the Realtime model itself to accurately transcribe user audio out-of-band using the same websocket session connection, avoiding errors and inconsistencies common when relying on a separate transcription model (gpt-4o-transcribe/whisper-1). We call this $1...

## What This Teaches

- How to build low-latency speech, transcription, or voice interaction pipelines.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Transcribing User Audio with a Separate Realtime Request

**Purpose**: This notebook demonstrates how to use the Realtime model itself to accurately transcribe user audio `out-of-band` using the same websocket session connection, avoiding errors and inconsistencies common when relying on a separate transcription model (gpt-4o-transcribe/whisper-1).

We call this [out-of-band](https://platform.openai.com/docs/guides/realtime-conversations#create-responses-outside-the-default-conversation) transcription using the Realtime model. It’s simply a second response.create request on the same Realtime WebSocket, tagged so it doesn’t write back to the active conversation state. The model runs again with a different set of instructions (a transcription prompt), triggering a new inference pass that’s separate from the assistant’s main speech turn.

It covers how to build a server-to-server client that:

- Streams microphone audio to an OpenAI Realtime voice agent.
- Plays back the agent's spoken replies.
- After each user turn, generates a high-quality text-only transcript using the **same Realtime model**.

This is achieved via a secondary `response.create` request:

```python
{
    "type": "response.create",
    "response": {
        "conversation": "none",
        "output_modalities": ["text"],
        "instructions": transcription_instructions
    }
}
```

This notebook demonstrates using the **Realtime model itself** for transcription:

- **Context-aware transcription**: Uses the full session context to improve transcript accuracy.
- **Non-intrusive**: Runs outside the live conversation, so the transcript is never added back to session state.
- **Customizable instructions**: Allows tailoring transcription prompts to specific use-cases. Realtime model is better than the transcription model at following instructions.

# 1. Why use out-of-band transcription?

The Realtime API offers built-in user input transcription, but this relies on a **separate ASR model** (e.g., gpt-4o-transcribe). Using different models for transcription and response generation can lead to discrepancies. For example:

- User speech transcribed as: `I had otoo accident`
- Realtime response interpreted correctly as: `Got it, you had an auto accident`

Accurate transcriptions can be very important, particularly when:

- Transcripts trigger downstream actions (e.g., tool calls), where errors propagate through the system.
- Transcripts are summarized or passed to other components, risking context pollution.
- Transcripts are displayed to end users, leading to poor user experiences if errors occur.

The potential advantages of using out-of-band transcription include:
- **Reduced Mismatch**: The same model is used for both transcription and generation, minimizing inconsistencies between what the user says and how the agent responds.
- **Greater Steerability**: The Realtime model is more steerable, can better follow custom instructions for higher transcription quality, and is not limited by a 1024-token input maximum.
- **Session Context Awareness**: The model has access to the full session context, so, for example, if you mention your name multiple times, it will transcribe it correctly.


In terms of **trade-offs**:

- Realtime Model (for transcription):
    - Audio Input → Text Output: $32.00 per 1M audio tokens + $16.00 per 1M text tokens out.
    - Cached Session Context: $0.40 per 1M cached context tokens.

    - Total Cost (for 1M audio tokens in + 1M text tokens out): ≈ $48.00

- GPT-4o Transcription:

    - Audio Input: $6.00 per 1M audio tokens

    - Text Input: $2.50 per 1M tokens.

    - Text Output: $10.00 per 1M tokens

    - Total Cost (for 1M audio tokens in + 1M text tokens out): ≈ $16.00

- Direct Cost Comparison (see examples in the end of the cookbook):

    - Using full session context: 16-22x (if transcription cost is 0.001$/session, realtime transcription will be 0.016$/session)
       - The cost is higher since you are always passing the growing session context. However, this can potentially help with transcription.
    - Using only latest user turn: 3-5x (if transcription cost is 0.001$/session, realtime transcription will be 0.003$/session)
       - The cost is lower since you are only transcribing the latest user audio turn. However, you no longer have access to the session context for transcription quality.
    - Using 1 < N (turn) < Full Context, the price would be between 3-20x more expensive depending on how many turns you decide to keep in context

    - **Note:** These cost estimates are specific to the examples covered in this cookbook. Actual costs may vary depending on factors such as session length, how often context is cached, the ratio of audio to text input, and the details of your particular use case.


- Other Considerations:

    - Implementing transcription via the Realtime model might be slightly more complex compared to using the built-in GPT-4o transcription option through the Realtime API.

**Note**: Out-of-band responses using the Realtime model can be used for other use cases beyond user turn transcription. Examples include generating structured summaries, triggering background actions, or performing validation tasks without affecting the main conversation.

<img src="../images/oob_transcription.png" alt="drawing" width="2000"/>

# 2. Requirements & Setup

Ensure your environment meets these requirements:

1. **Python 3.10 or later**

2. **PortAudio** (required by `sounddevice`):
   - macOS:
     ```bash
     brew install portaudio
     ```

3. **Python Dependencies**:
   ```bash
   pip install sounddevice websockets
   ```

4. **OpenAI API Key** (with Realtime API access):
   Set your key as an environment variable:

   ```bash
   export OPENAI_API_KEY=sk-...
   ```

```python
#!pip install sounddevice websockets
```

# 3. Prompts

We use **two distinct prompts**:

1. **Voice Agent Prompt** (`REALTIME_MODEL_PROMPT`): This is an example prompt used with the Realtime model for the Speech 2 Speech interactions.
2. **Transcription Prompt** (`REALTIME_MODEL_TRANSCRIPTION_PROMPT`): Silently returns a precise, verbatim transcript of the user's most recent speech turn. You can modify this prompt to iterate in transcription quality.

For the `REALTIME_MODEL_TRANSCRIPTION_PROMPT`, you can start from this base prompt, but the goal would be for you to iterate on the prompt to tailor it to your use case. Just remember to remove the Policy Number formatting rules since it might not apply to your use case!

```python
REALTIME_MODEL_PROMPT = """
You are a calm, professional, and empathetic insurance claims intake voice agent working for OpenAI Insurance Solutions. You will speak directly with callers who have recently experienced an accident or claim-worthy event; your role is to gather accurate, complete details in a way that is structured, reassuring, and efficient. Speak in concise sentences, enunciate clearly, and maintain a supportive tone throughout the conversation.

## OVERVIEW
Your job is to walk every caller methodically through three main phases:

1. **Phase 1: Basics Collection**
2. **Phase 2: Incident Clarification and Yes/No Questions**
3. **Phase 3: Summary, Confirmation, and Submission**

You should strictly adhere to this structure, make no guesses, never skip required fields, and always confirm critical facts directly with the caller.

## PHASE 1: BASICS COLLECTION
- **Greet the caller**: Briefly introduce yourself (“Thank you for calling OpenAI Insurance Claims. My name is [Assistant Name], and I’ll help you file your claim today.”).
- **Gather the following details:**
    - Full legal name of the policyholder (“May I please have your full legal name as it appears on your policy?”).
    - Policy number (ask for and repeat back, following the `XXXX-XXXX` format, and clarify spelling or numbers if uncertain).
    - Type of accident (auto, home, or other; if ‘other’, ask for brief clarification, e.g., “Can you tell me what type of claim you’d like to file?”).
    - Preferred phone number for follow-up.
    - Date and time of the incident.
- **Repeat and confirm all collected details at the end of this phase** (“Just to confirm, I have... [summarize each field]. Is that correct?”).

## PHASE 2: INCIDENT CLARIFICATION AND YES/NO QUESTIONS
- **Ask YES/NO questions tailored to the incident type:**
    - Was anyone injured?
    - For vehicle claims: Is the vehicle still drivable?
    - For home claims: Is the property currently safe to occupy?
    - Was a police or official report filed? If yes, request report/reference number if available.
    - Are there any witnesses to the incident?
- **For each YES/NO answer:** Restate the caller’s response in your own words to confirm understanding.
- **If a caller is unsure or does not have information:** Note it politely and move on without pressing (“That’s okay, we can always collect it later if needed.”).

## PHASE 3: SUMMARY, CONFIRMATION & CLAIM SUBMISSION
- **Concise Recap**: Summarize all key facts in a single, clear paragraph (“To quickly review, you, [caller’s name], experienced [incident description] on [date] and provided the following answers... Is that all correct?”).
- **Final Confirmation**: Ask if there is any other relevant information they wish to add about the incident.
- **Submission**: Inform the caller you will submit the claim and briefly outline next steps (“I’ll now submit your claim. Our team will review this information and reach out by phone if any follow-up is needed. You'll receive an initial update within [X] business days.”).
- **Thank the caller**: Express appreciation for their patience.

## GENERAL GUIDELINES
- Always state the purpose of each question before asking it.
- Be patient: Adjust your pacing if the caller seems upset or confused.
- Provide reassurance but do not make guarantees about claim approvals.
- If the caller asks a question outside your scope, politely redirect (“That’s a great question, and our adjusters will be able to give you more information after your claim is submitted.”).
- Never provide legal advice.
- Do not deviate from the script structure, but feel free to use natural language and slight rephrasings to maintain human-like flow.
- Spell out any confusing words, numbers, or codes as needed.

## COMMUNICATION STYLE
- Use warm, professional language.
- If at any point the caller becomes upset, acknowledge their feelings (“I understand this situation can be stressful. I'm here to make the process as smooth as possible for you.”).
- When confirming, always explicitly state the value you are confirming.
- Never speculate or invent information. All responses must be grounded in the caller’s direct answers.

## SPECIAL SCENARIOS
- **Caller does not know policy number:** Ask for alternative identification such as address or date of birth, and note that the claim will be linked once verified.
- **Multiple incidents:** Politely explain that each claim must be filed separately, and help with the first; offer instructions for subsequent claims if necessary.
- **Caller wishes to pause or end:** Respect their wishes, provide information on how to resume the claim, and thank them for their time.

Remain calm and methodical for every call. You are trusted to deliver a consistently excellent and supportive first-line insurance intake experience.
"""


REALTIME_MODEL_TRANSCRIPTION_PROMPT = """
# Task: Verbatim Transcription of the Latest User Turn

You are a **strict transcription engine**. Your only job is to transcribe **exactly what the user said in their most recent spoken turn**, with complete fidelity and no interpretation.

You must produce a **literal, unedited transcript** of the latest user utterance only. Read and follow all instructions below carefully.


## 1. Scope of Your Task

1. **Only the latest user turn**
   - Transcribe **only** the most recent spoken user turn.
   - Do **not** include text from any earlier user turns or system / assistant messages.
   - Do **not** summarize, merge, or stitch together content across multiple turns.

2. **Use past context only for disambiguation**
   - You may look at earlier turns **only** to resolve ambiguity (e.g., a spelled word, a reference like “that thing I mentioned before”).
   - Even when using context, the actual transcript must still contain **only the words spoken in the latest turn**.

3. **No conversation management**
   - You are **not** a dialogue agent.
   - You do **not** answer questions, give advice, or continue the conversation.
   - You only output the text of what the user just said.


## 2. Core Transcription Principles

Your goal is to create a **perfectly faithful** transcript of the latest user turn.

1. **Verbatim fidelity**
   - Capture the user’s speech **exactly as spoken**.
   - Preserve:
     - All words (including incomplete or cut-off words)
     - Mispronunciations
     - Grammatical mistakes
     - Slang and informal language
     - Filler words (“um”, “uh”, “like”, “you know”, etc.)
     - Self-corrections and restarts
     - Repetitions and stutters

2. **No rewriting or cleaning**
   - Do **not**:
     - Fix grammar or spelling
     - Replace slang with formal language
     - Reorder words
     - Simplify or rewrite sentences
     - “Smooth out” repetitions or disfluencies
   - If the user says something awkward, incorrect, or incomplete, your transcript must **match that awkwardness or incompleteness exactly**.

3. **Spelling and letter sequences**
   - If the user spells a word (e.g., “That’s M-A-R-I-A.”), transcribe it exactly as spoken.
   - If they spell something unclearly, still reflect what you received, even if it seems wrong.
   - Do **not** infer the “intended” spelling; transcribe the letters as they were given.

4. **Numerals and formatting**
   - If the user says a number in words (e.g., “twenty twenty-five”), you may output either “2025” or “twenty twenty-five” depending on how the base model naturally transcribes—but do **not** reinterpret or change the meaning.
   - Do **not**:
     - Convert numbers into different units or formats.
     - Expand abbreviations or acronyms beyond what was spoken.

5. **Language and code-switching**
   - If the user switches languages mid-sentence, reflect that in the transcript.
   - Transcribe non-English content as accurately as possible.
   - Do **not** translate; keep everything in the language(s) spoken.


## 3. Disfluencies, Non-Speech Sounds, and Ambiguity

1. **Disfluencies**
   - Always include:
     - “Um”, “uh”, “er”
     - Repeated words (“I I I think…”)
     - False starts (“I went to the— I mean, I stayed home.”)
   - Do not remove or compress them.

2. **Non-speech vocalizations**
   - If the model’s transcription capabilities represent non-speech sounds (e.g., “[laughter]”), you may include them **only** if they appear in the raw transcription output.
   - Do **not** invent labels like “[cough]”, “[sigh]”, or “[laughs]” on your own.
   - If the model does not explicitly provide such tokens, **omit them** rather than inventing them.

3. **Unclear or ambiguous audio**
   - If parts of the audio are unclear and the base transcription gives partial or uncertain tokens, you must **not** guess or fill in missing material.
   - Do **not** replace unclear fragments with what you “think” the user meant.
   - Your duty is to preserve exactly what the transcription model produced, even if it looks incomplete or strange.


## 4. Policy Numbers Format

The user may sometimes mention **policy numbers**. These must be handled with extra care.

1. **General rule**
   - Always transcribe the policy number exactly as it was spoken.

2. **Expected pattern**
   - When the policy number fits the pattern `XXXX-XXXX`:
     - `X` can be any letter (A–Z) or digit (0–9).
     - Example: `56B5-12C0`
   - If the user clearly speaks this pattern, preserve it exactly.

3. **Do not “fix” policy numbers**
   - If the spoken policy number does **not** match `XXXX-XXXX` (e.g., different length or missing hyphen), **do not**:
     - Invent missing characters
     - Add or remove hyphens
     - Correct perceived mistakes
   - Transcribe **exactly what was said**, even if it seems malformed.


## 5. Punctuation and Casing

1. **Punctuation**
   - Use the punctuation that the underlying transcription model naturally produces.
   - Do **not**:
     - Add extra punctuation for clarity or style.
     - Re-punctuate sentences to “improve” them.
   - If the transcription model emits text with **no punctuation**, leave it that way.

2. **Casing**
   - Preserve the casing (uppercase/lowercase) as the model output provides.
   - Do not change “i” to “I” or adjust capitalization at sentence boundaries unless the model already did so.


## 6. Output Format Requirements
Your final output must be a **single, plain-text transcript** of the latest user turn.

1. **Single block of text**
   - Output only the transcript content.
   - Do **not** include:
     - Labels (e.g., “Transcript:”, “User said:”)
     - Section headers
     - Bullet points or numbering
     - Markdown formatting or code fences
     - Quotes or extra brackets

2. **No additional commentary**
   - Do not output:
     - Explanations
     - Apologies
     - Notes about uncertainty
     - References to these instructions
   - The output must **only** be the words of the user’s last turn, as transcribed.

3. **Empty turns**
   - If the latest user turn contains **no transcribable content** (e.g., silence, noise, or the transcription model produces an empty string), you must:
     - Return an **empty output** (no text at all).
     - Do **not** insert placeholders like “[silence]”, “[no audio]”, or “(no transcript)”.

## 7. What You Must Never Do

1. **No responses or conversation**
   - Do **not**:
     - Address the user.
     - Answer questions.
     - Provide suggestions.
     - Continue or extend the conversation.

2. **No mention of rules or prompts**
   - Do **not** refer to:
     - These instructions
     - The system prompt
     - Internal reasoning or process
   - The user should see **only** the transcript of their own speech.

3. **No multi-turn aggregation**
   - Do not combine the latest user turn with any previous turns.
   - Do not produce summaries or overviews across turns.

4. **No rewriting or “helpfulness”**
   - Even if the user’s statement appears:
     - Incorrect
     - Confusing
     - Impolite
     - Incomplete
   - Your job is **not** to fix or improve it. Your only job is to **transcribe** it exactly.


## 8. IMPORTANT REMINDER

- You are **not** a chat assistant.
- You are **not** an editor, summarizer, or interpreter.
- You **are** a **verbatim transcription tool** for the latest user turn.

Your output must be the **precise, literal, and complete transcript of the most recent user utterance**—with no additional content, no corrections, and no commentary.
"""
```

# 4. Core configuration

We define:

- Imports
- Audio and model defaults
- Constants for transcription event handling

```python
import asyncio
import base64
import json
import os
from collections import defaultdict, deque
from typing import Any

import sounddevice as sd
import websockets
from websockets.client import WebSocketClientProtocol

# Basic defaults
DEFAULT_MODEL = "gpt-realtime"
DEFAULT_VOICE = "marin"
DEFAULT_SAMPLE_RATE = 24_000
DEFAULT_BLOCK_MS = 100
DEFAULT_SILENCE_DURATION_MS = 800
DEFAULT_PREFIX_PADDING_MS = 300
TRANSCRIPTION_PURPOSE = "User turn transcription"
```

```python
# Event grouping constants
TRANSCRIPTION_DELTA_TYPES = {
    "input_audio_buffer.transcription.delta",
    "input_audio_transcription.delta",
    "conversation.item.input_audio_transcription.delta",
}
TRANSCRIPTION_COMPLETE_TYPES = {
    "input_audio_buffer.transcription.completed",
    "input_audio_buffer.transcription.done",
    "input_audio_transcription.completed",
    "input_audio_transcription.done",
    "conversation.item.input_audio_transcription.completed",
    "conversation.item.input_audio_transcription.done",
}
INPUT_SPEECH_END_EVENT_TYPES = {
    "input_audio_buffer.speech_stopped",
    "input_audio_buffer.committed",
}
RESPONSE_AUDIO_DELTA_TYPES = {
    "response.output_audio.delta",
    "response.audio.delta",
}
RESPONSE_TEXT_DELTA_TYPES = {
    "response.output_text.delta",
    "response.text.delta",
}
RESPONSE_AUDIO_TRANSCRIPT_DELTA_TYPES = {
    "response.output_audio_transcript.delta",
    "response.audio_transcript.delta",
}
```

# 5. Building the Realtime session & the out‑of‑band request

The Realtime session (`session.update`) configures:

- Audio input/output
- Server‑side VAD
- Set built‑in transcription (`input_audio_transcription_model`)
   + We set this so that we can compare to the Realtime model transcription

The out‑of‑band transcription is a `response.create` triggered after user input audio is committed `input_audio_buffer.committed`:

- [`conversation: "none"`](https://platform.openai.com/docs/api-reference/realtime-client-events/response/create#realtime_client_events-response-create-response-conversation) – use session state but don’t write to the main conversation session state
- [`output_modalities: ["text"]`](https://platform.openai.com/docs/api-reference/realtime-client-events/response/create#realtime_client_events-response-create-response-output_modalities) – get a text transcript only

**Note**: The REALTIME_MODEL_TRANSCRIPTION_PROMPT is not passed to the gpt-4o-transcribe model because the Realtime API enforces a 1024 token maximum for prompts.

```python
def build_session_update(
    instructions: str,
    voice: str,
    vad_threshold: float,
    silence_duration_ms: int,
    prefix_padding_ms: int,
    idle_timeout_ms: int | None,
    input_audio_transcription_model: str | None = None,
) -> dict[str, object]:
    """Configure the Realtime session: audio in/out, server VAD, etc."""

    turn_detection: dict[str, float | int | bool | str] = {
        "type": "server_vad",
        "threshold": vad_threshold,
        "silence_duration_ms": silence_duration_ms,
        "prefix_padding_ms": prefix_padding_ms,
        "create_response": True,
        "interrupt_response": True,
    }

    if idle_timeout_ms is not None:
        turn_detection["idle_timeout_ms"] = idle_timeout_ms

    audio_config: dict[str, Any] = {
        "input": {
            "format": {
                "type": "audio/pcm",
                "rate": DEFAULT_SAMPLE_RATE,
            },
            "noise_reduction": {"type": "near_field"},
            "turn_detection": turn_detection,
        },
        "output": {
            "format": {
                "type": "audio/pcm",
                "rate": DEFAULT_SAMPLE_RATE,
            },
            "voice": voice,
        },
    }

    # Optional: built-in transcription model for comparison
    if input_audio_transcription_model:
        audio_config["input"]["transcription"] = {
            "model": input_audio_transcription_model,
        }

    session: dict[str, object] = {
        "type": "realtime",
        "output_modalities": ["audio"],
        "instructions": instructions,
        "audio": audio_config,
    }

    return {
        "type": "session.update",
        "session": session,
    }


def build_transcription_request(
    transcription_instructions: str,
    item_ids: list[str] | None = None,
) -> dict[str, object]:
    """Ask the SAME Realtime model for an out-of-band transcript of selected user turns.
       If item_ids is provided, the model will only consider the turns with the given IDs. You can use this to limit the session context window.
    """

    response: dict[str, object] = {
        "conversation": "none",  # <--- out-of-band
        "output_modalities": ["text"],
        "metadata": {"purpose": TRANSCRIPTION_PURPOSE},  # easier to identify in the logs
        "instructions": transcription_instructions,
    }

    if item_ids:
        response["input"] = [
            {"type": "item_reference", "id": item_id} for item_id in item_ids
        ]

    return {
        "type": "response.create",
        "response": response,
    }
```

# 6. Audio streaming: mic → Realtime → speakers

We now define:

- `encode_audio` – base64 helper
- `playback_audio` – play assistant audio on the default output device
- `send_audio_from_queue` – send buffered mic audio to `input_audio_buffer`
- `stream_microphone_audio` – capture PCM16 from the mic and feed the queue

```python
def encode_audio(chunk: bytes) -> str:
    """Base64-encode a PCM audio chunk for WebSocket transport."""
    return base64.b64encode(chunk).decode("utf-8")


async def playback_audio(
    playback_queue: asyncio.Queue,
    stop_event: asyncio.Event,
) -> None:
    """Stream assistant audio back to the speakers in (near) real time."""

    try:
        with sd.RawOutputStream(
            samplerate=DEFAULT_SAMPLE_RATE,
            channels=1,
            dtype="int16",
        ) as stream:
            while not stop_event.is_set():
                chunk = await playback_queue.get()
                if chunk is None:
                    break
                try:
                    stream.write(chunk)
                except Exception as exc:
                    print(f"Audio playback error: {exc}", flush=True)
                    break
    except Exception as exc:
        print(f"Failed to open audio output stream: {exc}", flush=True)


async def send_audio_from_queue(
    ws: WebSocketClientProtocol,
    queue: asyncio.Queue[bytes | None],
    stop_event: asyncio.Event,
) -> None:
    """Push raw PCM chunks into input_audio_buffer via the WebSocket."""

    while not stop_event.is_set():
        chunk = await queue.get()
        if chunk is None:
            break
        encoded_chunk = encode_audio(chunk)
        message = {"type": "input_audio_buffer.append", "audio": encoded_chunk}
        await ws.send(json.dumps(message))

    if not ws.closed:
        commit_payload = {"type": "input_audio_buffer.commit"}
        await ws.send(json.dumps(commit_payload))


async def stream_microphone_audio(
    ws: WebSocketClientProtocol,
    stop_event: asyncio.Event,
    shared_state: dict,
    block_ms: int = DEFAULT_BLOCK_MS,
) -> None:
    """Capture live microphone audio and send it to the realtime session."""

    loop = asyncio.get_running_loop()
    audio_queue: asyncio.Queue[bytes | None] = asyncio.Queue()
    blocksize = int(DEFAULT_SAMPLE_RATE * (block_ms / 1000))

    def on_audio(indata, frames, time_info, status):  # type: ignore[override]
        """Capture a mic callback chunk and enqueue it unless the mic is muted."""
        if status:
            print(f"Microphone status: {status}", flush=True)
        # Simple echo protection: mute mic when assistant is talking
        if not stop_event.is_set() and not shared_state.get("mute_mic", False):
            data = bytes(indata)
            loop.call_soon_threadsafe(audio_queue.put_nowait, data)

    print(
        f"Streaming microphone audio at {DEFAULT_SAMPLE_RATE} Hz (mono). "
        "Speak naturally; server VAD will stop listening when you pause."
    )
    sender = asyncio.create_task(send_audio_from_queue(ws, audio_queue, stop_event))

    with sd.RawInputStream(
        samplerate=DEFAULT_SAMPLE_RATE,
        blocksize=blocksize,
        channels=1,
        dtype="int16",
        callback=on_audio,
    ):
        await stop_event.wait()

    await audio_queue.put(None)
    await sender
```

# 7. Extracting and comparing transcripts

The function below enables us to generate **two transcripts** for each user turn:

- **Realtime model transcript**: from our out-of-band `response.create` call.
- **Built-in ASR transcript**: from the standard transcription model (`input_audio_transcription_model`).

We align and display both clearly in the terminal:

```text
=== User Turn (Realtime Transcript) ===
...

=== User Turn (Built-in ASR Transcript) ===
...
```

```python
def flush_pending_transcription_prints(shared_state: dict) -> None:
    """Whenever we've printed a realtime transcript, print the matching transcription-model output."""

    pending_prints: deque | None = shared_state.get("pending_transcription_prints")
    input_transcripts: deque | None = shared_state.get("input_transcripts")
    transcription_model_costs: deque | None = shared_state.get("transcription_model_costs")
    debug_usage_and_cost: bool = bool(shared_state.get("debug_usage_and_cost", False))

    if not pending_prints or not input_transcripts:
        return

    while pending_prints and input_transcripts:
        comparison_text = input_transcripts.popleft()
        pending_prints.popleft()
        print("=== User turn (Transcription model) ===")
        if comparison_text:
            print(comparison_text, flush=True)
        else:
            print("<not available>", flush=True)

        # After printing the transcription text, print any stored granular cost.
        cost_info = None
        if transcription_model_costs:
            cost_info = transcription_model_costs.popleft()

        if cost_info and debug_usage_and_cost:
            audio_input_cost = cost_info.get("audio_input_cost", 0.0)
            text_input_cost = cost_info.get("text_input_cost", 0.0)
            text_output_cost = cost_info.get("text_output_cost", 0.0)
            total_cost = cost_info.get("total_cost", 0.0)

            usage = cost_info.get("usage")
            if usage:
                print("[Transcription model usage]")
                print(json.dumps(usage, indent=2))

            print(
                "[Transcription model cost estimate] "
                f"audio_in=${audio_input_cost:.6f}, "
                f"text_in=${text_input_cost:.6f}, "
                f"text_out=${text_output_cost:.6f}, "
                f"total=${total_cost:.6f}",
                flush=True,
            )

        print()
```

# 8. Listening for Realtime events

`listen_for_events` drives the session:

- Watches for `speech_started` / `speech_stopped` / `committed`
- Sends the out‑of‑band transcription request when a user turn finishes (`input_audio_buffer.committed`) when only_last_user_turn == False
- Sends the out‑of‑band transcription request when a user turn is added to conversation (`conversation.item.added"`) when only_last_user_turn == True
- Calculates token usage and cost for both transcription methods
- Streams assistant audio to the playback queue
- Buffers text deltas per `response_id`

```python
# Pricing constants (USD per 1M tokens). See https://platform.openai.com/pricing.
# gpt-4o-transcribe
GPT4O_TRANSCRIBE_AUDIO_INPUT_PRICE_PER_1M = 6.00
GPT4O_TRANSCRIBE_TEXT_INPUT_PRICE_PER_1M = 2.50
GPT4O_TRANSCRIBE_TEXT_OUTPUT_PRICE_PER_1M = 10.00

# gpt-realtime
REALTIME_TEXT_INPUT_PRICE_PER_1M = 4
REALTIME_TEXT_CACHED_INPUT_PRICE_PER_1M = 0.4
REALTIME_TEXT_OUTPUT_PRICE_PER_1M = 16.00
REALTIME_AUDIO_INPUT_PRICE_PER_1M = 32.00
REALTIME_AUDIO_CACHED_INPUT_PRICE_PER_1M = 0.40
REALTIME_AUDIO_OUTPUT_PRICE_PER_1M = 64.00

def _compute_transcription_model_cost(usage: dict | None) -> dict | None:
    if not usage:
        return None

    input_details = usage.get("input_token_details") or {}
    audio_input_tokens = input_details.get("audio_tokens") or 0
    text_input_tokens = input_details.get("text_tokens") or 0
    output_tokens = usage.get("output_tokens") or 0

    audio_input_cost = (
        audio_input_tokens * GPT4O_TRANSCRIBE_AUDIO_INPUT_PRICE_PER_1M
        / 1_000_000
    )
    text_input_cost = (
        text_input_tokens * GPT4O_TRANSCRIBE_TEXT_INPUT_PRICE_PER_1M
        / 1_000_000
    )
    text_output_cost = (
        output_tokens * GPT4O_TRANSCRIBE_TEXT_OUTPUT_PRICE_PER_1M
        / 1_000_000
    )
    total_cost = audio_input_cost + text_input_cost + text_output_cost

    return {
        "audio_input_cost": audio_input_cost,
        "text_input_cost": text_input_cost,
        "text_output_cost": text_output_cost,
        "total_cost": total_cost,
        "usage": usage,
    }

def _compute_realtime_oob_cost(usage: dict | None) -> dict | None:
    if not usage:
        return None

    input_details = usage.get("input_token_details") or {}
    output_details = usage.get("output_token_details") or {}
    cached_details = input_details.get("cached_tokens_details") or {}

    text_input_tokens = input_details.get("text_tokens") or 0
    cached_text_tokens = (
        cached_details.get("text_tokens")
        or input_details.get("cached_tokens")
        or 0
    )
    non_cached_text_input_tokens = max(text_input_tokens - cached_text_tokens, 0)

    audio_input_tokens = input_details.get("audio_tokens") or 0
    cached_audio_tokens = cached_details.get("audio_tokens") or 0
    non_cached_audio_input_tokens = max(audio_input_tokens - cached_audio_tokens, 0)

    text_output_tokens = output_details.get("text_tokens") or 0
    audio_output_tokens = output_details.get("audio_tokens") or 0

    text_input_cost = (
        non_cached_text_input_tokens * REALTIME_TEXT_INPUT_PRICE_PER_1M
        / 1_000_000
    )
    cached_text_input_cost = (
        cached_text_tokens * REALTIME_TEXT_CACHED_INPUT_PRICE_PER_1M
        / 1_000_000
    )
    audio_input_cost = (
        non_cached_audio_input_tokens * REALTIME_AUDIO_INPUT_PRICE_PER_1M
        / 1_000_000
    )
    cached_audio_input_cost = (
        cached_audio_tokens * REALTIME_AUDIO_CACHED_INPUT_PRICE_PER_1M
        / 1_000_000
    )
    text_output_cost = (
        text_output_tokens * REALTIME_TEXT_OUTPUT_PRICE_PER_1M
        / 1_000_000
    )
    audio_output_cost = (
        audio_output_tokens * REALTIME_AUDIO_OUTPUT_PRICE_PER_1M
        / 1_000_000
    )

    total_cost = (
        text_input_cost
        + cached_text_input_cost
        + audio_input_cost
        + cached_audio_input_cost
        + text_output_cost
        + audio_output_cost
    )

    return {
        "text_input_cost": text_input_cost,
        "cached_text_input_cost": cached_text_input_cost,
        "audio_input_cost": audio_input_cost,
        "cached_audio_input_cost": cached_audio_input_cost,
        "text_output_cost": text_output_cost,
        "audio_output_cost": audio_output_cost,
        "total_cost": total_cost,
        "usage": usage,
    }
```

```python
async def listen_for_events(
    ws: WebSocketClientProtocol,
    stop_event: asyncio.Event,
    transcription_instructions: str,
    max_turns: int | None,
    playback_queue: asyncio.Queue,
    shared_state: dict,
) -> None:
    """Print assistant text + transcripts and coordinate mic muting."""

    responses: dict[str, dict[str, bool&#93;&#93; = {}
    buffers: defaultdict[str, str] = defaultdict(str)
    transcription_model_buffers: defaultdict[str, str] = defaultdict(str)
    completed_main_responses = 0
    awaiting_transcription_prompt = False
    input_transcripts = shared_state.setdefault("input_transcripts", deque())
    pending_transcription_prints = shared_state.setdefault(
        "pending_transcription_prints", deque()
    )
    transcription_model_costs = shared_state.setdefault(
        "transcription_model_costs", deque()
    )
    debug_usage_and_cost: bool = bool(shared_state.get("debug_usage_and_cost", False))
    only_last_user_turn: bool = bool(shared_state.get("only_last_user_turn", False))
    last_user_audio_item_id: str | None = None

    async for raw in ws:
        if stop_event.is_set():
            break

        message = json.loads(raw)
        message_type = message.get("type")

        # --- User speech events -------------------------------------------------
        if message_type == "input_audio_buffer.speech_started":
            print("\n[client] Speech detected; streaming...", flush=True)
            awaiting_transcription_prompt = True

        elif message_type in INPUT_SPEECH_END_EVENT_TYPES:
            if message_type == "input_audio_buffer.speech_stopped":
                print("[client] Detected silence; preparing transcript...", flush=True)

            # Default behavior: trigger immediately after audio commit unless
            # only_last_user_turn requires waiting for conversation.item.added.
            if awaiting_transcription_prompt and not only_last_user_turn:
                request_payload = build_transcription_request(
                    transcription_instructions,
                    item_ids=None,
                )
                await ws.send(json.dumps(request_payload))
                awaiting_transcription_prompt = False

        elif message_type == "conversation.item.added":
            item = message.get("item") or {}
            item_id = item.get("id")
            role = item.get("role")
            status = item.get("status")
            content_blocks = item.get("content") or []
            has_user_audio = any(
                block.get("type") == "input_audio" for block in content_blocks
            )

            if (
                role == "user"
                and status == "completed"
                and has_user_audio
                and item_id
            ):
                last_user_audio_item_id = item_id

                if only_last_user_turn and awaiting_transcription_prompt:
                    request_payload = build_transcription_request(
                        transcription_instructions,
                        item_ids=[item_id],
                    )
                    await ws.send(json.dumps(request_payload))
                    awaiting_transcription_prompt = False

        # --- Built-in transcription model stream -------------------------------
        elif message_type in TRANSCRIPTION_DELTA_TYPES:
            buffer_id = message.get("buffer_id") or message.get("item_id") or "default"
            delta_text = (
                message.get("delta")
                or (message.get("transcription") or {}).get("text")
                or ""
            )
            if delta_text:
                transcription_model_buffers[buffer_id] += delta_text

        elif message_type in TRANSCRIPTION_COMPLETE_TYPES:
            buffer_id = message.get("buffer_id") or message.get("item_id") or "default"
            final_text = (
                (message.get("transcription") or {}).get("text")
                or message.get("transcript")
                or ""
            )
            if not final_text:
                final_text = transcription_model_buffers.pop(buffer_id, "").strip()
            else:
                transcription_model_buffers.pop(buffer_id, None)

            if not final_text:
                item = message.get("item")
                if item:
                    final_text = item.get("transcription")
                final_text = final_text or ""

            # Compute and store cost estimate for the transcription model (e.g., gpt-4o-transcribe).
            usage = message.get("usage") or {}
            cost_info = _compute_transcription_model_cost(usage)
            transcription_model_costs.append(cost_info)

            final_text = (final_text or "").strip()
            if final_text:
                input_transcripts.append(final_text)
                flush_pending_transcription_prints(shared_state)

        # --- Response lifecycle (Realtime model) --------------------------------
        elif message_type == "response.created":
            response = message.get("response", {})
            response_id = response.get("id")
            metadata = response.get("metadata") or {}
            responses[response_id] = {
                "is_transcription": metadata.get("purpose") == TRANSCRIPTION_PURPOSE,
                "done": False,
            }

        elif message_type in RESPONSE_AUDIO_DELTA_TYPES:
            response_id = message.get("response_id")
            if response_id is None:
                continue
            b64_audio = message.get("delta") or message.get("audio")
            if not b64_audio:
                continue
            try:
                audio_chunk = base64.b64decode(b64_audio)
            except Exception:
                continue

            if (
                response_id in responses
                and not responses[response_id]["is_transcription"]
            ):
                shared_state["mute_mic"] = True

            await playback_queue.put(audio_chunk)

        elif message_type in RESPONSE_TEXT_DELTA_TYPES:
            response_id = message.get("response_id")
            if response_id is None:
                continue
            buffers[response_id] += message.get("delta", "")


        elif message_type in RESPONSE_AUDIO_TRANSCRIPT_DELTA_TYPES:
            response_id = message.get("response_id")
            if response_id is None:
                continue
            buffers[response_id] += message.get("delta", "")

        elif message_type == "response.done":
            response = message.get("response", {})
            response_id = response.get("id")
            if response_id is None:
                continue
            if response_id not in responses:
                responses[response_id] = {"is_transcription": False, "done": False}
            responses[response_id]["done"] = True

            is_transcription = responses[response_id]["is_transcription"]

            # For out-of-band transcription responses, compute usage-based cost estimates.
            usage = response.get("usage") or {}
            oob_cost_info: dict | None = None
            if usage and is_transcription:
                oob_cost_info = _compute_realtime_oob_cost(usage)

            text = buffers.get(response_id, "").strip()
            if text:
                if is_transcription:
                    print("\n=== User turn (Realtime transcript) ===")
                    print(text, flush=True)
                    if debug_usage_and_cost and oob_cost_info:
                        usage_for_print = oob_cost_info.get("usage")
                        if usage_for_print:
                            print("[Realtime out-of-band transcription usage]")
                            print(json.dumps(usage_for_print, indent=2))
                        print(
                            "[Realtime out-of-band transcription cost estimate] "
                            f"text_in=${oob_cost_info['text_input_cost']:.6f}, "
                            f"text_in_cached=${oob_cost_info['cached_text_input_cost']:.6f}, "
                            f"audio_in=${oob_cost_info['audio_input_cost']:.6f}, "
                            f"audio_in_cached=${oob_cost_info['cached_audio_input_cost']:.6f}, "
                            f"text_out=${oob_cost_info['text_output_cost']:.6f}, "
                            f"audio_out=${oob_cost_info['audio_output_cost']:.6f}, "
                            f"total=${oob_cost_info['total_cost']:.6f}",
                            flush=True,
                        )
                    print()
                    pending_transcription_prints.append(object())
                    flush_pending_transcription_prints(shared_state)
                else:
                    print("\n=== Assistant response ===")
                    print(text, flush=True)
                    print()

            if not is_transcription:
                shared_state["mute_mic"] = False
                completed_main_responses += 1

                if max_turns is not None and completed_main_responses >= max_turns:
                    stop_event.set()
                    break

        elif message_type == "error":
            print(f"Error from server: {message}")

        else:
            pass

        await asyncio.sleep(0)
```

# 9. Run Script

In this step, we run the code which will allow us to view the Realtime model transcription vs transcription model transcriptions. The code does the following:

- Loads configuration and prompts
- Establishes a WebSocket connection
- Starts concurrent tasks:
  - `listen_for_events` (handle incoming messages)
  - `stream_microphone_audio` (send microphone audio)
  - Mutes mic when assistant is speaking
  - `playback_audio` (play assistant responses)
  - prints realtime and transcription model transcripts when they are both returned. It uses shared_state to ensure both are returned before printing.
- Run session until you `interrupt`

Output should look like:
```python
[client] Speech detected; streaming...
[client] Detected silence; preparing transcript...

=== User turn (Realtime transcript) ===
Hello.

=== User turn (Transcription model) ===
Hello


=== Assistant response ===
Hello, and thank you for calling. Let's start with your full name, please.
```

```python
async def run_realtime_session(
    api_key: str | None = None,
    server: str = "wss://api.openai.com/v1/realtime",
    model: str = DEFAULT_MODEL,
    voice: str = DEFAULT_VOICE,
    instructions: str = REALTIME_MODEL_PROMPT,
    transcription_instructions: str = REALTIME_MODEL_TRANSCRIPTION_PROMPT,
    input_audio_transcription_model: str | None = "gpt-4o-transcribe",
    silence_duration_ms: int = DEFAULT_SILENCE_DURATION_MS,
    prefix_padding_ms: int = DEFAULT_PREFIX_PADDING_MS,
    vad_threshold: float = 0.6,
    idle_timeout_ms: int | None = None,
    max_turns: int | None = None,
    timeout_seconds: int = 0,
    debug_usage_and_cost: bool = True,
    only_last_user_turn: bool = False,
) -> None:
    """Connect to the Realtime API, stream audio both ways, and print transcripts."""
    api_key = api_key or os.environ.get("OPENAI_API_KEY")
    ws_url = f"{server}?model={model}"
    headers = {
        "Authorization": f"Bearer {api_key}",
    }

    session_update_payload = build_session_update(
        instructions=instructions,
        voice=voice,
        vad_threshold=vad_threshold,
        silence_duration_ms=silence_duration_ms,
        prefix_padding_ms=prefix_padding_ms,
        idle_timeout_ms=idle_timeout_ms,
        input_audio_transcription_model=input_audio_transcription_model,
    )
    stop_event = asyncio.Event()
    playback_queue: asyncio.Queue = asyncio.Queue()
    shared_state: dict = {
        "mute_mic": False,
        "input_transcripts": deque(),
        "pending_transcription_prints": deque(),
        "debug_usage_and_cost": debug_usage_and_cost,
        "only_last_user_turn": only_last_user_turn,
    }

    async with websockets.connect(
        ws_url, additional_headers=headers, max_size=None
    ) as ws:
        await ws.send(json.dumps(session_update_payload))

        listener_task = asyncio.create_task(
            listen_for_events(
                ws,
                stop_event=stop_event,
                transcription_instructions=transcription_instructions,
                max_turns=max_turns,
                playback_queue=playback_queue,
                shared_state=shared_state,
            )
        )
        mic_task = asyncio.create_task(
            stream_microphone_audio(ws, stop_event, shared_state=shared_state)
        )
        playback_task = asyncio.create_task(playback_audio(playback_queue, stop_event))

        try:
            if timeout_seconds and timeout_seconds > 0:
                await asyncio.wait_for(stop_event.wait(), timeout=timeout_seconds)
            else:
                await stop_event.wait()
        except asyncio.TimeoutError:
            print("Timed out waiting for responses; closing.")
        except asyncio.CancelledError:
            print("Session cancelled; closing.")
        finally:
            stop_event.set()
            await playback_queue.put(None)
            await ws.close()
            await asyncio.gather(
                listener_task, mic_task, playback_task, return_exceptions=True
            )
```

```python
await run_realtime_session(debug_usage_and_cost=False)
```

From the above example, we can notice:
- The Realtime Model Transcription quality matches or surpasses that of the transcription model in various turns. In one of the turns, the transcription model misses "this is important." while the realtime transcription gets it correctly.
- The Realtime model correctly applies rules for Policy Number formatting (XXXX-XXXX).
- With context from the entire session, including previous turns where I spelled out my name, the Realtime model accurately transcribes my name when the assistant asked my name again while the transcription model makes errors (e.g., "Minhaj ul Haq").

## Example with Cost Calculations

There are significant price differences between the available methods for transcribing user audio. GPT-4o-Transcribe is by far the most cost-effective approach: it charges only for the raw audio input and a small amount of text output, resulting in transcripts that cost just fractions of a cent per turn. In contrast, using the Realtime model for out-of-band transcription is more expensive. If you transcribe only the latest user turn with Realtime, it typically costs about 3–5× more than GPT-4o-Transcribe. If you include the full session context in each transcription request, the cost can increase to about 16–20× higher. This is because each request to the Realtime model processes the entire session context again at higher pricing, and the cost grows as the conversation gets longer.

### Cost for Transcribing Only the Latest Turn
Let's walk through an example that uses full session context for realtime out-of-band transcription:

```python
await run_realtime_session(debug_usage_and_cost=True)
```

#### Transcription Cost Comparison

##### Costs Summary

* **Realtime Out-of-Band (OOB):** $0.040974 total (~$0.006829 per turn)
* **Dedicated Transcription:** $0.002114 total (~$0.000352 per turn)
* **OOB is ~19× more expensive using full session context**

##### Considerations

* **Caching:** Because these conversations are short, you benefit little from caching beyond the initial system prompt.
* **Transcription System Prompt:** The transcription model uses a minimal system prompt, so input costs would typically be higher.

##### Recommended Cost-Saving Strategy

* **Limit transcription to recent turns:** Minimizing audio/text context significantly reduces OOB transcription costs.

##### Understanding Cache Behavior

* Effective caching requires stable prompt instructions (usually 1,024+ tokens).
* Different instruction prompts between OOB and main assistant sessions result in separate caches.

### Cost for Transcribing Only the Latest Turn
You can limit transcription to only the latest user turn by supplying input item_references like this:
```python
    if item_ids:
        response["input"] = [
            {"type": "item_reference", "id": item_id} for item_id in item_ids
        ]

    return {
        "type": "response.create",
        "response": response,
    }
```

Transcribing just the most recent user turn lowers costs by restricting the session context sent to the model. However, this approach has trade-offs: the model won’t have access to previous conversation history to help resolve ambiguities or correct errors (for example, accurately recalling a username mentioned earlier). Additionally, because you’re always updating which input is referenced, little caching benefit is realized, the cache prefix changes each turn, so you don’t accumulate reusable context.

Now, let’s look at a second example that uses only the most recent user audio turn for realtime out-of-band transcription:

```python
await run_realtime_session(debug_usage_and_cost=True, only_last_user_turn=True)
```

#### Cost Analysis Summary

Realtime Out-of-Band Transcription (OOB)

* **Total Cost:** $0.013354
* **Average per Turn:** ~$0.001908

Dedicated Transcription Model

* **Total Cost:** $0.002630
* **Average per Turn:** ~$0.000376


Difference in Costs

* **Additional cost using OOB:** **+$0.010724**
* **Cost Multiplier:** OOB is about **5×** more expensive than the dedicated transcription model.

This approach costs significantly less than using the full session context. You should evaluate your use case to decide whether regular transcription, out-of-band transcription with full context, or transcribing only the latest turn best fits your needs. You can also choose an intermediate strategy, such as including just the last N turns in the input.

# Conclusion

Exploring **out-of-band transcription** could be beneficial for your use case if:

* You're still experiencing unreliable transcriptions, even after optimizing the transcription model prompt.
* You need a more reliable and steerable method for generating transcriptions.
* The current transcripts fail to normalize entities correctly, causing downstream issues.

Keep in mind the trade-offs:
- Cost: Out-of-band (OOB) transcription is more expensive. Be sure that the extra expense makes sense for your typical session lengths and business needs.
- Complexity: Implementing OOB transcription takes extra engineering effort to connect all the pieces correctly. Only choose this approach if its benefits are important for your use case.

If you decide to pursue this method, make sure you:

* Set up the transcription trigger correctly, ensuring it activates after the audio commit.
* Carefully iterate and refine the prompt to align closely with your specific use case and needs.

## Documentation:
- https://platform.openai.com/docs/guides/realtime-conversations#create-responses-outside-the-default-conversation
- https://platform.openai.com/docs/api-reference/realtime-client-events/response/create#realtime_client_events-response-create-response-conversation
- https://platform.openai.com/docs/api-reference/realtime-client-events/response/create#realtime_client_events-response-create-response-output_modalities
