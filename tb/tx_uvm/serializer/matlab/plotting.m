function plotting(t, raw_tx_p_ffe, raw_tx_n_ffe, v_cm, ...
                  ch_tx_p_ffe, ch_tx_n_ffe, ch_v_diff_ffe, ...
                  ch_tx_p_no_ffe, ch_tx_n_no_ffe, ch_v_diff_no_ffe, ...
                  samples_per_bit, time_per_bit)

                  
% PLOTTING Centralized visualization module for SerDes TX and Channel Eye Diagrams.
%
%   Layout A (2 Figures):
%     - Figure 1: Transmitter Pre-Channel Waveforms (Equalized TX+/TX- & V_diff)
%     - Figure 2: Post-Channel Waveforms & Side-by-Side Eye Diagrams (Without FFE vs. With FFE)
%
%   Also supports legacy 4-argument call from calc_differential.m:
%     plotting(t, raw_tx_p, raw_tx_n, v_cm)

    % 1. Always plot Figure 1: Pre-Channel Transmitter Waveforms
    plot_tx_waveforms(t, raw_tx_p_ffe, raw_tx_n_ffe, v_cm);

    % 2. If channel waveforms are provided, plot Figure 2: Channel & Dual Eye Diagrams
    if nargin >= 12
        plot_channel_and_eyes(t, v_cm, ...
                              ch_tx_p_ffe, ch_tx_n_ffe, ch_v_diff_ffe, ...
                              ch_tx_p_no_ffe, ch_tx_n_no_ffe, ch_v_diff_no_ffe, ...
                              samples_per_bit, time_per_bit);
    end

    drawnow;
    shg;
end

