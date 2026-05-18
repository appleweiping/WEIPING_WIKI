---
title: "Gpt Action Box"
type: source
status: imported
created: 2026-05-15
updated: 2026-05-18
tags:
  - chatgpt
  - cookbook
  - example
  - gpt-actions
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/chatgpt/gpt_actions_library/gpt_action_box
  - https://github.com/openai/openai-cookbook/blob/main/examples/chatgpt/gpt_actions_library/gpt_action_box.ipynb
---

# Gpt Action Box

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/chatgpt/gpt_actions_library/gpt_action_box
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/chatgpt/gpt_actions_library/gpt_action_box.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/chatgpt/gpt_actions_library/gpt_action_box.ipynb
- Source path: `examples/chatgpt/gpt_actions_library/gpt_action_box.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `be41fc3172c6a166a8adf46f0b7b1dba8494e0211989458f6572d3b00c8177c4`

## Classification

- Primary category: ChatGPT / GPT Actions
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

GPT Action Library: Box Introduction This page provides an instruction & guide for developers building a GPT Action for a specific application. Before you proceed, make sure to first familiarize yourself with the following information: - Introduction to GPT Actions - Introduction to GPT Actions Library - Example of Buliding a GPT Action from Scratch This gui...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: ChatGPT / GPT Actions.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# GPT Action Library: Box

## Introduction

This page provides an instruction & guide for developers building a GPT Action for a specific application. Before you proceed, make sure to first familiarize yourself with the following information:
- [Introduction to GPT Actions](https://platform.openai.com/docs/actions)
- [Introduction to GPT Actions Library](https://platform.openai.com/docs/actions/actions-library)
- [Example of Buliding a GPT Action from Scratch](https://platform.openai.com/docs/actions/getting-started)

This guide provides details on how to connect chatGPT with a Box.com account, the GPT requires two actions to pull data from Box. The GPT will interact with the Box API directly but requires middleware (ie Azure function) to properly format the response from Box to download and read the file contents. The azure function action is transparent to the end user, meaning the user will not need to explicity call the action.

- Action 1 : Box API Action - Leverages the Box API to query data from Box
- Action 2 : Azure function - Formats response from Box enabling chatGPT to download the file directly from Box

### Value + Example Business Use Cases

Existing Box customers can leverage these guidelines to query details about files, contents of files and any metadata related. This enables a OpenAI powered analysis of any content stored in Box such as visualizing data sets and creating summaries across multiple folders and files. This GPT can access folders, files and business process data such as metadata in Box. Additionally Box admins can use this GPT action for visibility into audit trails and health checks.

## Application Information

### Application Key Links

Check out these links from Box and Azure before you get started:

**Box Action**
- Application Website: https://app.box.com
- Application API Documentation: https://developer.box.com/reference/

</br>

**Azure Function**
- Application Website: https://learn.microsoft.com/en-us/azure/azure-functions/
- Application API Documentation: https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference/

### Application Prerequisites

Before you get started, make sure you go through the following steps in your Box environment:
- This requires a Box developer account to get started : https://developer.box.com/
- Follow the Box Developer site to create a custom app with OAuth 2.0 authentication type  : https://developer.box.com/guides/getting-started/first-application/
- Navigate to **Configuration** tab for the following values
    - OAuth 2.0 Credentials (**Client ID** / **Client Secret**) You will need both of these values for the chatGPT configuration
    - OAuth 2.0 **Redirect URIs** : You will fill this value in from chatGPT action configuration below
    - Application scopes (**Read all files and folders in Box**, **Manage Enterprise properties**)

You will want to keep this window open, the Redirct URIs needs to be filled in from the gpt configuration.



![gpt_actions_box_boxconfig1.png.png](../../../images/gpt_actions_box_boxconfig1.png)

</br>


### Middleware information : required for Action 2

Make sure you go through the following steps in your Azure environment:
- Azure Portal with access to create Azure Function Apps and Azure Entra App Registrations
- There is a detailed section in this guide related to deploying and designing the function required to wrap the response from Box in order to view the contents of the file. Without the function the GPT will only be able to query data about the file and not the contents. Be sure to read this section after creating the first action.

## ChatGPT Steps

### Custom GPT Instructions

Once you've created a Custom GPT, copy the text below in the Instructions panel. Have questions? Check out [Getting Started Example](https://platform.openai.com/docs/actions/getting-started) to see how this step works in more detail.

```python
**context**

This GPT will connect to your Box.com account to search files and folders, providing accurate and helpful responses based on the user's queries. It will assist with finding, organizing, and retrieving information stored in Box.com. Ensure secure and private handling of any accessed data. Avoid performing any actions that could modify or delete files unless explicitly instructed. Prioritize clarity and efficiency in responses. Use simple language for ease of understanding. Ask for clarification if a request is ambiguous or if additional details are needed to perform a search. Maintain a professional and friendly tone, ensuring users feel comfortable and supported.


