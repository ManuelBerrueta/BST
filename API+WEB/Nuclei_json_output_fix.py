import argparse
import json
import os

# create an argument parser to handle command-line arguments
parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input_file', help='path to input file')
parser.add_argument('-o', '--output_file', help='path to output file')
args = parser.parse_args()

# check that input and output file names were provided
if not args.input_file:
    print("Error: Please provide an input file name.")
    exit()
if not args.output_file:
    print("Error: Please provide an output file name.")
    exit()

# check that the input file exists
if not os.path.isfile(args.input_file):
    print(f'Error: Input file {args.input_file} does not exist')
    exit()

# check that the output file does not exist
if os.path.isfile(args.output_file):
    print(f'Error: Output file {args.output_file} already exists')
    exit()

# read in the original file
with open(args.input_file, 'r') as f:
    original_data = f.read()

# add opening bracket
fixed_data = '[' + original_data

# add commas between objects
fixed_data = fixed_data.replace('}\n{', '},\n{')

# add closing bracket
fixed_data += ']'

# parse the data to check if it's valid JSON
try:
    json.loads(fixed_data)
except json.JSONDecodeError as e:
    print(f'Error: {e}')
else:
    # write the fixed data to a new file
    with open(args.output_file, 'w') as f:
        f.write(fixed_data)
