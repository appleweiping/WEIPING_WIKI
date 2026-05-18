---
title: "Creating Slides With Assistants Api And Dall E3"
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
  - https://developers.openai.com/cookbook/examples/creating_slides_with_assistants_api_and_dall-e3
  - https://github.com/openai/openai-cookbook/blob/main/examples/Creating_slides_with_Assistants_API_and_DALL-E3.ipynb
---

# Creating Slides With Assistants Api And Dall E3

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/creating_slides_with_assistants_api_and_dall-e3
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Creating_slides_with_Assistants_API_and_DALL-E3.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Creating_slides_with_Assistants_API_and_DALL-E3.ipynb
- Source path: `examples/Creating_slides_with_Assistants_API_and_DALL-E3.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `f408c0a1cb818d52f5e1008a44af7ddb696f6964119a46fd8daaac689d9dd038`

## Classification

- Primary category: Multimodal / image / video
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Creating slides with the Assistants API (GPT-4), and DALL·E-3 This notebook illustrates the use of the new Assistants API (GPT-4), and DALL·E-3 in crafting informative and visually appealing slides. <br Creating slides is a pivotal aspect of many jobs, but can be laborious and time-consuming. Additionally, extracting insights from data and articulating them...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: Multimodal / image / video.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Creating slides with the Assistants API (GPT-4), and DALL·E-3

This notebook illustrates the use of the new [Assistants API](https://platform.openai.com/docs/assistants/overview) (GPT-4), and DALL·E-3 in crafting informative and visually appealing slides. <br>
Creating slides is a pivotal aspect of many jobs, but can be laborious and time-consuming. Additionally, extracting insights from data and articulating them effectively on slides can be challenging. <br><br> This cookbook recipe will demonstrate how you can utilize the new Assistants API to facilitate the end to end slide creation process for you without you having to touch Microsoft PowerPoint or Google Slides, saving you valuable time and effort!

## 0. Setup

```python
from IPython.display import display, Image
from openai import OpenAI
import os
import pandas as pd
import json
import io
from PIL import Image
import requests

client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "<your OpenAI API key if not set as env var>"))

#Lets import some helper functions for assistants from https://cookbook.openai.com/examples/assistants_api_overview_python
def show_json(obj):
    display(json.loads(obj.model_dump_json()))

def submit_message(assistant_id, thread, user_message,file_ids=None):
    params = {
        'thread_id': thread.id,
        'role': 'user',
        'content': user_message,
    }
    if file_ids:
        params['file_ids']=file_ids

    client.beta.threads.messages.create(
        **params
)
    return client.beta.threads.runs.create(
    thread_id=thread.id,
    assistant_id=assistant_id,
)

def get_response(thread):
    return client.beta.threads.messages.list(thread_id=thread.id)
```

## 1. Creating the content

In this recipe, we will be creating a brief fictional presentation for the quarterly financial review of our company, NotReal Corporation. We want to highlight some key trends we are seeing that are affecting the profitability of our company.<br> Let's say we have the some financial data at our disposal. Let's load in the data, and take a look...

```python
financial_data_path = 'data/NotRealCorp_financial_data.json'
financial_data = pd.read_json(financial_data_path)
financial_data.head(5)
```

As you can see, this data has quarterly revenue, costs and customer data across different distribution channels. Let's create an Assistant
that can act as a personal analyst and make a nice visualization for our PowerPoint!

First, we need to upload our file so our Assistant can access it.

```python
file = client.files.create(
  file=open('data/NotRealCorp_financial_data.json',"rb"),
  purpose='assistants',
)
```

Now, we're ready to create our Assistant. We can instruct our assistant to act as a data scientist, and take any queries we give it and run the necessary code to output the proper data visualization. The instructions parameter here is akin to system instructions in the ChatCompletions endpoint, and can help guide the assistant. We can also turn on the tool of Code Interpreter, so our Assistant will be able to code. Finally, we can specifiy any files we want to use, which in this case is just the `financial_data` file we created above.

```python
assistant = client.beta.assistants.create(
  instructions="You are a data scientist assistant. When given data and a query, write the proper code and create the proper visualization",
  model="gpt-4-1106-preview",
  tools=[{"type": "code_interpreter"}],
  file_ids=[file.id]
)
```

Let's create a thread now, and as our first request ask the Assistant to calculate quarterly profits, and then plot the profits by distribution channel over time. The assistant will automatically calculate the profit for each quarter, and also create a new column combining quarter and year, without us having to ask for that directly. We can also specify the colors of each line.

```python
thread = client.beta.threads.create(
  messages=[
    {
      "role": "user",
      "content": "Calculate profit (revenue minus cost) by quarter and year, and visualize as a line plot across the distribution channels, where the colors of the lines are green, light red, and light blue",
      "file_ids": [file.id]
    }
  ]
)
```

No we can execute the run of our thread

```python

