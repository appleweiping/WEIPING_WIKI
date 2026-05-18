---
title: "Whisper Processing Guide"
type: source
status: imported
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - example
  - notebook
  - openai
  - realtime
  - voice
source_pages:
  - https://developers.openai.com/cookbook/examples/whisper_processing_guide
  - https://github.com/openai/openai-cookbook/blob/main/examples/Whisper_processing_guide.ipynb
---

# Whisper Processing Guide

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/whisper_processing_guide
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Whisper_processing_guide.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Whisper_processing_guide.ipynb
- Source path: `examples/Whisper_processing_guide.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `b7fee3c54cd9e65882709efffa7bf48f72f408125ffbda06bf44f3af3964627d`

## Classification

- Primary category: Realtime / voice / transcription
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Enhancing Whisper transcriptions: pre- & post-processing techniques This notebook offers a guide to improve the Whisper's transcriptions. We'll streamline your audio data via trimming and segmentation, enhancing Whisper's transcription quality. After transcriptions, we'll refine the output by adding punctuation, adjusting product terminology (e.g., 'five two...

## What This Teaches

- How to build low-latency speech, transcription, or voice interaction pipelines.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Enhancing Whisper transcriptions: pre- & post-processing techniques

This notebook offers a guide to improve the Whisper's transcriptions. We'll streamline your audio data via trimming and segmentation, enhancing Whisper's transcription quality. After transcriptions, we'll refine the output by adding punctuation, adjusting product terminology (e.g., 'five two nine' to '529'), and mitigating Unicode issues. These strategies will help improve the clarity of your transcriptions, but remember, customization based on your unique use-case may be beneficial.

## Setup

To get started let's import a few different libraries:

- [PyDub](http://pydub.com/) is a simple and easy-to-use Python library for audio processing tasks such as slicing, concatenating, and exporting audio files.

- The `Audio` class from the `IPython.display` module allows you to create an audio control that can play sound in Jupyter notebooks, providing a straightforward way to play audio data directly in your notebook.

- For our audio file, we'll use a fictional earnings call written by ChatGPT and read aloud by the author.This audio file is relatively short, but hopefully provides you with an illustrative idea of how these pre and post processing steps can be applied to any audio file.

```python
from openai import OpenAI
import os
import urllib
from IPython.display import Audio
from pathlib import Path
from pydub import AudioSegment
import ssl
```

```python
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "<your OpenAI API key if not set as env var>"))
```

```python
# set download paths
earnings_call_remote_filepath = "https://cdn.openai.com/API/examples/data/EarningsCall.wav"

# set local save locations
earnings_call_filepath = "data/EarningsCall.wav"

# download example audio files and save locally
ssl._create_default_https_context = ssl._create_unverified_context
urllib.request.urlretrieve(earnings_call_remote_filepath, earnings_call_filepath)
```

At times, files with long silences at the beginning can cause Whisper to transcribe the audio incorrectly. We'll use Pydub to detect and trim the silence.

Here, we've set the decibel threshold of 20. You can change this if you would like.

```python
# Function to detect leading silence
# Returns the number of milliseconds until the first sound (chunk averaging more than X decibels)
def milliseconds_until_sound(sound, silence_threshold_in_decibels=-20.0, chunk_size=10):
    trim_ms = 0  # ms

    assert chunk_size > 0  # to avoid infinite loop
    while sound[trim_ms:trim_ms+chunk_size].dBFS < silence_threshold_in_decibels and trim_ms < len(sound):
        trim_ms += chunk_size

    return trim_ms
```

```python
def trim_start(filepath):
    path = Path(filepath)
    directory = path.parent
    filename = path.name
    audio = AudioSegment.from_file(filepath, format="wav")
    start_trim = milliseconds_until_sound(audio)
    trimmed = audio[start_trim:]
    new_filename = directory / f"trimmed_{filename}"
    trimmed.export(new_filename, format="wav")
    return trimmed, new_filename
```

```python
def transcribe_audio(file,output_dir):
    audio_path = os.path.join(output_dir, file)
    with open(audio_path, 'rb') as audio_data:
        transcription = client.audio.transcriptions.create(
            model="whisper-1", file=audio_data)
        return transcription.text
```

At times, we've seen unicode character injection in transcripts, removing any non-ASCII characters should help mitigate this issue.

Keep in mind you should not use this function if you are transcribing in Greek, Cyrillic, Arabic, Chinese, etc

```python
# Define function to remove non-ascii characters
def remove_non_ascii(text):
    return ''.join(i for i in text if ord(i)<128)
