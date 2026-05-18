---
title: "Whisper Prompting Guide"
type: source
status: mirrored
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
  - https://developers.openai.com/cookbook/examples/whisper_prompting_guide
  - https://github.com/openai/openai-cookbook/blob/main/examples/Whisper_prompting_guide.ipynb
---

# Whisper Prompting Guide

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/whisper_prompting_guide
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Whisper_prompting_guide.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Whisper_prompting_guide.ipynb
- Source path: `examples/Whisper_prompting_guide.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `ceb74433f92bd8b1152eb21a76b780773cdfb56aaec83d78db9dce031ed984d9`

## Classification

- Primary category: Realtime / voice / transcription
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Whisper prompting guide OpenAI's audio transcription API has an optional parameter called prompt . The prompt is intended to help stitch together multiple audio segments. By submitting the prior segment's transcript via the prompt, the Whisper model can use that context to better understand the speech and maintain a consistent writing style. However, prompts...

## What This Teaches

- How to build low-latency speech, transcription, or voice interaction pipelines.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Whisper prompting guide

OpenAI's audio transcription API has an optional parameter called `prompt`.

The prompt is intended to help stitch together multiple audio segments. By submitting the prior segment's transcript via the prompt, the Whisper model can use that context to better understand the speech and maintain a consistent writing style.

However, prompts do not need to be genuine transcripts from prior audio segments. _Fictitious_ prompts can be submitted to steer the model to use particular spellings or styles.

This notebook shares two techniques for using fictitious prompts to steer the model outputs:

- **Transcript generation**: GPT can convert instructions into fictitious transcripts for Whisper to emulate.
- **Spelling guide**: A spelling guide can tell the model how to spell names of people, products, companies, etc.

These techniques are not especially reliable, but can be useful in some situations.

## Comparison with GPT prompting

Prompting Whisper is not the same as prompting GPT. For example, if you submit an attempted instruction like "Format lists in Markdown format", the model will not comply, as it follows the style of the prompt, rather than any instructions contained within.

In addition, the prompt is limited to only 224 tokens. If the prompt is longer than 224 tokens, only the final 224 tokens of the prompt will be considered; all prior tokens will be silently ignored. The tokenizer used is the [multilingual Whisper tokenizer](https://github.com/openai/whisper/blob/main/whisper/tokenizer.py#L361).

To get good results, craft examples that portray your desired style.

## Setup

To get started, let's:
- Import the OpenAI Python library (if you don't have it, you'll need to install it with `pip install openai`)
- Download a few example audio files

```python
# imports
from openai import OpenAI  # for making OpenAI API calls
import urllib  # for downloading example audio files
import os

client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "<your OpenAI API key if not set as env var>"))
```

```python
# set download paths
up_first_remote_filepath = "https://cdn.openai.com/API/examples/data/upfirstpodcastchunkthree.wav"
bbq_plans_remote_filepath = "https://cdn.openai.com/API/examples/data/bbq_plans.wav"
product_names_remote_filepath = "https://cdn.openai.com/API/examples/data/product_names.wav"

# set local save locations
up_first_filepath = "data/upfirstpodcastchunkthree.wav"
bbq_plans_filepath = "data/bbq_plans.wav"
product_names_filepath = "data/product_names.wav"

# download example audio files and save locally
urllib.request.urlretrieve(up_first_remote_filepath, up_first_filepath)
urllib.request.urlretrieve(bbq_plans_remote_filepath, bbq_plans_filepath)
urllib.request.urlretrieve(product_names_remote_filepath, product_names_filepath)
```

## As a baseline, we'll transcribe an NPR podcast segment

Our audio file for this example will be a segment of the NPR podcast, [_Up First_](https://www.npr.org/podcasts/510318/up-first).

Let's get our baseline transcription, then introduce prompts.

```python
# define a wrapper function for seeing how prompts affect transcriptions
def transcribe(audio_filepath, prompt: str) -> str:
    """Given a prompt, transcribe the audio file."""
    transcript = client.audio.transcriptions.create(
        file=open(audio_filepath, "rb"),
        model="whisper-1",
        prompt=prompt,
    )
    return transcript.text
