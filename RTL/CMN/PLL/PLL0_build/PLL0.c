/*
 * PLL0.c
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

#include "PLL0.h"
#include "rtwtypes.h"
#include "PLL0_private.h"
#include <math.h>
#include "rt_nonfinite.h"
#include <string.h>
#include "PLL0_capi.h"
#include "zero_crossing_types.h"

/*
 * System initialize for enable_with_trigger system:
 *    '<S8>/D Flip-Flop'
 *    '<S9>/D Flip-Flop'
 */
void PLL0_DFlipFlop_Init(B_DFlipFlop_PLL0_T *localB)
{
  /* SystemInitialize for SignalConversion generated from: '<S10>/D' incorporates:
   *  Outport: '<S10>/Q'
   */
  localB->D = false;

  /* SystemInitialize for Logic: '<S10>/Logic' incorporates:
   *  Outport: '<S10>/!Q'
   */
  localB->Logic = true;
}

/*
 * Disable for enable_with_trigger system:
 *    '<S8>/D Flip-Flop'
 *    '<S9>/D Flip-Flop'
 */
void PLL0_DFlipFlop_Disable(B_DFlipFlop_PLL0_T *localB, DW_DFlipFlop_PLL0_T
  *localDW)
{
  /* Disable for SignalConversion generated from: '<S10>/D' incorporates:
   *  Outport: '<S10>/Q'
   */
  localB->D = false;

  /* Disable for Logic: '<S10>/Logic' incorporates:
   *  Outport: '<S10>/!Q'
   */
  localB->Logic = true;
  localDW->DFlipFlop_MODE = false;
}

/*
 * Output and update for enable_with_trigger system:
 *    '<S8>/D Flip-Flop'
 *    '<S9>/D Flip-Flop'
 */
void PLL0_DFlipFlop(boolean_T rtu_C, boolean_T rtu_Trigger, boolean_T rtu_D,
                    B_DFlipFlop_PLL0_T *localB, DW_DFlipFlop_PLL0_T *localDW,
                    ZCE_DFlipFlop_PLL0_T *localZCE)
{
  boolean_T zcEvent;

  /* Outputs for Enabled and Triggered SubSystem: '<S8>/D Flip-Flop' incorporates:
   *  EnablePort: '<S10>/C'
   *  TriggerPort: '<S10>/Trigger'
   */
  zcEvent = (rtu_Trigger && (localZCE->DFlipFlop_Trig_ZCE != POS_ZCSIG));
  if (rtu_C) {
    localDW->DFlipFlop_MODE = true;
    if (zcEvent) {
      /* SignalConversion generated from: '<S10>/D' */
      localB->D = rtu_D;

      /* Logic: '<S10>/Logic' */
      localB->Logic = !localB->D;
    }

    localZCE->DFlipFlop_Trig_ZCE = rtu_Trigger;
  } else {
    if (localDW->DFlipFlop_MODE) {
      PLL0_DFlipFlop_Disable(localB, localDW);
    }

    localZCE->DFlipFlop_Trig_ZCE = rtu_Trigger;
  }

  /* End of Outputs for SubSystem: '<S8>/D Flip-Flop' */
}

/*
 * Termination for enable_with_trigger system:
 *    '<S8>/D Flip-Flop'
 *    '<S9>/D Flip-Flop'
 */
void PLL0_DFlipFlop_Term(void)
{
}

