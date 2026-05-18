---
title: "Gpt Action Snowflake Middleware"
type: source
status: mirrored
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
  - https://developers.openai.com/cookbook/examples/chatgpt/gpt_actions_library/gpt_action_snowflake_middleware
  - https://github.com/openai/openai-cookbook/blob/main/examples/chatgpt/gpt_actions_library/gpt_action_snowflake_middleware.ipynb
---

# Gpt Action Snowflake Middleware

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/chatgpt/gpt_actions_library/gpt_action_snowflake_middleware
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/chatgpt/gpt_actions_library/gpt_action_snowflake_middleware.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/chatgpt/gpt_actions_library/gpt_action_snowflake_middleware.ipynb
- Source path: `examples/chatgpt/gpt_actions_library/gpt_action_snowflake_middleware.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `df77243d103cb44b3123cdb599463c0402917f6d16e62722528859dbd3c9082d`

## Classification

- Primary category: ChatGPT / GPT Actions
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

GPT Actions - Snowflake middleware Introduction This page provides an instruction & guide for developers building a GPT Action for a specific application. Before you proceed, make sure to first familiarize yourself with the following information: Introduction to GPT Actions Introduction to GPT Actions Library Example of Buliding a GPT Action from Scratch Thi...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: ChatGPT / GPT Actions.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# GPT Actions - Snowflake middleware
## Introduction


This page provides an instruction & guide for developers building a GPT Action for a specific application. Before you proceed, make sure to first familiarize yourself with the following information:

* [Introduction to GPT Actions](https://platform.openai.com/docs/actions)
* [Introduction to GPT Actions Library](https://platform.openai.com/docs/actions/actions-library)
* [Example of Buliding a GPT Action from Scratch](https://platform.openai.com/docs/actions/getting-started)


This guide provides details on how to connect ChatGPT with a Snowflake Data Warehouse for the purposes of returning a SQL query to ChatGPT for use with [Data Analysis](https://help.openai.com/en/articles/8437071-data-analysis-with-chatgpt). The GPT requires an action that interfaces with middleware (ie Azure function) so that the action can properly format the response from Snowflake for use in the Python notebook environment. Data must be [returned as a file](https://platform.openai.com/docs/actions/sending-files/returning-files), so the middleware function should transform the SQL response into a CSV/Excel file, under 10MB in size.

This document will outline the Middleware function GPT action. For setting up the middleware function itself, see [GPT Actions library (Middleware) - Azure Functions](https://cookbook.openai.com/examples/chatgpt/gpt_actions_library/gpt_middleware_azure_function). You can combine this Snowflake middleware action with an action to Snowflake Directly to enable a GPT that can form and test SQL queries prior to executing them.

### Value + Example Business Use Cases


Existing Snowflake customers can leverage these guidelines to query data from their data warehouse and load that data into the Data Analysis Python environment for further insights. This enables ChatGPT powered analysis such as visualizing data sets, identifying patterns/anomalies, or identifying gaps for data cleansing purposes. This GPT can be used to drive business decisions from relatively small datasets, or to explore subsets of data through AI to generate hypotheses as you explore the holistic dataset in your BI tool, saving time and money, while identifying previously unseen patterns.

## Application Information

### Application Key Links


Check out these links from Snowflake and Azure before you get started:

**Snowflake Action**

* Application Website: [https://app.snowflake.com/](https://app.snowflake.com/)
* Application Python Connector Documentation: [https://docs.snowflake.com/en/developer-guide/python-connector/python-connector-connect](https://docs.snowflake.com/en/developer-guide/python-connector/python-connector-connect)

**Azure Function**

* Application Website: [https://learn.microsoft.com/en-us/azure/azure-functions/](https://learn.microsoft.com/en-us/azure/azure-functions/)
* Application API Documentation: [https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference/](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference/)

### Application Prerequisites


Before you get started, make sure you go through the following steps in your application environment:

* Provision a Snowflake Data Warehouse
* Ensure that the user authenticating into Snowflake via ChatGPT has access to the database, schemas, and tables with the necessary role

In addition, before creating your application in Azure Function App, you’ll need a way to handle user authentication. You’ll need to set up an OAuth App Registration in Azure Entra ID that can be linked with a Snowflake External OAuth security integration. Snowflake’s External OAuth security integrations allow external systems to issue access tokens that Snowflake can use for determining level of access. In this case, that external token provider is Azure Entra ID. Since ChatGPT will connect to Azure rather than Snowflake, the GPT user’s OAuth token will be provisioned by Azure associated with their user in Entra ID. Thus you’ll need a way to map users in Snowflake to their corresponding user in Azure.

All of the necessary steps for both the Azure side and the Snowflake side are laid out below.

## Configure the OAuth resource in Azure Entra ID


We’ll set up a new App Registration, configure the necessary Snowflake Scopes in Azure that will be used, and retrieve all of the OAuth configuration parameters that will be needed in both Snowflake and ChatGPT. This section will all be in Azure so that in the next section, you’ll have the necessary info to link to this App Registration when configuring on the Snowflake side.

1. Navigate to the [Microsoft Azure Portal](https://portal.azure.com/) and authenticate.
2. Navigate to Azure Entra ID (formerly Active Directory).
3. Click on **App Registrations** under **Manage**.
4. Click on **New Registration**.
5. Enter `Snowflake GPT OAuth Client`, or similar value as the **Name**.
6. Verify the **Supported account types** is set to **Single Tenant**.
7. Ignore Redirect URI for now. You will come back for this once you are configuring your GPT
8. Click **Register**.
9. Note down the **Directory (tenant) ID** (`TENANT_ID`) under **Essentials**. You will use this to generate your `AZURE_AD_ISSUER` and `AZURE_AD_JWS_KEY_ENDPOINT.`
    * The `AZURE_AD_ISSUER` is `https://sts.windows.net/TENANT_ID/`
    *  The `AZURE_AD_JWS_KEY_ENDPOINT` is `https://login.microsoftonline.com/TENANT_ID/discovery/v2.0/keys`
