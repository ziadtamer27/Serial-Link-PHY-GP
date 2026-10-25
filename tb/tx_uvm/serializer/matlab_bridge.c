#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "engine.h"
#include "matrix.h"
#include "svdpi.h"

static Engine *ep = NULL;

void get_differential_out(unsigned char bit_val, double *tx_p, double *tx_n, double *v_diff) {
    if (ep == NULL) {
        printf("[C-DPI] Initializing MATLAB Engine...\n");
        fflush(stdout);
        ep = engOpen(NULL);
        if (!ep) {
            fprintf(stderr, "[C-DPI] Error: Failed to start MATLAB Engine!\n");
            fflush(stderr);
            *tx_p = 0.0;
            *tx_n = 0.0;
            *v_diff = 0.0;
            return;
        }

        // Make MATLAB desktop and plot windows visible on screen
        engSetVisible(ep, 1);

        // Clear previous history and set working directory to the coding files folder
        engEvalString(ep, "cd 'A:/college/senior 2 term 1/GP/coding files'; clear calc_differential;");
        printf("[C-DPI] MATLAB Engine connected and set to VISIBLE.\n");
        fflush(stdout);
    }

    printf("[C-DPI] Passing bit value '%d' from SystemVerilog to MATLAB...\n", bit_val);
    fflush(stdout);

    // Put variable into MATLAB workspace
    mxArray *m_in = mxCreateDoubleScalar((double)bit_val);
    engPutVariable(ep, "bit_in", m_in);
    mxDestroyArray(m_in);

    // Call calc_differential.m
    engEvalString(ep, "[tx_p, tx_n, v_diff] = calc_differential(bit_in);");

    // Fetch outputs from MATLAB
    mxArray *m_p = engGetVariable(ep, "tx_p");
    mxArray *m_n = engGetVariable(ep, "tx_n");
    mxArray *m_d = engGetVariable(ep, "v_diff");

    if (m_p && m_n && m_d) {
        *tx_p = mxGetScalar(m_p);
        *tx_n = mxGetScalar(m_n);
        *v_diff = mxGetScalar(m_d);
        mxDestroyArray(m_p);
        mxDestroyArray(m_n);
        mxDestroyArray(m_d);
    } else {
        fprintf(stderr, "[C-DPI] Error: Failed to retrieve variables from MATLAB!\n");
        fflush(stderr);
        *tx_p = 0.0;
        *tx_n = 0.0;
        *v_diff = 0.0;
        return;
    }

    printf("[C-DPI] Received from MATLAB: TX+ = %0.3f V, TX- = %0.3f V, Vdiff = %0.3f V\n",
           *tx_p, *tx_n, *v_diff);
    fflush(stdout);
}

// Keep MATLAB open on screen when simulation ends
void close_matlab() {
    if (ep != NULL) {
        printf("[C-DPI] Simulation completed! Keeping MATLAB open so you can view and interact with the plots.\n");
        fflush(stdout);
        engEvalString(ep, "shg; figure(1);");
        // We intentionally do NOT call engClose(ep) so MATLAB stays open for the user!
    }
}
