import os
#import xmlrpc
import time
import sys
import win32pipe
import win32file
import pywintypes
import ctypes
from ctypes import byref, c_ulong, c_char_p
import msvcrt
kernel32 = ctypes.WinDLL('kernel32', use_last_error=True)

NamedPipeExemptList = ['InitShutdown', 'scerpc']

if __name__ == '__main__':
    namedPipePrefix = fr"\\.\pipe"
    named_pipe_list = os.listdir(namedPipePrefix)
    print(named_pipe_list)

    for index,pipe in enumerate(named_pipe_list):
        if index == (len(named_pipe_list) - 1):
            print("Last pipe")
        if pipe not in NamedPipeExemptList:
            try:
                print(fr"Working on {namedPipePrefix}\{pipe}")
                #handle = win32file.CreateFile(fr"{namedPipePrefix}\{pipe}", win32file.GENERIC_READ |
                #                              win32file.GENERIC_WRITE, 0, None, win32file.OPEN_EXISTING, 0, None)
                handle = win32file.CreateFile(fr"{namedPipePrefix}\{pipe}", win32file.GENERIC_READ, 0, None, win32file.OPEN_EXISTING, 0, None)
                res = win32pipe.SetNamedPipeHandleState(
                    handle, win32pipe.PIPE_READMODE_MESSAGE, None, None)
                if res == 0:
                    print(f"SetNamedPipeHandleState return code: {res}")
                while True:
                    resp = win32file.ReadFile(handle, 64*1024)
                    print(f"message: {resp}")
            except pywintypes.error as e:
                if e.args[0] == 2:
                    print("no pipe")
                    time.sleep(1)
                elif e.args[0] == 109:
                    print("broken pipe")
                    #quit = True
                else:
                    print("Pipe Error: ",e.args[0])