run = client.beta.threads.runs.create(
    thread_id=thread.id,
    assistant_id=assistant.id,
)
```

We can now start a loop that will check if the image has been created. Note: This may take a few minutes

```python
messages = client.beta.threads.messages.list(thread_id=thread.id)
```

```python
import time

while True:
    messages = client.beta.threads.messages.list(thread_id=thread.id)
    try:
        #See if image has been created
        messages.data[0].content[0].image_file
        #Sleep to make sure run has completed
        time.sleep(5)
        print('Plot created!')
        break
    except:
        time.sleep(10)
        print('Assistant still working...')
```

Let's see the messages the Assistant added.

```python
messages = client.beta.threads.messages.list(thread_id=thread.id)
[message.content[0] for message in messages.data]
```

We can see that the last message (latest message is shown first) from the assistant contains the image file we are looking for. An interesting note here is that the Assistant was able to attempt several times to parse the JSON data, as the first parsing was unsuccessful, demonstrating the assistant's adaptability.

```python
# Quick helper function to convert our output file to a png
def convert_file_to_png(file_id, write_path):
    data = client.files.content(file_id)
    data_bytes = data.read()
    with open(write_path, "wb") as file:
        file.write(data_bytes)
```

```python
plot_file_id = messages.data[0].content[0].image_file.file_id
image_path = "../images/NotRealCorp_chart.png"
convert_file_to_png(plot_file_id,image_path)

#Upload
plot_file = client.files.create(
  file=open(image_path, "rb"),
  purpose='assistants'
)
```

Let's load in the plot!

![The Image](../images/NotRealCorp_chart.png)

Nice! So, with just one sentence, we were able to have our assistant use code interpreter to
calculate the profitability, and graph the three lineplots of the various distribution channels.<br><br>
Now we have a nice visual for our slide, but we want some insights to go along with it.

## 2. Generating insights

To get insights from our image, we simply need to add a new message to our thread. Our Assistant will know to use the message history to give us some concise takeaways from the visual provided.

```python
submit_message(assistant.id,thread,"Give me two medium length sentences (~20-30 words per sentence) of the \
      most important insights from the plot you just created.\
             These will be used for a slide deck, and they should be about the\
                     'so what' behind the data."
)
```

Now, once the run has completed, we can see the latest message

```python
# Hard coded wait for a response, as the assistant may iterate on the bullets.
time.sleep(10)
response = get_response(thread)
bullet_points = response.data[0].content[0].text.value
print(bullet_points)
```

Cool! So our assistant was able to identify the noteworthy growth in Online Sales profit, and infer that this shows the importance of a large digital presence. Now let's get a compelling title for the slide.

```python
submit_message(assistant.id,thread,"Given the plot and bullet points you created,\
 come up with a very brief title for a slide. It should reflect just the main insights you came up with."
)
```

And the title is:

```python
#Wait as assistant may take a few steps
time.sleep(10)
response = get_response(thread)
title = response.data[0].content[0].text.value
print(title)
```

## 3. DALL·E-3 title image

Nice, now we have a title, a plot and two bullet points. We're almost ready to put this all on a slide, but as a final step, let's have DALL·E-3 come up with an image to use as the title slide of the presentation. <br><br>
*Note:* DALL·E-3 is not yet available within the assistants API but is coming soon! <br> <br>
We'll feed in a brief description of our company (NotRealCorp) and have DALL·E-3 do the rest!

```python
company_summary = "NotReal Corp is a prominent hardware company that manufactures and sells processors, graphics cards and other essential computer hardware."
```

```python
response = client.images.generate(
  model='dall-e-3',
  prompt=f"given this company summary {company_summary}, create an inspirational \
    photo showing the growth and path forward. This will be used at a quarterly\
       financial planning meeting",
       size="1024x1024",
       quality="hd",
       n=1
)
image_url = response.data[0].url
```

Cool, now we can add this image to our thread. First, we can save the image locally, then upload it to the assistants API using the `File` upload endpoint. Let's also take a look at our image

```python
dalle_img_path = '../images/dalle_image.png'
img = requests.get(image_url)

