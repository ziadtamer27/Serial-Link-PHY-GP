@echo off
setlocal


:: Resolve path to the serializer\matlab directory
for %%I in ("%~dp0..\matlab") do set "MATLAB_DIR=%%~fI"

echo ========================================================
echo Launching MATLAB Differential Transmitter Test (Preset FFE)
echo Directory: %MATLAB_DIR%
echo ========================================================

:: Run test_differential.m and keep MATLAB open so the figure window stays visible
matlab -r "cd('%MATLAB_DIR%'); test_differential;"

endlocal
