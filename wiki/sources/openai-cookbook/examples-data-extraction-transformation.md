---
title: "Data Extraction Transformation"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - example
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/data_extraction_transformation
  - https://github.com/openai/openai-cookbook/blob/main/examples/Data_extraction_transformation.ipynb
---

# Data Extraction Transformation

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/data_extraction_transformation
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Data_extraction_transformation.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Data_extraction_transformation.ipynb
- Source path: `examples/Data_extraction_transformation.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `b943849d90760911a1fe4ffb618f314031a41b10b66e7b60f94b70f1ab3d1cac`

## Classification

- Primary category: General OpenAI API patterns
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Data Extraction and Transformation in ELT Workflows using GPT-4o as an OCR Alternative A lot of enterprise data is unstructured and locked up in difficult-to-use formats, e.g. PDFs, PPT, PNG, that are not optimized for use with LLMs or databases. As a result this type of data tends to be underutilized for analysis and product development, despite it being so...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: General OpenAI API patterns.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Data Extraction and Transformation in ELT Workflows using GPT-4o as an OCR Alternative

A lot of enterprise data is unstructured and locked up in difficult-to-use formats, e.g. PDFs, PPT, PNG, that are not optimized for use with LLMs or databases. As a result this type of data tends to be underutilized for analysis and product development, despite it being so valuable. The traditional way of extracting information from unstructured or non-ideal formats has been to use OCR, but OCR struggles with complex layouts and can have limited multilingual support. Moreover, manually applying transforms to data can be cumbersome and timeconsuming.

The multi-modal capabilities of GPT-4o enable new ways to extract and transform data because of GPT-4o's ability to adapt to different types of documents and to use reasoning for interpreting the content of documents. Here are some reasons why you would choose GPT-4o for your extraction and transformation workflows over traditional methods.

| **Extraction**                                               | **Transformation**                                              |
|---------------------------------------------------------------|------------------------------------------------------------------|
| **Adaptable**: Handles complex document layouts better, reducing errors | **Schema Adaptability**: Easily transforms data to fit specific schemas for database ingestion |
| **Multilingual Support**: Seamlessly processes documents in multiple languages | **Dynamic Data Mapping**: Adapts to different data structures and formats, providing flexible transformation rules |
| **Contextual Understanding**: Extracts meaningful relationships and context, not just text | **Enhanced Insight Generation**: Applies reasoning to create more insightful transformations, enriching the dataset with derived metrics, metadata and relationships |
| **Multimodality**: Processes various document elements, including images and tables |  |

This cookbook has three parts:
1. How to extract data from multilingual PDFs
2. How to transform data according to a schema for loading into a database
3. How to load transformed data into a database for downstream analysis

We're going to mimic a simple ELT workflow where data is first extracted from PDFs into JSON using GPT-4o, stored in an unstructured format somewhere like a data lake, transformed to fit a schema using GPT-4o, and then finally ingested into a relational database for querying. It's worth noting that you can do all of this with the BatchAPI if you're interested in lowering the cost of this workflow.

![](../images/elt_workflow.png)

The data we'll be using is a set of publicly available 2019 hotel invoices from Germany available on [Jens Walter's GitHub](https://github.com/JensWalter/my-receipts/tree/master/2019/de/hotel), (thank you Jens!). Though hotel invoices generally contain similar information (reservation details, charges, taxes etc.), you'll notice that the invoices present itemized information in different ways and are multilingual containing both German and English. Fortunately GPT-4o can adapt to a variety of different document styles without us having to specify formats and it can seamlessly handle a variety of languages, even in the same document.
Here is what one of the invoices looks like:

![](../images/sample_hotel_invoice.png)

## Part 1: Extracting data from PDFs using GPT-4o's vision capabilities
GPT-4o doesn't natively handle PDFs so before we extract any data we'll first need to convert each page into an image and then encode the images as base64.

```python
from openai import OpenAI
import fitz  # PyMuPDF
import io
import os
from PIL import Image
import base64
import json

api_key = os.getenv("OPENAI_API_KEY")
client = OpenAI(api_key=api_key)


@staticmethod
def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode("utf-8")


def pdf_to_base64_images(pdf_path):
    #Handles PDFs with multiple pages
    pdf_document = fitz.open(pdf_path)
    base64_images = []
    temp_image_paths = []

    total_pages = len(pdf_document)

    for page_num in range(total_pages):
        page = pdf_document.load_page(page_num)
        pix = page.get_pixmap()
        img = Image.open(io.BytesIO(pix.tobytes()))
        temp_image_path = f"temp_page_{page_num}.png"
        img.save(temp_image_path, format="PNG")
        temp_image_paths.append(temp_image_path)
        base64_image = encode_image(temp_image_path)
        base64_images.append(base64_image)

    for temp_image_path in temp_image_paths:
        os.remove(temp_image_path)

    return base64_images
