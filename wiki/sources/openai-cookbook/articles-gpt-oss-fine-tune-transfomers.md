---
title: "Fine Tune Transfomers"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-18
tags:
  - article
  - cookbook
  - fine-tuning
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/articles/gpt-oss/fine-tune-transfomers
  - https://github.com/openai/openai-cookbook/blob/main/articles/gpt-oss/fine-tune-transfomers.ipynb
---

# Fine Tune Transfomers

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/articles/gpt-oss/fine-tune-transfomers
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/articles/gpt-oss/fine-tune-transfomers.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/articles/gpt-oss/fine-tune-transfomers.ipynb
- Source path: `articles/gpt-oss/fine-tune-transfomers.ipynb`
- Source kind: `articles`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `97814cbebe3259a3809a95f6f376b3934a6e1443c606394147cca82af9f30567`

## Classification

- Primary category: Fine-tuning / reinforcement fine-tuning
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Fine-tuning a Multilingual Reasoner with Hugging Face Authored by: Edward Beeching, Quentin Gallouédec, and Lewis Tunstall Large reasoning models like OpenAI o3 generate a chain-of-thought to improve the accuracy and quality of their responses. However, most of these models reason in English, even when a question is asked in another language. In this noteboo...

## What This Teaches

- How to prepare data or workflows for model adaptation and fine-tuning.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Fine-tuning a Multilingual Reasoner with Hugging Face

