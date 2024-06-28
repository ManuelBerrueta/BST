import base64
import json
import sys
from pygments import highlight
from pygments.lexers import JsonLexer
from pygments.formatters import TerminalFormatter

def base64_url_decode(input_str):
    """Decode a base64 URL-safe string."""
    padding = '=' * (4 - len(input_str) % 4)
    return base64.urlsafe_b64decode(input_str + padding)

def decode_jwt(jwt):
    """Decode the JWT and print its components with syntax highlighting."""
    try:
        header, payload, signature = jwt.split('.')
    except ValueError:
        print("Error: Invalid JWT format. Make sure it has three parts separated by dots.")
        sys.exit(1)
    
    try:
        header_json = json.loads(base64_url_decode(header))
        payload_json = json.loads(base64_url_decode(payload))
    except (json.JSONDecodeError, base64.binascii.Error):
        print("Error: Failed to decode JWT components. Make sure the JWT is valid.")
        sys.exit(1)
    
    print("Header:")
    print(highlight(json.dumps(header_json, indent=4), JsonLexer(), TerminalFormatter()))

    print("Payload:")
    print(highlight(json.dumps(payload_json, indent=4), JsonLexer(), TerminalFormatter()))

    print("Signature:")
    print(signature)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Error: No JWT provided. Usage: python decode_jwt.py <your_jwt_here>")
        sys.exit(1)
    
    jwt = sys.argv[1]
    decode_jwt(jwt)