```

We can then pass each base64 encoded image in a GPT-4o LLM call, specifying a high level of detail and JSON as the response format. We're not concerned about enforcing a schema at this step, we just want all of the data to be extracted regardless of type.

```python
def extract_invoice_data(base64_image):
    system_prompt = f"""
    You are an OCR-like data extraction tool that extracts hotel invoice data from PDFs.

    1. Please extract the data in this hotel invoice, grouping data according to theme/sub groups, and then output into JSON.

    2. Please keep the keys and values of the JSON in the original language.

    3. The type of data you might encounter in the invoice includes but is not limited to: hotel information, guest information, invoice information,
    room charges, taxes, and total charges etc.

    4. If the page contains no charge data, please output an empty JSON object and don't make up any data.

    5. If there are blank data fields in the invoice, please include them as "null" values in the JSON object.

    6. If there are tables in the invoice, capture all of the rows and columns in the JSON object.
    Even if a column is blank, include it as a key in the JSON object with a null value.

    7. If a row is blank denote missing fields with "null" values.

    8. Don't interpolate or make up data.

    9. Please maintain the table structure of the charges, i.e. capture all of the rows and columns in the JSON object.

    """

    response = client.chat.completions.create(
        model="gpt-4o",
        response_format={ "type": "json_object" },
        messages=[
            {
                "role": "system",
                "content": system_prompt
            },
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": "extract the data in this hotel invoice and output into JSON "},
                    {"type": "image_url", "image_url": {"url": f"data:image/png;base64,{base64_image}", "detail": "high"}}
                ]
            }
        ],
        temperature=0.0,
    )
    return response.choices[0].message.content
```

Because invoice data can span multiple pages in a PDF, we're going to produce JSON objects for each page in the invoice and then append them together. The final invoice extraction will be a single JSON file.

```python
def extract_from_multiple_pages(base64_images, original_filename, output_directory):
    entire_invoice = []

    for base64_image in base64_images:
        invoice_json = extract_invoice_data(base64_image)
        invoice_data = json.loads(invoice_json)
        entire_invoice.append(invoice_data)

    # Ensure the output directory exists
    os.makedirs(output_directory, exist_ok=True)

    # Construct the output file path
    output_filename = os.path.join(output_directory, original_filename.replace('.pdf', '_extracted.json'))

    # Save the entire_invoice list as a JSON file
    with open(output_filename, 'w', encoding='utf-8') as f:
        json.dump(entire_invoice, f, ensure_ascii=False, indent=4)
    return output_filename


def main_extract(read_path, write_path):
    for filename in os.listdir(read_path):
        file_path = os.path.join(read_path, filename)
        if os.path.isfile(file_path):
            base64_images = pdf_to_base64_images(file_path)
            extract_from_multiple_pages(base64_images, filename, write_path)


read_path= "./data/hotel_invoices/receipts_2019_de_hotel"
write_path= "./data/hotel_invoices/extracted_invoice_json"

