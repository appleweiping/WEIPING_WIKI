---
title: "How To Automate S3 Storage With Functions"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - example
  - notebook
  - openai
  - rag
  - retrieval
source_pages:
  - https://developers.openai.com/cookbook/examples/third_party/how_to_automate_s3_storage_with_functions
  - https://github.com/openai/openai-cookbook/blob/main/examples/third_party/How_to_automate_S3_storage_with_functions.ipynb
---

# How To Automate S3 Storage With Functions

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/third_party/how_to_automate_s3_storage_with_functions
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/third_party/How_to_automate_S3_storage_with_functions.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/third_party/How_to_automate_S3_storage_with_functions.ipynb
- Source path: `examples/third_party/How_to_automate_S3_storage_with_functions.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `5a149708ba60e242bfabf717d66b583f31d61af88dccd2bed07473c464e09cd4`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

How to automate tasks with functions (S3 bucket example) This code demonstrates how to interact with ChatGPT functions to perform tasks related to Amazon S3 buckets. The notebook covers S3 bucket key functionalities such as running simple listing commands, searching for a specific file in all buckets, uploading a file to a bucket, and downloading a file from...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.
- How to expose tools, APIs, schemas, or structured outputs to model workflows.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# How to automate tasks with functions (S3 bucket example)

This code demonstrates how to interact with ChatGPT functions to perform tasks related to Amazon S3 buckets. The notebook covers S3 bucket key functionalities such as running simple listing commands, searching for a specific file in all buckets, uploading a file to a bucket, and downloading a file from a bucket. The OpenAI Chat API understands the user instructions, generates the natural language responses, and extracts appropriate function calls based on the user's input.

**Requirements**:
To run the notebook generate AWS access key with S3 bucket writing permission and store them in a local environment file alongside the Openai key. The "`.env`" file format:
```
AWS_ACCESS_KEY_ID=<your-key>
AWS_SECRET_ACCESS_KEY=<your-key>
OPENAI_API_KEY=<your-key>
```

```python
! pip install openai
! pip install boto3
! pip install tenacity
! pip install python-dotenv
```

```python
from openai import OpenAI
import json
import boto3
import os
import datetime
from urllib.request import urlretrieve

# load environment variables
from dotenv import load_dotenv
load_dotenv()
```

## Initials

```python
OpenAI.api_key = os.environ.get("OPENAI_API_KEY")
GPT_MODEL = "gpt-3.5-turbo"
```

```python
# Optional - if you had issues loading the environment file, you can set the AWS values using the below code
# os.environ['AWS_ACCESS_KEY_ID'] = ''
# os.environ['AWS_SECRET_ACCESS_KEY'] = ''

# Create S3 client
s3_client = boto3.client('s3')

# Create openai client
client = OpenAI()
```

## Utilities

To connect user questions or commands to the appropriate function, we need to provide ChatGPT with the necessary function details and expected parameters.

```python
# Functions dict to pass S3 operations details for the GPT model
functions = [
    {
        "type": "function",
        "function":{
            "name": "list_buckets",
            "description": "List all available S3 buckets",
            "parameters": {
                "type": "object",
                "properties": {}
            }
        }
    },
    {
        "type": "function",
        "function":{
            "name": "list_objects",
            "description": "List the objects or files inside a given S3 bucket",
            "parameters": {
                "type": "object",
                "properties": {
                    "bucket": {"type": "string", "description": "The name of the S3 bucket"},
                    "prefix": {"type": "string", "description": "The folder path in the S3 bucket"},
                },
                "required": ["bucket"],
            },
        }
    },
    {
        "type": "function",
        "function":{
            "name": "download_file",
            "description": "Download a specific file from an S3 bucket to a local distribution folder.",
            "parameters": {
                "type": "object",
                "properties": {
                    "bucket": {"type": "string", "description": "The name of the S3 bucket"},
                    "key": {"type": "string", "description": "The path to the file inside the bucket"},
                    "directory": {"type": "string", "description": "The local destination directory to download the file, should be specificed by the user."},
                },
                "required": ["bucket", "key", "directory"],
            }
        }
    },
    {
        "type": "function",
        "function":{
            "name": "upload_file",
            "description": "Upload a file to an S3 bucket",
            "parameters": {
                "type": "object",
                "properties": {
                    "source": {"type": "string", "description": "The local source path or remote URL"},
                    "bucket": {"type": "string", "description": "The name of the S3 bucket"},
                    "key": {"type": "string", "description": "The path to the file inside the bucket"},
                    "is_remote_url": {"type": "boolean", "description": "Is the provided source a URL (True) or local path (False)"},
                },
                "required": ["source", "bucket", "key", "is_remote_url"],
            }
        }
    },
    {
        "type": "function",
        "function":{
            "name": "search_s3_objects",
            "description": "Search for a specific file name inside an S3 bucket",
            "parameters": {
                "type": "object",
                "properties": {
                    "search_name": {"type": "string", "description": "The name of the file you want to search for"},
                    "bucket": {"type": "string", "description": "The name of the S3 bucket"},
                    "prefix": {"type": "string", "description": "The folder path in the S3 bucket"},
                    "exact_match": {"type": "boolean", "description": "Set exact_match to True if the search should match the exact file name. Set exact_match to False to compare part of the file name string (the file contains)"}
                },
                "required": ["search_name"],
            },
        }
    }
]
```

Create helper functions to interact with the S3 service, such as listing buckets, listing objects, downloading and uploading files, and searching for specific files.

```python
def datetime_converter(obj):
    if isinstance(obj, datetime.datetime):
        return obj.isoformat()
    raise TypeError(f"Object of type {obj.__class__.__name__} is not JSON serializable")
