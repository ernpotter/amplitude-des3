import os
import boto3
from dotenv import load_dotenv
from datetime import datetime, timedelta
from modules.extract_amplitude_files import extract_amplitude_data
from modules.unzip_json import unzip_json_files

# Load env variables
load_dotenv()

api_key = os.getenv('AMP_API_KEY')
secret_key = os.getenv('AMP_SECRET_KEY')
aws_access = os.getenv('AWS_ACCESS_KEY')
aws_secret = os.getenv('AWS_SECRET_KEY')
bucket_name = os.getenv('AWS_BUCKET_NAME')

# Define start and end date for Amplitude API
yesterday = datetime.now() - timedelta(days=1)
start_date = yesterday.strftime('%Y%m%dT00')
end_date = yesterday.strftime('%Y%m%dT23')

# Extract amplitude data from the API
extract_amplitude_data(start_date, end_date, api_key, secret_key)

# Unzip files to data/
unzip_json_files("data.zip")

# Upload each unzipped JSON file to S3
s3_client = boto3.client(
    's3',
    aws_access_key_id=aws_access,
    aws_secret_access_key=aws_secret
)

data_dir = "data"

for filename in os.listdir(data_dir):
    if filename.endswith(".json"):
        local_path = os.path.join(data_dir, filename)
        s3_key = f"python-import/{filename}"

        print(f"Uploading {filename} to s3://{bucket_name}/{s3_key}")
        s3_client.upload_file(Filename = local_path,
                               Bucket = bucket_name,
                                Key = s3_key)

        # Optional: delete local file after upload
        os.remove(local_path)