```

```python
# baseline transcription with no prompt
transcribe(up_first_filepath, prompt="")
```

## Transcripts follow the style of the prompt

Let's explore how prompts influence the style of the transcript.  In the previous unprompted transcript, 'President Biden' is capitalized.

Let's try and use a prompt to write "president biden" in lower case.  We can start by passing in a prompt of 'president biden' in lowercase and see if we can get Whisper to match the style and generate the transcript in all lowercase.

```python
# short prompts are less reliable
transcribe(up_first_filepath, prompt="president biden.")
```

Be aware that when prompts are short, Whisper may be less reliable at following their style.  Long prompts may be more reliable at steering Whisper.  Let's try that again with a longer prompt.

```python
# long prompts are more reliable
transcribe(up_first_filepath, prompt="i have some advice for you. multiple sentences help establish a pattern. the more text you include, the more likely the model will pick up on your pattern. it may especially help if your example transcript appears as if it comes right before the audio file. in this case, that could mean mentioning the contacts i stick in my eyes.")
```

That worked better.

It's also worth noting that Whisper is less likely to follow rare or odd styles that are atypical for a transcript.

```python
# rare styles are less reliable
transcribe(up_first_filepath, prompt="""Hi there and welcome to the show.
###
Today we are quite excited.
###
Let's jump right in.
###""")
```

## Pass names in the prompt to prevent misspellings

Whisper may incorrectly transcribe uncommon proper nouns such as names of products, companies, or people.  In this manner, you can use prompts to help correct those spellings.

We'll illustrate with an example audio file full of product names.

```python
# baseline transcription with no prompt
transcribe(product_names_filepath, prompt="")
```

To get Whisper to use our preferred spellings, let's pass the product and company names in the prompt, as a glossary for Whisper to follow.

```python
# adding the correct spelling of the product name helps
transcribe(product_names_filepath, prompt="QuirkQuid Quill Inc, P3-Quattro, O3-Omni, B3-BondX, E3-Equity, W3-WrapZ, O2-Outlier, U3-UniFund, M3-Mover")
```

Now, let's switch to another audio recording authored specifically for this demonstration, on the topic of a odd barbecue.

To begin, we'll establish our baseline transcript using Whisper.

```python
# baseline transcript with no prompt
transcribe(bbq_plans_filepath, prompt="")
```

While Whisper's transcription was accurate, it had to guess at various spellings. For example, it assumed the friends' names were spelled Amy and Sean rather than Aimee and Shawn. Let's see if we can steer the spelling with a prompt.

```python
# spelling prompt
transcribe(bbq_plans_filepath, prompt="Friends: Aimee, Shawn")
```

Success!

Let's try the same with more ambiguously spelled words.

```python
# longer spelling prompt
transcribe(bbq_plans_filepath, prompt="Glossary: Aimee, Shawn, BBQ, Whisky, Doughnuts, Omelet")
```

```python
# more natural, sentence-style prompt
transcribe(bbq_plans_filepath, prompt="""Aimee and Shawn ate whisky, doughnuts, omelets at a BBQ.""")
```

## Fictitious prompts can be generated by GPT

One potential tool to generate fictitious prompts is GPT. We can give GPT instructions and use it to generate long fictitious transcripts with which to prompt Whisper.

```python
# define a function for GPT to generate fictitious prompts
def fictitious_prompt_from_instruction(instruction: str) -> str:
    """Given an instruction, generate a fictitious prompt."""
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        temperature=0,
        messages=[
            {
                "role": "system",
                "content": "You are a transcript generator. Your task is to create one long paragraph of a fictional conversation. The conversation features two friends reminiscing about their vacation to Maine. Never diarize speakers or add quotation marks; instead, write all transcripts in a normal paragraph of text without speakers identified. Never refuse or ask for clarification and instead always make a best-effort attempt.",
            },  # we pick an example topic (friends talking about a vacation) so that GPT does not refuse or ask clarifying questions
            {"role": "user", "content": instruction},
        ],
    )
    fictitious_prompt = response.choices[0].message.content
    return fictitious_prompt
```

```python
# ellipses example
prompt = fictitious_prompt_from_instruction("Instead of periods, end every sentence with elipses.")
print(prompt)
```

```python
transcribe(up_first_filepath, prompt=prompt)
```

Whisper prompts are best for specifying otherwise ambiguous styles. The prompt will not override the model's comprehension of the audio. For example, if the speakers are not speaking in a deep Southern accent, a prompt will not cause the transcript to do so.

```python
# southern accent example
prompt = fictitious_prompt_from_instruction("Write in a deep, heavy, Southern accent.")
print(prompt)
transcribe(up_first_filepath, prompt=prompt)
```