/* Model output function */
void PLL0_output(RT_MODEL_PLL0_T *const PLL0_M)
{
  B_PLL0_T *PLL0_B = PLL0_M->blockIO;
  DW_PLL0_T *PLL0_DW = PLL0_M->dwork;
  PrevZCX_PLL0_T *PLL0_PrevZCX = PLL0_M->prevZCSigState;
  ExtU_PLL0_T *PLL0_U = (ExtU_PLL0_T *) PLL0_M->inputs;
  ExtY_PLL0_T *PLL0_Y = (ExtY_PLL0_T *) PLL0_M->outputs;
  real_T baseCycles;
  real_T extraCycle;
  boolean_T rise;

  /* UnitDelay: '<S1>/Phase State' */
  PLL0_B->PhaseState = PLL0_DW->PhaseState_DSTATE;

  /* DiscreteIntegrator: '<S3>/Discrete-Time Integrator' */
  PLL0_B->DiscreteTimeIntegrator = PLL0_DW->DiscreteTimeIntegrator_DSTATE;

  /* Memory generated from: '<S8>/D Flip-Flop' */
  PLL0_B->TmpLatchAtDFlipFlopInport1 =
    PLL0_DW->TmpLatchAtDFlipFlopInport1_PreviousInput;

  /* UnitDelay: '<S5>/Unit Delay' */
  PLL0_B->UnitDelay = PLL0_DW->UnitDelay_DSTATE;

  /* Outputs for Enabled and Triggered SubSystem: '<S8>/D Flip-Flop' */
  PLL0_DFlipFlop(PLL0_B->UnitDelay, PLL0_U->Fref,
                 PLL0_B->TmpLatchAtDFlipFlopInport1, &PLL0_B->DFlipFlop,
                 &PLL0_DW->DFlipFlop, &PLL0_PrevZCX->DFlipFlop);

  /* End of Outputs for SubSystem: '<S8>/D Flip-Flop' */

  /* Memory generated from: '<S9>/D Flip-Flop' */
  PLL0_B->TmpLatchAtDFlipFlopInport1_g =
    PLL0_DW->TmpLatchAtDFlipFlopInport1_PreviousInput_o;

  /* Outport: '<Root>/F_N' incorporates:
   *  Constant: '<S6>/Constant'
   *  RelationalOperator: '<S6>/Compare'
   */
  PLL0_Y->F_N = (PLL0_B->PhaseState >= 0.5);

  /* DataTypeConversion: '<S1>/Data Type Conversion1' */
  PLL0_B->DataTypeConversion1 = PLL0_U->rst_N;

  /* MATLAB Function: '<S1>/MATLAB Function' */
  rise = (PLL0_Y->F_N && (!PLL0_DW->prevClk));
  PLL0_DW->prevClk = PLL0_Y->F_N;
  if (!PLL0_B->DataTypeConversion1) {
    PLL0_DW->count = 0.0;
    PLL0_DW->periodCycles = 0.0;
    PLL0_DW->fracAccum = 0.0;
    PLL0_DW->clkOut = false;
  } else if (rise) {
    if (PLL0_DW->count == 0.0) {
      baseCycles = floor(PLL0_U->N);
      PLL0_DW->fracAccum += PLL0_U->N - baseCycles;
      extraCycle = floor(PLL0_DW->fracAccum);
      PLL0_DW->periodCycles = baseCycles + extraCycle;
      PLL0_DW->fracAccum -= extraCycle;
    }

    PLL0_DW->clkOut = (PLL0_DW->count < floor(PLL0_DW->periodCycles / 2.0));
    PLL0_DW->count++;
    if (PLL0_DW->count == PLL0_DW->periodCycles) {
      PLL0_DW->count = 0.0;
    }
  }

  PLL0_B->vco_clk_N = PLL0_DW->clkOut;

  /* End of MATLAB Function: '<S1>/MATLAB Function' */

  /* Outputs for Enabled and Triggered SubSystem: '<S9>/D Flip-Flop' */
  PLL0_DFlipFlop(PLL0_B->UnitDelay, PLL0_B->vco_clk_N,
                 PLL0_B->TmpLatchAtDFlipFlopInport1_g, &PLL0_B->DFlipFlop_j,
                 &PLL0_DW->DFlipFlop_j, &PLL0_PrevZCX->DFlipFlop_j);

  /* End of Outputs for SubSystem: '<S9>/D Flip-Flop' */

  /* MATLAB Function: '<S1>/Charge Pump' */
  PLL0_B->i_pump = ((real_T)PLL0_B->DFlipFlop.D - (real_T)PLL0_B->DFlipFlop_j.D)
    * 0.0001;

  /* Gain: '<S3>/Gain' */
  PLL0_B->Gain = 1000.0 * PLL0_B->i_pump;

  /* Sum: '<S3>/Sum' */
  PLL0_B->Sum = PLL0_B->Gain + PLL0_B->DiscreteTimeIntegrator;

  /* MATLAB Function: '<S1>/vco' incorporates:
   *  Constant: '<S1>/Filter Step'
   */
  baseCycles = (PLL0_B->Sum - 0.5) * 5.0E+7 + 9.5E+7;
  extraCycle = baseCycles * 2.5E-11 + PLL0_B->PhaseState;
  if (rtIsNaN(extraCycle) || rtIsInf(extraCycle)) {
    PLL0_B->phase_next = (rtNaN);
  } else if (extraCycle == 0.0) {
    PLL0_B->phase_next = 0.0;
  } else {
    PLL0_B->phase_next = fmod(extraCycle, 1.0);
    if (PLL0_B->phase_next == 0.0) {
      PLL0_B->phase_next = 0.0;
    } else if (extraCycle < 0.0) {
      PLL0_B->phase_next++;
    }
  }

  PLL0_B->fvco = baseCycles;

  /* End of MATLAB Function: '<S1>/vco' */

  /* Logic: '<S5>/NAND' */
  PLL0_B->NAND = ((!PLL0_B->DFlipFlop.D) || (!PLL0_B->DFlipFlop_j.D));
}

