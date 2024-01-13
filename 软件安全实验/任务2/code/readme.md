运行环境为win7
直接点击exe文件即可运行exe文件
汇编以及链接文件使用如下命令
setpath.bat
ml /c /coff MyPE1.asm && link /subsystem:windows /section:.text,rwe MyPE1.obj
ml /c /coff hello.asm && link /subsystem:windows /section:.text,rwe hello.obj
ml /c /coff win7virus.asm && link /subsystem:windows /section:.text,rwe win7virus.obj
