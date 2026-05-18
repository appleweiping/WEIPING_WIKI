---
title: "Dispute Agent"
type: source
status: imported
created: 2026-05-15
updated: 2026-05-18
tags:
  - agent-workflows
  - agents
  - cookbook
  - example
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/agents_sdk/dispute_agent
  - https://github.com/openai/openai-cookbook/blob/main/examples/agents_sdk/dispute_agent.ipynb
---

# Dispute Agent

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/agents_sdk/dispute_agent
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/agents_sdk/dispute_agent.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/agents_sdk/dispute_agent.ipynb
- Source path: `examples/agents_sdk/dispute_agent.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `27dc2e1e1eafc1f1a32bb1465817d2d461e1628aea5dcf26d8f1174b0fbe2032`

## Classification

- Primary category: Agents SDK / agent workflows
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Introduction We recently announced our new open-source Agents SDK , designed to help you build agentic AI applications using a lightweight, easy-to-use package with minimal abstractions. This cookbook demonstrates how you can leverage the Agents SDK in combination with Stripe's API to handle dispute management, a common operational challenge many businesses...

## What This Teaches

- How to structure agent workflows, tool use, memory, evaluation, or multi-agent coordination.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Introduction

We recently announced our new open-source **Agents SDK**, designed to help you build agentic AI applications using a lightweight, easy-to-use package with minimal abstractions.

This cookbook demonstrates how you can leverage the Agents SDK in combination with Stripe's API to handle dispute management, a common operational challenge many businesses face. Specifically, we focus on two real-world scenarios:

1. **Company Mistake:**
   A scenario where the company clearly made an error, such as failing to fulfill an order, where accepting the dispute the appropriate action.

2. **Customer Dispute (Final Sale):**
   A scenario where a customer knowingly disputes a transaction despite receiving the correct item and understanding that the purchase was final sale, requiring further investigation to gather supporting evidence.

To address these scenarios, we'll introduce three distinct agents:

- **Triage Agent:**
  Determines whether to accept or escalate a dispute based on the fulfillment status of the order.

- **Acceptance Agent:**
  Handles clear-cut cases by automatically accepting disputes, providing concise reasoning.

- **Investigator Agent:**
Performs thorough investigations into disputes by analyzing communication records and order information to collect essential evidence.

Throughout this cookbook, we’ll guide you step-by-step, illustrating how custom agentic workflows can automate dispute management and support your business operations.

## Prerequisites

Before running this cookbook, you must set up the following accounts and complete a few setup actions. These prerequisites are essential to interact with the APIs used in this project.

#### 1. OpenAI Account

- **Purpose:**
  You need an OpenAI account to access language models and use the Agents SDK featured in this cookbook.

- **Action:**
  [Sign up for an OpenAI account](https://openai.com) if you don’t already have one. Once you have an account, create an API key by visiting the [OpenAI API Keys page](https://platform.openai.com/api-keys).

#### 2. Stripe Account

- **Purpose:**
  A Stripe account is required to simulate payment processing, manage disputes, and interact with the Stripe API as part of our demo workflow.

- **Action:**
  Create a free Stripe account by visiting the [Stripe Signup Page](https://dashboard.stripe.com/register).

- **Locate Your API Keys:**
  Log in to your Stripe dashboard and navigate to **Developers > API keys**.

- **Use Test Mode:**
  Use your **Test Secret Key** for all development and testing.


#### 3. Create a .env file with your OpenAI API and Stripe API Keys

```
OPENAI_API_KEY=
STRIPE_SECRET_KEY=
```

### Environment Setup
First we will install the necessary dependencies, then import the libraries and write some utility functions that we will use later on.

```python
%pip install python-dotenv --quiet
%pip install openai-agents --quiet
%pip install stripe --quiet
%pip install typing_extensions --quiet
```

```python
import os
import logging
import json
from dotenv import load_dotenv
from agents import Agent, Runner, function_tool  # Only import what you need
import stripe
from typing_extensions import TypedDict, Any
# Load environment variables from .env file
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Set Stripe API key from environment variables
stripe.api_key = os.getenv("STRIPE_SECRET_KEY")
```

#### Define Function Tools
This section defines several helper function tools that support the dispute processing workflow.
<br>

- `get_order`, `get_phone_logs` and `get_emails` simulate external data lookups by returning order details and email/phone records based on provided identifiers.
- `retrieve_payment_intent`  interacts with the Stripe API to fetch payment intent details.
- `close_dispute`  automatically closes a Stripe dispute using the provided dispute ID, ensuring that disputes are properly resolved and logged.

```python
@function_tool
def get_phone_logs(phone_number: str) -> list:
    """
    Return a list of phone call records for the given phone number.
    Each record might include call timestamps, durations, notes,
    and an associated order_id if applicable.
    """
    phone_logs = [
        {
            "phone_number": "+15551234567",
            "timestamp": "2023-03-14 15:24:00",
            "duration_minutes": 5,
            "notes": "Asked about status of order #1121",
            "order_id": 1121
        },
        {
            "phone_number": "+15551234567",
            "timestamp": "2023-02-28 10:10:00",
            "duration_minutes": 7,
            "notes": "Requested refund for order #1121, I told him we were unable to refund the order because it was final sale",
            "order_id": 1121
        },
        {
            "phone_number": "+15559876543",
            "timestamp": "2023-01-05 09:00:00",
            "duration_minutes": 2,
            "notes": "General inquiry; no specific order mentioned",
            "order_id": None
        },
    ]
    return [
        log for log in phone_logs if log["phone_number"] == phone_number
    ]