Please use this website for instructions using the box API : https://developer.box.com/reference/ each endpoint can be found from this reference documentation

Users can search with the Box search endpoint or Box metadata search endpoint

**instructions**
When retrieving file information from Box provide as much details as possible and format into a table when more than one file is returned, include the modified date, created date and any other headers you might find valuable

Provide insights to files and suggest patterns for users, gives example queries and suggestions when appropriate

When a user wants to compare files retrieve the file for the user with out asking
```

### Action 1 : Box API Action

Once you've created a Custom GPT, you will need to create 2 actions. Copy the text below in the 1st Actions panel, this will be for the Box action. Have questions? Check out [Getting Started Example](https://platform.openai.com/docs/actions/getting-started) to see how this step works in more detail.

```python
{
  "openapi": "3.1.0",
  "info": {
    "title": "Box.com API",
    "description": "API for Box.com services",
    "version": "v1.0.0"
  },
  "servers": [
    {
      "url": "https://api.box.com/2.0"
    }
  ],
  "paths": {
    "/folders/{folder_id}": {
      "get": {
        "summary": "Get Folder Items",
        "operationId": "getFolderItems",
        "parameters": [
          {
            "name": "folder_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            },
            "description": "The ID of the folder"
          }
        ],
        "responses": {
          "200": {
            "description": "A list of items in the folder",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/FolderItems"
                }
              }
            }
          }
        },
        "security": [
          {
            "OAuth2": [
              "read:folders"
            ]
          }
        ]
      }
    },
    "/files/{file_id}": {
      "get": {
        "summary": "Get File Information",
        "operationId": "getFileInfo",
        "parameters": [
          {
            "name": "file_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            },
            "description": "The ID of the file"
          }
        ],
        "responses": {
          "200": {
            "description": "File information",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/FileInfo"
                }
              }
            }
          }
        },
        "security": [
          {
            "OAuth2": [
              "read:files"
            ]
          }
        ]
      }
    },
    "/folders": {
      "get": {
        "summary": "List All Folders",
        "operationId": "listAllFolders",
        "responses": {
          "200": {
            "description": "A list of all folders",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/FoldersList"
                }
              }
            }
          }
        },
        "security": [
          {
            "OAuth2": [
              "read:folders"
            ]
          }
        ]
      }
    },
    "/events": {
      "get": {
        "summary": "Get User Events",
        "operationId": "getUserEvents",
        "parameters": [
          {
            "name": "stream_type",
            "in": "query",
            "required": true,
            "schema": {
              "type": "string"
            },
            "description": "The type of stream"
          }
        ],
        "responses": {
          "200": {
            "description": "User events",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/UserEvents"
                }
              }
            }
          }
        },
        "security": [
          {
            "OAuth2": [
              "read:events"
            ]
          }
        ]
      }
    },
    "/admin_events": {
      "get": {
        "summary": "Get Admin Events",
        "operationId": "getAdminEvents",
        "responses": {
          "200": {
            "description": "Admin events",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/AdminEvents"
                }
              }
            }
          }
        },
        "security": [
          {
            "OAuth2": [
              "read:events"
            ]
          }
        ]
      }
    },
    "/search": {
      "get": {
        "summary": "Search",
        "operationId": "search",
        "parameters": [
          {
            "name": "query",
            "in": "query",
            "required": true,
            "schema": {
              "type": "string"
            },
            "description": "Search query"
          }
        ],
        "responses": {
          "200": {
            "description": "Search results",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/SearchResults"
                }
              }
            }
          }
        },
        "security": [
          {
            "OAuth2": [
              "search:items"
            ]
          }
        ]
      }
    },
    "/metadata_templates": {
      "get": {
        "summary": "Get Metadata Templates",
        "operationId": "getMetadataTemplates",
        "responses": {
          "200": {
            "description": "Metadata templates",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/MetadataTemplates"
                }
              }
            }
          }
        },
        "security": [
          {
            "OAuth2": [
              "read:metadata_templates"
            ]
          }
        ]
      }
    },
    "/metadata_templates/enterprise": {
      "get": {
        "summary": "Get Enterprise Metadata Templates",
        "operationId": "getEnterpriseMetadataTemplates",
        "responses": {
          "200": {
            "description": "Enterprise metadata templates",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/MetadataTemplates"
                }
              }
            }
          }
        },
        "security": [
          {
            "OAuth2": [
              "read:metadata_templates"
            ]
          }
        ]
      }
    },
    "/files/{file_id}/metadata": {
      "get": {
        "summary": "Get All Metadata for a File",
        "operationId": "getAllMetadataForFile",
        "parameters": [
          {
            "name": "file_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            },
            "description": "The ID of the file"
          }
        ],
        "responses": {
          "200": {
            "description": "All metadata instances for the file",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/MetadataInstances"
                }
              }
            }
          }
        },
        "security": [
          {
            "OAuth2": [
              "read:metadata"
            ]
          }
        ]
      }
    }
  },
  "components": {
    "schemas": {
      "FolderItems": {
        "type": "object",
        "properties": {
          "total_count": {
            "type": "integer",
            "description": "The total number of items in the folder"
          },
          "entries": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "type": {
                  "type": "string",
                  "description": "The type of the item (e.g., file, folder)"
                },
                "id": {
                  "type": "string",
                  "description": "The ID of the item"
                },
                "name": {
                  "type": "string",
                  "description": "The name of the item"
                }
              }
            }
          }
        }
      },
      "FileInfo": {
        "type": "object",
        "properties": {
          "id": {
            "type": "string",
            "description": "The ID of the file"
          },
          "name": {
            "type": "string",
            "description": "The name of the file"
          },
          "size": {
            "type": "integer",
            "description": "The size of the file in bytes"
          },
          "created_at": {
            "type": "string",
            "format": "date-time",
            "description": "The creation time of the file"
          },
          "modified_at": {
            "type": "string",
            "format": "date-time",
            "description": "The last modification time of the file"
          }
        }
      },
      "FoldersList": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "id": {
              "type": "string",
              "description": "The ID of the folder"
            },
            "name": {
              "type": "string",
              "description": "The name of the folder"
            }
          }
        }
      },
      "UserEvents": {
        "type": "object",
        "properties": {
          "entries": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "event_id": {
                  "type": "string",
                  "description": "The ID of the event"
                },
                "event_type": {
                  "type": "string",
                  "description": "The type of the event"
                },
                "created_at": {
                  "type": "string",
                  "format": "date-time",
                  "description": "The time the event occurred"
                }
              }
            }
          }
        }
      },
      "AdminEvents": {
        "type": "object",
        "properties": {
          "entries": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "event_id": {
                  "type": "string",
                  "description": "The ID of the event"
                },
                "event_type": {
                  "type": "string",
                  "description": "The type of the event"
                },
                "created_at": {
                  "type": "string",
                  "format": "date-time",
                  "description": "The time the event occurred"
                }
              }
            }
          }
        }
      },
      "SearchResults": {
        "type": "object",
        "properties": {
          "total_count": {
            "type": "integer",
            "description": "The total number of search results"
          },
          "entries": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "type": {
                  "type": "string",
                  "description": "The type of the item (e.g., file, folder)"
                },
                "id": {
                  "type": "string",
                  "description": "The ID of the item"
                },
                "name": {
                  "type": "string",
                  "description": "The name of the item"
                }
              }
            }
          }
        }
      },
      "MetadataTemplates": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "templateKey": {
              "type": "string",
              "description": "The key of the metadata template"
            },
            "displayName": {
              "type": "string",
              "description": "The display name of the metadata template"
            },
            "scope": {
              "type": "string",
              "description": "The scope of the metadata template"
            }
          }
        }
      },
      "MetadataInstances": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "templateKey": {
              "type": "string",
              "description": "The key of the metadata template"
            },
            "type": {
              "type": "string",
              "description": "The type of the metadata instance"
            },
            "attributes": {
              "type": "object",
              "additionalProperties": {
                "type": "string"
              },
              "description": "Attributes of the metadata instance"
            }
          }
        }
      }
    },
    "securitySchemes": {
      "OAuth2": {
        "type": "oauth2",
        "flows": {
          "authorizationCode": {
            "authorizationUrl": "https://account.box.com/api/oauth2/authorize",
            "tokenUrl": "https://api.box.com/oauth2/token",
            "scopes": {
              "read:folders": "Read folders",
              "read:files": "Read files",
              "search:items": "Search items",
              "read:metadata": "Read metadata",
              "read:metadata_templates": "Read metadata templates",
              "read:events": "Read events"
            }
          }
        }
      }
    }
  }
}
```

**Note : this schema above does not contain all possible API endpoints, be sure to edit the schema to produce the appropriate actions from [Box Developer documentation](https://developer.box.com)**

## Authentication Instructions

Below are instructions on setting up authentication with this 3rd party application. Have questions? Check out [Getting Started Example](https://platform.openai.com/docs/actions/getting-started) to see how this step works in more detail.

### In ChatGPT

In ChatGPT, click on "Authentication" and choose OAuth


<br> ![gptactions_box_gptauth.png](../../../images/gpt_actions_box_gptauth.png)

**OAuth Connection**

- Client ID - value from Box custom app you created earlier
- Client Secret - value from Box custom app you created earlier
- Authorization URL - : https://account.box.com/api/oauth2/authorize?response_type=code&client_id=[client ID from above]&redirect_uri=[use a placeholder like chat.openai.com/aip//oauth/callback for now, you’ll update this later when you create the Action in ChatGPT]
- Token URL : https:api.box.com/oauth2/token
</br>
</br>
You need to save the configuration and navigate back to the gpt Configuration tab to copy the Callback URL, edit the configuration for the Box action Authorization URL and format the URL as https://account.box.com/api/oauth2/authorize?response_type=code&client_id=[client_ID]&redirect_uri=[callBack URL]

### Post-Action Steps

Update the Box.com custom application
</br>
- Copy the CallBack URL from the gpt and add a OAuth 2.0 Redirect URIs in Box.com
</br>
</br>
![gpt_actions_box_boxconfig1.png.png](../../../images/gpt_actions_box_boxconfig1.png)

</br>

### Action 2 : Azure Function

Now that we have the GPT created and authenticating against Box.com, we can create the azure function to handle the response formatting enabling the GPT to download the files from Box.

Follow this [Azure Cookbook Guide](https://cookbook.openai.com/examples/azure/functions) for further details deploying an Azure function. Below you will find sample code to add to the function.

This code is meant to be directional - while it should work out of the box, it is designed to be customized to your need.</br>

</br>

**Data flow**

![gpt_actions_box_azureflow.png](../../../images/gpt_actions_box_azuredataflow.png)

</br></br>

Now that you have the azure function created, add the sample code below:

function_app.py

```python
import azure.functions as func
from boxsdk import Client, JWTAuth

