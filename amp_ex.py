# data extraction using amplitude's api
# https://amplitude.com/api/2/export

#Load libraries
import os # Work with files and folders
import requests # Make web requests
import zipfile # Open and unpack .zip files
import gzip # 	Open .gz compressed files
import shutil # Helps copy file contents from one place to another
import tempfile # Creates temporary folders to hold files while processing
from dotenv import load_dotenv 	# Loads secret info (like API keys) from a .env file
from datetime import datetime, timedelta # Work with dates and times (like calculating "yesterday")

#Load .env file so we can grab the API keys
load_dotenv()

# Read the .env file. Loads the key and secret from .env so we don't hard-code them
api_key = os.getenv('AMP_API_KEY')
secret_key = os.getenv('AMP_SECRET_KEY')

# Define url. This is the URL your script will ask for data from
url = 'https://analytics.eu.amplitude.com/api/2/export'


#calculating yesterday so our start_time and end_time paramaters are dynamic
yesterday = (datetime.now()-timedelta(days=1)) # gets the current date and subtracts 1 day
start_time = yesterday.strftime('%Y%m%dT00')
end_time = yesterday.strftime('%Y%m%dT23')

#print(start_time)
#print(end_time)

# Define parameters dictionary. Preparing our api requests so we only pull data within these parameters 
params= {
    'start': start_time, 
    'end': end_time
    }

# sends request to amplitude to get response 
response = requests.get(url, params= params , auth=(api_key, secret_key)) #includes url, start/end times and login/auth info
# print(response.content)

# Make sure we only save files when we get successful status 
if response.status_code == 200:
    #if true then saves the returned ZIP file 
    data = response.content
    print('Data retrieved successful')
    with open('data.zip', 'wb') as file:
        file.write(data)
else:
    # Need to return error if not status = 200
    print(f'Error {response.status_code}: {response.text}')

# Create a temporary directory for extraction. 
temp_dir = tempfile.mkdtemp() #throw away folder 

# Create a local output directory. This is where the final .json files will be saved
data_dir = "data"
os.makedirs(data_dir, exist_ok=True) #exit_ok=True means that if it does already exist, its okay to overwrite it 

# Unpack zip. r = read. Unzips data.zip into your termporary folder ]
with zipfile.ZipFile("data.zip", "r") as zip_ref:
    zip_ref.extractall(temp_dir)

# Loacate the folders -> need file path. Amplitude structures ZIPs like: ZIP → Folder like "20250709" → .gz files
day_folder = next(f for f in os.listdir(temp_dir) if f.isdigit())
day_path = os.path.join(temp_dir, day_folder)

# triple unpack jsons. Loop through and extract each .gz
#print(os.walk(day_path))
for root, _, files in os.walk(day_path):
    #print("root=", root)
    #print("_=", _)
    #print("files=", files)
    for file in files:
        if file.endswith('.gz'):
            #print(file)
            # gz -> final location
            gz_path = os.path.join(root, file)
            json_filename = file[: -3]
            output_path = os.path.join(data_dir, json_filename)
            with gzip.open(gz_path, 'rb') as gz_file, open(output_path, 'wb') as out_file:
                shutil.copyfileobj(gz_file, out_file)