10. Click on **Endpoints** in the **Overview** interface.
11. On the right-hand side, note the **OAuth 2.0 authorization endpoint (v2)** as the `AZURE_AD_OAUTH_AUTHORIZATION_ENDPOINT`  and **OAuth 2.0 token endpoint (v2)** as the `AZURE_AD_OAUTH_TOKEN_ENDPOINT`.
    * The endpoints should be similar to `https://login.microsoftonline.com/90288a9b-97df-4c6d-b025-95713f21cef9/oauth2/v2.0/authorization` and `https://login.microsoftonline.com/90288a9b-97df-4c6d-b025-95713f21cef9/oauth2/v2.0/token`.
12. Click on **Expose an API **under **Manage**.
13. Click on the **Set** link next to **Application ID URI** to set the `Application ID URI`.
    * The `Application ID URI` must be unique within your organization’s directory, such as `https://your.company.com/4d2a8c2b-a5f4-4b86-93ca-294185f45f2e`. This value will be referred to as the `<SNOWFLAKE_APPLICATION_ID_URI>` in the subsequent configuration steps.
14. To add a Snowflake Role as an OAuth scope for OAuth flows where the programmatic client acts on behalf of a user, click on **Add a scope** to add a scope representing the Snowflake role.
    * Enter the scope by having the name of the Snowflake role with the `session:scope:` prefix. For example, for the Snowflake Analyst role, enter `session:scope:analyst`.
    * Select who can consent.
    * Enter a **display name** for the scope (e.g.: Account Admin).
    * Enter a **description** for the scope (e.g.: Can administer the Snowflake account).
    * Click **Add Scope**.
    * Save the scope as `AZURE_AD_SCOPE`. It should be a concatenation of your `Application ID URI` and your `Scope name`