%% ========================================================================
%  Sub-function 1: Figure 1 - Pre-Channel Transmitter Waveforms
%  ========================================================================
function plot_tx_waveforms(t, raw_tx_p, raw_tx_n, v_cm)
    % Smooth digital transitions slightly for visual rise/fall time at TX pins
    filter_span = 11;
    smooth_tx_p = movmean(raw_tx_p, filter_span);
    smooth_tx_n = movmean(raw_tx_n, filter_span);
    smooth_v_diff = smooth_tx_p - smooth_tx_n;

    fig1 = figure(1);
    if isempty(get(fig1, 'UserData'))
        set(fig1, 'Name', 'Figure 1: SerDes FFE Transmitter Waveforms (Pre-Channel)', ...
                  'NumberTitle', 'off', ...
                  'Color', [0.95 0.95 0.97], ...
                  'Units', 'normalized', ...
                  'OuterPosition', [0.01 0.08 0.44 0.84], ...
                  'UserData', true);
    end

    % Subplot 1: Single-Ended Outputs (TX+ and TX-)
    subplot(2, 1, 1);
    plot(t, smooth_tx_p, 'r-', 'LineWidth', 2.0);
    hold on;
    plot(t, smooth_tx_n, 'b-', 'LineWidth', 2.0);
    yline(v_cm, 'k--', 'V_{CM} = 1.2 V', 'LineWidth', 1.2);
    hold off;
    grid on;
    ylim([0.8 1.6]);
    title('Equalized Transmitter Outputs (TX+ and TX-)', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Time (ns)');
    ylabel('Voltage (V)');
    legend('TX+', 'TX-', 'Location', 'northeast');

    % Subplot 2: Equalized Differential Voltage (V_diff)
    subplot(2, 1, 2);
    plot(t, smooth_v_diff, 'm-', 'LineWidth', 2.2);
    yline(0, 'k-', 'LineWidth', 1.0);
    grid on;
    ylim([-0.6 0.6]);
    title('Equalized Differential Voltage (V_{diff} = TX+ - TX-)', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Time (ns)');
    ylabel('Differential Voltage (V)');
    legend('V_{diff} (With FFE)', 'Location', 'northeast');
end

%% ========================================================================
%  Sub-function 2: Figure 2 - Post-Channel Waveforms & Side-by-Side Eyes
%  ========================================================================
function plot_channel_and_eyes(t, v_cm, ...
                               ch_tx_p_ffe, ch_tx_n_ffe, ch_v_diff_ffe, ...
                               ch_tx_p_no_ffe, ch_tx_n_no_ffe, ch_v_diff_no_ffe, ...
                               samples_per_bit, time_per_bit)
    fig2 = figure(2);
    if isempty(get(fig2, 'UserData'))
        set(fig2, 'Name', 'Figure 2: Channel Effect & Eye Diagrams (Without FFE vs. With FFE)', ...
                  'NumberTitle', 'off', ...
                  'Color', [0.95 0.95 0.97], ...
                  'Units', 'normalized', ...
                  'OuterPosition', [0.46 0.08 0.53 0.84], ...
                  'UserData', true);
    end

    % Top-Left (Subplot 2,2,1): Post-Channel Single-Ended TX+ and TX- (WITHOUT FFE)
    subplot(2, 2, 1);
    plot(t, ch_tx_p_no_ffe, 'r-', 'LineWidth', 1.8);
    hold on;
    plot(t, ch_tx_n_no_ffe, 'b-', 'LineWidth', 1.8);
    yline(v_cm, 'k--', 'V_{CM} = 1.2 V', 'LineWidth', 1.0);
    hold off;
    grid on;
    ylim([0.8 1.6]);
    title('Post-Channel TX+ and TX- (Without FFE)', 'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Time (ns)');
    ylabel('Voltage (V)');
    legend('TX+', 'TX-', 'Location', 'northeast');

    % Top-Right (Subplot 2,2,2): Post-Channel Single-Ended TX+ and TX- (WITH FFE)
    subplot(2, 2, 2);
    plot(t, ch_tx_p_ffe, 'r-', 'LineWidth', 1.8);
    hold on;
    plot(t, ch_tx_n_ffe, 'b-', 'LineWidth', 1.8);
    yline(v_cm, 'k--', 'V_{CM} = 1.2 V', 'LineWidth', 1.0);
    hold off;
    grid on;
    ylim([0.8 1.6]);
    title('Post-Channel TX+ and TX- (With FFE)', 'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Time (ns)');
    ylabel('Voltage (V)');
    legend('TX+', 'TX-', 'Location', 'northeast');

    % Bottom-Left (Subplot 2,2,3): Eye Diagram WITHOUT FFE
    subplot(2, 2, 3);
    draw_eye_diagram(ch_v_diff_no_ffe, samples_per_bit, time_per_bit, ...
                     'Channel Eye Diagram (WITHOUT FFE)', [0.85 0.33 0.10]);

    % Bottom-Right (Subplot 2,2,4): Eye Diagram WITH FFE
    subplot(2, 2, 4);
    draw_eye_diagram(ch_v_diff_ffe, samples_per_bit, time_per_bit, ...
                     'Channel Eye Diagram (WITH FFE)', [0.00 0.45 0.74]);
end

%% ========================================================================
%  Sub-function 3: Reusable 2-UI Eye Diagram Renderer
%  ========================================================================
function draw_eye_diagram(v_diff_signal, samples_per_bit, time_per_bit, plot_title, trace_color)
    samples_per_eye = 2 * samples_per_bit; % 2 Unit Intervals (2 UI) per eye trace
    num_traces = floor((length(v_diff_signal) - samples_per_eye) / samples_per_bit) + 1;
    eye_t = (0:samples_per_eye-1) * (time_per_bit / samples_per_bit);

    cla;
    hold on;
    for k = 1:num_traces
        start_idx = (k - 1) * samples_per_bit + 1;
        end_idx   = start_idx + samples_per_eye - 1;
        eye_segment = v_diff_signal(start_idx:end_idx);
        plot(eye_t, eye_segment, 'Color', trace_color, 'LineWidth', 1.1);
    end
    yline(0, 'k--', 'LineWidth', 1.0);
    hold off;
    grid on;
    xlim([0, 2 * time_per_bit]);
    ylim([-0.6, 0.6]);
    title(plot_title, 'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Time (ns) [2 UI Window]');
    ylabel('Differential Voltage (V)');
end