/* Model update function */
void PLL0_update(RT_MODEL_PLL0_T *const PLL0_M)
{
  B_PLL0_T *PLL0_B = PLL0_M->blockIO;
  DW_PLL0_T *PLL0_DW = PLL0_M->dwork;

  /* Update for UnitDelay: '<S1>/Phase State' */
  PLL0_DW->PhaseState_DSTATE = PLL0_B->phase_next;

  /* Update for DiscreteIntegrator: '<S3>/Discrete-Time Integrator' */
  PLL0_DW->DiscreteTimeIntegrator_DSTATE += 2.5 * PLL0_B->i_pump;

  /* Update for Memory generated from: '<S8>/D Flip-Flop' incorporates:
   *  Constant: '<S5>/Constant'
   */
  PLL0_DW->TmpLatchAtDFlipFlopInport1_PreviousInput = true;

  /* Update for UnitDelay: '<S5>/Unit Delay' */
  PLL0_DW->UnitDelay_DSTATE = PLL0_B->NAND;

  /* Update for Memory generated from: '<S9>/D Flip-Flop' incorporates:
   *  Constant: '<S5>/Constant'
   */
  PLL0_DW->TmpLatchAtDFlipFlopInport1_PreviousInput_o = true;
}

/* Model initialize function */
void PLL0_initialize(RT_MODEL_PLL0_T *const PLL0_M)
{
  B_PLL0_T *PLL0_B = PLL0_M->blockIO;
  DW_PLL0_T *PLL0_DW = PLL0_M->dwork;

  /* InitializeConditions for UnitDelay: '<S1>/Phase State' */
  PLL0_DW->PhaseState_DSTATE = 0.0;

  /* InitializeConditions for DiscreteIntegrator: '<S3>/Discrete-Time Integrator' */
  PLL0_DW->DiscreteTimeIntegrator_DSTATE = 0.5;

  /* InitializeConditions for Memory generated from: '<S8>/D Flip-Flop' */
  PLL0_DW->TmpLatchAtDFlipFlopInport1_PreviousInput = false;

  /* InitializeConditions for UnitDelay: '<S5>/Unit Delay' */
  PLL0_DW->UnitDelay_DSTATE = false;

  /* InitializeConditions for Memory generated from: '<S9>/D Flip-Flop' */
  PLL0_DW->TmpLatchAtDFlipFlopInport1_PreviousInput_o = false;

  /* SystemInitialize for Enabled and Triggered SubSystem: '<S8>/D Flip-Flop' */
  PLL0_DFlipFlop_Init(&PLL0_B->DFlipFlop);

  /* End of SystemInitialize for SubSystem: '<S8>/D Flip-Flop' */

  /* SystemInitialize for MATLAB Function: '<S1>/MATLAB Function' */
  PLL0_DW->prevClk = false;
  PLL0_DW->count = 0.0;
  PLL0_DW->periodCycles = 0.0;
  PLL0_DW->fracAccum = 0.0;
  PLL0_DW->clkOut = false;

  /* SystemInitialize for Enabled and Triggered SubSystem: '<S9>/D Flip-Flop' */
  PLL0_DFlipFlop_Init(&PLL0_B->DFlipFlop_j);

  /* End of SystemInitialize for SubSystem: '<S9>/D Flip-Flop' */
}

