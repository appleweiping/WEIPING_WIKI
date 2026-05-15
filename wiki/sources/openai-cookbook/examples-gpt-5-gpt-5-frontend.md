---
title: "Gpt 5 Frontend"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - example
  - gpt-5
  - notebook
  - openai
  - reasoning
source_pages:
  - https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_frontend
  - https://github.com/openai/openai-cookbook/blob/main/examples/gpt-5/gpt-5_frontend.ipynb
---

# Gpt 5 Frontend

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_frontend
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/gpt-5/gpt-5_frontend.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/gpt-5/gpt-5_frontend.ipynb
- Source path: `examples/gpt-5/gpt-5_frontend.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `021862f162cbb17ca3d4330665f22be7cb4be8325847f38066722586989ba989`

## Classification

- Primary category: GPT-5 / reasoning / prompting
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Frontend with GPT-5 GPT-5 is a large leap forward in frontend development. We have seen the model be excellent at developing full stack applications in one shot, making complex refactors look easy, and making surgical edits within large codebases. In this cookbook we will show some examples and some learnings of developing frontend applications with GPT-5 ac...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: GPT-5 / reasoning / prompting.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Frontend with GPT-5

GPT-5 is a large leap forward in frontend development. We have seen the model be excellent at developing full stack applications in one shot, making complex refactors look easy, and making surgical edits within large codebases.

In this cookbook we will show some examples and some learnings of developing frontend applications with GPT-5 across multiple axes.

## Intro
There are some general principles we have seen be effective in developing strong frontend applications. We share some of these learnings in the [prompt guide](https://cookbook.openai.com/examples/gpt-5/gpt-5_prompting_guide). Below are some important pieces to consider when building frontend applications.

Here are libraries and packages we recommend to start with steering the model:
- Frameworks: Next.js (TypeScript), React, HTML
- Styling / UI: Tailwind CSS, shadcn/ui, Radix Themes
- Icons: Material Symbols, Heroicons, Lucide
- Animation: Motion
- Fonts: San Serif, Inter, Geist, Mona Sans, IBM Plex Sans, Manrope

These packages are not an exhaustive list and we have seen many different application styles.

Below you'll find an easy way to iterate over frontend abstractions on the API. We’re excited to see how users can unlock creativity with GPT-5.

## Interactive Example

Let's dive into an example of creating frontends from scratch. First let's create some help functions to see the generated websites from GPT-5.

```python
import os
import re
import webbrowser
from pathlib import Path

import openai
from openai.types.responses import ResponseInputParam

client = openai.OpenAI()


def get_response_output_text(input: str | ResponseInputParam):

    response = client.responses.create(
        model="gpt-5",
        input=input,
    )
    return response.output_text


def extract_html_from_text(text: str):
    """Extract an HTML code block from text; fallback to first code block, else full text."""
    html_block = re.search(r"```html\s*(.*?)\s*```", text, re.DOTALL | re.IGNORECASE)
    if html_block:
        result = html_block.group(1)
        return result
    any_block = re.search(r"```\s*(.*?)\s*```", text, re.DOTALL)
    if any_block:
        result = any_block.group(1)
        return result
    return text


def save_html(html: str, filename: str) -> Path:
    """Save HTML to outputs/ directory and return the path."""
    try:
        base_dir = Path(__file__).parent
    except NameError:
        base_dir = Path.cwd()

    folder = "outputs"
    outputs_dir = base_dir / folder
    outputs_dir.mkdir(parents=True, exist_ok=True)

    output_path = outputs_dir / filename
    output_path.write_text(html, encoding="utf-8")
    return output_path

def open_in_browser(path: Path) -> None:
    """Open a file in the default browser (macOS compatible)."""
    try:
        webbrowser.open(path.as_uri())
    except Exception:
        os.system(f'open "{path}"')
```

Now, let's combine the above into one helper function.

```python
def make_website_and_open_in_browser(*, website_input: str | ResponseInputParam, filename: str = "website.html"):
    response_text = get_response_output_text(website_input)
    html = extract_html_from_text(response_text)
    output_path = save_html(html, filename)
    open_in_browser(output_path)
```

We'll start with a simple example: one-shot building a retro gaming store with the right theme

```python
make_website_and_open_in_browser(
    website_input="Make me landing page for a retro-games store. Retro-arcade noir some might say",
    filename="retro_dark.html",
)
```

Not bad for a one line, one shot prompt!

<img src="../../images/retro_dark.png" style="width:60vw; display:block; margin:auto;">


Now let's steer it to be lighter, and a bit softer

```python
make_website_and_open_in_browser(
    website_input="Make me landing page for a retro-games store. Make it light, more pastel coloured & flowery (think Mario, not cyberpunk)",
    filename="retro_light.html"
)
```

As you can see GPT-5 is incredibly steerable - with just a one line you can change entire applications effortlessly

<img src="../../images/retro_light.png" style="width:60vw; display:block; margin:auto;">

But what if you have existing website designs that you want to make additions to? For example, we already have this dashboard.

<img src="../../images/input_image.png" style="width:60vw; display:block; margin:auto;">

Since GPT-5 is natively multimodal and accepts both image and text input, when you are generating frontend applications we can take advantage of image input to improve model performance.

```python
import base64
from openai.types.responses import ResponseInputImageParam

# Function to encode the image
def encode_image(image_path: str):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode("utf-8")

image_path="../../images/input_image.png"
encoded_image = encode_image(image_path)
input_image: ResponseInputImageParam = {"type": "input_image", "image_url": f"data:image/png;base64,{encoded_image}", "detail": "auto"}
input: ResponseInputParam = [
    {
        "role": "user",
        "content": [
            {"type": "input_text", "text": "Can you make a login page for this website that maintains the same theme"},
            input_image,
        ],
    }
]

make_website_and_open_in_browser(
    website_input=input,
    filename="login_page.html"
)
```

As you can see, GPT-5 does an incredible job of matching the existing style & vibe of the app.

<img src="../../images/login_page.png" style="width:60vw; display:block; margin:auto;">

So far this has been pretty static - let's try a more interactive task

```python
make_website_and_open_in_browser(
    website_input="Make me a snake game. It should be futuristic, neon, cyberpunk style. Make sure the typography is suitably cool.",
    filename="snake_game.html"
)
```

We've got a theme consistent snake game: matching colours, typography, and even sound

<img src="../../images/snake_game.png" style="width:60vw; display:block; margin:auto;">

We hope this has given some ideas of how powerful GPT-5 is at frontend. From a single underspecified prompt and API call, we get production grade outputs.

Now it's your turn - we can't wait to see what you'll build

```python
your_prompt = "[edit this! what website would you like to build?]"

make_website_and_open_in_browser(
    website_input=your_prompt,
    filename="your_website.html"
)
```
