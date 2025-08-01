# Amplitude ELT Pipeline

A full Amplitude ELT pipeline using **Python**, **Snowflake**, and **dbt** to extract, load, and transform event-level analytics data into structured, analytics-ready tables.

---

## Python Script: `main.py`
A simple Python script that:
- Extracts campaign and email activity data from the Mailchimp API
- Stores the data as raw JSON files in:
  - data/email_activity/
  - data/campaigns/
- Uploads only the most recent file from each folder to an S3 bucket
- Deletes the local files after upload

---

## Functions

 ### `extract_mailchimp_data()`
- Calls the Mailchimp Marketing API
- Saves JSON responses into:
  - `data/email_activity/`
  - `data/campaigns/`
- Includes error handling and logging

### `load_to_s3()`
- Identifies the most recent `.json` file in each subfolder
- Uploads it to a defined S3 bucket location
- Deletes the local file after successful upload

---

## How to Run

1. Clone the repo  
2. Create a `.env` file with your credentials (see below)  
3. Install dependencies  
4. Run the ETL script:

```bash
python mailchimp_extract_and_load.py
```

---

## Environment Variables

Create a `.env` file in the root directory with the following:

```dotenv
MAILCHIMP_API_KEY=your_key_here
MAILCHIMP_SERVER_PREFIX=usX
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
AWS_BUCKET_NAME=your_bucket_name
```

---

## Requirements

Install the required dependencies:

```bash
pip install -r requirements.txt
```

---

## Testing Individual Functions

You can test the functions on their own by importing them in an interactive session or script:

```python
from modules.extract_mailchimp_data import extract_mailchimp_data
from modules.load_to_s3 import load_to_s3

extract_mailchimp_data()
load_to_s3()
```

---

## Notes

- Only the most recent JSON file in each folder is uploaded to S3
- Files are deleted locally after successful upload
- The full process is handled in a single script (mailchimp_extract_and_load.py) that calls both functions

---

## Snowflake + SQL Pipeline
Once files are in S3, they’re staged and transformed in Snowflake.

### Key SQL Scripts in `/snowflake/`:
- `s3_load.sql`: Loads JSON from S3 into raw Snowflake tables
- `transform.sql`: Unnests the raw JSON and creates structured silver layer tables
- `stored_procedure.sql`: A Snowflake stored procedure that keeps your silver tables fresh via streams and tasks

---

## dbt Project
The dbt layer transforms and organizes your Snowflake data using the medallion architecture: staging → intermediate → marts

### Subfolders in `/dbt/`:
- `_sources/`:
  - Contains sources.yml
  - Defines raw Snowflake tables pulled from S3
- `staging/`:
  - Cleans and flattens data from the raw layer
  - Includes staging.yml with documentation and tests
- `intermediate/`:
  - Applies logic, joins, and formatting
  - Preps data for business use
  - Includes intermediate.yml
- `marts/`:
  - Final gold-layer models for reporting
  - These are the cleanest, most useful tables for analytics
  - Includes marts.yml

---

## Folder Structure Summary
```bash
.
├── dev/                       # Experimental Python scripts
├── modules/                  # Reusable Python functions
│   ├── extract_mailchimp_data.py
│   └── load_to_s3.py
├── mailchimp_extract_and_load.py  # Main script
├── snowflake/                # SQL scripts for Snowflake pipeline
│   ├── s3_load.sql
│   ├── transform.sql
│   └── stored_procedure.sql
└── dbt/                      # dbt project for transformation
    ├── _sources/
    ├── staging/
    ├── intermediate/
    └── marts/

```
