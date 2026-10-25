function [tx_p, tx_n, v_diff] = calc_differential(bit_val)
    % CALC_DIFFERENTIAL
    % Converts digital bit to differential signaling and plots live waveforms.
    
    persistent bit_history
    if isempty(bit_history)
        bit_history = [];
    end
    bit_history(end+1) = bit_val;%%fill data stream

    % Voltage parameters
    v_cm = 1.2;  % Common-mode voltage (1.2 V)
    v_od = 0.4;  % Differential output swing (0.4 V)

    if bit_val == 1
        tx_p = v_cm + (v_od / 2);  % 1.4 V
        tx_n = v_cm - (v_od / 2);  % 1.0 V
    else
        tx_p = v_cm - (v_od / 2);  % 1.0 V
        tx_n = v_cm + (v_od / 2);  % 1.4 V
    end
    v_diff = tx_p - tx_n;

    % Generate smooth waveforms for plotting
    samples_per_bit = 50;
    time_per_bit = 1.0; % 1 ns per bit
    
    total_samples = length(bit_history) * samples_per_bit;
    t = linspace(0, length(bit_history) * time_per_bit, total_samples);
    
    raw_tx_p = [];
    raw_tx_n = [];
    for b = bit_history
        if b == 1
            raw_tx_p = [raw_tx_p, repmat(v_cm + v_od/2, 1, samples_per_bit)];
            raw_tx_n = [raw_tx_n, repmat(v_cm - v_od/2, 1, samples_per_bit)];
        else
            raw_tx_p = [raw_tx_p, repmat(v_cm - v_od/2, 1, samples_per_bit)];
            raw_tx_n = [raw_tx_n, repmat(v_cm + v_od/2, 1, samples_per_bit)];
        end
    end

    % Apply realistic analog rise/fall smoothing (Gaussian/RC filter)
    filter_span = 11;
    smooth_tx_p = movmean(raw_tx_p, filter_span);
    smooth_tx_n = movmean(raw_tx_n, filter_span);
    smooth_v_diff = smooth_tx_p - smooth_tx_n;

    % Plotting in MATLAB window
    fig = figure(1);
    set(fig, 'Name', 'SerDes Differential Transmitter Waveforms', ...
             'NumberTitle', 'off', 'Color', [0.95 0.95 0.97], 'Position', [150 150 900 650]);

    % Subplot 1: TX+ and TX- (Single-ended differential pair)
    subplot(2, 1, 1);
    plot(t, smooth_tx_p, 'r-', 'LineWidth', 2.2); hold on;
    plot(t, smooth_tx_n, 'b-', 'LineWidth', 2.2);
    yline(v_cm, 'k--', 'V_{CM} = 1.2 V', 'LineWidth', 1.2, 'FontSize', 10);
    hold off;
    grid on;
    ylim([0.8 1.6]);
    title('Single-Ended Complementary Outputs (TX+ and TX-)', 'FontSize', 13, 'FontWeight', 'bold');
    xlabel('Time (ns)', 'FontSize', 11);
    ylabel('Voltage (V)', 'FontSize', 11);
    legend('TX+ (Non-inverting)', 'TX- (Inverting)', 'Location', 'northeast');

    % Subplot 2: Differential Voltage Vdiff = TX+ - TX-
    subplot(2, 1, 2);
    plot(t, smooth_v_diff, 'm-', 'LineWidth', 2.5);
    yline(0, 'k-', 'LineWidth', 1.0);
    grid on;
    ylim([-0.6 0.6]);
    title('Differential Output Voltage: V_{diff} = TX+ - TX-', 'FontSize', 13, 'FontWeight', 'bold');
    xlabel('Time (ns)', 'FontSize', 11);
    ylabel('Differential Voltage (V)', 'FontSize', 11);
    legend('V_{diff} (\pm 0.4 V)', 'Location', 'northeast');

    drawnow;
    shg;
end
