from cryptography.hazmat.primitives import serialization
import jwt
import datetime
import argparse

# To run this script: python jwt_sign.py /path/to/private/key

parser = argparse.ArgumentParser(description='CLI input')
parser.add_argument('private_key_path', type=str, help='The path to the private key')
args = parser.parse_args()

# Now you can use args.private_key_path where you need the private key path
print(f'Using Private key @ path: {args.private_key_path}')

private_key_path = args.private_key_path

# Open + read the private key
private_key_str = open(args.private_key_path, 'r').read()

# Load as PEM private key
private_key = serialization.load_pem_private_key(
    private_key_str.encode('utf-8'), password=None) #password=b''

headers = {
    "alg": "RS256",
    "typ": "JWT",
    "x5t": input('Enter the x5t: ')
}

payload_data = {
    "aud": input('Enter the aud claim: '),
    "iss": input('Enter the iss claim: '),
    "nbf": datetime.datetime.now(tz=datetime.timezone.utc) + datetime.timedelta(seconds=30),
    "exp": datetime.datetime.now(tz=datetime.timezone.utc) + datetime.timedelta(days=2),
    "sub": input('Enter the sub claim: ')
}

new_token = jwt.encode(
    payload=payload_data,
    headers=headers,
    key=private_key,
    algorithm='RS256'
)
print(new_token)

# Reference:
# - [How to handle JWTs](https://auth0.com/blog/how-to-handle-jwt-in-python/
# - [PyJWT Docs](https://pyjwt.readthedocs.io/en/stable/usage.html#encoding-decoding-tokens-with-rs256-rsa)