@function_tool
def get_order(order_id: int) -> str:
    """
    Retrieve an order by ID from a predefined list of orders.
    Returns the corresponding order object or 'No order found'.
    """
    orders = [
        {
            "order_id": 1234,
            "fulfillment_details": "not_shipped"
        },
        {
            "order_id": 9101,
            "fulfillment_details": "shipped",
            "tracking_info": {
                "carrier": "FedEx",
                "tracking_number": "123456789012"
            },
            "delivery_status": "out for delivery"
        },
        {
            "order_id": 1121,
            "fulfillment_details": "delivered",
            "customer_id": "cus_PZ1234567890",
            "customer_phone": "+15551234567",
            "order_date": "2023-01-01",
            "customer_email": "customer1@example.com",
            "tracking_info": {
                "carrier": "UPS",
                "tracking_number": "1Z999AA10123456784",
                "delivery_status": "delivered"
            },
            "shipping_address": {
                "zip": "10001"
            },
            "tos_acceptance": {
                "date": "2023-01-01",
                "ip": "192.168.1.1"
            }
        }
    ]
    for order in orders:
        if order["order_id"] == order_id:
            return order
    return "No order found"


@function_tool
def get_emails(email: str) -> list:
    """
    Return a list of email records for the given email address.
    """
    emails = [
        {
            "email": "customer1@example.com",
            "subject": "Order #1121",
            "body": "Hey, I know you don't accept refunds but the sneakers don't fit and I'd like a refund"
        },
        {
            "email": "customer2@example.com",
            "subject": "Inquiry about product availability",
            "body": "Hello, I wanted to check if the new model of the smartphone is available in stock."
        },
        {
            "email": "customer3@example.com",
            "subject": "Feedback on recent purchase",
            "body": "Hi, I recently purchased a laptop from your store and I am very satisfied with the product. Keep up the good work!"
        }
    ]
    return [email_data for email_data in emails if email_data["email"] == email]


@function_tool
async def retrieve_payment_intent(payment_intent_id: str) -> dict:
    """
    Retrieve a Stripe payment intent by ID.
    Returns the payment intent object on success or an empty dictionary on failure.
    """
    try:
        return stripe.PaymentIntent.retrieve(payment_intent_id)
    except stripe.error.StripeError as e:
        logger.error(f"Stripe error occurred while retrieving payment intent: {e}")
        return {}

@function_tool
async def close_dispute(dispute_id: str) -> dict:
    """
    Close a Stripe dispute by ID.
    Returns the dispute object on success or an empty dictionary on failure.
    """
    try:
        return stripe.Dispute.close(dispute_id)
    except stripe.error.StripeError as e:
        logger.error(f"Stripe error occurred while closing dispute: {e}")
        return {}
```

### Define the Agents

- The **Dispute Intake Agent (investigator_agent)** is responsible for investigating disputes by gathering all relevant evidence and providing a report.
- The **Accept a Dispute Agent (accept_dispute_agent)** handles disputes that are determined to be valid by automatically closing them and providing a brief explanation for the decision.
- The **Triage Agent (triage_agent)** serves as the decision-maker by extracting the order ID from the payment intent's metadata, retrieving detailed order information, and then deciding whether to escalate the dispute to the investigator or to pass it to the accept dispute agent.
- Together, these agents form a modular workflow that automates and streamlines the dispute resolution process by delegating specific tasks to specialized agents.

```python
investigator_agent = Agent(
    name="Dispute Intake Agent",
    instructions=(
        "As a dispute investigator, please compile the following details in your final output:\n\n"
        "Dispute Details:\n"
        "- Dispute ID\n"
        "- Amount\n"
        "- Reason for Dispute\n"
        "- Card Brand\n\n"
        "Payment & Order Details:\n"
        "- Fulfillment status of the order\n"
        "- Shipping carrier and tracking number\n"
        "- Confirmation of TOS acceptance\n\n"
        "Email and Phone Records:\n"
        "- Any relevant email threads (include the full body text)\n"
        "- Any relevant phone logs\n"
    ),
    model="o3-mini",
    tools=[get_emails, get_phone_logs]
)


