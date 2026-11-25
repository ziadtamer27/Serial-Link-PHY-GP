/*
 * PLL0_private.h
 *
 * Code generation for model "PLL0".
 *
 * Model version              : 1.3
 * Simulink Coder version : 9.9 (R2023a) 19-Nov-2022
 * C source code generated on : Tue Nov 24 19:33:21 2026
 *
 * Target selection: systemverilog_dpi_grt.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef RTW_HEADER_PLL0_private_h_
#define RTW_HEADER_PLL0_private_h_
#include "rtwtypes.h"
#include "builtin_typeid_types.h"
#include "multiword_types.h"
#include "zero_crossing_types.h"
#include "PLL0.h"
#include "PLL0_types.h"
#if !defined(rt_VALIDATE_MEMORY)
#define rt_VALIDATE_MEMORY(S, ptr)     if(!(ptr)) {\
 rtmSetErrorStatus(PLL0_M, RT_MEMORY_ALLOCATION_ERROR);\
 }
#endif

#if !defined(rt_FREE)
#if !defined(_WIN32)
#define rt_FREE(ptr)                   if((ptr) != (NULL)) {\
 free((ptr));\
 (ptr) = (NULL);\
 }
#else

/* Visual and other windows compilers declare free without const */
#define rt_FREE(ptr)                   if((ptr) != (NULL)) {\
 free((void *)(ptr));\
 (ptr) = (NULL);\
 }
#endif
#endif

void PLL0_DFlipFlop_Init(B_DFlipFlop_PLL0_T *localB);
void PLL0_DFlipFlop_Disable(B_DFlipFlop_PLL0_T *localB, DW_DFlipFlop_PLL0_T
  *localDW);
void PLL0_DFlipFlop(boolean_T rtu_C, boolean_T rtu_Trigger, boolean_T rtu_D,
                    B_DFlipFlop_PLL0_T *localB, DW_DFlipFlop_PLL0_T *localDW,
                    ZCE_DFlipFlop_PLL0_T *localZCE);
void PLL0_DFlipFlop_Term(void);

#endif                                 /* RTW_HEADER_PLL0_private_h_ */
