import os
from dotenv import load_dotenv
from datetime import datetime, timedelta
from modules.extract_amplitude_files import extract_amplitude_data
from modules.unzip_json import unzip_json_files
load_dotenv()
api_key = os.getenv('AMP_API_KEY')
secret_key = os.getenv('AMP_SECRET_KEY')

#Define start and end date
yesterday = datetime.now() - timedelta(days=1)
start_date = yesterday.strftime('%Y%m%dT00')
end_date = yesterday.strftime('%Y%m%dT23')

# Extract amplitude data from the API
extract_amplitude_data(start_date, end_date, api_key, secret_key)

# Unzip files to a stable format
unzip_json_files("data.zip")