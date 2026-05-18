---
title: "Using Reasoning For Routine Generation"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - example
  - gpt-5
  - notebook
  - openai
  - reasoning
source_pages:
  - https://developers.openai.com/cookbook/examples/o1/using_reasoning_for_routine_generation
  - https://github.com/openai/openai-cookbook/blob/main/examples/o1/Using_reasoning_for_routine_generation.ipynb
---

# Using Reasoning For Routine Generation

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/o1/using_reasoning_for_routine_generation
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/o1/Using_reasoning_for_routine_generation.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/o1/Using_reasoning_for_routine_generation.ipynb
- Source path: `examples/o1/Using_reasoning_for_routine_generation.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `f46dfdef0e4c37433c656c7af0be75eda6267c560fc61bf17e2409b61742a87e`

## Classification

- Primary category: GPT-5 / reasoning / prompting
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Using reasoning for routine generation When developing customer service solutions, one of the initial steps involves transforming knowledge base articles into a set of routines that an LLM can comprehend and follow. A routine, in this context, refers to a set of step-by-step instructions designed specifically for the LLM to execute efficiently. Each routine...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: GPT-5 / reasoning / prompting.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Using reasoning for routine generation

When developing customer service solutions, one of the initial steps involves transforming knowledge base articles into a set of routines that an LLM can comprehend and follow. A routine, in this context, refers to a set of step-by-step instructions designed specifically for the LLM to execute efficiently. Each routine is carefully structured so that a step corresponds to a clear action. Actions can include responding to a user, triggering a function call, or retrieving additional relevant knowledge.

Most internal knowledge base articles are complex and structured for human interpretation. They often include intricate diagrams, multi-step processes, and decision trees that pose challenges for LLM-based solutions to reason through in a meaningful way. By breaking down these documents into routines, each instruction can be simplified and formatted in a way that guides the LLM through a series of small, manageable tasks. This granular approach reduces ambiguity, allowing the LLM to process the information methodically and reducing the risk of hallucination or deviation from the expected path.

Converting these knowledge base articles into routines can be time-consuming and challenging, especially for companies attempting to build an automated pipeline. Each routine must account for various user scenarios, where actions need to be clearly defined. For instance, when a function call is necessary, the routine must specify the exact information to retrieve or the action to execute—whether it’s triggering an API, retrieving external data, or pulling in additional context. While automating this process with traditional GPT-class models can significantly reduce the manual effort involved, it often introduces new challenges. Some challenges include designing robust instructions that are specific enough for the LLM to follow consistently, capturing unique edge cases that may arise during customer interactions, providing high-quality few-shot examples to guide the model’s behavior, and in some cases, fine-tuning the model to achieve more reliable or specialized outcomes.

o1 has demonstrated the capability to efficiently deconstruct these articles and convert them into sets of routines zero-shot, meaning that the LLM can understand and follow the instructions without extensive examples or prior training on similar tasks. This minimizes the prompting effort required, as the routine structure itself provides the necessary guidance for the LLM to complete each step. By breaking down tasks into specific actions and integrating function calls where needed, o1’s approach ensures that even complex workflows can be handled seamlessly by the LLM, leading to more effective and scalable customer service solutions.

## Selecting Knowledge Base Articles

In this example, we will use a set of publicly available Help Center articles from the OpenAI website and convert them into internal routines that an LLM can execute. Besides transforming the policies into routines, we will also have the model generate functions that allow the LLM to perform actions on behalf of the user. This is necessary to allow the LLM to execute the same actions that human agents have, and access additional information that may not be immediately available just from the policy documentation.

We will begin by using the following Help Center articles for conversion into routines:
- [How do I delete my payment method](https://help.openai.com/en/articles/8156070-how-do-i-delete-my-payment-method)
- [How can I get a Business Associate Agreement (BAA) with OpenAI?](https://help.openai.com/en/articles/8660679-how-can-i-get-a-business-associate-agreement-baa-with-openai)
- [How can I set up prepaid billing?](https://help.openai.com/en/articles/8264644-how-can-i-set-up-prepaid-billing)
- [How do I submit a VAT exemption request](https://help.openai.com/en/articles/7232908-how-do-i-submit-a-vat-exemption-request)

```python
from openai import OpenAI
from IPython.display import display, HTML
import pandas as pd
from concurrent.futures import ThreadPoolExecutor
import csv

client = OpenAI()
MODEL = 'o1-preview'
```

We have our articles stored in an accessible csv. We will take the articles and pass them to o1-preview in parallel and generate the initial routines.

Our instructions for converting the policy to a routine include:
- Converting the policy from an external facing document to an internal SOP routine
- Breaking down the policy in specific actions and sub-actions
- Outlining specific conditions for moving between steps
- Determing where external knowledge/actions may be required, and defining functions that we could use to get that information

```python
articles = []

with open('../data/helpcenter_articles.csv', mode='r', encoding='utf-8') as file:
    reader = csv.DictReader(file)
    for row in reader:
        articles.append({
            "policy": row["policy"],
            "content": row["content"]
        })
