# Amplitude ELT Pipeline

A full Amplitude ELT pipeline using **Python**, **Snowflake**, **dbt**, and **Kestra** to extract, load, and transform event-level analytics data into structured, analytics-ready tables.

---

## Python Script: `main.py`
A Python script that:
- Extracts event data from the Amplitude Export API
- Unzips the `.zip` response into individual JSON files
- Uploads each file to an S3 bucket
- Deletes local files after upload

---

## Functions

 ### `extract_amplitude_data(start_date, end_date, api_key, secret_key)`
- Calls the Amplitude Export API for a given date range
- Downloads a `.zip` file of event data

### `unzip_json_files(zip_path)`
- Unzips the downloaded archive
- Saves each JSON file to the `data/` folder

---

## How to Run

1. Clone the repo  
2. Create a `.env` file with your credentials (see below)  
3. Install dependencies  
4. Run the ETL script:

```bash
python main.py
```

---

## Environment Variables

Create a `.env` file in the root directory with the following:

```dotenv
AMP_API_KEY=your_amplitude_api_key
AMP_SECRET_KEY=your_amplitude_secret_key
AWS_ACCESS_KEY=your_aws_access_key
AWS_SECRET_KEY=your_aws_secret
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
from modules.extract_amplitude_files import extract_amplitude_data
from modules.unzip_json import unzip_json_files

extract_amplitude_data("20250801T00", "20250801T23", api_key, secret_key)
unzip_json_files("data.zip")
```

---

## Kestra Orchestration
This pipeline is orchestrated using Kestra. A Kestra flow YAML is provided to automatically:
- Clone this repo
- Install dependencies
- Run main.py inside a Docker container

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
└── kestra/                   # Kestra YAML flow definition
    └── amplitude_api_github.yml
```