#Save locally
with open(dalle_img_path,'wb') as file:
  file.write(img.content)

#Upload
dalle_file = client.files.create(
  file=open(dalle_img_path, "rb"),
  purpose='assistants'
)
```


![Image](../images/dalle_image.png)

## 4. Creating the slides

We now have all the content we need to create the slides. While we could simply add a message asking for slides, but let's instead give the assistant a slide template, using the `python-pptx` library, to use. This will ensure we get a deck in the style we want. See the `Extensions` section at the end of the notebook for notes on creating the template.

```python
title_template = """
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_PARAGRAPH_ALIGNMENT
from pptx.dml.color import RGBColor

# Create a new presentation object
prs = Presentation()

# Add a blank slide layout
blank_slide_layout = prs.slide_layouts[6]
slide = prs.slides.add_slide(blank_slide_layout)

# Set the background color of the slide to black
background = slide.background
fill = background.fill
fill.solid()
fill.fore_color.rgb = RGBColor(0, 0, 0)

# Add image to the left side of the slide with a margin at the top and bottom
left = Inches(0)
top = Inches(0)
height = prs.slide_height
width = prs.slide_width * 3/5
pic = slide.shapes.add_picture(image_path, left, top, width=width, height=height)

# Add title text box positioned higher
left = prs.slide_width * 3/5
top = Inches(2)
width = prs.slide_width * 2/5
height = Inches(1)
title_box = slide.shapes.add_textbox(left, top, width, height)
title_frame = title_box.text_frame
title_p = title_frame.add_paragraph()
title_p.text = title_text
title_p.font.bold = True
title_p.font.size = Pt(38)
title_p.font.color.rgb = RGBColor(255, 255, 255)
title_p.alignment = PP_PARAGRAPH_ALIGNMENT.CENTER

# Add subtitle text box
left = prs.slide_width * 3/5
top = Inches(3)
width = prs.slide_width * 2/5
height = Inches(1)
subtitle_box = slide.shapes.add_textbox(left, top, width, height)
subtitle_frame = subtitle_box.text_frame
subtitle_p = subtitle_frame.add_paragraph()
subtitle_p.text = subtitle_text
subtitle_p.font.size = Pt(22)
subtitle_p.font.color.rgb = RGBColor(255, 255, 255)
subtitle_p.alignment = PP_PARAGRAPH_ALIGNMENT.CENTER
"""

