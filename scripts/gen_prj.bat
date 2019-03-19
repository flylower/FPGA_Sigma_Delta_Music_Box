@echo off

call common.bat

Pushd %VIVADO_HOME%\VIVADO\%VIVADO_VERSION%
call %VIVADO_HOME%\VIVADO\%VIVADO_VERSION%\settings64.bat
popd

del /f /s /q ..\Wavplay
rmdir /S /q ..\Wavplay
mkdir ..\Wavplay
cd ..\Wavplay
call vivado -mode tcl -source ../scripts/Wavplay.tcl
pause