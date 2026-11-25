function [tx_p, tx_n, v_diff, valid] = calc_diff2(bit_val, preset)
% CALC_DIFF2 Converts serialized bit stream into equalized & un-equalized
% differential signals, passes both through the channel model, and plots
% pre-channel waveforms and post-channel eye diagrams (With vs. Without FFE).

    if nargin < 2
        preset = 'P7';
    end

    persistent raw_tx_p_ffe raw_tx_n_ffe raw_tx_p_no_ffe raw_tx_n_no_ffe

    % Voltage parameters
    v_cm = 1.2;
    v_od = 0.4;

    % Call the 3-tap FFE model in FFE.m (get_bit_multiplier)
    [bit_multiplier, valid, bit_multiplier_no_ffe] = FFE(bit_val, preset);

    % First call: 1-UI pipeline lookahead delay (no valid output yet)
    if ~valid
        tx_p = v_cm;
        tx_n = v_cm;
        v_diff = 0;
        return;
    end

    % Equalized transmitter outputs (With FFE)
    tx_p = v_cm + (v_od / 2) * bit_multiplier;
    tx_n = v_cm - (v_od / 2) * bit_multiplier;
    v_diff = tx_p - tx_n;

    % Un-equalized transmitter outputs (Without FFE, for baseline comparison)
    tx_p_no_ffe = v_cm + (v_od / 2) * bit_multiplier_no_ffe;
    tx_n_no_ffe = v_cm - (v_od / 2) * bit_multiplier_no_ffe;

    % Oversampling parameters
    samples_per_bit = 50;
    time_per_bit = 1.0; % 1 ns per bit

    % Append current UI samples to persistent waveform histories
    raw_tx_p_ffe    = [raw_tx_p_ffe,    repmat(tx_p,        1, samples_per_bit)];
    raw_tx_n_ffe    = [raw_tx_n_ffe,    repmat(tx_n,        1, samples_per_bit)];
    raw_tx_p_no_ffe = [raw_tx_p_no_ffe, repmat(tx_p_no_ffe, 1, samples_per_bit)];
    raw_tx_n_no_ffe = [raw_tx_n_no_ffe, repmat(tx_n_no_ffe, 1, samples_per_bit)];

    total_samples = length(raw_tx_p_ffe);
    t = (0:total_samples-1) * (time_per_bit / samples_per_bit);

    % Pass both With-FFE and Without-FFE waveforms through the channel model
    [ch_tx_p_ffe,    ch_tx_n_ffe,    ch_v_diff_ffe]    = channel_effect(raw_tx_p_ffe,    raw_tx_n_ffe,    samples_per_bit, time_per_bit);
    [ch_tx_p_no_ffe, ch_tx_n_no_ffe, ch_v_diff_no_ffe] = channel_effect(raw_tx_p_no_ffe, raw_tx_n_no_ffe, samples_per_bit, time_per_bit);

    % Render Figure 1 (TX waveforms) and Figure 2 (Channel & Dual Eye Diagrams)
    plotting(t, raw_tx_p_ffe, raw_tx_n_ffe, v_cm, ...
             ch_tx_p_ffe, ch_tx_n_ffe, ch_v_diff_ffe, ...
             ch_tx_p_no_ffe, ch_tx_n_no_ffe, ch_v_diff_no_ffe, ...
             samples_per_bit, time_per_bit);

end