15. In the **Overview** section, copy the `ClientID` from the **Application (client) ID** field. This will be known as the `OAUTH_CLIENT_ID` in the following steps.
16. Click on **Certificates & secrets** and then **New client secret**.
17. Add a description of the secret.
18. Select **730 days (24 months)**. For testing purposes, select secrets that don’t expire soon.
19. Click **Add**. Copy the secret. This will be known as the `OAUTH_CLIENT_SECRET` in the following steps.
20. For programmatic clients that will request an Access Token on behalf of a user, configure Delegated permissions for Applications as follows.
    * Click on **API Permissions**.
    * Click on **Add Permission**.
    * Click on **My APIs**.
    * Click on the **Snowflake OAuth Resource** that you created in [Configure the OAuth resource in Azure AD](https://docs.snowflake.com/en/user-guide/oauth-azure#configure-the-oauth-resource-in-azure-ad).
    * Click on the **Delegated Permissions** box.
    * Check on the Permission related to the Scopes defined in the Application that you wish to grant to this client.
    * Click **Add Permissions**.
    * Click on the **Grant Admin Consent** button to grant the permissions to the client. Note that for testing purposes, permissions are configured this way. However, in a production environment, granting permissions in this manner is not advisable.
    * Click **Yes**.

## Create a security integration in Snowflake

Once the App Registration is complete in Azure Entra ID, the next step is to link that App Registration to Snowflake via an External OAuth Security Integration. The `external_oauth_audience_list` parameter of the security integration must match the **Application ID URI** that you specified while configuring Azure Entra ID.

The **Issuer** and the **JWS Keys endpoint** will also come from values collected in the previous steps. The **User Mapping Attribute** can either be set to `EMAIL_ADDRESS` or `LOGIN_NAME`, and this is how user’s Microsoft login credentials will be mapped to their user in Snowflake to ensure permissions in Snowflake are honored by the access token issued to ChatGPT.

```python
CREATE OR REPLACE SECURITY INTEGRATION AZURE_OAUTH_INTEGRATION
  TYPE = EXTERNAL_OAUTH
  ENABLED = TRUE
  EXTERNAL_OAUTH_TYPE = 'AZURE'
  EXTERNAL_OAUTH_ISSUER = '<AZURE_AD_ISSUER>'
  EXTERNAL_OAUTH_JWS_KEYS_URL = '<AZURE_AD_JWS_KEY_ENDPOINT>'
  EXTERNAL_OAUTH_AUDIENCE_LIST = ('<SNOWFLAKE_APPLICATION_ID_URI>')
  EXTERNAL_OAUTH_TOKEN_USER_MAPPING_CLAIM = 'upn'
  EXTERNAL_OAUTH_SNOWFLAKE_USER_MAPPING_ATTRIBUTE = 'EMAIL_ADDRESS';
```

### Middleware information:

Make sure you go through the following steps in your Azure environment:

* Azure Portal or VS Code with access to create Azure Function Apps and Azure Entra App Registrations
* There is [a detailed section in this guide](#azure-function-app) related to deploying and designing the function required to wrap the response from Snowflake in order to return the query results as a CSV to ChatGPT. The Azure Function App allows your GPT to ingest larger datasets as ChatGPT can ingest more data from files responses rather than from application/json payloads. Additionally, those datasets will only be available for Data Analysis (aka Code Interpreter) with a response formatted as a CSV file.

### Azure Function App

Now that we have the GPT created and handled Azure/Snowflake authentication, we can create the Azure Function App itself to execute the SQL query and handle the response formatting enabling the GPT to download the result as a CSV for use with Data Analysis.

Follow this [Azure Cookbook Guide](https://cookbook.openai.com/examples/azure/functions) for further details deploying an Azure Function App. Below you will find sample code to add to the function.

This code is meant to be directional - while it should work out of the box, you should customize it based on the needs specific to your GPT and your IT setup.

### Application Code

You’ll need to setup the following flows in your Azure Function App:

* Extracting the token from the HTTP request and using it to connect to Snowflake
* Executing the SQL query and writing the results to a CSV
* Temporarily storing that CSV in Blob Storage*
* Generating a pre-signed URL to access that CSV securely*
* Responding with an openaiFileResponse

*These steps may not be required if you use the [file stream](https://platform.openai.com/docs/actions/getting-started/inline-option) option instead of the [url](https://platform.openai.com/docs/actions/getting-started/url-option) option for returning files to your GPT. More on this below.

Ensure you have the necessary libraries installed and imported into your script. In addition to Python standard libraries, this sample script leveraged the following:

```python
import azure.functions as func
from azure.storage.blob import BlobServiceClient, generate_blob_sas, BlobSasPermissions, ContentSettings
import snowflake.connector
import jwt    # pyjwt for token decoding
```

#### Connecting to Snowflake

To connect to Snowflake, you’ll need to extract the access token assigned from Azure Entra ID from the Authorization header and use that token when connecting to the Snowflake server.

In this this example, Snowflake usernames are email addresses which simplifies the mapping of the Entra ID user extracted from the HTTP access token to the Snowflake user ID needed to connect. If this is not the case for your organization, you can map email addresses to Snowflake user IDs in your Python application.

My application was built to interface with a single Snowflake Account (i.e. ab12345.eastus2.azure) and Warehouse. If you need to access multiple accounts or warehouses, you may consider passing these parameters in your GPT action parameters so you can extract them from the HTTP request.

```python
# Extract the token from the Authorization header
auth_header = req.headers.get('Authorization')
token_type, token = auth_header.split()

try:
    # Extract email address from token to use for Snowflake user mapping
    # If Snowflake usernames are not emails, then identify the username accordingly
    decoded_token = jwt.decode(token, options={"verify_signature": False})
    email = decoded_token.get('upn')

    conn = snowflake.connector.connect(
        user=email, # Snowflake username, i.e., user's email in my example
        account=SNOWFLAKE_ACCOUNT, # Snowflake account, i.e., ab12345.eastus2.azure
        authenticator="oauth",
        token=token,
        warehouse=SNOWFLAKE_WAREHOUSE # Replace with Snowflake warehouse
    )
    logging.info("Successfully connected to Snowflake.")
except Exception as e:
    logging.error(f"Failed to connect to Snowflake: {e}")
```

#### Execute query and save CSV

Once you connect to Snowflake you’ll need to execute the query and store the results into a CSV. While the role in Snowflake should prevent any chance of harmful queries, you may want to sanitize your query in your application (not included below) just as you would any other programmatic SQL query execution.

```python
# Extract SQL query from request parameters or body
sql_query = req.params.get('sql_query')

try:
    # Use the specified warehouse
    cursor = conn.cursor()

    # Execute the query
    cursor.execute(sql_query)
    results = cursor.fetchall()
    column_names = [desc[0] for desc in cursor.description]
    logger.info(f"Query executed successfully: {sql_query}")

    # Convert results to CSV
    csv_file_path = write_results_to_csv(results, column_names)
except Exception as e:
    logger.error(f"Error executing query or processing data: {e}")


def write_results_to_csv(results, column_names):
    try:
        # Create a temporary file
        temp_file = tempfile.NamedTemporaryFile(delete=False, mode='w', newline='')
        csv_writer = csv.writer(temp_file)
        csv_writer.writerow(column_names)  # Write the column headers
        csv_writer.writerows(results)      # Write the data rows
        temp_file.close()  # Close the file to flush the contents
        return temp_file.name  # Return file path
    except Exception as e:
        logger.error(f"Error writing results to CSV: {e}")
```

#### Storing the file in Blob Storage

There are 2 methods for returning files to ChatGPT for processing. You can either [stream](https://platform.openai.com/docs/actions/getting-started/inline-option) the base64 encoded data along with the mimeType and file name in the openaiFileResponse list response, or you can return a [list of URLs](https://platform.openai.com/docs/actions/getting-started/url-option). In this solution we’ll focus on the latter.

To do this, you’ll need to upload the CSV to Azure Blob Storage and return a pre-signed URL for accessing that file securely in ChatGPT. It is important to note that in order to download a URL in ChatGPT, you’ll need to ensure that URL includes a content_type and content_disposition, as in the below example. If you’d like to inspect whether a URL has the necessary headers, you can use ``curl -I <url>`` from any terminal.

You’ll need to get a connection String for your Azure storage bucket, as per instructions [here](https://learn.microsoft.com/en-us/azure/storage/common/storage-configure-connection-string).

```python
def upload_csv_to_azure(file_path, container_name, blob_name, connect_str):
    try:
        # Create the BlobServiceClient object which will be used to create a container client
        blob_service_client = BlobServiceClient.from_connection_string(connect_str)

        # Create a blob client using the local file name as the name for the blob
        blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)

        # Upload the file with specified content settings
        with open(file_path, "rb") as data:
            blob_client.upload_blob(data, overwrite=True, content_settings=ContentSettings(
                content_type='text/csv',
                content_disposition=f'attachment; filename="{blob_name}"'
            ))
        logger.info(f"Successfully uploaded {file_path} to {container_name}/{blob_name}")

        # Generate a SAS token for the blob
        sas_token = generate_blob_sas(
            account_name=blob_service_client.account_name,
            container_name=container_name,
            blob_name=blob_name,
            account_key=blob_service_client.credential.account_key,
            permission=BlobSasPermissions(read=True),
            expiry=datetime.datetime.utcnow() + datetime.timedelta(hours=1)  # Token valid for 1 hour
        )

        # Generate a presigned URL using the SAS token
        url = f"https://{blob_service_client.account_name}.blob.core.windows.net/{container_name}/{blob_name}?{sas_token}"
        logger.info(f"Generated presigned URL: {url}")

        return url
    except Exception as e:
        logger.error(f"Error uploading file to Azure Blob Storage: {e}")
        raise
```

#### Format openaiFileResponse

Lastly, you’ll need to format the response appropriately to instruct ChatGPT to process that response as a file or series of files. The openaiFileResponse is a list which can include up to 10 URLs (or base64 encodings if using the [inline option](https://platform.openai.com/docs/actions/getting-started/inline-option)).

```python
# Format the response so ChatGPT treats it as a file
response = {
    'openaiFileResponse': [csv_url]
}
cursor.close()
conn.close()
return func.HttpResponse(
    json.dumps(response),
    status_code=200
)
```


There are a lot of moving pieces to this application, so testing your Azure Function App can be important. ChatGPT can be a difficult testing grounds given that requests and responses can sometimes be more opaque than needed for debugging. Initial testing of your application through cURL or Postman to invoke the HTTP request from a more controlled environment will allow you to debug and triage issues more easily. Once you determine that responses are being returned as expected in those tools, you are ready to build your GPT.

## ChatGPT Steps

### Custom GPT Instructions

Once you've created a Custom GPT, use the text below in the Instructions panel for inspiration. Have questions? Check out [Getting Started Example](https://platform.openai.com/docs/actions/getting-started) to see how this step works in more detail.

##### Example Instructions

It is important that ChatGPT understands your table schema to properly form SQL queries. There are different methods for doing so, and this Instruction set represents the most direct way. We are working to publish additional instructions for different versions of Snowflake GPTs you may want to build to allow for working with multiple different tables, schemas and databases, or to even learn dynamically for schemas that tend to change over time.

Below are some basic instructions when working with a single schema and table. This GPT has been optimized for a single use case (analyzing flight data from January 2013 out of NYC) which allows for the most simple instructions to provide the most reliable GPT performance.

You are an expert at writing SQL queries to fetch data from Snowflake. You help users convert their prompts into SQL queries. Any question around flight data will be converted into a Snowflake SQL query that hits the table `FLIGHTS.PUBLIC.JAN_2013_NYC`. Pass any query into the "sql_query" parameter


The schema of the table includes
```
ID	NUMBER	A unique identifier for each flight
YEAR	NUMBER	The year of the flight
MONTH	NUMBER	The month of the flight
DAY		NUMBER	The day of the month on which the flight departed
DEP_TIME	NUMBER	The actual departure time of the flight
SCHED_DEP_TIME	NUMBER	The scheduled departure time of the flight
DEP_DELAY	NUMBER	The departure delay in minutes (negative values indicate early departures)
ARR_TIME	NUMBER	The actual arrival time of the flight
SCHED_ARR_TIME	NUMBER	The scheduled arrival time of the flight
ARR_DELAY	NUMBER	The arrival delay in minutes (negative values indicate early arrivals)
CARRIER_CODE	TEXT	The carrier code of the airline
FLIGHT	NUMBER	The flight number
TAILNUM	TEXT	The aircraft tail number
ORIGIN_AIRPORT_CODE	TEXT	The origin airport code
DEST_AIRPORT_CODE	TEXT	The destination airport code
AIR_TIME	NUMBER	The total airtime of the flight in minutes
DISTANCE	NUMBER	The distance traveled by the flight in miles
HOUR	NUMBER	The hour part of the scheduled departure time
MINUTE	NUMBER	The minute part of the scheduled departure time
TIME_HOUR	NUMBER	The time at which the flight departed (rounded to the nearest hour)
CARRIER_NAME	TEXT	The full name of the airline carrier
ORIGIN_AIRPORT_NAME	TEXT	The full name of the origin airport
ORIGIN_REGION	TEXT	The region code of the origin airport
ORIGIN_MUNICIPALITY	TEXT	The city where the origin airport is located
ORIGIN_COORDINATES	TEXT	The geographical coordinates of the origin airport
DEST_AIRPORT_NAME	TEXT	The full name of the destination airport
DEST_REGION	TEXT	The region code of the destination airport
DEST_MUNICIPALITY	TEXT	The city where the destination airport is located
DEST_COORDINATES	TEXT	The geographical coordinates of the destination airport
```


When a user asks for data around flights, perform the following:


1. Use the `executeSQL` action to send a POST request to the Azure function endpoint
2. Receive the file that is returned as part of the Action response. Display it as a spreadsheet
3. Perform analysis on the file and provide the necessary information that the user has asked for


The user will wish to ask questions about the data in code interpreter, so use that for any data analysis insights from the dataset you pulled.

### OpenAPI Schema

Once you've created a Custom GPT, copy the text below in the Actions panel, replacing the placeholder values with your specific function details and updating your parameters based on any additional inputs you built into your Azure Function App.

Have questions? Check out [Getting Started Example](https://platform.openai.com/docs/actions/getting-started) to see how this step works in more detail.

```python
openapi: 3.1.0
info:
  title: Snowflake GPT API
  description: API to execute SQL queries on Snowflake and get the results as a CSV file URL.
  version: 1.0.0
servers:
  - url: https://<server-name>.azurewebsites.net
    description: Azure Function App server running Snowflake integration application
paths:
  /api/<function_name>?code=<code>:
    post:
      operationId: executeSQL
      summary: Executes a SQL query on Snowflake and returns the result file URL as a CSV.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                sql_query:
                  type: string
                  description: The SQL query to be executed on Snowflake.
              required:
                - sql_query
      responses:
        '200':
          description: Successfully executed the query.
          content:
            application/json:
              schema:
                type: object
                properties:
                  openaiFileResponse:
                    type: array
                    items:
                      type: string
                      format: uri
                    description: Array of URLs pointing to the result files.
        '401':
          description: Unauthorized. Missing or invalid authentication token.
        '400':
          description: Bad Request. The request was invalid or cannot be otherwise served.
        '500':
          description: Internal Server Error. An error occurred on the server.
components:
  schemas: {}
```

### FAQ & Troubleshooting

* Files returned to ChatGPT are limited in size to 10MB. Your request may fail if the file returned is larger than that. Ensure to include LIMITs on your SQL commands if you find you are running into these limitations.
* _Why is the Azure Function App requred in the first place?_ ChatGPT’s Data Analysis feature (aka Code Interpreter) depends on a secure Python environment that is separate from the model’s context window. Data passed to Data Analysis must be done so by uploading a file today. GPT actions returning data must then return that data as a CSV or other data file type. In order to return a file via GPT action, the response must be wrapped in an `openaiFileResponse` object. This requires custom code to properly format the response.
* _My company uses a different cloud provider than Azure._ For connecting other middleware functions to ChatGPT via GPT action, please refer to other [AWS](https://cookbook.openai.com/examples/chatgpt/gpt_actions_library/gpt_middleware_aws_function) or [GCP](https://cookbook.openai.com/examples/chatgpt/gpt_actions_library/gpt_middleware_google_cloud_function) middleware cookbooks. You can use the concepts discussed in this cookbook to advise on considerations when building your middleware app, but connecting that middleware to Snowflake may be different for different cloud providers. For example, Snowflake built an External OAuth integration specifically for linking with Azure Entra ID.
* _How do I limit the datasets that my GPT has access to?_ It can be imporant to limit the scope of access ChatGPT has within Snowflake. There are a few ways to do this:
    * Snowflake roles can limit who has access to which tables, and will be respected by the GPT user’s access token provisioned by Azure Entra ID
    * In your middleware function you can add sanity checks to verify the tables accessed are approved by for that application
    * You may want to generate an entirely new Database/Warehouse specific to integrating with ChatGPT that is scrubbed of anything sensitive, such as PII.
* _Schema calls the wrong warehouse or dataset:_ If ChatGPT calls the wrong warehouse or database, consider updating your instructions to make it more explicit either (a) which warehouse / database should be called or (b) to require the user provide those exact details before it runs the query


_Are there integrations that you’d like us to prioritize? Are there errors in our integrations? File a PR or issue in our github, and we’ll take a look._