accept_dispute_agent = Agent(
    name="Accept Dispute Agent",
    instructions=(
        "You are an agent responsible for accepting disputes. Please do the following:\n"
        "1. Use the provided dispute ID to close the dispute.\n"
        "2. Provide a short explanation of why the dispute is being accepted.\n"
        "3. Reference any relevant order details (e.g., unfulfilled order, etc.) retrieved from the database.\n\n"
        "Then, produce your final output in this exact format:\n\n"
        "Dispute Details:\n"
        "- Dispute ID\n"
        "- Amount\n"
        "- Reason for Dispute\n\n"
        "Order Details:\n"
        "- Fulfillment status of the order\n\n"
        "Reasoning for closing the dispute\n"
    ),
    model="gpt-4o",
    tools=[close_dispute]
)

triage_agent = Agent(
    name="Triage Agent",
    instructions=(
        "Please do the following:\n"
        "1. Find the order ID from the payment intent's metadata.\n"
        "2. Retrieve detailed information about the order (e.g., shipping status).\n"
        "3. If the order has shipped, escalate this dispute to the investigator agent.\n"
        "4. If the order has not shipped, accept the dispute.\n"
    ),
    model="gpt-4o",
    tools=[retrieve_payment_intent, get_order],
    handoffs=[accept_dispute_agent, investigator_agent],
)
```

#### Retrieve the Dispute and Initiate the Agentic Workflow
This function retrieves the dispute details from Stripe using the provided `payment_intent_id` and initiates the dispute-handling workflow by passing the retrieved dispute information to the specified `triage_agent`.

```python
async def process_dispute(payment_intent_id, triage_agent):
    """Retrieve and process dispute data for a given PaymentIntent."""
    disputes_list = stripe.Dispute.list(payment_intent=payment_intent_id)
    if not disputes_list.data:
        logger.warning("No dispute data found for PaymentIntent: %s", payment_intent_id)
        return None

    dispute_data = disputes_list.data[0]

    relevant_data = {
        "dispute_id": dispute_data.get("id"),
        "amount": dispute_data.get("amount"),
        "due_by": dispute_data.get("evidence_details", {}).get("due_by"),
        "payment_intent": dispute_data.get("payment_intent"),
        "reason": dispute_data.get("reason"),
        "status": dispute_data.get("status"),
        "card_brand": dispute_data.get("payment_method_details", {}).get("card", {}).get("brand")
    }

    event_str = json.dumps(relevant_data)
    # Pass the dispute data to the triage agent
    result = await Runner.run(triage_agent, input=event_str)
    logger.info("WORKFLOW RESULT: %s", result.final_output)

    return relevant_data, result.final_output
```

#### Scenario 1: Company Mistake (Product Not Received)
This scenario represents a situation where the company has clearly made an error—for instance, failing to fulfill or ship an order. In such cases, it may be appropriate to accept the dispute rather than contest it.

```python
payment = stripe.PaymentIntent.create(
  amount=2000,
  currency="usd",
  payment_method = "pm_card_createDisputeProductNotReceived",
  confirm=True,
  metadata={"order_id": "1234"},
  off_session=True,
  automatic_payment_methods={"enabled": True},
)
relevant_data, triage_result = await process_dispute(payment.id, triage_agent)
```

#### Scenario 2: Customer Dispute (Final Sale)
This scenario describes a situation where a customer intentionally disputes a transaction, despite having received the correct product and being fully aware that the purchase was clearly marked as a "final sale" (no refunds or returns). Such disputes typically require further investigation to collect evidence in order to effectively contest the dispute.

```python
payment = stripe.PaymentIntent.create(
  amount=2000,
  currency="usd",
  payment_method = "pm_card_createDispute",
  confirm=True,
  metadata={"order_id": "1121"},
  off_session=True,
  automatic_payment_methods={"enabled": True},
)
relevant_data, triage_result = await process_dispute(payment.id, triage_agent)
```

## Conclusion

In this Jupyter Notebook, we explored the capabilities of the **OpenAI Agents SDK**, demonstrating how to efficiently create agent-based AI applications using a simple, Python-first approach. Specifically, we showcased the following SDK features:

- **Agent Loop**: Manages tool calls, communicates results to the LLM, and loops until completion.
- **Handoffs**: Enables coordination and delegation tasks between multiple specialized agents.
- **Function Tools**: Converts Python functions into tools with automatic schema generation and validation.

Additionally, the SDK offers built-in **Tracing**, accessible via the OpenAI dashboard. Tracing helps you visualize, debug, and monitor your agent workflows during both development and production phases. It also integrates smoothly with OpenAI’s evaluation, fine-tuning, and distillation tools.

While we didn't cover it directly in this notebook, implementing **Guardrails** is strongly recommended for production applications to validate inputs and proactively detect errors.

Overall, this notebook lays a clear foundation for further exploration, emphasizing how the OpenAI Agents SDK facilitates intuitive and effective agent-driven workflows.
