# MATLAB <--> UVM Integration via DPI-C

This directory contains a complete, minimal, and fully functional example connecting **MATLAB** to the **UVM Environment** using **SystemVerilog DPI-C**.

---

## 1. Directory Structure

- [`matlab_func.m`](file:///a:/college/senior%202%20term%201/GP/Serial-Link-PHY-GP/RTL/TX/UVM_environment/serializer/matlab_dpi/matlab_func.m): A trivial MATLAB function that computes `(a + b) * 2`.
- [`matlab_dpi_pkg.sv`](file:///a:/college/senior%202%20term%201/GP/Serial-Link-PHY-GP/RTL/TX/UVM_environment/serializer/matlab_dpi/matlab_dpi_pkg.sv): SystemVerilog package declaring the `import "DPI-C"` functions and a convenient SV wrapper `call_matlab_func(a, b)`.
- [`matlab_func_dpi.dll`](file:///a:/college/senior%202%20term%201/GP/Serial-Link-PHY-GP/RTL/TX/UVM_environment/serializer/matlab_dpi/matlab_func_dpi.dll): Pre-compiled 64-bit Windows DLL loaded by QuestaSim during simulation.
- [`build_matlab_dpi.bat`](file:///a:/college/senior%202%20term%201/GP/Serial-Link-PHY-GP/RTL/TX/UVM_environment/serializer/matlab_dpi/build_matlab_dpi.bat): Batch script to regenerate C code via MATLAB HDL Verifier (`dpigen`) and recompile the DLL with MinGW GCC.
- `codegen/`: Generated C wrapper files from MATLAB.

---

## 2. UVM Integration

- [`ser_matlab_dpi_test.sv`](file:///a:/college/senior%202%20term%201/GP/Serial-Link-PHY-GP/RTL/TX/UVM_environment/serializer/ser_matlab_dpi_test.sv):
  A dedicated UVM test extending `ser_test`. In its `run_phase`, it calls the MATLAB DPI-C function with test inputs `(a=20, b=30)`, compares the returned result (`100`) against the expected value, logs the status via `uvm_info`, and then runs the standard serializer sequence.

---

## 3. How to Run

From QuestaSim or ModelSim in the `serializer` directory:
```tcl
do run.do
```

Or from the command line:
```powershell
vlog +define+SIM -f Src_files.list
vsim -c -sv_lib matlab_dpi/matlab_func_dpi +UVM_TESTNAME=ser_matlab_dpi_test work.top -do "run -all; quit -f"
```