/* Model terminate function */
void PLL0_terminate(RT_MODEL_PLL0_T * PLL0_M)
{
  /* model code */
  rt_FREE(PLL0_M->blockIO);
  rt_FREE(PLL0_M->inputs);
  rt_FREE(PLL0_M->outputs);
  rt_FREE(PLL0_M->dwork);
  rt_FREE(PLL0_M->prevZCSigState);
  rt_FREE(PLL0_M);
}

/* Model data allocation function */
RT_MODEL_PLL0_T *PLL0(void)
{
  RT_MODEL_PLL0_T *PLL0_M;
  PLL0_M = (RT_MODEL_PLL0_T *) malloc(sizeof(RT_MODEL_PLL0_T));
  if (PLL0_M == (NULL)) {
    return (NULL);
  }

  (void) memset((char *)PLL0_M, 0,
                sizeof(RT_MODEL_PLL0_T));

  /* block I/O */
  {
    B_PLL0_T *b = (B_PLL0_T *) malloc(sizeof(B_PLL0_T));
    rt_VALIDATE_MEMORY(PLL0_M,b);
    PLL0_M->blockIO = (b);
  }

  /* states (dwork) */
  {
    DW_PLL0_T *dwork = (DW_PLL0_T *) malloc(sizeof(DW_PLL0_T));
    rt_VALIDATE_MEMORY(PLL0_M,dwork);
    PLL0_M->dwork = (dwork);
  }

  /* external inputs */
  {
    ExtU_PLL0_T *PLL0_U = (ExtU_PLL0_T *) malloc(sizeof(ExtU_PLL0_T));
    rt_VALIDATE_MEMORY(PLL0_M,PLL0_U);
    PLL0_M->inputs = (((ExtU_PLL0_T *) PLL0_U));
  }

  /* external outputs */
  {
    ExtY_PLL0_T *PLL0_Y = (ExtY_PLL0_T *) malloc(sizeof(ExtY_PLL0_T));
    rt_VALIDATE_MEMORY(PLL0_M,PLL0_Y);
    PLL0_M->outputs = (PLL0_Y);
  }

  /* previous zero-crossing states */
  {
    PrevZCX_PLL0_T *zc = (PrevZCX_PLL0_T *) malloc(sizeof(PrevZCX_PLL0_T));
    rt_VALIDATE_MEMORY(PLL0_M,zc);
    PLL0_M->prevZCSigState = (zc);
  }

  /* Initialize DataMapInfo substructure containing ModelMap for C API */
  PLL0_InitializeDataMapInfo(PLL0_M);

  {
    B_PLL0_T *PLL0_B = PLL0_M->blockIO;
    DW_PLL0_T *PLL0_DW = PLL0_M->dwork;
    PrevZCX_PLL0_T *PLL0_PrevZCX = PLL0_M->prevZCSigState;
    ExtU_PLL0_T *PLL0_U = (ExtU_PLL0_T *) PLL0_M->inputs;
    ExtY_PLL0_T *PLL0_Y = (ExtY_PLL0_T *) PLL0_M->outputs;

    /* initialize non-finites */
    rt_InitInfAndNaN(sizeof(real_T));

    /* block I/O */
    (void) memset(((void *) PLL0_B), 0,
                  sizeof(B_PLL0_T));

    /* states (dwork) */
    (void) memset((void *)PLL0_DW, 0,
                  sizeof(DW_PLL0_T));

    /* external inputs */
    (void)memset(PLL0_U, 0, sizeof(ExtU_PLL0_T));

    /* external outputs */
    PLL0_Y->F_N = false;

    /* previous zero-crossing states */
    {
      PLL0_PrevZCX->DFlipFlop_j.DFlipFlop_Trig_ZCE = POS_ZCSIG;
      PLL0_PrevZCX->DFlipFlop.DFlipFlop_Trig_ZCE = POS_ZCSIG;
    }
  }

  return PLL0_M;
}
