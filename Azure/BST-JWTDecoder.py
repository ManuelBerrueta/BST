#!/usr/bin/env python3
import jwt
import json
import os
import subprocess

user = subprocess.check_output("whoami")
token_path = "/home/" + user.decode().strip('\n') + "/.azure/accessTokens.json"


with open(token_path, "r") as data_file:
    tokens = json.load(data_file)
    for i, token in enumerate(tokens):
        #TODO: FORMAT STRING#print("][Token #][",token)
        print("][Token #][")
        print(token['accessToken']) 

        jwt.decode(token['accessToken'], algorithms=['RS256'])
        #print(token)
        print("\n")

        # https://stackoverflow.com/questions/59425161/getting-only-decoded-payload-from-jwt-in-python