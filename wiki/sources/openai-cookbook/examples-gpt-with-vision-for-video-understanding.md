---
title: "Gpt With Vision For Video Understanding"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - example
  - multimodal
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/gpt_with_vision_for_video_understanding
  - https://github.com/openai/openai-cookbook/blob/main/examples/GPT_with_vision_for_video_understanding.ipynb
---

# Gpt With Vision For Video Understanding

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/gpt_with_vision_for_video_understanding
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/GPT_with_vision_for_video_understanding.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/GPT_with_vision_for_video_understanding.ipynb
- Source path: `examples/GPT_with_vision_for_video_understanding.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `913448102a8284de675d6ce0138342d2a8d06e6a365ce054dfcbf4845f40f09a`

## Classification

- Primary category: Multimodal / image / video
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Processing and narrating a video with GPT-4.1-mini's visual capabilities and GPT-4o TTS API This notebook demonstrates how to use GPT's visual capabilities with a video. Although GPT-4.1-mini doesn't take videos as input directly, we can use vision and the 1M token context window to describe the static frames of a whole video at once. We'll walk through two...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: Multimodal / image / video.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Processing and narrating a video with GPT-4.1-mini's visual capabilities and GPT-4o TTS API

This notebook demonstrates how to use GPT's visual capabilities with a video. Although GPT-4.1-mini doesn't take videos as input directly, we can use vision and the 1M token context window to describe the static frames of a whole video at once. We'll walk through two examples:

1. Using GPT-4.1-mini to get a description of a video
2. Generating a voiceover for a video with GPT-4o TTS API

```python
from IPython.display import display, Image, Audio

import cv2  # We're using OpenCV to read video, to install !pip install opencv-python
import base64
import time
from openai import OpenAI
import os

client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "<your OpenAI API key if not set as env var>"))
```

## 1. Using GPT's visual capabilities to get a description of a video

First, we use OpenCV to extract frames from a nature [video](https://www.youtube.com/watch?v=kQ_7GtE529M) containing bisons and wolves:

```python
video = cv2.VideoCapture("data/bison.mp4")

base64Frames = []
while video.isOpened():
    success, frame = video.read()
    if not success:
        break
    _, buffer = cv2.imencode(".jpg", frame)
    base64Frames.append(base64.b64encode(buffer).decode("utf-8"))

video.release()
print(len(base64Frames), "frames read.")
```

Display frames to make sure we've read them in correctly:

```python
display_handle = display(None, display_id=True)
for img in base64Frames:
    display_handle.update(Image(data=base64.b64decode(img.encode("utf-8"))))
    time.sleep(0.025)
```

Once we have the video frames, we craft our prompt and send a request to GPT (Note that we don't need to send every frame for GPT to understand what's going on):

```python
response = client.responses.create(
    model="gpt-4.1-mini",
    input=[
        {
            "role": "user",
            "content": [
                {
                    "type": "input_text",
                    "text": (
                        "These are frames from a video that I want to upload. Generate a compelling description that I can upload along with the video."
                    )
                },
                *[
                    {
                        "type": "input_image",
                        "image_url": f"data:image/jpeg;base64,{frame}"
                    }
                    for frame in base64Frames[0::25]
                ]
            ]
        }
    ],
)

print(response.output_text)
```

## 2. Generating a voiceover for a video with GPT-4.1 and the GPT-4o TTS API

Let's create a voiceover for this video in the style of David Attenborough. Using the same video frames we prompt GPT to give us a short script:

```python
result = client.responses.create(
    model="gpt-4.1-mini",
    input=[
        {
            "role": "user",
            "content": [
                {
                    "type": "input_text",
                    "text": (
                        "These are frames of a video. Create a short voiceover script in the style of David Attenborough. Only include the narration."
                    )
                },
                *[
                    {
                        "type": "input_image",
                        "image_url": f"data:image/jpeg;base64,{frame}"
                    }
                    for frame in base64Frames[0::25]
                ]
            ]
        }
    ]
)

print(result.output_text)
```

Now, we can work with the GPT-4o TTS model and provide it a set of instructions on how the voice should sound. You can play around with the voice models and instructers at [OpenAI.fm](openai.fm). We can then pass in the script we generated above with GPT-4.1-mini and generate audio of the voiceover:

```python
instructions = """
Voice Affect: Calm, measured, and warmly engaging; convey awe and quiet reverence for the natural world.

Tone: Inquisitive and insightful, with a gentle sense of wonder and deep respect for the subject matter.

Pacing: Even and steady, with slight lifts in rhythm when introducing a new species or unexpected behavior; natural pauses to allow the viewer to absorb visuals.

Emotion: Subtly emotive—imbued with curiosity, empathy, and admiration without becoming sentimental or overly dramatic.

Emphasis: Highlight scientific and descriptive language (“delicate wings shimmer in the sunlight,” “a symphony of unseen life,” “ancient rituals played out beneath the canopy”) to enrich imagery and understanding.

Pronunciation: Clear and articulate, with precise enunciation and slightly rounded vowels to ensure accessibility and authority.

Pauses: Insert thoughtful pauses before introducing key facts or transitions (“And then... with a sudden rustle...”), allowing space for anticipation and reflection.
"""

audio_response = response = client.audio.speech.create(
  model="gpt-4o-mini-tts",
  voice="echo",
  instructions=instructions,
  input=result.output_text,
  response_format="wav"
)

audio_bytes = audio_response.content
Audio(data=audio_bytes)
```
