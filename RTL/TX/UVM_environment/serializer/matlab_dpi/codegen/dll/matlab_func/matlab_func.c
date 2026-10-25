/*
 * File: matlab_func.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 20-Oct-2026 19:22:18
 */

/* Include Files */
#include "matlab_func.h"

/* Function Definitions */
/*
 * Trivial MATLAB function to test SystemVerilog / UVM DPI-C connection
 *  Returns (a + b) * 2
 *
 * Arguments    : int a
 *                int b
 * Return Type  : int
 */
int matlab_func(int a, int b)
{
  long long i;
  i = ((long long)a + b) << 1;
  if (i > 2147483647LL) {
    i = 2147483647LL;
  } else if (i < -2147483648LL) {
    i = -2147483648LL;
  }
  return (int)i;
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void matlab_func_initialize(void)
{
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void matlab_func_terminate(void)
{
}

/*
 * File trailer for matlab_func.c
 *
 * [EOF]
 */
