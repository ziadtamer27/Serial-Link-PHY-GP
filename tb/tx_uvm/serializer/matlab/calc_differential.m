function [tx_p, tx_n, v_diff, valid] = calc_differential(bit_val)
    % CALC_DIFFERENTIAL Converts digital bit to equalized differential signaling and plots live waveforms.

    persistent amplitude_history is_initialized

    if isempty(is_initialized)
        amplitude_history = [];
        presets(0, 'P4', true);
        is_initialized = true;
    end

    % Voltage parameters
    v_cm = 1.2;  % Common-mode voltage (1.2 V)
    v_od = 0.4;  % Differential output swing (0.4 V)

    % Call the FFE model in presets.m
    [y, valid] = presets(bit_val, 'P4', false);

    % First call: no valid FFE output (1 clk cycle delay)
    if ~valid
        tx_p = v_cm;
        tx_n = v_cm;
        v_diff = 0;
        return;
    end

    tx_p = v_cm + (v_od / 2) * y;
    tx_n = v_cm - (v_od / 2) * y;
    v_diff = tx_p - tx_n;

    % Store equalized amplitudes
    amplitude_history(end+1) = y;

    % Generate oversampled waveforms for plotting
    samples_per_bit = 50;
    time_per_bit = 0.125;  % 125 ps for PCIe Gen3

    total_samples = length(amplitude_history) * samples_per_bit;
    t = (0:total_samples-1) * (time_per_bit / samples_per_bit);

    raw_tx_p = [];
    raw_tx_n = [];

    for a = amplitude_history
        raw_tx_p = [raw_tx_p, repmat(v_cm + v_od*a/2, 1, samples_per_bit)];
        raw_tx_n = [raw_tx_n, repmat(v_cm - v_od*a/2, 1, samples_per_bit)];
    end

    plotting(t, raw_tx_p, raw_tx_n, v_cm);
end
