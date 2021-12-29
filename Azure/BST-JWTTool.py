#!/usr/bin/env python3
import jwt
from jwt.utils import base64url_decode, base64url_encode
import base64
import json
import os
import subprocess
import argparse

parser = argparse.ArgumentParser()

parser.add_argument('--grabAzTokens', type=str, required=False,
                    default='.azure/accessTokens.json', help='--grabAzTokens /path/to/.azure/accessTokens.json')
parser.add_argument('--grabAzTokdefault', required=False, default=False,
                    action='store_true', help='--grabAzTokdefault')
parser.add_argument('--decode', type=str, required=False,
                    default='', help='--decode <eyJ0...tokenString>')
parser.add_argument('--tamper', nargs=2, metavar=('in_jwt', 'new_payload'), type=str, required=False, default='',
                    help='--tamper <eyJ0...tokenString> \'{"aud": "https://some.domain.net/","iat": 16408037602,"nbf": 1648976610,"exp": 1648986610,"name": "Not Me","sub": "1A2b3C4d5E6f7G8h9I0j"}\'')

args = parser.parse_args()


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def decode_az_accesstokens(token_path):
    with open(token_path, "r") as data_file:
        tokens = json.load(data_file)
        for i, token in enumerate(tokens):
            print(bcolors.WARNING + "][Token #" + i.__str__() + "][")
            print(token['accessToken'] + bcolors.ENDC)

            # Split decode each piece:
            split_JWT = str(token['accessToken']).split(".")
            for j, partOfJWT in enumerate(split_JWT):
                if j == 0:
                    print(bcolors.HEADER + "Header:")
                elif j == 1:
                    print(bcolors.OKBLUE + "Claims:")
                else:
                    print(bcolors.OKGREEN + "Signature:\n" +
                          base64url_decode(partOfJWT).__str__() + bcolors.ENDC)
                    break

                # print(base64url_decode(partOfJWT).__str__() + bcolors.ENDC)
                print(json.dumps(json.loads(base64url_decode(
                    partOfJWT)), indent=3) + bcolors.ENDC)

            # Decode Header and Claims together
            # print(jwt.decode(token['accessToken'], verify=False))

            # jwt.decode(token['accessToken'], algorithms=['RS256'])
            print("\n")

            # https://stackoverflow.com/questions/59425161/getting-only-decoded-payload-from-jwt-in-python


def encode_clean_jwt():
    # Ref: https://auth0.com/blog/how-to-handle-jwt-in-python/
    # encoded_JWT = jwt.encode({"some": "payload"}, private_key, algorithm="RS256")
    # jwt.encode(
    #    {"some": "payload"},
    #    "secret",
    #    algorithm="HS256",
    #    headers={"kid": "230498151c214b788dd97f22b85410a5"},
    # )
    print("WIP")


def tamper_jwt_payload(in_jwt: str, tampered_payload: str):
    split_JWT = in_jwt.split(".")

    split_JWT[1] = base64url_encode(tampered_payload.encode()).decode()
    #split_JWT[1] = 'test'

    tampered_jwt = '.'.join(split_JWT)
    print("\n===[New Tampered JWT]===\n")
    print(tampered_jwt)


def decode_jwt(in_jwt: str):
    # Split decode each piece:
    split_JWT = in_jwt.split(".")
    for j, partOfJWT in enumerate(split_JWT):
        if j == 0:
            print(bcolors.HEADER + "Header:")
        elif j == 1:
            print(bcolors.OKBLUE + "Claims:")
        else:
            print(bcolors.OKGREEN + "Signature:\n" +
                  base64url_decode(partOfJWT).__str__() + bcolors.ENDC)
            break

        # print(base64url_decode(partOfJWT).__str__() + bcolors.ENDC)
        print(json.dumps(json.loads(base64url_decode(
            partOfJWT)), indent=3) + bcolors.ENDC)

    # Decode Header and Claims together
    # print(jwt.decode(token['accessToken'], verify=False))

    # jwt.decode(token['accessToken'], algorithms=['RS256'])
    print("\n")


def main():
    token_path = ''
    if args.decode:
        print("DECODING JWT")
        decode_jwt(args.decode)
        print("DONE!")
    elif args.tamper:
        in_jwt, new_payload = args.tamper
        tamper_jwt_payload(in_jwt, new_payload)
        print("Finished Tampered JWT")
    elif args.grabAzTokdefault:
        user = subprocess.check_output("whoami")
        token_path = "/home/" + user.decode().strip('\n') + "/.azure/accessTokens.json"
        decode_az_accesstokens(token_path)
        print("Running Default")
    elif args.grabAzTokens:
        decode_az_accesstokens(args.grabAzTokens)
        print("Running passed in")
        print(args.grabAzTokens)


if __name__ == "__main__":
    main()