main_extract(read_path, write_path)
```

Each invoice JSON will have different keys depending on what data the original invoice contained, so at this point you can store the unschematized JSON files in a data lake that can handle unstructured data. For simplicity though, we're going to store the files in a folder. Here is what one of the extracted JSON files looks like, you'll notice that even though we didn't specify a schema, GPT-4o was able to understand German and group similar information together. Moreover, if there was a blank field in the invoice GPT-4o transcribed that as "null".

```python
[
    {
        "Hotel Information": {
            "Name": "Hamburg City (Zentrum)",
            "Address": "Willy-Brandt-Straße 21, 20457 Hamburg, Deutschland",
            "Phone": "+49 (0) 40 3039 379 0"
        },
        "Guest Information": {
            "Name": "APIMEISTER CONSULTING GmbH",
            "Guest": "Herr Jens Walter",
            "Address": "Friedrichstr. 123, 10117 Berlin"
        },
        "Invoice Information": {
            "Rechnungsnummer": "GABC19014325",
            "Rechnungsdatum": "23.09.19",
            "Referenznummer": "GABC015452127",
            "Buchungsnummer": "GABR15867",
            "Ankunft": "23.09.19",
            "Abreise": "27.09.19",
            "Nächte": 4,
            "Zimmer": 626,
            "Kundereferenz": 2
        },
        "Charges": [
            {
                "Datum": "23.09.19",
                "Uhrzeit": "16:36",
                "Beschreibung": "Übernachtung",
                "MwSt.%": 7.0,
                "Betrag": 77.0,
                "Zahlung": null
            },
            {
                "Datum": "24.09.19",
                "Uhrzeit": null,
                "Beschreibung": "Übernachtung",
                "MwSt.%": 7.0,
                "Betrag": 135.0,
                "Zahlung": null
            },
            {
                "Datum": "25.09.19",
                "Uhrzeit": null,
                "Beschreibung": "Übernachtung",
                "MwSt.%": 7.0,
                "Betrag": 82.0,
                "Zahlung": null
            },
            {
                "Datum": "26.09.19",
                "Uhrzeit": null,
                "Beschreibung": "Übernachtung",
                "MwSt.%": 7.0,
                "Betrag": 217.0,
                "Zahlung": null
            },
            {
                "Datum": "24.09.19",
                "Uhrzeit": "9:50",
                "Beschreibung": "Premier Inn Frühstücksbuffet",
                "MwSt.%": 19.0,
                "Betrag": 9.9,
                "Zahlung": null
            },
            {
                "Datum": "25.09.19",
                "Uhrzeit": "9:50",
                "Beschreibung": "Premier Inn Frühstücksbuffet",
                "MwSt.%": 19.0,
                "Betrag": 9.9,
                "Zahlung": null
            },
            {
                "Datum": "26.09.19",
                "Uhrzeit": "9:50",
                "Beschreibung": "Premier Inn Frühstücksbuffet",
                "MwSt.%": 19.0,
                "Betrag": 9.9,
                "Zahlung": null
            },
            {
                "Datum": "27.09.19",
                "Uhrzeit": "9:50",
                "Beschreibung": "Premier Inn Frühstücksbuffet",
                "MwSt.%": 19.0,
                "Betrag": 9.9,
                "Zahlung": null
            }
        ],
        "Payment Information": {
            "Zahlung": "550,60",
            "Gesamt (Rechnungsbetrag)": "550,60",
            "Offener Betrag": "0,00",
            "Bezahlart": "Mastercard-Kreditkarte"
        },
        "Tax Information": {
            "MwSt.%": [
                {
                    "Rate": 19.0,
                    "Netto": 33.28,
                    "MwSt.": 6.32,
                    "Brutto": 39.6
                },
                {
                    "Rate": 7.0,
                    "Netto": 477.57,
                    "MwSt.": 33.43,
                    "Brutto": 511.0
                }
            ]
        }
    }
]
```

## Part 2: Transforming data according to a schema

You've extracted data from PDFs and have likely loaded the unstructured extractions as JSON objects in a data lake. The next step in our ELT workflow is to use GPT-4o to transform the extractions according to our desired schema. This will enable us to ingest any resulting tables into a database. We've decided upon the following schema that broadly covers most of the information we would have seen across the different invoices. This schema will be used to process each raw JSON extraction into our desired schematized JSON and can specify particular formats such as "date": "YYYY-MM-DD". We're also going to translate the data into English at this step.

```python
[
    {
        "hotel_information": {
            "name": "string",
            "address": {
                "street": "string",
                "city": "string",
                "country": "string",
                "postal_code": "string"
            },
            "contact": {
                "phone": "string",
                "fax": "string",
                "email": "string",
                "website": "string"
            }
        },
        "guest_information": {
            "company": "string",
            "address": "string",
            "guest_name": "string"
        },
        "invoice_information": {
            "invoice_number": "string",
            "reservation_number": "string",
            "date": "YYYY-MM-DD",
            "room_number": "string",
            "check_in_date": "YYYY-MM-DD",
            "check_out_date": "YYYY-MM-DD"
        },
        "charges": [
            {
                "date": "YYYY-MM-DD",
                "description": "string",
                "charge": "number",
                "credit": "number"
            }
        ],
        "totals_summary": {
            "currency": "string",
            "total_net": "number",
            "total_tax": "number",
            "total_gross": "number",
            "total_charge": "number",
            "total_credit": "number",
            "balance_due": "number"
        },
        "taxes": [
            {
                "tax_type": "string",
                "tax_rate": "string",
                "net_amount": "number",
                "tax_amount": "number",
                "gross_amount": "number"
            }
        ]
    }
]
```

```python
def transform_invoice_data(json_raw, json_schema):
    system_prompt = f"""
    You are a data transformation tool that takes in JSON data and a reference JSON schema, and outputs JSON data according to the schema.
    Not all of the data in the input JSON will fit the schema, so you may need to omit some data or add null values to the output JSON.
    Translate all data into English if not already in English.
    Ensure values are formatted as specified in the schema (e.g. dates as YYYY-MM-DD).
    Here is the schema:
    {json_schema}

    """

    response = client.chat.completions.create(
        model="gpt-4o",
        response_format={ "type": "json_object" },
        messages=[
            {
                "role": "system",
                "content": system_prompt
            },
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": f"Transform the following raw JSON data according to the provided schema. Ensure all data is in English and formatted as specified by values in the schema. Here is the raw JSON: {json_raw}"}
                ]
            }
        ],
        temperature=0.0,
    )
    return json.loads(response.choices[0].message.content)



