@echo off
call common.bat

Pushd %VIVADO_HOME%\VIVADO\%VIVADO_VERSION%
call %VIVADO_HOME%\VIVADO\%VIVADO_VERSION%\settings64.bat
popd

echo 1.dsm_order6
echo 2.dsm_control
echo 3.axi_datatran


set/p a1=«Î ‰»Îƒƒ∏ˆIP:

if %a1% == 1 goto 1

if %a1% == 2 goto 2

if %a1% == 3 goto 3



:1

call vivado -mode tcl -source dsm_order6_ip.tcl

goto :eof



:2

call vivado -mode tcl -source dsm_control_ip.tcl

goto :eof



:3

call vivado -mode tcl -source axi_datatran_ip.tcl
 
goto :eof


:eof
pause