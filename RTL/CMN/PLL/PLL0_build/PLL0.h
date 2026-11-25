/*
 * PLL0.h
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

#ifndef RTW_HEADER_PLL0_h_
#define RTW_HEADER_PLL0_h_
#ifndef PLL0_COMMON_INCLUDES_
#define PLL0_COMMON_INCLUDES_
#include <stdlib.h>
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#endif                                 /* PLL0_COMMON_INCLUDES_ */

#include "PLL0_types.h"
#include "rt_nonfinite.h"
#include "rtGetNaN.h"
#include "rtw_modelmap.h"
#include <stddef.h>
#include <string.h>
#include "zero_crossing_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetBlockIO
#define rtmGetBlockIO(rtm)             ((rtm)->blockIO)
#endif

#ifndef rtmSetBlockIO
#define rtmSetBlockIO(rtm, val)        ((rtm)->blockIO = (val))
#endif

#ifndef rtmGetDataMapInfo
#define rtmGetDataMapInfo(rtm)         ((rtm)->DataMapInfo)
#endif

#ifndef rtmSetDataMapInfo
#define rtmSetDataMapInfo(rtm, val)    ((rtm)->DataMapInfo = (val))
#endif

#ifndef rtmGetPrevZCSigState
#define rtmGetPrevZCSigState(rtm)      ((rtm)->prevZCSigState)
#endif

#ifndef rtmSetPrevZCSigState
#define rtmSetPrevZCSigState(rtm, val) ((rtm)->prevZCSigState = (val))
#endif

#ifndef rtmGetRootDWork
#define rtmGetRootDWork(rtm)           ((rtm)->dwork)
#endif

#ifndef rtmSetRootDWork
#define rtmSetRootDWork(rtm, val)      ((rtm)->dwork = (val))
#endif

#ifndef rtmGetU
#define rtmGetU(rtm)                   ((rtm)->inputs)
#endif

#ifndef rtmSetU
#define rtmSetU(rtm, val)              ((rtm)->inputs = (val))
#endif

#ifndef rtmGetY
#define rtmGetY(rtm)                   ((rtm)->outputs)
#endif

#ifndef rtmSetY
#define rtmSetY(rtm, val)              ((rtm)->outputs = (val))
#endif

#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

#define PLL0_M_TYPE                    RT_MODEL_PLL0_T

/* Block signals for system '<S8>/D Flip-Flop' */
typedef struct {
  boolean_T D;                         /* '<S10>/D' */
  boolean_T Logic;                     /* '<S10>/Logic' */
} B_DFlipFlop_PLL0_T;

/* Block states (default storage) for system '<S8>/D Flip-Flop' */
typedef struct {
  boolean_T DFlipFlop_MODE;            /* '<S8>/D Flip-Flop' */
} DW_DFlipFlop_PLL0_T;

/* Zero-crossing (trigger) state for system '<S8>/D Flip-Flop' */
typedef struct {
  ZCSigState DFlipFlop_Trig_ZCE;       /* '<S8>/D Flip-Flop' */
} ZCE_DFlipFlop_PLL0_T;

/* Block signals (default storage) */
typedef struct {
  real_T PhaseState;                   /* '<S1>/Phase State' */
  real_T DiscreteTimeIntegrator;       /* '<S3>/Discrete-Time Integrator' */
  real_T Gain;                         /* '<S3>/Gain' */
  real_T Sum;                          /* '<S3>/Sum' */
  real_T phase_next;                   /* '<S1>/vco' */
  real_T fvco;                         /* '<S1>/vco' */
  real_T i_pump;                       /* '<S1>/Charge Pump' */
  boolean_T TmpLatchAtDFlipFlopInport1;
  boolean_T UnitDelay;                 /* '<S5>/Unit Delay' */
  boolean_T TmpLatchAtDFlipFlopInport1_g;
  boolean_T DataTypeConversion1;       /* '<S1>/Data Type Conversion1' */
  boolean_T NAND;                      /* '<S5>/NAND' */
  boolean_T vco_clk_N;                 /* '<S1>/MATLAB Function' */
  B_DFlipFlop_PLL0_T DFlipFlop_j;      /* '<S9>/D Flip-Flop' */
  B_DFlipFlop_PLL0_T DFlipFlop;        /* '<S8>/D Flip-Flop' */
} B_PLL0_T;