```

```python
def list_buckets():
    response = s3_client.list_buckets()
    return json.dumps(response['Buckets'], default=datetime_converter)

def list_objects(bucket, prefix=''):
    response = s3_client.list_objects_v2(Bucket=bucket, Prefix=prefix)
    return json.dumps(response.get('Contents', []), default=datetime_converter)

def download_file(bucket, key, directory):

    filename = os.path.basename(key)

    # Resolve destination to the correct file path
    destination = os.path.join(directory, filename)

    s3_client.download_file(bucket, key, destination)
    return json.dumps({"status": "success", "bucket": bucket, "key": key, "destination": destination})

def upload_file(source, bucket, key, is_remote_url=False):
    if is_remote_url:
        file_name = os.path.basename(source)
        urlretrieve(source, file_name)
        source = file_name

    s3_client.upload_file(source, bucket, key)
    return json.dumps({"status": "success", "source": source, "bucket": bucket, "key": key})

def search_s3_objects(search_name, bucket=None, prefix='', exact_match=True):
    search_name = search_name.lower()

    if bucket is None:
        buckets_response = json.loads(list_buckets())
        buckets = [bucket_info["Name"] for bucket_info in buckets_response]
    else:
        buckets = [bucket]

    results = []

    for bucket_name in buckets:
        objects_response = json.loads(list_objects(bucket_name, prefix))
        if exact_match:
            bucket_results = [obj for obj in objects_response if search_name == obj['Key'].lower()]
        else:
            bucket_results = [obj for obj in objects_response if search_name in obj['Key'].lower()]

        if bucket_results:
            results.extend([{"Bucket": bucket_name, "Object": obj} for obj in bucket_results])

    return json.dumps(results)
```

The below dictionary connects the name with the function to use it for execution based on ChatGPT responses.

```python
available_functions = {
    "list_buckets": list_buckets,
    "list_objects": list_objects,
    "download_file": download_file,
    "upload_file": upload_file,
    "search_s3_objects": search_s3_objects
}
```

## ChatGPT

```python
def chat_completion_request(messages, functions=None, function_call='auto',
                            model_name=GPT_MODEL):

    if functions is not None:
        return client.chat.completions.create(
            model=model_name,
            messages=messages,
            tools=functions,
            tool_choice=function_call)
    else:
        return client.chat.completions.create(
            model=model_name,
            messages=messages)
```

### Conversation flow

Create a main function for the chatbot, which takes user input, sends it to the OpenAI Chat API, receives a response, executes any function calls generated by the API, and returns a final response to the user.

```python
def run_conversation(user_input, topic="S3 bucket functions.", is_log=False):

    system_message=f"Don't make assumptions about what values to plug into functions. Ask for clarification if a user request is ambiguous. If the user ask question not related to {topic} response your scope is {topic} only."

    messages = [{"role": "system", "content": system_message},
                {"role": "user", "content": user_input}]

    # Call the model to get a response
    response = chat_completion_request(messages, functions=functions)
    response_message = response.choices[0].message

    if is_log:
        print(response.choices)

    # check if GPT wanted to call a function
    if response_message.tool_calls:
        function_name = response_message.tool_calls[0].function.name
        function_args = json.loads(response_message.tool_calls[0].function.arguments)

        # Call the function
        function_response = available_functions[function_name](**function_args)

        # Add the response to the conversation
        messages.append(response_message)
        messages.append({
            "role": "tool",
            "content": function_response,
            "tool_call_id": response_message.tool_calls[0].id,
        })

        # Call the model again to summarize the results
        second_response = chat_completion_request(messages)
        final_message = second_response.choices[0].message.content
    else:
        final_message = response_message.content

    return final_message
```

### S3 bucket bot testing
In the following examples, make sure to replace the placeholders such as `<file_name>`, `<bucket_name>`, and `<directory_path>` with your specific values before execution.

#### Listing and searching

Let's start by listing all the available buckets.

```python
print(run_conversation('list my S3 buckets'))
```

You can ask the assistant to search for a specific file name either in all the buckets or in a specific one.

```python
search_file = '<file_name>'
print(run_conversation(f'search for a file {search_file} in all buckets'))
```

```python
search_word = '<file_name_part>'
bucket_name = '<bucket_name>'
print(run_conversation(f'search for a file contains {search_word} in {bucket_name}'))
```

The model is expected to clarify the ask from the user in case of ambiguity in the parameters values as described in the system message.

```python
print(run_conversation('search for a file'))
```

#### Validate edge cases

We also instructed the model to reject irrelevant tasks. Let's test it out and see how it works in action.

```python
# the model should not answer details not related to the scope
print(run_conversation('what is the weather today'))
```

The provided functions are not limited to just retrieving information. They can also assist the user in uploading or downloading files.

#### Download a file

```python
search_file = '<file_name>'
bucket_name = '<bucket_name>'
local_directory = '<directory_path>'
print(run_conversation(f'download {search_file} from {bucket_name} bucket to {local_directory} directory'))
```

#### Upload a file

```python
local_file = '<file_name>'
bucket_name = '<bucket_name>'
print(run_conversation(f'upload {local_file} to {bucket_name} bucket'))
```
