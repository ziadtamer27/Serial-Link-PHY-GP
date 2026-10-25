@echo off
echo ====================================================================
echo Rebuilding MATLAB DPI-C Component
echo ====================================================================

REM Set location of MinGW64 if not set
if not defined MW_MINGW64_LOC set MW_MINGW64_LOC=C:\mingw64

REM Check for MATLAB
where matlab >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [1/2] Generating C code from matlab_func.m using MATLAB dpigen...
    matlab -batch "dpigen matlab_func.m -args {int32(0), int32(0)}"
) else (
    echo [INFO] matlab command not in current PATH; skipping dpigen and compiling existing C files.
)

echo [2/2] Compiling DLL with GCC...
gcc -shared -o matlab_func_dpi.dll -Icodegen\dll\matlab_func -I"F:\programs\matlabfolder\extern\include" codegen\dll\matlab_func\matlab_func.c codegen\dll\matlab_func\matlab_func_dpi.c -Wl,--export-all-symbols

if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] matlab_func_dpi.dll built successfully!
) else (
    echo [ERROR] DLL compilation failed!
)
