/*
 * File: _coder_matlab_func_mex.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 20-Oct-2026 19:22:18
 */

#ifndef _CODER_MATLAB_FUNC_MEX_H
#define _CODER_MATLAB_FUNC_MEX_H

/* Include Files */
#include "emlrt.h"
#include "mex.h"
#include "tmwtypes.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
MEXFUNCTION_LINKAGE void mexFunction(int32_T nlhs, mxArray *plhs[],
                                     int32_T nrhs, const mxArray *prhs[]);

emlrtCTX mexFunctionCreateRootTLS(void);

void unsafe_matlab_func_mexFunction(int32_T nlhs, mxArray *plhs[1],
                                    int32_T nrhs, const mxArray *prhs[2]);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_matlab_func_mex.h
 *
 * [EOF]
 */
