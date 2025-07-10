# data extraction using amplitude's api
# https://amplitude.com/api/2/export

import os
import requests
import zipfile
import gzip
import shutil
import tempfile
import time
from dotenv import load_dotenv
from datetime import datetime, timedelta

# 1. Load environment variables (AMP_API_KEY and AMP_SECRET_KEY)
load_dotenv()
api_key = os.getenv('AMP_API_KEY')
secret_key = os.getenv('AMP_SECRET_KEY')

# 2. Set up URL and time range (yesterday)
url = 'https://analytics.eu.amplitude.com/api/2/export'

yesterday = datetime.now() - timedelta(days=1)
start_time = yesterday.strftime('%Y%m%dT00')
end_time = yesterday.strftime('%Y%m%dT23')

params = {
    'start': start_time,
    'end': end_time
}

# 3. Set up wait-and-try-again logic
max_tries = 3
current_try = 0
wait_time = 3

while current_try < max_tries:
    try:
        print(f'Attempt {current_try + 1} of {max_tries}')
        response = requests.get(url, params=params, auth=(api_key, secret_key))
        response.raise_for_status()  # raises HTTPError for bad status

        # If response was okay, save zip file
        with open('data.zip', 'wb') as file:
            file.write(response.content)
        print('Data retreived successful')

        # 4. Extract ZIP to a temporary folder
        temp_dir = tempfile.mkdtemp()
        data_dir = 'data'
        os.makedirs(data_dir, exist_ok=True)

        with zipfile.ZipFile('data.zip', 'r') as zip_ref:
            zip_ref.extractall(temp_dir)

        # 5. Find the folder like "20250709" inside temp_dir
        day_folder = next(f for f in os.listdir(temp_dir) if f.isdigit())
        day_path = os.path.join(temp_dir, day_folder)

        # 6. Extract each .gz to .json
        for root, _, files in os.walk(day_path):
            for file in files:
                if file.endswith('.gz'):
                    gz_path = os.path.join(root, file)
                    json_filename = file[:-3]  # remove ".gz"
                    output_path = os.path.join(data_dir, json_filename)
                    with gzip.open(gz_path, 'rb') as gz_file, open(output_path, 'wb') as out_file:
                        shutil.copyfileobj(gz_file, out_file)

        print('All .gz files extracted to .json')
        break  # if successful exit while loop

    # 7. Catch errors and retry
    except requests.exceptions.RequestException as e:
        print(f'Request error: {e}')
    except Exception as e:
        print(f'General error: {e}')
    except:
        print('Unknown error')

    # 8. Wait before trying again
    current_try += 1
    print('Waiting before retry...\n')
    time.sleep(wait_time)

# 9. Final failure message if all tries failed
if current_try == max_tries:
    print('Too many tries — data not downloaded.')
