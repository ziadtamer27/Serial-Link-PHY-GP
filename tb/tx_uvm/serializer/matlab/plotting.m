function plotting(t, raw_tx_p, raw_tx_n, v_cm)
    % PLOTTING Smooths and plots live differential transmitter waveforms.

    % Apply realistic analog rise/fall smoothing (moving-average filter)
    filter_span = 11;
    smooth_tx_p = movmean(raw_tx_p, filter_span);
    smooth_tx_n = movmean(raw_tx_n, filter_span);
    smooth_v_diff = smooth_tx_p - smooth_tx_n;

    % Configure MATLAB figure window
    fig = figure(1);
    set(fig, 'Name', 'SerDes Differential Transmitter Waveforms', ...
             'NumberTitle', 'off', ...
             'Color', [0.95 0.95 0.97], ...
             'Position', [150 150 900 650]);

    % Subplot 1: TX+ and TX- (Single-ended differential pair)
    subplot(2, 1, 1);
    plot(t, smooth_tx_p, 'r-', 'LineWidth', 2.2);
    hold on;
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
