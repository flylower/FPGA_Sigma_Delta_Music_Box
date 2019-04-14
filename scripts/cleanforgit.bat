@echo off

xcopy /i /y ..\sdk\wavdatatran\src\wavtran.c ..\source\sdk\
rem rmdir /s/q ..\ip_repo
rmdir /s/q ..\sdk
rmdir /s/q ..\Wavplay
del  /f /q /a vivado.*

pause