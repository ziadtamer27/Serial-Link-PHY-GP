
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

static FILE *rx_file = NULL;

/* Write a real voltage into SystemVerilog */
static void write_real(vpiHandle handle, double voltage)
{
    s_vpi_value value = {0};

    value.format = vpiRealVal;
    value.value.real = voltage;

    vpi_put_value(handle, &value, NULL, vpiNoDelay);
}

/* Write an integer status into SystemVerilog */
static void write_int(vpiHandle handle, int number)
{
    s_vpi_value value = {0};

    value.format = vpiIntVal;
    value.value.integer = number;

    vpi_put_value(handle, &value, NULL, vpiNoDelay);
}

/* $rx_load("rx_in_real.txt") */
static PLI_INT32 rx_load(PLI_BYTE8 *user_data)
{
    vpiHandle call, iterator, argument;
    s_vpi_value value = {0};

    (void)user_data;

    call = vpi_handle(vpiSysTfCall, NULL);
    iterator = vpi_iterate(vpiArgument, call);

    if (!iterator) {
        vpi_printf("ERROR: Missing filename\n");
        return 0;
    }

    argument = vpi_scan(iterator);

    value.format = vpiStringVal;
    vpi_get_value(argument, &value);

    if (rx_file) {
        fclose(rx_file);
        rx_file = NULL;
    }

    rx_file = fopen(value.value.str, "r");

    if (!rx_file) {
        vpi_printf("ERROR: Cannot open %s\n", value.value.str);
        vpi_control(vpiFinish, 1);
    } else {
        vpi_printf("RX waveform loaded: %s\n", value.value.str);
    }

    return 0;
}

/* $rx_next(Dp, Dn, valid) */
static PLI_INT32 rx_next(PLI_BYTE8 *user_data)
{
    vpiHandle call, iterator;
    vpiHandle dp_handle, dn_handle, valid_handle;
    double dp, dn;
    int result;

    (void)user_data;

    call = vpi_handle(vpiSysTfCall, NULL);
    iterator = vpi_iterate(vpiArgument, call);

    dp_handle = vpi_scan(iterator);
    dn_handle = vpi_scan(iterator);
    valid_handle = vpi_scan(iterator);

    if (!rx_file) {
        vpi_printf("ERROR: No RX waveform loaded\n");
        vpi_control(vpiFinish, 1);
        return 0;
    }

    result = fscanf(rx_file, "%lf %lf", &dp, &dn);

    if (result == 2) {
        write_real(dp_handle, dp);
        write_real(dn_handle, dn);
        write_int(valid_handle, 1);
    } else {
        write_int(valid_handle, 0);
    }

    return 0;
}

/* Register custom SystemVerilog tasks */
static void register_rx_pli(void)
{
    s_vpi_systf_data task = {0};

    task.type = vpiSysTask;
    task.tfname = "$rx_load";
    task.calltf = rx_load;
    task.compiletf = NULL;
    task.sizetf = NULL;
    task.user_data = NULL;

    vpi_register_systf(&task);

    task.tfname = "$rx_next";
    task.calltf = rx_next;

    vpi_register_systf(&task);
}

/* Simulator startup entry point */
void (*vlog_startup_routines[])(void) = {
    register_rx_pli,
    NULL
};
