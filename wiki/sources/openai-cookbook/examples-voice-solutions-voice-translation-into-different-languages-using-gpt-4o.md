---
title: "Voice Translation Into Different Languages Using Gpt 4o"
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
  - https://developers.openai.com/cookbook/examples/voice_solutions/voice_translation_into_different_languages_using_gpt-4o
  - https://github.com/openai/openai-cookbook/blob/main/examples/voice_solutions/voice_translation_into_different_languages_using_GPT-4o.ipynb
---

# Voice Translation Into Different Languages Using Gpt 4o

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/voice_solutions/voice_translation_into_different_languages_using_gpt-4o
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/voice_solutions/voice_translation_into_different_languages_using_GPT-4o.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/voice_solutions/voice_translation_into_different_languages_using_GPT-4o.ipynb
- Source path: `examples/voice_solutions/voice_translation_into_different_languages_using_GPT-4o.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `f49140c1c3ad4b7d590e4e476949269dc810ca1a37b6f81fc6eab65694849fe9`

## Classification

- Primary category: Realtime / voice / transcription
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Voice Translation of Audio Files into Different Languages Using Gpt-4o Have you ever wanted to translate a podcast into your native language? Translating and dubbing audio content can make it more accessible to audiences worldwide. With GPT-4o's new audio-in and audio-out modality, this process is now easier than ever. This guide will walk you through transl...

## What This Teaches

- How to build low-latency speech, transcription, or voice interaction pipelines.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

### Voice Translation of Audio Files into Different Languages Using Gpt-4o

Have you ever wanted to translate a podcast into your native language? Translating and dubbing audio content can make it more accessible to audiences worldwide. With GPT-4o's new audio-in and audio-out modality, this process is now easier than ever.

This guide will walk you through translating an English audio file into Hindi using OpenAI's GPT-4o audio modality API.

GPT-4o simplifies the dubbing process for audio content. Previously, you had to convert the audio to text and then translate the text into the target language before converting it back into audio. Now, with GPT-4o’s voice-to-voice capability, you can achieve this in a single step with audio input and output.

A note on semantics used in this Cookbook regarding **Language** and written **Script**. These words are generally used interchangeably, though it's important to understand the distinction, given the task at hand.

**- Language** refers to the spoken or written system of communication. For instance, Hindi and Marathi are different languages, but both use the Devanagari script. Similarly, English and French are different languages, but are written in Latin script.

**- Script** refers to the set of characters or symbols used to write the language. For example, Serbian language traditionally written in Cyrillic Script, is also written in Latin script.


GPT-4o audio-in and audio-out modality makes it easier to dub the audio from one language to another with one API call.

**1. Transcribe** the source audio file into source language script using GPT-4o. This is an optional step that can be skipped if you already have the transcription of source audio content.

**2. Dub** the audio file from source language directly to the target langauge.

**3. Obtain Translation Benchmarks** using BLEU or ROUGE.

**4. Interpret and improve** scores by adjusting prompting parameters in steps 1-3 as needed.


Before we get started, make sure you have your OpenAI API key configured as an environment variable, and necessary packages installed as outlined in the code cells below.

### Step 1: Transcribe the Audio to Source Language Script using GPT-4o

Let's start by creating a function that sends an audio file to OpenAI's GPT-4o API for processing, using the chat completions API endpoint.

The function `process_audio_with_gpt_4o` takes three inputs:

1. A base64-encoded audio file (base64_encoded_audio) that will be sent to the GPT-4o model.
2. Desired output modalities (such as text, or both text and audio).
3. A system prompt that instructs the model on how to process the input.

The function sends an API request to OpenAI's chat/completions endpoint. The request headers include the API key for authorization. The data payload contains the model type (`gpt-4o-audio-preview`), the selected output modalities, and audio details, such as the voice type and format (in this case, "alloy" and "wav"). It also includes the system prompt and the base64-encoded audio file as part of the "user" message. If the API request is successful (HTTP status 200), the response is returned as JSON. If an error occurs (non-200 status), it prints the error code and message.

This function enables audio processing through OpenAI's GPT-4o API, allowing tasks like dubbing, transcription, or translation to be performed based on the input provided.

```python
# Make sure requests package is installed
import requests
import os
import json

# Load the API key from the environment variable
api_key = os.getenv("OPENAI_API_KEY")