def main_transform(extracted_invoice_json_path, json_schema_path, save_path):
    # Load the JSON schema
    with open(json_schema_path, 'r', encoding='utf-8') as f:
        json_schema = json.load(f)

    # Ensure the save directory exists
    os.makedirs(save_path, exist_ok=True)

    # Process each JSON file in the extracted invoices directory
    for filename in os.listdir(extracted_invoice_json_path):
        if filename.endswith(".json"):
            file_path = os.path.join(extracted_invoice_json_path, filename)

            # Load the extracted JSON
            with open(file_path, 'r', encoding='utf-8') as f:
                json_raw = json.load(f)

            # Transform the JSON data
            transformed_json = transform_invoice_data(json_raw, json_schema)

            # Save the transformed JSON to the save directory
            transformed_filename = f"transformed_{filename}"
            transformed_file_path = os.path.join(save_path, transformed_filename)
            with open(transformed_file_path, 'w', encoding='utf-8') as f:
                json.dump(transformed_json, f, ensure_ascii=False, indent=2)


    extracted_invoice_json_path = "./data/hotel_invoices/extracted_invoice_json"
    json_schema_path = "./data/hotel_invoices/invoice_schema.json"
    save_path = "./data/hotel_invoices/transformed_invoice_json"

    main_transform(extracted_invoice_json_path, json_schema_path, save_path)
```

## Part 3: Loading transformed data into a database

Now that we've schematized all of our data, we can segment it into tables for ingesting into a relational database. In particular, we're going to create four tables: Hotels, Invoices, Charges and Taxes. All of the invoices pertained to one guest, so we won't create a guest table.

```python
import os
import json
import sqlite3