import requests
import base64
import json
import jwt
import logging

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

@app.route(route="box_retrieval")
def box_retrieval(req: func.HttpRequest) -> func.HttpResponse:
    logger.info('Starting box_retrieval function')
    file_ids = req.params.get('file_ids')
    auth_header = req.headers.get('Authorization')

    if not file_ids or not auth_header:
        logger.error('Missing file_ids or Authorization header')
        return func.HttpResponse(
            "Missing file_id or Authorization header.",
            status_code=400
        )

    file_ids = file_ids.split(",")  # Assuming file_ids are passed as a comma-separated string
    if len(file_ids) == 0 or len(file_ids) > 10:
        logger.error('file_ids list is empty or contains more than 10 IDs')
        return func.HttpResponse(
            "file_ids list is empty or contains more than 10 IDs.",
            status_code=400
        )

    try:
        # Decode JWT to extract the email
        token = auth_header.split(" ")[1]
        decoded_token = jwt.decode(token, options={"verify_signature": False})
        upn = decoded_token['upn']
        user_email = get_user_mapping(upn)
        logger.info(f'User email extracted: {user_email}')

        config = JWTAuth.from_settings_file('jwt_config.json')
        sdk = Client(config)
        logger.info('Authenticated with Box API')

        # Use the user email to get the user ID
        users = sdk.users(filter_term=user_email)
        user = next(users)
        user_id = user.id
        logger.info(f'User ID obtained: {user_id}')

        openai_file_responses = []
        for file_id in file_ids:
            # Perform as_user call to get the file representation
            my_file = sdk.as_user(user).file(file_id).get()
            file_url = my_file.get_download_url()
            openai_file_responses.append(file_url)

        response_body = json.dumps({'openaiFileResponse': openai_file_responses})

        return func.HttpResponse(
            response_body,
            status_code=200,
            mimetype="application/json"
        )

    except Exception as e:
        return func.HttpResponse(
            f"An error occurred: {str(e)}",
            status_code=500
        )