def process_audio_with_gpt_4o(base64_encoded_audio, output_modalities, system_prompt):
    # Chat Completions API end point
    url = "https://api.openai.com/v1/chat/completions"

    # Set the headers
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }

    # Construct the request data
    data = {
        "model": "gpt-4o-audio-preview",
        "modalities": output_modalities,
        "audio": {
            "voice": "alloy",
            "format": "wav"
        },
        "messages": [
            {
                "role": "system",
                "content": system_prompt
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "input_audio",
                        "input_audio": {
                            "data": base64_encoded_audio,
                            "format": "wav"
                        }
                    }
                ]
            }
        ]
    }

    request_response = requests.post(url, headers=headers, data=json.dumps(data))
    if request_response.status_code == 200:
        return request_response.json()
    else:
        print(f"Error {request_response.status_code}: {request_response.text}")
        return
```

Using the function `process_audio_with_gpt_4o`, we will first get an English transcription of the source audio. You can skip this step if you already have a transcription in the source language.

In this step, we:
1. Read the WAV file and convert it into base64 encoding.
2. Set the output modality to ["text"], as we only need a text transcription.
3. Provide a system prompt to instruct the model to focus on transcribing the speech and to ignore background noises like applause.
4. Call the process_audio_with_gpt_4o function to process the audio and return the transcription.

```python
import base64
audio_wav_path = "./sounds/keynote_recap.wav"

# Read the WAV file and encode it to base64
with open(audio_wav_path, "rb") as audio_file:
    audio_bytes = audio_file.read()
    english_audio_base64 = base64.b64encode(audio_bytes).decode('utf-8')

modalities = ["text"]
prompt = "The user will provide an audio file in English. Transcribe the audio to English text, word for word. Only provide the language transcription, do not include background noises such as applause. "

response_json = process_audio_with_gpt_4o(english_audio_base64, modalities, prompt)

english_transcript = response_json['choices'][0]['message']['content']

print(english_transcript)
```

This English transcript will serve as our ground truth as we benchmark the Hindi language dubbing of the audio in Step 3.

### Step 2. Dub the Audio from the Source Language to the Target Language using GPT-4o

With GPT-4o, we can directly dub the audio file from English to Hindi and get the Hindi transcription of the audio in one API call. For this, we set the output modality to `["text", "audio"] `

```python
glossary_of_terms_to_keep_in_original_language = "Turbo, OpenAI, token, GPT, Dall-e, Python"

modalities = ["text", "audio"]
prompt = f"The user will provide an audio file in English. Dub the complete audio, word for word in Hindi. Keep certain words in English for which a direct translation in Hindi does not exist such as  ${glossary_of_terms_to_keep_in_original_language}."

response_json = process_audio_with_gpt_4o(english_audio_base64, modalities, prompt)

message = response_json['choices'][0]['message']
```

In the following code snippet, we will retrieve both the Hindi transcription and the dubbed audio from the GPT-4o response. Previously, this would have been a multistep process, involving several API calls to first transcribe, then translate, and finally produce the audio in the target language. With GPT-4o, we can now accomplish this in a single API call.

```python
# Make sure pydub is installed
from pydub import AudioSegment
from pydub.playback import play
from io import BytesIO

# Get the transcript from the model. This will vary depending on the modality you are using.
hindi_transcript = message['audio']['transcript']

print(hindi_transcript)

# Get the audio content from the response
hindi_audio_data_base64 = message['audio']['data']
```

The transcribed text is a combination of Hindi and English, represented in their respective scripts: Devanagari for Hindi and Latin for English. This approach ensures more natural-sounding speech with the correct pronunciation of both languages' words. We will use the `pydub` module to play the audio as demonstrated in the code below.

```python
# Play the audio
audio_data_bytes = base64.b64decode(hindi_audio_data_base64)
audio_segment = AudioSegment.from_file(BytesIO(audio_data_bytes), format="wav")

play(audio_segment)
```

### Step 3. Obtain Translation Benchmarks (e.g., BLEU or ROUGE)

We can assess the quality of the translated text by comparing it to a reference translation using evaluation metrics like BLEU and ROUGE.

**BLEU (Bilingual Evaluation Understudy)**: Measures the overlap of n-grams between the candidate and reference translations. Scores range from 0 to 100, with higher scores indicating better quality.

**ROUGE (Recall-Oriented Understudy for Gisting Evaluation)**: Commonly used for summarization evaluation. Measures the overlap of n-grams and the longest common subsequence between the candidate and reference texts.

Ideally, a reference translation (a human-translated version) of the original text is needed for an accurate evaluation. However, developing such evaluations can be challenging, as it requires time and effort from bilingual humans proficient in both languages.

An alternative is to transcribe the output audio file from the target language back into the original language to assess the quality of the translation using GPT-4o.

```python
# Translate the audio output file generated by the model back into English and compare with the reference text
modalities = ["text"]
prompt = "The user will provide an audio file in Hindi. Transcribe the audio to English text word for word. Only provide the language transcription, do not include background noises such as applause. "