data_vis_template = """
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_PARAGRAPH_ALIGNMENT
from pptx.dml.color import RGBColor

# Create a new presentation object
prs = Presentation()

# Add a blank slide layout
blank_slide_layout = prs.slide_layouts[6]
slide = prs.slides.add_slide(blank_slide_layout)

# Set the background color of the slide to black
background = slide.background
fill = background.fill
fill.solid()
fill.fore_color.rgb = RGBColor(0, 0, 0)

# Define placeholders
image_path = data_vis_img
title_text = "Maximizing Profits: The Dominance of Online Sales & Direct Sales Optimization"
bullet_points = "• Online Sales consistently lead in profitability across quarters, indicating a strong digital market presence.\n• Direct Sales show fluctuations, suggesting variable performance and the need for targeted improvements in that channel."

# Add image placeholder on the left side of the slide
left = Inches(0.2)
top = Inches(1.8)
height = prs.slide_height - Inches(3)
width = prs.slide_width * 3/5
pic = slide.shapes.add_picture(image_path, left, top, width=width, height=height)

# Add title text spanning the whole width
left = Inches(0)
top = Inches(0)
width = prs.slide_width
height = Inches(1)
title_box = slide.shapes.add_textbox(left, top, width, height)
title_frame = title_box.text_frame
title_frame.margin_top = Inches(0.1)
title_p = title_frame.add_paragraph()
title_p.text = title_text
title_p.font.bold = True
title_p.font.size = Pt(28)
title_p.font.color.rgb = RGBColor(255, 255, 255)
title_p.alignment = PP_PARAGRAPH_ALIGNMENT.CENTER

# Add hardcoded "Key Insights" text and bullet points
left = prs.slide_width * 2/3
top = Inches(1.5)
width = prs.slide_width * 1/3
height = Inches(4.5)
insights_box = slide.shapes.add_textbox(left, top, width, height)
insights_frame = insights_box.text_frame
insights_p = insights_frame.add_paragraph()
insights_p.text = "Key Insights:"
insights_p.font.bold = True
insights_p.font.size = Pt(24)
insights_p.font.color.rgb = RGBColor(0, 128, 100)
insights_p.alignment = PP_PARAGRAPH_ALIGNMENT.LEFT
insights_frame.add_paragraph()


bullet_p = insights_frame.add_paragraph()
bullet_p.text = bullet_points
bullet_p.font.size = Pt(12)
bullet_p.font.color.rgb = RGBColor(255, 255, 255)
bullet_p.line_spacing = 1.5
"""
```

Let's set a few quick variables for our slides. We want the company name, NotRealCorp, to be on the title slide, and the title of the presentation should 'Quartlerly financial planning metting, Q3, 2023'.

```python
title_text = "NotRealCorp"
subtitle_text = "Quarterly financial planning meeting, Q3 2023"
```

And for the data slide, we have:

Here we have a template to create a Title Slide. The template below was created by uploading the image of a desirable title slide to GPT-V, and asking for the `python-pptx` code to create that template. The inputs to the template are the image_path, title_text, and subtitle_text.

```python
submit_message(assistant.id,thread,f"Use the included code template to create a PPTX slide that follows the template format, but uses the image, company name/title, and document name/subtitle included:\
{title_template}. IMPORTANT: Use the image file included in this message as the image_path image in this first slide, and use the Company Name {title_text} as the title_text variable, and \
  use the subtitle_text {subtitle_text} a the subtitle_text variable. \
    NEST, create a SECOND slide using the following code template: {data_vis_template} to create a PPTX slide that follows the template format, but uses the company name/title, and document name/subtitle included:\
{data_vis_template}. IMPORTANT: Use the line plot image, that is the second attached image in this message, that you created earlier in the thread as the data_vis_img image, and use the data visualization title that you created earlier for the variable title_text, and\
  the bullet points of insights you created earlier for the bullet_points variable. Output these TWO SLIDES as a .pptx file. Make sure the output is two slides, with each slide matching the respective template given in this message.",
              file_ids=[dalle_file.id, plot_file.id]
)
```

```python
#May take 1-3 mins
while True:
    try:
        response = get_response(thread)
        pptx_id = response.data[0].content[0].text.annotations[0].file_path.file_id
        print("Successfully retrieved pptx_id:", pptx_id)
        break
    except Exception as e:
        print("Assistant still working on PPTX...")
        time.sleep(10)
```

```python
pptx_id = response.data[0].content[0].text.annotations[0].file_path.file_id
ppt_file= client.files.content(pptx_id)
file_obj = io.BytesIO(ppt_file.read())
with open("data/created_slides.pptx", "wb") as f:
    f.write(file_obj.getbuffer())
```

Now, we have a PPTX file saved with all of our created content!. <br>

Let's look at the screenshots of the .pptx we just created using JUST the assistants API and DALL·E-3. We don't have a `seed` parameter yet in the Assistants API, so the DALL·E-3 image and wordings will be slightly different from what you see when you run this notebook, due to the non-determinism of LLMs, but the outputs should be directionally the same.

The title slide:

![Title Slide](../images/title_slide.png)

And the data slide:

![Data Slide](../images/data_vis_slide.png)

## 5. Conclusion

Woo! While these slides could use some formatting tweaks, we have made some great content using the Assistants API, GPT-4 and DALL·E-3. We were able to take a `.csv` file with financial data, and use our assisant to calculate profit by quarter across distribution channels, plot the results, identify insights and key takeaways from the visualization, and create a summarative title. And, given just a description of our company, NotRealCorp, we used DALL·E-3 to make an awesome title image. <br><br>
While we are still a ways away from entirely automating this process without a human in the loop, hopefully this notebook can make the slide creation process a bit easier for you. More importantly, this notebook can ideally give you a glimpse into the potential of the assistants API! We're excited to see what you build.

## 6. Extensions

- When  DALL·E-3 is incorporated in the Assistants API, we will have the ability to request the generated title image within the thread.
- GPT-4-Vision is not yet supported in the Assistants API, but could have been used to gather insights from the line plot image.
- GPT-4-Vision was used to generate the `python-pptx` template included in this recipe, so a potential extension project could be demonstrating best practices around converting images to slide templates.
