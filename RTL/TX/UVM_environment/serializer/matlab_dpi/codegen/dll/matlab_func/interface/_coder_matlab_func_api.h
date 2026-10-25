/*
 * File: _coder_matlab_func_api.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 20-Oct-2026 19:22:18
 */

#ifndef _CODER_MATLAB_FUNC_API_H
#define _CODER_MATLAB_FUNC_API_H

/* Include Files */
#include "emlrt.h"
#include "tmwtypes.h"
#include <string.h>

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
int32_T matlab_func(int32_T a, int32_T b);

void matlab_func_api(const mxArray *const prhs[2], const mxArray **plhs);

void matlab_func_atexit(void);

void matlab_func_initialize(void);

void matlab_func_terminate(void);

void matlab_func_xil_shutdown(void);

void matlab_func_xil_terminate(void);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_matlab_func_api.h
 *
 * [EOF]
 */
