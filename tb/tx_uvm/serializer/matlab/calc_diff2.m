function [tx_p, tx_n, v_diff, valid] = calc_diff2(bit_val, preset)

    if nargin < 2
        preset = 'P7';
    end
    %%defaults the preset to P7 if the numebr of output is < 2

    persistent amplitude_history is_initialized

    if isempty(is_initialized)
        amplitude_history = [];
        presets(0, preset, true);
        is_initialized = true;
    end

    % Voltage parameters
    v_cm = 1.2;
    v_od = 0.4;

    % Call the FFE model in presets.m
    [y, valid] = presets(bit_val, preset, false);

    % First call: no valid FFE output
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

    % Generate smooth waveforms for plotting
    samples_per_bit = 50;
    time_per_bit = 1.0; % 1 ns per bit

    total_samples = length(amplitude_history) * samples_per_bit;

    t = (0:total_samples-1) * ...
        (time_per_bit / samples_per_bit);

    raw_tx_p = [];
    raw_tx_n = [];

    for a = amplitude_history

        raw_tx_p = [raw_tx_p, ...
            repmat(v_cm + v_od*a/2, 1, samples_per_bit)];

        raw_tx_n = [raw_tx_n, ...
            repmat(v_cm - v_od*a/2, 1, samples_per_bit)];

    end

    % Smooth waveforms for visualization
    filter_span = 11;

    smooth_tx_p = movmean(raw_tx_p, filter_span);
    smooth_tx_n = movmean(raw_tx_n, filter_span);
    smooth_v_diff = smooth_tx_p - smooth_tx_n;

    % Plotting
    fig = figure(1);

    if isempty(get(fig, 'UserData'))
        set(fig, 'Name', 'SerDes FFE Transmitter Waveforms', ...
                 'NumberTitle', 'off', ...
                 'Color', [0.95 0.95 0.97], ...
                 'Units', 'normalized', ...
                 'OuterPosition', [0.02 0.10 0.46 0.82], ...
                 'UserData', true);
    end

    % TX+ and TX-
    subplot(2, 1, 1);

    plot(t, smooth_tx_p, 'r-', 'LineWidth', 2.2);
    hold on;

    plot(t, smooth_tx_n, 'b-', 'LineWidth', 2.2);

    yline(v_cm, 'k--', 'V_{CM} = 1.2 V', ...
          'LineWidth', 1.2);

    hold off;
    grid on;
    ylim([0.8 1.6]);

    title('Equalized Differential Outputs (TX+ and TX-)');
    xlabel('Time (ns)');
    ylabel('Voltage (V)');

    legend('TX+', 'TX-', 'Location', 'northeast');

    % Differential voltage
    subplot(2, 1, 2);

    plot(t, smooth_v_diff, 'm-', 'LineWidth', 2.5);

    yline(0, 'k-', 'LineWidth', 1.0);

    grid on;
    ylim([-0.6 0.6]);

    title('Equalized Differential Voltage');
    xlabel('Time (ns)');
    ylabel('Differential Voltage (V)');

    legend('V_{diff}', 'Location', 'northeast');

    % Pass FFE output through the channel model and plot channel waveforms & eye diagram
    channel_effect(t, raw_tx_p, raw_tx_n, v_cm, samples_per_bit, time_per_bit);

    drawnow;
    shg;

end
