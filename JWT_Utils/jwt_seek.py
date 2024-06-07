import re

# Python version for finding JWTs
def jwt_seeker(target_str: str):
    jwt_regex = "[= ]eyJ[A-Za-z0-9_\/+-]*\.[A-Za-z0-9._\/+-]*"
    matches = re.findall(jwt_regex, target_str)
    print(f"JWT Matches {matches}")