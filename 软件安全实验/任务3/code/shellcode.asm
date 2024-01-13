.386;
.model flat, stdcall
option casemap :none   ; case sensitive
include c:\masm32\include\windows.inc 
include c:\masm32\include\comctl32.inc 
includelib C:\masm32\lib\kernel32.lib    
includelib C:\masm32\lib\user32.lib    
include C:\masm32\include\kernel32.inc    
include C:\masm32\include\user32.inc    
includelib c:\masm32\lib\comctl32.lib 
.code
_start:
jmp short gotocall
shellcode:
pop esi
xor eax,eax
mov byte ptr[esi+8],al
mov ebx,esi
push ebx
mov ebx,75F50A60h ;system的地址
call ebx
mov ebx,75EB2F60h ;exit的地址
call ebx
gotocall:
call shellcode
db'calc.exeddd'
end _start