```

```python
CONVERSION_PROMPT = """
You are a helpful assistant tasked with taking an external facing help center article and converting it into a internal-facing programmatically executable routine optimized for an LLM.
The LLM using this routine will be tasked with reading the policy, answering incoming questions from customers, and helping drive the case toward resolution.

Please follow these instructions:
1. **Review the customer service policy carefully** to ensure every step is accounted for. It is crucial not to skip any steps or policies.
2. **Organize the instructions into a logical, step-by-step order**, using the specified format.
3. **Use the following format**:
   - **Main actions are numbered** (e.g., 1, 2, 3).
   - **Sub-actions are lettered** under their relevant main actions (e.g., 1a, 1b).
      **Sub-actions should start on new lines**
   - **Specify conditions using clear 'if...then...else' statements** (e.g., 'If the product was purchased within 30 days, then...').
   - **For instructions that require more information from the customer**, provide polite and professional prompts to ask for additional information.
   - **For actions that require data from external systems**, write a step to call a function using backticks for the function name (e.g., `call the check_delivery_date function`).
      - **If a step requires the customer service agent to take an action** (e.g., process a refund), generate a function call for this action (e.g., `call the process_refund function`).
      - **Define any new functions** by providing a brief description of their purpose and required parameters.
   - **If there is an action an assistant can performon behalf of the user**, include a function call for this action (e.g., `call the change_email_address function`), and ensure the function is defined with its purpose and required parameters.
      - This action may not be explicitly defined in the help center article, but can be done to help the user resolve their inquiry faster
   - **The step prior to case resolution should always be to ask if there is anything more you can assist with**.
   - **End with a final action for case resolution**: calling the `case_resolution` function should always be the final step.
4. **Ensure compliance** by making sure all steps adhere to company policies, privacy regulations, and legal requirements.
5. **Handle exceptions or escalations** by specifying steps for scenarios that fall outside the standard policy.

**Important**: If at any point you are uncertain, respond with "I don't know."

Please convert the customer service policy into the formatted routine, ensuring it is easy to follow and execute programmatically.

"""
```

```python
def generate_routine(policy):
    try:
        messages = [
            {
                "role": "user",
                "content": f"""
                    {CONVERSION_PROMPT}

                    POLICY:
                    {policy}
                """
            }
        ]

        response = client.chat.completions.create(
            model=MODEL,
            messages=messages
        )


        return response.choices[0].message.content
    except Exception as e:
        print(f"An error occurred: {e}")
```

```python
def process_article(article):
    routine = generate_routine(article['content'])
    return {"policy": article['policy'], "content": article['content'], "routine": routine}


with ThreadPoolExecutor() as executor:
    results = list(executor.map(process_article, articles))
```

We'll store the results of our routines in a dataframe and print them out so we can get an initial look.

```python
df = pd.DataFrame(results)

# Set display options to show all text in the dataframe cells
pd.set_option('display.max_colwidth', None)

# Function to display formatted text in HTML
def display_formatted_dataframe(df):
    def format_text(text):
        return text.replace('\n', '<br>')

    df_formatted = df.copy()
    df_formatted['content'] = df_formatted['content'].apply(format_text)
    df_formatted['routine'] = df_formatted['routine'].apply(format_text)

    display(HTML(df_formatted.to_html(escape=False, justify='left')))

display_formatted_dataframe(df)
```

## Results

Upon reviewing the generated routines, we can derive several insights:
- Sample Responses: The model effectively generates sample responses that the LLM can utilize when executing the policy (e.g., “Instruct the user: ‘Confirm and purchase your initial amount of credits.’”).
- Discrete Steps: The model excels at decomposing the problem into discrete actions that the LLM needs to execute. Each instruction is clearly defined and easy to interpret.
- Function Definitions: The routines’ outputs include clearly defined functions to retrieve external information or trigger actions (e.g., `review_and_apply_tax_exemption`, `get_billing_plan`, `update_payment_method`).
    - This is crucial for any successful routine because LLMs often need to interact with external systems. Leveraging function calls is an effective way to interact with those systems and execute actions.
- IFTTT Logic: The model effectively employs IFTTT (If This, Then That) logic, which is ideal for an LLM (e.g., “If the customer requests assistance, proceed to step 3f.”).
    - This type of translation becomes extremely valuable when the original knowledge base articles contain complex workflows and diagrams. Such complexity may not be easily understood by humans, and even less so by an LLM. IFTTT logic is easily comprehensible and works well for customer service solution

## Where do we go from here?

These routines can now be integrated into agentic systems to address specific customer issues. When a customer requests assistance with tasks such as setting up prepaid billing, we can employ a classifier to determine the appropriate routine to retrieve and provide that to the LLM to interact directly with the customer. Beyond providing instructions to the user on *how* to set up billing, the system can also perform the action on their behalf.

Before deploying these routines into production, we should develop comprehensive evaluations to test and validate the quality of the model’s responses. This process may necessitate adjusting the routines to ensure compliance and effectiveness.
