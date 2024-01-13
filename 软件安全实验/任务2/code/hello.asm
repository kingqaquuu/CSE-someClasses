.386 
.model flat,stdcall 
option casemap:none 

include windows.inc 
include kernel32.inc 

includelib kernel32.lib 
include user32.inc 

includelib user32.lib 
.data 
MsgBoxCaption  db "PeTest",0 
MsgBoxText    db "HelloPE",0 
num dd 12
buffer db 100 dup(0)
szBuff db "%li",0
.code 
start: 
invoke MessageBox, NULL, addr MsgBoxText, addr MsgBoxCaption, MB_OK+MB_ICONASTERISK+MB_DEFBUTTON1+MB_SYSTEMMODAL
invoke MessageBox, NULL, addr MsgBoxText, addr MsgBoxCaption, MB_OK+MB_ICONASTERISK+MB_DEFBUTTON1+MB_SYSTEMMODAL
invoke ExitProcess, NULL
invoke wsprintf,addr buffer,addr szBuff,num
end start 