import shodan
import json
import logging

# This script uses the Shodan API to get information about a list of IPs
## Provide the Shodan API key required in the Shodan() function to the API_KEY variable
## Provide the ip_input_file variable with the file path to file with all the IPs
### The format for IPs should be each IP in a new line 
## Provide the output_file variable with output file path for the JSON output of the results

# Configure logging to log to both a file and the console
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# File handler
log_file_path = 'shodan_utils.log' #? Put the path to the log file here
file_handler = logging.FileHandler(log_file_path, mode='w')
file_handler.setLevel(logging.INFO)
file_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler.setFormatter(file_formatter)
logger.addHandler(file_handler)

# Console handler
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
console_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
console_handler.setFormatter(console_formatter)
logger.addHandler(console_handler)

# Initialize the Shodan API
API_KEY = "" #! Put your Shodan API key here
api = shodan.Shodan(API_KEY)

# Read the IPs from the temp_ips.txt file and put them into a list
ip_input_file = "" #! Put the path to the file with the list of IPs here
with open(ip_input_file, 'r') as file:
    ip_list = [line.strip() for line in file]

# Log the list of IPs
logging.info(f"IP list: {ip_list}")

# Dictionary to store the information for each IP
ip_info_dict = {}

# Example: Get information for each IP and store it in the dictionary
for ip in ip_list:
    try:
        info = api.host(ip)
        ip_info_dict[ip] = info
        logging.info(f"Fetched data for {ip}")
    except shodan.APIError as e:
        logging.error(f"Error fetching data for {ip}: {e}")

# Log the dictionary with IP information
ip_info_json = json.dumps(ip_info_dict, indent=4)
logging.info(f"IP information: {ip_info_json}")

# Output the dictionary to a JSON file
output_file = "" #! Put the path to the output file here
with open(output_file, 'w') as json_file:
    json.dump(ip_info_dict, json_file, indent=4)

logging.info(f"IP information has been written to {output_file}")