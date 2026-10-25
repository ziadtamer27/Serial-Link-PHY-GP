@echo off

set MATLAB=F:\programs\matlabfolder

cd .

if "%1"=="" ("F:\programs\MATLAB~1\bin\win64\gmake"  -f matlab_func_rtw.mk all) else ("F:\programs\MATLAB~1\bin\win64\gmake"  -f matlab_func_rtw.mk %1)
@if errorlevel 1 goto error_exit

exit /B 0

:error_exit
echo The make command returned an error of %errorlevel%
exit /B 1