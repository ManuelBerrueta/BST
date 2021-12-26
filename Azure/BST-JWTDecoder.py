#!/usr/bin/env python3
import jwt
import base64
import json
import os
import subprocess

from jwt.utils import base64url_decode

user = subprocess.check_output("whoami")
token_path = "/home/" + user.decode().strip('\n') + "/.azure/accessTokens.json"


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


def decode_jwt():
    with open(token_path, "r") as data_file:
        tokens = json.load(data_file)
        for i, token in enumerate(tokens):
            # TODO: FORMAT STRING#print("][Token #][",token)
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
            #print(jwt.decode(token['accessToken'], verify=False))

            # jwt.decode(token['accessToken'], algorithms=['RS256'])
            print("\n")

            # https://stackoverflow.com/questions/59425161/getting-only-decoded-payload-from-jwt-in-python


def encode_jwt():
    # Ref: https://auth0.com/blog/how-to-handle-jwt-in-python/
    print("WIP")


decode_jwt()
