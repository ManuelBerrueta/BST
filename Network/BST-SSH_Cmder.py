from ast import Try
from sys import stderr, stdout
import os.path
import asyncio
import paramiko
from scp import SCPClient
import argparse
import getpass
import csv

from paramiko import client

parser = argparse.ArgumentParser()

parser.add_argument(
    "--user",
    type=str,
    required=False,
    default=getpass.getuser(),
    help="--user myUserName",
)
parser.add_argument(
    "--pw", type=str, required=False, default="", help="--pw mySSHPassword"
)
parser.add_argument(
    "--key", type=str, required=False, default="", help="--key id_rsa.txt"
)
parser.add_argument("--ip", type=str, required=False,
                    default="", help="--ip 127.0.0.1")
parser.add_argument("--port", type=int, required=False,
                    default=22, help="--port 22")
parser.add_argument(
    "--scp", type=str, required=False, default="", help="--scp put or --scp get"
)
parser.add_argument(
    "--scp_path", required=False, nargs='+', default="", help="--scp_path target/File/Path1 target/File/Path2"
)
parser.add_argument(
    "--ip_list", type=str, required=False, default="", help="--ip_list my_ip_list.txt"
)
parser.add_argument("--cmd", type=str, required=False,
                    default="", help="--cmd ls")
parser.add_argument(
    "--cmd_script",
    type=str,
    required=False,
    default="",
    help="--cmd_script file_w_commands.sh",
)

args = parser.parse_args()


def scp_transfer(user: str, password: str, key: str, ip_list: str, port: str, scp_action: str, paths: list):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    for ip in ip_list:
        if password != "" and key == "":
            ssh_client.connect(ip, port, user, password)
        elif key != "" and password == "":
            ssh_client.connect(
                ip, port, user, key_filename=key, look_for_keys=False)

        scp = SCPClient(ssh_client.get_transport())

        # Check if file(s) exists if it does not exist
        for file in paths:
            if not os.path.isfile(file):
                paths.remove(file)

        print("===[ Target IP: " + ip + " ]===")

        try:
            scp.put(paths)
        except:
            print("====( Error while transfering to IP: " + ip)

        print("====( Transfer of " + str(paths) + " success to IP: " + ip)
        ssh_client.close()
        print("\n")


def ssh_cmder(
    user: str, password: str, key: str, ip_list: str, port: str, cmd_list: list
):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    print("IP LIST: ", ip_list)

    for ip in ip_list:
        if password != "" and key == "":
            ssh_client.connect(ip, port, user, password)
        elif key != "" and password == "":
            ssh_client.connect(
                ip, port, user, key_filename=key, look_for_keys=False)

        for cmd in cmd_list:
            _, stdout, stderr = ssh_client.exec_command(cmd)
            cmd_output = stdout.readlines() + stderr.readlines()

            print("\n===[ CMD Output for IP:" + ip + "]===")
            if cmd_output:
                for each_line in cmd_output:
                    # print(each_line.strip())
                    print(each_line)

            print("\n")

    print("Test ssh_cmder")


def main():
    user = args.user
    pwd = ""
    key_path = ""
    ip_list = []
    port = args.port
    cmd_list = []
    scp_action = args.scp
    scp_paths = args.scp_path

    if args.ip_list == "" and args.ip == "":
        print("You must provide either --ip or --ip_list as an argument")
        exit(1)
    elif args.ip_list != "" and args.ip != "":
        print("You must provide either --ip or --ip_list as an argument but NOT both!")
        exit(1)
    elif args.ip_list:
        with open(args.ip_list, newline="") as ip_file:
            # file_content = ip_file.read()
            # ip_list = file_content.split(",")
            file_content = csv.reader(ip_file)
            ip_list = list(file_content)
            ip_list = ip_list[0]

            print(ip_list)
            print(type(ip_list))
            ip_file.close()
    elif args.ip:
        ip_list.append(args.ip)
    else:
        print("ERROR: Missing ip or ip list")
        exit(1)

    if args.pw == "" and args.key == "":
        print("You must provide either --pw or --key as an argument")
        exit(1)
    elif args.pw != "" and args.key != "":
        print("You must provide either --pw or --key as an argument but NOT both!")
        exit(1)
    elif args.key:
        key_path = args.key
    elif args.pw:
        pwd = args.pw
    else:
        print("ERROR: Missing pw or key file")
        exit(1)

    if scp_action != "":
        if not scp_paths:
            print("=== Error: No paths passed for scp file transfer ===")
            exit(1)

        print("scp_action: " + scp_action)

        if scp_action == "put":
            print("scp_action is put: " + scp_action)

        if scp_action == "get":
            print("scp_action is get: " + scp_action)

        if scp_action != "put" and scp_action != "get":
            print("=== Error: --scp must be either 'put' or 'get'  ===")
            exit(1)

        scp_transfer(user, pwd, key_path, ip_list, port, scp_action, scp_paths)

    else:
        if args.cmd == "" and args.cmd_script == "":
            print("You must provide either --cmd or --cmd_script as an argument")
            exit(1)
        elif args.cmd != "" and args.cmd_script != "":
            print(
                "You must provide either --cmd or --cmd_script as an argument but NOT both!"
            )
            exit(1)
        elif args.cmd_script:
            with open(args.cmd_script) as cmd_script_file:
                # cmd_script_file_content = cmd_script_file.read().splitlines()
                cmd_list = cmd_script_file.read().splitlines()
        elif args.cmd:
            cmd_list.append(args.cmd)
        else:
            print("ERROR: Missing cmd or cmd script")
            exit(1)

        ssh_cmder(user, pwd, key_path, ip_list, port, cmd_list)


if __name__ == "__main__":
    main()