response_json = process_audio_with_gpt_4o(hindi_audio_data_base64, modalities, prompt)

re_translated_english_text = response_json['choices'][0]['message']['content']

print(re_translated_english_text)
```

With the text transcribed back into English language script from the Hindi audio, we can run the evaluation metrics by comparing it to the original English transcription.

```python
# Make sure scarebleu package is installed
import sacrebleu
# Make sure rouge-score package is installed
from rouge_score import rouge_scorer

# We'll use the original English transcription as the reference text
reference_text = english_transcript

candidate_text = re_translated_english_text

# BLEU Score Evaluation
bleu = sacrebleu.corpus_bleu([candidate_text], &#91;&#91;reference_text&#93;&#93;)
print(f"BLEU Score: {bleu.score}")

# ROUGE Score Evaluation
scorer = rouge_scorer.RougeScorer(['rouge1', 'rougeL'], use_stemmer=True)
scores = scorer.score(reference_text, candidate_text)
print(f"ROUGE-1 Score: {scores['rouge1'].fmeasure}")
print(f"ROUGE-L Score: {scores['rougeL'].fmeasure}")
```

### Step 4. Interpret and improve scores by adjusting prompting parameters in steps 1-3 as needed

In this example, both BLEU and ROUGE scores indicate that the quality of the voice translation is between very good and excellent.

**Interpreting BLEU Scores:** While there is no universally accepted scale, some interpretations suggest:

0 to 10: Poor quality translation; significant errors and lack of fluency.

10 to 20: Low quality; understandable in parts but contains many errors.

20 to 30: Fair quality; conveys the general meaning but lacks precision and fluency.

30 to 40: Good quality; understandable and relatively accurate with minor errors.

40 to 50: Very good quality; accurate and fluent with very few errors.

50 and above: Excellent quality; closely resembles human translation.

**Interpreting ROUGE scores:** The interpretation of a "good" ROUGE score can vary depending on the task, dataset, and domain. The following guidelines indicate a good outcome:

ROUGE-1 (unigram overlap): Scores between 0.5 to 0.6 are generally considered good for abstractive summarization tasks.

ROUGE-L (Longest Common Subsequence): Scores around 0.4 to 0.5 are often regarded as good, reflecting the model's ability to capture the structure of the reference text.

If the score for your translation is unsatisfactory, consider the following questions:

#### 1. Is the source audio accurately transcribed?
If the transcription contains errors, such as confusing similar-sounding words, you can provide a glossary of such terms in the system prompt during step 1. This helps the model avoid misinterpretations and ensures accurate transcription of specific terms.

#### 2. Is the source audio free of grammatical errors?
If the source audio contains grammatical errors, consider using a post-processing step with the GPT model to refine the transcription by removing grammatical mistakes and adding appropriate punctuation. After this, instead of using GPT-4o’s audio-in and audio-out modality, you can use the corrected transcription with GPT-4o’s text-in and audio-out modality to generate the audio in the target language.

#### 3. Are there words that make sense to keep in the original language?
Certain terms or concepts may not have a suitable translation in the target language or may be better understood in their original form. Revisit your `glossary_of_terms_to_keep_in_original_language` and include any such terms to maintain clarity and context.

### Conclusion

In summary, this cookbook offers a clear, step-by-step process for translating and dubbing audio, making content more accessible to a global audience. Using GPT-4o’s audio input and output capabilities, translating and dubbing audio files from one language to another becomes much simpler. Our example focused on translating an audio file from English to Hindi.

The process can be broken down into the following steps:

**1. Transcription:** Obtain transcription of the source language audio into source language script using GPT-4o text modality.

**2. Dub:** Directly dub the audio file into the target language using GPT-4o's audio modality.

**3. Benchmark Translation Quality:** Evaluate the translation’s accuracy using BLEU or ROUGE scores compared to reference text.

**4. Optimize the Process:** If needed, adjust the prompting parameters to improve the transcription and dubbing results.

This guide also highlights the crucial distinction between "language" and "script"—terms that are often confused but are essential in translation work. Language refers to the system of communication, either spoken or written, while script is the set of characters used to write a language. Grasping this difference is vital for effective translation and dubbing.

By following the techniques in this cookbook, you can translate and dub a wide range of content—from podcasts and training videos to full-length films—into multiple languages. This method applies across industries such as entertainment, education, business, and global communication, empowering creators to extend their reach to diverse linguistic audiences.
