#!/usr/bin/env python3
import argparse

class CryptoStr:
    def __init__(self, cryptoStr) -> None:
        self.cryptoStr = cryptoStr

    
    def rmSpaces(self):
        return str(self.cryptoStr).replace(" ","")

def main():
    parser = argparse.ArgumentParser(description='Decrypt | Decode String')
    parser.add_argument('inStr', action='store', type=str, help='Provide a string as input')
    parser.add_argument('-rm','--remove_spaces', action='store_true', help='Remove whitespace')

    args = parser.parse_args()

    magicStr = CryptoStr(args.inStr)

    if args.remove_spaces == True:
        print("String without white space:")
        print(magicStr.rmSpaces())

if __name__ == "__main__":
    main()
    