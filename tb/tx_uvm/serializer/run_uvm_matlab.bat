@echo off
setlocal

:: 1. Add MATLAB bin/win64 to PATH for runtime DLLs (libeng.dll, libmx.dll)
set "PATH=F:\programs\matlabfolder\bin\win64;%PATH%"

:: 2. Set Questa license environment variables
set "LM_LICENSE_FILE=A:\programs\questa\mgcld.lic"
set "MGLS_LICENSE_FILE=A:\programs\questa\mgcld.lic"

:: Ensure working directory is the serializer folder
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

:: 3. Compile C-DPI MATLAB Bridge DLL if missing or requested
if not exist matlab_bridge.dll (
    echo ========================================================
    echo [STEP 1] Compiling C-DPI MATLAB Bridge DLL with GCC...
    echo ========================================================
    gcc -shared -fPIC -IA:/programs/questa/include -IF:/programs/matlabfolder/extern/include matlab_bridge.c -LF:/programs/matlabfolder/extern/lib/win64/mingw64 -leng -lmx -o matlab_bridge.dll
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Failed to compile matlab_bridge.dll!
        pause
        exit /b %ERRORLEVEL%
    )
    echo Successfully built matlab_bridge.dll.
) else (
    echo [INFO] Found existing matlab_bridge.dll.
)

echo.
echo ========================================================
echo [STEP 2] Compiling SystemVerilog Design and UVM TB...
echo ========================================================
if not exist work vlib work
vlog +define+SIM -f Src_files.list +cover=bcefst
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to compile SystemVerilog source files!
    pause
    exit /b %ERRORLEVEL%
)
echo Successfully compiled SystemVerilog source files.

echo.
echo ========================================================
echo [STEP 3] Running Simulation with QuestaSim and MATLAB DPI...
echo ========================================================
if /i "%1"=="gui" (
    echo Launching QuestaSim in GUI mode...
    vsim -gui -voptargs=+acc work.top -sv_lib matlab_bridge -classdebug -uvmcontrol=all -cover -do run_uvm_gui.do
) else (
    echo Launching QuestaSim in CLI mode...
    echo (Tip: Run "run_uvm_matlab.bat gui" to open Questa GUI with waveforms)
    vsim -c -voptargs=+acc work.top -sv_lib matlab_bridge -classdebug -uvmcontrol=all -cover -do run_uvm_cli.do
)

echo.
echo [DONE] Simulation finished successfully.
endlocal
