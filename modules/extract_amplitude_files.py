# Extract data from API

import os
import requests
from dotenv import load_dotenv
from datetime import datetime, timedelta # Work with dates and times (like calculating "yesterday")


def extract_amplitude_data(start_date, end_date, api_key, secret_key, output_file='data.zip'):

    """
    This function extracts data from Amplitude's Export API for a given date range and stores it in an output file which is called data.zip by default

    Args:
        start_time (str): Start date in format 'YYYYMMDDTHH' 
        end_time (str): End time in format 'YYYYMMDDTHH'
        api_key (str): Amplitude api key
        secret_key (str): amplitude secret key
        output_file (str): File name to be output, set by default to data.zip
    
    Output:
        bool: True if the extraction was successful, False otherwise 


    """

    # Define url. This is the URL your script will ask for data from
    url = 'https://analytics.eu.amplitude.com/api/2/export'


    # Define parameters dictionary. Preparing our api requests so we only pull data within these parameters 
    params= {
        'start': start_date, 
        'end': end_date
        }

    try: 
        # Make GET request
        response = requests.get(url, params=params , auth=(api_key, secret_key)) #includes url, start/end times and login/auth info
       

        # Check response status
        if response.status_code == 200:
            # Request was succesful
            data = response.content
            print('Data retrieved successful')

            # Save file
            with open(output_file, 'wb') as file:
                file.write(data)
            print(f'Data saved to {output_file}')
            return True
        
        else:
            # Need to return error if not status = 200
            print(f'Error {response.status_code}: {response.text}')
            return False
        
    except Exception as e:
        print(f'An error has occured!: {str(e)}')
        return False 