Authored by: [Edward Beeching](https://huggingface.co/edbeeching), [Quentin Gallouédec](https://huggingface.co/qgallouedec), and [Lewis Tunstall](https://huggingface.co/lewtun)

Large reasoning models like [OpenAI o3](https://openai.com/index/introducing-o3-and-o4-mini/) generate a chain-of-thought to improve the accuracy and quality of their responses. However, most of these models reason in English, even when a question is asked in another language.

In this notebook, we show how OpenAI's open-weight reasoning model [OpenAI gpt-oss-20b](https://huggingface.co/openai/gpt-oss-20b) can be fine-tuned to reason effectively in multiple languages. We'll do this by adding a new _"reasoning language"_ option to the model's system prompt, and applying [supervised fine-tuning](https://huggingface.co/learn/llm-course/chapter11/1) with Hugging Face's [TRL library](https://github.com/huggingface/trl) on a multilingual reasoning dataset.

We'll cover the following steps:

1. **Setup:** Install the required libraries.
2. **Prepare the dataset:**  Download and format the dataset for fine-tuning.
3. **Prepare the model:** Loading the base model and configure it for fine-tuning [LoRA](https://huggingface.co/learn/llm-course/chapter11/4), a memory efficient technique.
4. **Fine-tuning:** Train the model with our multilingual reasoning data.
5. **Inference:** Generate reasoning responses in different languages using the fine-tuned model.

The end result is a multilingual reasoning model that can generate a chain-of-thought in English, Spanish, French, Italian, or German. You can even _mix languages_—for example, ask a question in Spanish, request reasoning in German, and receive the final response in Spanish:

```txt
User:
    ¿Cuál es el capital de Australia?
Assistant reasoning:
    Okay, der Benutzer fragt nach der Hauptstadt Australiens. Ich erinnere mich, dass Canberra die Hauptstadt ist. Ich
    sollte das bestätigen. Lass mich sehen, ob es irgendwelche potenziellen Verwirrungen gibt. Der Benutzer könnte auch
    an der größten Stadt interessiert sein. Die größte Stadt ist Sydney, aber die Hauptstadt ist Canberra. Ich sollte
    das klarstellen. Vielleicht auch erwähnen, dass Canberra eine geplante Stadt ist und nicht die größte. Der Benutzer
    könnte auch nach der Geografie fragen. Vielleicht erwähne ich, dass Canberra im südwestlichen Teil der Australian
    Capital Territory liegt. Ich sollte die Antwort präzise und freundlich halten. Vielleicht auch erwähnen, dass
    Canberra oft mit Sydney verwechselt wird. Ich sollte sicherstellen, dass die Antwort klar und korrekt ist.
Assistant response:
    La capital de Australia es **Canberra**. Aunque es la ciudad más pequeña de las principales capitales del país, fue
    elegida en 1908 como la sede del gobierno federal para equilibrar la influencia entre las ciudades de Sydney y
    Melbourne. Canberra está ubicada en el Territorio de la Capital Australiana (ACT), en el este de Australia.
```

We hope this tutorial will enable AI developers working with under-represented languages to improve the interpretability of [`openai/gpt-oss-20b`](https://huggingface.co/openai/gpt-oss-20b) in their native languages.

> **Note:** This notebook is designed to be run on a single H100 GPU with 80GB of memory. If you have access to a smaller GPU, you can reduce the batch size and sequence length in the hyperparameters below.

## Setup

To get started, let’s install all the necessary libraries. First install PyTorch:

```python
%pip install torch --index-url https://download.pytorch.org/whl/cu128
```

Next, install the remaining dependencies:

```python
%pip install "trl>=0.20.0" "peft>=0.17.0" "transformers>=4.55.0" trackio
```

Finally, log into your Hugging Face account as follows:

```python
from huggingface_hub import notebook_login

notebook_login()
```

Now that we've installed the required libraries, let's take a look at the dataset that we will use for fine-tuning.

## Prepare the dataset

We will be using [Multilingual-Thinking](https://huggingface.co/datasets/HuggingFaceH4/Multilingual-Thinking), which is a reasoning dataset where the chain-of-thought has been translated into several languages such as French, Spanish, and German. By fine-tuning `openai/gpt-oss-20b` on this dataset, it will learn to generate reasoning steps in these languages, and thus its reasoning process can be interpreted by users who speak those languages.

<iframe
  src="https://huggingface.co/datasets/HuggingFaceH4/Multilingual-Thinking/embed/viewer/default/train"
  frameborder="0"
  width="100%"
  height="560px"
></iframe>



Let's download this dataset from the Hugging Face Hub:

```python
from datasets import load_dataset

dataset = load_dataset("HuggingFaceH4/Multilingual-Thinking", split="train")
dataset
```

This is a small dataset of 1,000 examples, but this is usually more than sufficient for models like `openai/gpt-oss-20b` which have undergone extensive post-training. Let's take a look at one of the training examples:

```python
dataset[0]
```

The `gpt-oss` models were trained on the Harmony response format for defining conversation structures, generating reasoning output and structuring function calls. The format is designed to mimic the OpenAI Responses API, and the table below summarizes the different message types used in the dataset:

|||
| :---- | :--|
| `developer` | The developer message is used to provide custom instructions for the model (what we usually call the `system` role). |
| `user` | The user message is used to provide the input to the model. |
| `assistant` | Output by the model which can either be a tool call or a message output. The output might also be associated with a particular “channel” identifying what the intent of the message is. |
| `analysis` | These are messages that are being used by the model for its chain-of-thought |
| `final` | Messages tagged in the final channel are messages intended to be shown to the end-user and represent the responses from the model. |
| `messages` | The list of messages that combine the content of the above to produce a full conversation. This is the input to the model. |

If you're familiar with [OpenAI's messages format](https://platform.openai.com/docs/api-reference/messages/object), you will recognise this as being quite similar, but with an important difference:

> The `assistant` turn contains two special fields: a `thinking` one which contains the model's reasoning process, and a `content` one which contains the final response to the user.

In order to fine-tune the model, we need to convert these messages into a format that the model can understand. In practice this is done by formatting each message with the model's [_chat template_](https://huggingface.co/docs/transformers/chat_templating) and then tokenizing the resulting text. The TRL library does this automatically, but let's walk through it step by step to understand how it works.

To do so, let's first load the tokenizer:

```python
from transformers import AutoTokenizer

tokenizer = AutoTokenizer.from_pretrained("openai/gpt-oss-20b")
```

Then we can use the tokenizer's `apply_chat_template()` method to format the messages:

```python
messages = dataset[0]["messages"]
conversation = tokenizer.apply_chat_template(messages, tokenize=False)
print(conversation)
```

This chat template is quite sophisticated, so let's take a closer look at it! First, we can see there are special tokens `<|start|>` and `<|end|>` that indicate the start and end of each message. There is also a `<|return|>` token that marks the end of the conversation. These tokens help the model understand the structure of the conversation.

We can also see there are _two_ types of system message:

* A default `system` one that is used for all messages. In the example above, this refers to the text _"You are ChatGPT, a large language model trained by OpenAI..."_
* A special `developer` one that contains custom instructions (defined by the `system` role in our `messages` object). This allows us to provide additional context to the model about how it should behave for a given conversation. In the example above, this refers to the text _"You are an AI chatbot with a lively and energetic personality."_

Finally, we can see that the assistant response is contained in a series of _channels_:

* The `analysis` channel is used for the model's reasoning process, where it can think step by step about the user's question. In the example above, this refers to the French text _"D'accord, l'utilisateur demande les tendances Twitter..."_
* The `final` channel is used for the model's final response to the user. In the example above, this refers to the text _"Hey there!  While I can't check Twitter..."_

Now that we understand how the dataset will be prepared, let's move on to preparing the model for training.

## Prepare the model

To prepare the model for training, let's first download the weights from the [Hugging Face Hub](https://huggingface.co). We will use the `AutoModelForCausalLM` class from 🤗 Transformers to load the model:

```python
import torch
from transformers import AutoModelForCausalLM, Mxfp4Config

quantization_config = Mxfp4Config(dequantize=True)
model_kwargs = dict(
    attn_implementation="eager",
    torch_dtype=torch.bfloat16,
    quantization_config=quantization_config,
    use_cache=False,
    device_map="auto",
)

model = AutoModelForCausalLM.from_pretrained("openai/gpt-oss-20b", **model_kwargs)
```

This will load the model with the necessary configurations for training. The `attn_implementation` is set to `eager` for better performance, and `use_cache` is set to `False` since we will fine-tune the model with gradient checkpointing.

If you're familiar with 🤗 Transformers, you might notice that we are using the `Mxfp4Config` for quantization. This is a specific configuration for the OpenAI models that allows us to use mixed precision training with a special 4-bit floating point format called [MXFP4](https://en.wikipedia.org/wiki/Block_floating_point) that is optimized for AI workloads.

Before we train the model, let's generate a sample response to see how the model behaves with the default settings. To do so, we need to tokenize a sample prompt and then use the model to generate a response:

```python
messages = [
    {"role": "user", "content": "¿Cuál es el capital de Australia?"},
]

input_ids = tokenizer.apply_chat_template(
    messages,
    add_generation_prompt=True,
    return_tensors="pt",
).to(model.device)

output_ids = model.generate(input_ids, max_new_tokens=512)
response = tokenizer.batch_decode(output_ids)[0]
print(response)
```

In this example, we can see that the model first reasons about the question in English, and then provides a final response in Spanish. This is the default behavior of the model, but let's see if we can change it with a bit of fine-tuning.

To do so, we will use a technique called [LoRA](https://huggingface.co/learn/llm-course/chapter11/4) (Low-Rank Adaptation) to fine-tune the model. This technique allows us to tune a few specific layers of the model, which is particularly useful for large models like `openai/gpt-oss-20b`.

First we need to wrap the model as a `PeftModel` and define the LoRA configuration. We will use the `LoraConfig` class from the [PEFT library](https://github.com/huggingface/peft) to do this:

```python
from peft import LoraConfig, get_peft_model

peft_config = LoraConfig(
    r=8,
    lora_alpha=16,
    target_modules="all-linear",
    target_parameters=[
        "7.mlp.experts.gate_up_proj",
        "7.mlp.experts.down_proj",
        "15.mlp.experts.gate_up_proj",
        "15.mlp.experts.down_proj",
        "23.mlp.experts.gate_up_proj",
        "23.mlp.experts.down_proj",
    ],
)
peft_model = get_peft_model(model, peft_config)
peft_model.print_trainable_parameters()
```

Here we've used some basic hyperparameters for LoRA, but you can experiment with different values to see how they affect the model's performance. For instance, if you increase `r` you will enable more trainable parameters, which may produce a better model at the expense of requiring more VRAM and time to train.

**Note:** The `openai/gpt-oss-20b` model is a [Mixture-of-Experts (MoE)](https://huggingface.co/blog/moe) architecture. In addition to targeting the attention layers (`target_modules="all-linear"`), it’s also important to include the projection layers within the expert modules. PEFT facilitates this via the `target_parameters` argument, which allows you to specify expert-specific layers such as `mlp.experts.down_proj` and `mlp.experts.gate_up_proj`. In this example, we target a subset of these projection layers, but you are encouraged to experiment with different configurations.

Now that we have the model and dataset ready, we can define the hyperparameters for training.

## Fine-tuning

TRL provides a convenient way to define hyperparameters for training using the `SFTConfig` class. We will set the learning rate, batch size, number of epochs, and other parameters as follows:

```python
from trl import SFTConfig

training_args = SFTConfig(
    learning_rate=2e-4,
    gradient_checkpointing=True,
    num_train_epochs=1,
    logging_steps=1,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    max_length=2048,
    warmup_ratio=0.03,
    lr_scheduler_type="cosine_with_min_lr",
    lr_scheduler_kwargs={"min_lr_rate": 0.1},
    output_dir="gpt-oss-20b-multilingual-reasoner",
    report_to="trackio",
    push_to_hub=True,
)
```

Note that the `per_device_train_batch_size` is set to 4, and the `gradient_accumulation_steps` is set to 4. This means that we will effectively have a batch size of 4 x 4 = 16 across 1 GPU. You may need to adjust these values based on your hardware setup. We also use [Trackio](https://huggingface.co/blog/trackio) to log the training progress and metrics, but you can use any other logging library of your choice.

We now have all the pieces needed to train the model. We will use the `SFTTrainer` class from TRL to handle the training process. The trainer will take care of formatting the dataset, applying the chat template, and training the model:

```python
from trl import SFTTrainer

trainer = SFTTrainer(
    model=peft_model,
    args=training_args,
    train_dataset=dataset,
    processing_class=tokenizer,
)
trainer.train()
```

On a H100 GPU, this takes about 18 minutes to train, but may take longer depending on your hardware.

## Save the model and push to the Hugging Face Hub

Finally, you can push the fine-tuned model to your Hub repository to share with the community:

```python
trainer.save_model(training_args.output_dir)
trainer.push_to_hub(dataset_name="HuggingFaceH4/Multilingual-Thinking")
```

**Note**: To avoid out-of-memory (OOM) errors, we recommend restarting the kernel at this point. The trained model is still occupying GPU memory, but it's no longer needed.

## Inference

Once the model is uploaded to Hub, we can use it for inference. To do so we first initialize the original base model and its tokenizer. Next, we need to merge the fine-tuned weights with the base model for fast inference:

```python
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel

# Load the tokenizer
tokenizer = AutoTokenizer.from_pretrained("openai/gpt-oss-20b")

# Load the original model first
model_kwargs = dict(attn_implementation="eager", torch_dtype="auto", use_cache=True, device_map="auto")
base_model = AutoModelForCausalLM.from_pretrained("openai/gpt-oss-20b", **model_kwargs).cuda()

# Merge fine-tuned weights with the base model
peft_model_id = "gpt-oss-20b-multilingual-reasoner"
model = PeftModel.from_pretrained(base_model, peft_model_id)
model = model.merge_and_unload()
```

Now that the model is loaded, the final step is to generate some tokens from it! Here we use the model's `generate` method to produce output based on the input prompt. Let's first define the prompt:

Now we can tokenize the prompt and generate the output. Finally, we can decode the output tokens to get the final response:

```python
REASONING_LANGUAGE = "German"
SYSTEM_PROMPT = f"reasoning language: {REASONING_LANGUAGE}"
USER_PROMPT = "¿Cuál es el capital de Australia?"  # Spanish for "What is the capital of Australia?"

messages = [
    {"role": "system", "content": SYSTEM_PROMPT},
    {"role": "user", "content": USER_PROMPT},
]

input_ids = tokenizer.apply_chat_template(
    messages,
    add_generation_prompt=True,
    return_tensors="pt",
).to(model.device)

gen_kwargs = {"max_new_tokens": 512, "do_sample": True, "temperature": 0.6, "top_p": None, "top_k": None}

output_ids = model.generate(input_ids, **gen_kwargs)
response = tokenizer.batch_decode(output_ids)[0]
print(response)
```

Let's also try with languages that the model has not been explicitly fine-tuned on, such as Chinese and Hindi:

```python
REASONING_LANGUAGE = "Chinese"  # or Hindi, or any other language...
SYSTEM_PROMPT = f"reasoning language: {REASONING_LANGUAGE}"
USER_PROMPT = "What is the national symbol of Canada?"

messages = [
    {"role": "system", "content": SYSTEM_PROMPT},
    {"role": "user", "content": USER_PROMPT},
]

input_ids = tokenizer.apply_chat_template(
    messages,
    add_generation_prompt=True,
    return_tensors="pt",
).to(model.device)

output_ids = model.generate(input_ids, **gen_kwargs)
response = tokenizer.batch_decode(output_ids)[0]
print(response)
```

Great, it works - we've now fine-tuned `openai/gpt-oss-20b` to reason in multiple languages!

## Conclusion

Congratulations! You have successfully fine-tuned a multilingual reasoning model using the TRL library and LoRA. The steps in this notebook can be adapted to fine-tune [`openai/gpt-oss-20b`](https://huggingface.co/openai/gpt-oss-20b) on many other [datasets](https://huggingface.co/datasets) on the Hugging Face Hub - we are excited to see what you'll build!