def get_user_mapping(upn):
    # In our case, the user's authentication email into Azure AD is the same as their email in Box
    # If that is not the case, map the email in Box to the email in Azure AD
    return upn
```

jwt_config.json.sample

```python
{
    "boxAppSettings": {
      "clientID": "12345",
      "clientSecret": "abcde",
      "appAuth": {
        "publicKeyID": "123",
        "privateKey": "-----BEGIN ENCRYPTED PRIVATE KEY-----\nvwxyz==\n-----END ENCRYPTED PRIVATE KEY-----\n",
        "passphrase": "lmnop"
      }
    },
    "enterpriseID": "09876"
  }
```

requirements.txt

```python
boxsdk[jwt]
azure-functions
requests
pyjwt
```

Make sure to follow the rest of the Azure guide for post authentication steps and chatGPT configuration : [Azure Cookbook Guide](https://cookbook.openai.com/examples/azure/functions)

### FAQ & Troubleshooting

- *Schema calls the wrong project or dataset:* If ChatGPT calls the wrong project or dataset, consider updating your instructions to make it more explicit either (a) which project / dataset should be called or (b) to require the user provide those exact details before it runs the query
- Box can return a large set of data in the event stream which can cause errors,

*Are there integrations that you’d like us to prioritize? Are there errors in our integrations? File a PR or issue in our github, and we’ll take a look.*
