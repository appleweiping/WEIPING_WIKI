---
title: "Steering Tts"
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
  - https://developers.openai.com/cookbook/examples/voice_solutions/steering_tts
  - https://github.com/openai/openai-cookbook/blob/main/examples/voice_solutions/steering_tts.ipynb
---

# Steering Tts

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/voice_solutions/steering_tts
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/voice_solutions/steering_tts.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/voice_solutions/steering_tts.ipynb
- Source path: `examples/voice_solutions/steering_tts.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `5f847fb31e545c5adcc0a1fc15a227d19b673c452b991d7847f581a30932b6e9`

## Classification

- Primary category: Realtime / voice / transcription
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Steering Text-to-Speech for more dynamic audio generation Our traditional $1 don't have the ability to steer the voice of the generated audio. For example, if you wanted to convert a paragraph of text to audio, you would not be able to give any specific instructions on audio generation. With $1, you can give specific instructions before generating the audio....

## What This Teaches

- How to build low-latency speech, transcription, or voice interaction pipelines.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

## Steering Text-to-Speech for more dynamic audio generation

Our traditional [TTS APIs](https://platform.openai.com/docs/guides/text-to-speech) don't have the ability to steer the voice of the generated audio. For example, if you wanted to convert a paragraph of text to audio, you would not be able to give any specific instructions on audio generation.

With [audio chat completions](https://platform.openai.com/docs/guides/audio/quickstart), you can give specific instructions before generating the audio. This allows you to tell the API to speak at different speeds, tones, and accents. With appropriate instructions, these voices can be more dynamic, natural, and context-appropriate.

### Traditional TTS

Traditional TTS can specify voices, but not the tone, accent, or any other contextual audio parameters.

```python
from openai import OpenAI
client = OpenAI()

tts_text = """
Once upon a time, Leo the lion cub woke up to the smell of pancakes and scrambled eggs.
His tummy rumbled with excitement as he raced to the kitchen. Mama Lion had made a breakfast feast!
Leo gobbled up his pancakes, sipped his orange juice, and munched on some juicy berries.
"""

speech_file_path = "./sounds/default_tts.mp3"
response = client.audio.speech.create(
    model="tts-1-hd",
    voice="alloy",
    input=tts_text,
)

response.write_to_file(speech_file_path)
```

### Chat Completions TTS

With chat completions, you can give specific instructions before generating the audio. In the following example, we generate a British accent in a learning setting for children. This is particularly useful for educational applications where the voice of the assistant is important for the learning experience.

```python
import base64

speech_file_path = "./sounds/chat_completions_tts.mp3"
completion = client.chat.completions.create(
    model="gpt-4o-audio-preview",
    modalities=["text", "audio"],
    audio={"voice": "alloy", "format": "mp3"},
    messages=[
        {
            "role": "system",
            "content": "You are a helpful assistant that can generate audio from text. Speak in a British accent and enunciate like you're talking to a child.",
        },
        {
            "role": "user",
            "content": tts_text,
        }
    ],
)

mp3_bytes = base64.b64decode(completion.choices[0].message.audio.data)
with open(speech_file_path, "wb") as f:
    f.write(mp3_bytes)

speech_file_path = "./sounds/chat_completions_tts_fast.mp3"
completion = client.chat.completions.create(
    model="gpt-4o-audio-preview",
    modalities=["text", "audio"],
    audio={"voice": "alloy", "format": "mp3"},
    messages=[
        {
            "role": "system",
            "content": "You are a helpful assistant that can generate audio from text. Speak in a British accent and speak really fast.",
        },
        {
            "role": "user",
            "content": tts_text,
        }
    ],
)

mp3_bytes = base64.b64decode(completion.choices[0].message.audio.data)
with open(speech_file_path, "wb") as f:
    f.write(mp3_bytes)
```

### Chat Completions Multilingual TTS

We can also generate audio in different language accents. In the following example, we generate audio in a specific Spanish Uruguayan accent.

```python
completion = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {
            "role": "system",
            "content": "You are an expert translator. Translate any text given into Spanish like you are from Uruguay.",
        },
        {
            "role": "user",
            "content": tts_text,
        }
    ],
)
translated_text = completion.choices[0].message.content
print(translated_text)

speech_file_path = "./sounds/chat_completions_tts_es_uy.mp3"
completion = client.chat.completions.create(
    model="gpt-4o-audio-preview",
    modalities=["text", "audio"],
    audio={"voice": "alloy", "format": "mp3"},
    messages=[
        {
            "role": "system",
            "content": "You are a helpful assistant that can generate audio from text. Speak any text that you receive in a Uruguayan spanish accent and more slowly.",
        },
        {
            "role": "user",
            "content": translated_text,
        }
    ],
)

mp3_bytes = base64.b64decode(completion.choices[0].message.audio.data)
with open(speech_file_path, "wb") as f:
    f.write(mp3_bytes)
```

## Conclusion

The ability to steer the voice of the generated audio opens up a lot of possibilities for richer audio experiences. There are many use cases such as:
- **Enhanced Expressiveness**: Steerable TTS allows adjustments in tone, pitch, speed, and emotion, enabling the voice to convey different moods (e.g., excitement, calmness, urgency).
- **Language learning and education**: Steerable TTS can mimic accents, inflections, and pronunciation, which is beneficial for language learners and educational applications where accurate intonation and emphasis are critical.
- **Contextual Voice**: Steerable TTS adapts the voice to fit the content’s context, such as formal tones for professional documents or friendly, conversational styles for social interactions. This helps create more natural conversations in virtual assistants and chatbots.