def ingest_transformed_jsons(json_folder_path, db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Create necessary tables
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS Hotels (
        hotel_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        street TEXT,
        city TEXT,
        country TEXT,
        postal_code TEXT,
        phone TEXT,
        fax TEXT,
        email TEXT,
        website TEXT
    )
    ''')

    cursor.execute('''
    CREATE TABLE IF NOT EXISTS Invoices (
        invoice_id INTEGER PRIMARY KEY AUTOINCREMENT,
        hotel_id INTEGER,
        invoice_number TEXT,
        reservation_number TEXT,
        date TEXT,
        room_number TEXT,
        check_in_date TEXT,
        check_out_date TEXT,
        currency TEXT,
        total_net REAL,
        total_tax REAL,
        total_gross REAL,
        total_charge REAL,
        total_credit REAL,
        balance_due REAL,
        guest_company TEXT,
        guest_address TEXT,
        guest_name TEXT,
        FOREIGN KEY(hotel_id) REFERENCES Hotels(hotel_id)
    )
    ''')

    cursor.execute('''
    CREATE TABLE IF NOT EXISTS Charges (
        charge_id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER,
        date TEXT,
        description TEXT,
        charge REAL,
        credit REAL,
        FOREIGN KEY(invoice_id) REFERENCES Invoices(invoice_id)
    )
    ''')

    cursor.execute('''
    CREATE TABLE IF NOT EXISTS Taxes (
        tax_id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER,
        tax_type TEXT,
        tax_rate TEXT,
        net_amount REAL,
        tax_amount REAL,
        gross_amount REAL,
        FOREIGN KEY(invoice_id) REFERENCES Invoices(invoice_id)
    )
    ''')

    # Loop over all JSON files in the specified folder
    for filename in os.listdir(json_folder_path):
        if filename.endswith(".json"):
            file_path = os.path.join(json_folder_path, filename)

            # Load the JSON data
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # Insert Hotel Information
            cursor.execute('''
            INSERT INTO Hotels (name, street, city, country, postal_code, phone, fax, email, website)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                data["hotel_information"]["name"],
                data["hotel_information"]["address"]["street"],
                data["hotel_information"]["address"]["city"],
                data["hotel_information"]["address"]["country"],
                data["hotel_information"]["address"]["postal_code"],
                data["hotel_information"]["contact"]["phone"],
                data["hotel_information"]["contact"]["fax"],
                data["hotel_information"]["contact"]["email"],
                data["hotel_information"]["contact"]["website"]
            ))
            hotel_id = cursor.lastrowid

            # Insert Invoice Information
            cursor.execute('''
            INSERT INTO Invoices (hotel_id, invoice_number, reservation_number, date, room_number, check_in_date, check_out_date, currency, total_net, total_tax, total_gross, total_charge, total_credit, balance_due, guest_company, guest_address, guest_name)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                hotel_id,
                data["invoice_information"]["invoice_number"],
                data["invoice_information"]["reservation_number"],
                data["invoice_information"]["date"],
                data["invoice_information"]["room_number"],
                data["invoice_information"]["check_in_date"],
                data["invoice_information"]["check_out_date"],
                data["totals_summary"]["currency"],
                data["totals_summary"]["total_net"],
                data["totals_summary"]["total_tax"],
                data["totals_summary"]["total_gross"],
                data["totals_summary"]["total_charge"],
                data["totals_summary"]["total_credit"],
                data["totals_summary"]["balance_due"],
                data["guest_information"]["company"],
                data["guest_information"]["address"],
                data["guest_information"]["guest_name"]
            ))
            invoice_id = cursor.lastrowid

            # Insert Charges
            for charge in data["charges"]:
                cursor.execute('''
                INSERT INTO Charges (invoice_id, date, description, charge, credit)
                VALUES (?, ?, ?, ?, ?)
                ''', (
                    invoice_id,
                    charge["date"],
                    charge["description"],
                    charge["charge"],
                    charge["credit"]
                ))

            # Insert Taxes
            for tax in data["taxes"]:
                cursor.execute('''
                INSERT INTO Taxes (invoice_id, tax_type, tax_rate, net_amount, tax_amount, gross_amount)
                VALUES (?, ?, ?, ?, ?, ?)
                ''', (
                    invoice_id,
                    tax["tax_type"],
                    tax["tax_rate"],
                    tax["net_amount"],
                    tax["tax_amount"],
                    tax["gross_amount"]
                ))

    conn.commit()
    conn.close()
```

Now let's check that we've correctly ingested the data by running a sample SQL query to determine the most expensive hotel stay and the same of the hotel!
You can even automate the generation of SQL queries at this step by using function calling, check out our [cookbook on function calling with model generated arguments](https://cookbook.openai.com/examples/how_to_call_functions_with_chat_models#how-to-call-functions-with-model-generated-arguments) to learn how to do that.

```python

def execute_query(db_path, query, params=()):
    """
    Execute a SQL query and return the results.

    Parameters:
    db_path (str): Path to the SQLite database file.
    query (str): SQL query to be executed.
    params (tuple): Parameters to be passed to the query (default is an empty tuple).

    Returns:
    list: List of rows returned by the query.
    """
    try:
        # Connect to the SQLite database
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        # Execute the query with parameters
        cursor.execute(query, params)
        results = cursor.fetchall()

        # Commit if it's an INSERT/UPDATE/DELETE query
        if query.strip().upper().startswith(('INSERT', 'UPDATE', 'DELETE')):
            conn.commit()

        return results
    except sqlite3.Error as e:
        print(f"An error occurred: {e}")
        return []
    finally:
        # Close the connection
        if conn:
            conn.close()


# Example usage
transformed_invoices_path = "./data/hotel_invoices/transformed_invoice_json"
db_path = "./data/hotel_invoices/hotel_DB.db"
ingest_transformed_jsons(transformed_invoices_path, db_path)

query = '''
    SELECT
        h.name AS hotel_name,
        i.total_gross AS max_spent
    FROM
        Invoices i
    JOIN
        Hotels h ON i.hotel_id = h.hotel_id
    ORDER BY
        i.total_gross DESC
    LIMIT 1;
    '''

results = execute_query(db_path, query)
for row in results:
    print(row)
```

To recap in this cookbook we showed you how to use GPT-4o for extracting and transforming data that would otherwise be inaccessible for data analysis. If you don't need these workflows to happen in real-time, you can take advantage of OpenAI's BatchAPI to run jobs asynchronously at a much lower cost!
