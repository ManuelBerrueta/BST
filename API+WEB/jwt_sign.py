from cryptography.hazmat.primitives import serialization
import jwt
import datetime

# Path where private key is located
private_key_path = 'CertPrivateKey/priv_key.pem'

# Open + read the private key
private_key_str = open(private_key_path, 'r').read()

# Load as PEM private key
private_key = serialization.load_pem_private_key(
    private_key_str.encode('utf-8'), password=None) #password=b''

headers = {
    "alg": "RS256",
    "typ": "JWT",
    "my_custom": "blah"
}

payload_data = {
    "aud": "https://www.<>.com",
    "iss": "00000000-0000-0000-0000-000000000000",
    "nbf": datetime.datetime.now(tz=datetime.timezone.utc) + datetime.timedelta(seconds=30),
    "exp": datetime.datetime.now(tz=datetime.timezone.utc) + datetime.timedelta(days=2),
    "sub": "00000000-0000-0000-0000-000000000000"
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