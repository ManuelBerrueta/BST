from cryptography.hazmat.primitives import serialization
import jwt
import datetime
import argparse
import pyperclip

# NOTE: you can run this script from the command line with the following command:
# 1. python3 jwt_sign.py path/to/private_key.pem --x5t x5t_value --aud aud_claim --iss client_id --sub client_id
# 2. python3 jwt_sign.py path/to/private_key.pem, and follow the prompts for each of the inputs

# NOTE: You can also use it as a module by importing the function and calling it with the required arguments
# from jwt_sign import sign_jwt
# token = sign_jwt(private_key_path, x5t, aud, iss, sub) or 
# token = sign_jwt('/path/to/private/key', x5t='your_x5t', aud='your_aud', iss='your_iss', sub='your_sub')
# print(f'JWT Token: {token}')

def sign_jwt(private_key_path, x5t=None, aud=None, iss=None, sub=None):
    # Open + read the private key
    private_key_str = open(private_key_path, 'r').read()

    # Load as PEM private key
    private_key = serialization.load_pem_private_key(
        private_key_str.encode('utf-8'), password=None)  # password=b''

    # Use provided arguments or prompt for input
    x5t = x5t if x5t is not None else input('Enter the x5t: ')
    aud = aud if aud is not None else input('Enter the aud claim: ')
    iss = iss if iss is not None else input('Enter the iss claim: ')
    sub = sub if sub is not None else input('Enter the sub claim: ')

    headers = {
        "alg": "RS256",
        "typ": "JWT",
        "x5t": x5t
    }

    payload_data = {
        "aud": aud,
        "iss": iss,
        "nbf": datetime.datetime.now(tz=datetime.timezone.utc) + datetime.timedelta(seconds=30),
        "exp": datetime.datetime.now(tz=datetime.timezone.utc) + datetime.timedelta(days=2),
        "sub": sub
    }

    # Sign the JWT
    token = jwt.encode(payload=payload_data, key=private_key, algorithm="RS256", headers=headers)
    return token

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='CLI input for JWT signing')
    parser.add_argument('private_key_path', type=str, help='The path to the private key')
    parser.add_argument('--x5t', type=str, help='x5t value', default=None)
    parser.add_argument('--aud', type=str, help='aud claim', default=None)
    parser.add_argument('--iss', type=str, help='iss claim', default=None)
    parser.add_argument('--sub', type=str, help='sub claim', default=None)
    args = parser.parse_args()

    # Call the function with command line arguments or prompts
    token = sign_jwt(args.private_key_path, args.x5t, args.aud, args.iss, args.sub)
    pyperclip.copy(token)
    print(f'JWT Token (Copied to Clipboard):\n{token}')