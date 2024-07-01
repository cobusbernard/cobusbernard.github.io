---
title: "Adding parameters to my serverless web scraper API"
description: Third installment of the series where I build a serverless API to scrape the historic dates from the USCIS monthly visa bulletin pages.
aws-services:
  - amazon-q
  - amazon-dynamodb
  - aws-lambda
date: 2024-06-16
tags: [aws, amazon-q, amazon-dynamodb, aws-lambda, terraform]
---

In the previous articles, I built a serverless API that scrapes the data from the USCIS monthly visa bulletins, and stores them in an Amazon DynamoDB table. After jumping in and [defining the whole infrastructure with Terraform](), [I realised that I should probably first ensure the code is working](). Now it is time to add some parameters to our function so that it will return the data from categories other than the hard-coded EB-3 one :)

Before we get to that though, we need to update the logic around the lookups and storing the data. Currently, it will loop over all the URLs on the [main page](), extract the ones that contain `/visa-bulletin-for-`, and then do a lookup in the DynamoDB table `ProcessedURLS` to see if that URL was processed. Only the data from pages that are not in that database table will be scraped, added to a single collection, then that whole collection will be stored. We need to update the code so that it stores the data as it scrapes a URL, and before writing the processed entry - if there was an error, it currently will not reprocess that page. 

To get started, [let's see what we need to change


---

## Prompts used in this article

### Prompt 1

Can you please show me how to update the highlighted code so that it will store the data after processing the URL, but before it saves the URL via `processed_urls_table.put_item`?

**Response:**

Sure, here's how you can modify the highlighted code to store the data after processing the URL, but before saving the URL via 
processed_urls_table.put_item
:

python

Insert at cursor

Copy
for link in visa_bulletin_links:
    if '2022' in link or '2023' in link or '2024' in link:
        # Check if the URL has been processed
        response = processed_urls_table.get_item(Key={'url': link})
        if 'Item' in response:
            print(f"Skipping URL: {link} (already processed)")
            continue

        # Process the URL
        print(f"Processing URL: {link}")
        url = f"https://travel.state.gov{link}"
        url_data = scrape_visa_bulletin(url)
        data.extend(url_data)

        # Store the data
        store_data(url_data)

        # Store the processed URL in DynamoDB
        processed_urls_table.put_item(Item={'url': link})

store_data(data)
Here's what's changed:

1. After scraping the visa bulletin data from the URL using `scrape_visa_bulletin(url)`, the scraped data is stored in a new variable `url_data`.
2. The `url_data` is then appended to the `data` list using `data.extend(url_data)`.
3.A new line `store_data(url_data)` is added to store the data scraped from the current URL.

After storing the data, the URL is marked as processed in DynamoDB using `processed_urls_table.put_item(Item={'url': link})`.

This way, the data is stored immediately after being scraped from the URL, and before the URL is marked as processed in DynamoDB.

Note: This assumes that the `store_data` function is defined elsewhere in your code and correctly handles storing the data in the desired location (e.g., a database, a file, etc.).

---

### Prompt 2

**Response:**

---

### Prompt 3

**Response:**

---

### Prompt 4

**Response:**

---

### Prompt 5

**Response:**

---

### Prompt 6

**Response:**

---

### Prompt 7

**Response:**

---

### Prompt 8

**Response:**

---

### Prompt 9

**Response:**

---

### Prompt 10

**Response:**

---
