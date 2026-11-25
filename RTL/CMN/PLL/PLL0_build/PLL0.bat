
set MATLAB=D:\DIGITAL\MATLAB

cd .

if "%1"=="" ("D:\DIGITAL\MATLAB\bin\win64\gmake"  -f PLL0.mk all) else ("D:\DIGITAL\MATLAB\bin\win64\gmake"  -f PLL0.mk %1)
@if errorlevel 1 goto error_exit

exit /B 0

:error_exit
echo The make command returned an error of %errorlevel%
exit /B 1