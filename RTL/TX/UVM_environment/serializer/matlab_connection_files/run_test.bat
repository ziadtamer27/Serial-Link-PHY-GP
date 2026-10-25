@echo off
setlocal

:: 1. Add MATLAB bin/win64 to PATH for runtime DLLs
set PATH=F:\programs\matlabfolder\bin\win64;%PATH%

:: 2. Set Questa license environment variables
set MGLS_LICENSE_FILE=A:\programs\questa\mgcld.lic
set LM_LICENSE_FILE=A:\programs\questa\mgcld.lic

echo ========================================================
echo [STEP 1] Compiling C-DPI MATLAB Bridge DLL with GCC...
echo ========================================================
gcc -shared -fPIC -IA:/programs/questa/include -IF:/programs/matlabfolder/extern/include matlab_bridge.c -LF:/programs/matlabfolder/extern/lib/win64/mingw64 -leng -lmx -o matlab_bridge.dll
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to compile matlab_bridge.dll!
    exit /b %ERRORLEVEL%
)
echo Successfully built matlab_bridge.dll.

echo.
echo ========================================================
echo [STEP 2] Compiling SystemVerilog Design and Testbench...
echo ========================================================
if exist work rmdir /s /q work
vlib work
vlog -sv not_gate.sv tb.sv
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to compile SystemVerilog files!
    exit /b %ERRORLEVEL%
)

echo.
echo ========================================================
echo [STEP 3] Running Simulation in QuestaSim with DPI-C...
echo ========================================================
vsim -c tb -sv_lib matlab_bridge -do run.do

echo.
echo [DONE] Simulation finished.
endlocal