/* Block states (default storage) for system '<Root>' */
typedef struct {
  real_T PhaseState_DSTATE;            /* '<S1>/Phase State' */
  real_T DiscreteTimeIntegrator_DSTATE;/* '<S3>/Discrete-Time Integrator' */
  real_T count;                        /* '<S1>/MATLAB Function' */
  real_T periodCycles;                 /* '<S1>/MATLAB Function' */
  real_T fracAccum;                    /* '<S1>/MATLAB Function' */
  boolean_T UnitDelay_DSTATE;          /* '<S5>/Unit Delay' */
  boolean_T TmpLatchAtDFlipFlopInport1_PreviousInput;/* synthesized block */
  boolean_T TmpLatchAtDFlipFlopInport1_PreviousInput_o;/* synthesized block */
  boolean_T prevClk;                   /* '<S1>/MATLAB Function' */
  boolean_T clkOut;                    /* '<S1>/MATLAB Function' */
  DW_DFlipFlop_PLL0_T DFlipFlop_j;     /* '<S9>/D Flip-Flop' */
  DW_DFlipFlop_PLL0_T DFlipFlop;       /* '<S8>/D Flip-Flop' */
} DW_PLL0_T;

/* Zero-crossing (trigger) state */
typedef struct {
  ZCE_DFlipFlop_PLL0_T DFlipFlop_j;    /* '<S9>/D Flip-Flop' */
  ZCE_DFlipFlop_PLL0_T DFlipFlop;      /* '<S8>/D Flip-Flop' */
} PrevZCX_PLL0_T;

/* External inputs (root inport signals with default storage) */
typedef struct {
  boolean_T Fref;                      /* '<Root>/Fref' */
  boolean_T rst_N;                     /* '<Root>/rst_N' */
  real_T N;                            /* '<Root>/N' */
} ExtU_PLL0_T;

/* External outputs (root outports fed by signals with default storage) */
typedef struct {
  boolean_T F_N;                       /* '<Root>/F_N' */
} ExtY_PLL0_T;

/* Real-time Model Data Structure */
struct tag_RTM_PLL0_T {
  const char_T *errorStatus;
  B_PLL0_T *blockIO;
  PrevZCX_PLL0_T *prevZCSigState;
  ExtU_PLL0_T *inputs;
  ExtY_PLL0_T *outputs;
  DW_PLL0_T *dwork;

  /*
   * DataMapInfo:
   * The following substructure contains information regarding
   * structures generated in the model's C API.
   */
  struct {
    rtwCAPI_ModelMappingInfo mmi;
  } DataMapInfo;
};

/* External data declarations for dependent source files */
extern const char_T *RT_MEMORY_ALLOCATION_ERROR;

/* Model entry point functions */
extern RT_MODEL_PLL0_T *PLL0(void);
extern void PLL0_initialize(RT_MODEL_PLL0_T *const PLL0_M);
extern void PLL0_output(RT_MODEL_PLL0_T *const PLL0_M);
extern void PLL0_update(RT_MODEL_PLL0_T *const PLL0_M);
extern void PLL0_terminate(RT_MODEL_PLL0_T * PLL0_M);

/* Function to get C API Model Mapping Static Info */
extern const rtwCAPI_ModelMappingStaticInfo*
  PLL0_GetCAPIStaticMap(void);

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Note that this particular code originates from a subsystem build,
 * and has its own system numbers different from the parent model.
 * Refer to the system hierarchy for this subsystem below, and use the
 * MATLAB hilite_system command to trace the generated code back
 * to the parent model.  For example,
 *
 * hilite_system('PLL/PLL')    - opens subsystem PLL/PLL
 * hilite_system('PLL/PLL/Kp') - opens and selects block Kp
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'PLL'
 * '<S1>'   : 'PLL/PLL'
 * '<S2>'   : 'PLL/PLL/Charge Pump'
 * '<S3>'   : 'PLL/PLL/Loop Filter'
 * '<S4>'   : 'PLL/PLL/MATLAB Function'
 * '<S5>'   : 'PLL/PLL/PFD'
 * '<S6>'   : 'PLL/PLL/VCO Clock'
 * '<S7>'   : 'PLL/PLL/vco'
 * '<S8>'   : 'PLL/PLL/PFD/D Flip-Flop'
 * '<S9>'   : 'PLL/PLL/PFD/D Flip-Flop1'
 * '<S10>'  : 'PLL/PLL/PFD/D Flip-Flop/D Flip-Flop'
 * '<S11>'  : 'PLL/PLL/PFD/D Flip-Flop1/D Flip-Flop'
 */
#endif                                 /* RTW_HEADER_PLL0_h_ */