```

This function will add formatting and punctuation to our transcript. Whisper generates a transcript with punctuation but without formatting.

```python
# Define function to add punctuation
def punctuation_assistant(ascii_transcript):

    system_prompt = """You are a helpful assistant that adds punctuation to text.
      Preserve the original words and only insert necessary punctuation such as periods,
     commas, capialization, symbols like dollar sings or percentage signs, and formatting.
     Use only the context provided. If there is no context provided say, 'No context provided'\n"""
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        temperature=0,
        messages=[
            {
                "role": "system",
                "content": system_prompt
            },
            {
                "role": "user",
                "content": ascii_transcript
            }
        ]
    )
    return response
```

Our audio file is a recording from a fake earnings call that includes a lot of financial products. This function can help ensure that if Whisper transcribes these financial product names incorrectly, that they can be corrected.

```python
# Define function to fix product mispellings
def product_assistant(ascii_transcript):
    system_prompt = """You are an intelligent assistant specializing in financial products;
    your task is to process transcripts of earnings calls, ensuring that all references to
     financial products and common financial terms are in the correct format. For each
     financial product or common term that is typically abbreviated as an acronym, the full term
    should be spelled out followed by the acronym in parentheses. For example, '401k' should be
     transformed to '401(k) retirement savings plan', 'HSA' should be transformed to 'Health Savings Account (HSA)'
    , 'ROA' should be transformed to 'Return on Assets (ROA)', 'VaR' should be transformed to 'Value at Risk (VaR)'
, and 'PB' should be transformed to 'Price to Book (PB) ratio'. Similarly, transform spoken numbers representing
financial products into their numeric representations, followed by the full name of the product in parentheses.
For instance, 'five two nine' to '529 (Education Savings Plan)' and 'four zero one k' to '401(k) (Retirement Savings Plan)'.
 However, be aware that some acronyms can have different meanings based on the context (e.g., 'LTV' can stand for
'Loan to Value' or 'Lifetime Value'). You will need to discern from the context which term is being referred to
and apply the appropriate transformation. In cases where numerical figures or metrics are spelled out but do not
represent specific financial products (like 'twenty three percent'), these should be left as is. Your role is to
 analyze and adjust financial product terminology in the text. Once you've done that, produce the adjusted
 transcript and a list of the words you've changed"""
    response = client.chat.completions.create(
        model="gpt-4",
        temperature=0,
        messages=[
            {
                "role": "system",
                "content": system_prompt
            },
            {
                "role": "user",
                "content": ascii_transcript
            }
        ]
    )
    return response
```

This function will create a new file with 'trimmed' appended to the original file name

```python
# Trim the start of the original audio file
trimmed_audio = trim_start(earnings_call_filepath)
```

```python
trimmed_audio, trimmed_filename = trim_start(earnings_call_filepath)
```

Our fake earnings report audio file is fairly short in length, so we'll adjust the segments accordingly. Keep in mind you can adjust the segment length as you need.

```python
# Segment audio
trimmed_audio = AudioSegment.from_wav(trimmed_filename)  # Load the trimmed audio file

one_minute = 1 * 60 * 1000  # Duration for each segment (in milliseconds)

start_time = 0  # Start time for the first segment

i = 0  # Index for naming the segmented files

output_dir_trimmed = "trimmed_earnings_directory"  # Output directory for the segmented files

if not os.path.isdir(output_dir_trimmed):  # Create the output directory if it does not exist
    os.makedirs(output_dir_trimmed)

while start_time < len(trimmed_audio):  # Loop over the trimmed audio file
    segment = trimmed_audio[start_time:start_time + one_minute]  # Extract a segment
    segment.export(os.path.join(output_dir_trimmed, f"trimmed_{i:02d}.wav"), format="wav")  # Save the segment
    start_time += one_minute  # Update the start time for the next segment
    i += 1  # Increment the index for naming the next file
```

```python
# Get list of trimmed and segmented audio files and sort them numerically
audio_files = sorted(
    (f for f in os.listdir(output_dir_trimmed) if f.endswith(".wav")),
    key=lambda f: int(''.join(filter(str.isdigit, f)))
)
```

```python
# Use a loop to apply the transcribe function to all audio files
transcriptions = [transcribe_audio(file, output_dir_trimmed) for file in audio_files]
```

```python
# Concatenate the transcriptions
full_transcript = ' '.join(transcriptions)
```

```python
print(full_transcript)
```

```python
# Remove non-ascii characters from the transcript
ascii_transcript = remove_non_ascii(full_transcript)
```

```python
print(ascii_transcript)
```

```python
# Use punctuation assistant function
response = punctuation_assistant(ascii_transcript)
```

```python
# Extract the punctuated transcript from the model's response
punctuated_transcript = response.choices[0].message.content
```

```python
print(punctuated_transcript)
```

```python
# Use product assistant function
response = product_assistant(punctuated_transcript)
```

```python
# Extract the final transcript from the model's response
final_transcript = response.choices[0].message.content
```

```python
print(final_transcript)
```
