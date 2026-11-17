function [ch_tx_p, ch_tx_n, ch_v_diff] = channel_effect(t, raw_tx_p, raw_tx_n, before_v_diff, v_cm, samples_per_bit, time_per_bit)
% CHANNEL_EFFECT Applies the 4th-order low-pass channel filter to the FFE
% transmitter output and plots waveforms + eye diagrams (before & after channel).

    % Sampling frequency (Hz)
    Fs = samples_per_bit / (time_per_bit * 1e-9);

    % =====================================================================
    % Fourth-Order Low-Pass Channel Filter (from friend's model)
    % =====================================================================
    % H2(s) = w0^2 / (s^2 + (w0/Q)*s + w0^2)
    % Note: Scaled f0 to 6 GHz for PCIe Gen3 (0.125 ns UI / 8 GT/s)
    %       (friend's original 2 GHz was sized for a 1.0 ns UI / 1 Gbps).
    Q = 0.7;                % Quality factor
    f0 = 6e9;               % Natural frequency (Hz)
    % Normalize angular frequency by Fs to prevent (2*pi*f0)^4 ~ 1e42
    % ill-conditioning inside MATLAB's bilinear() state-space conversion
    wnode = (2*pi*f0) / Fs;

    % Second-order section coefficients
    num = [wnode^2];
    den = [1, wnode/Q, wnode^2];

    % Cascade two identical second-order sections -> fourth-order channel
    num4 = conv(num, num);
    den4 = conv(den, den);

    % Convert continuous-time filter H(s) into a digital filter H(z)
    [b, a] = bilinear(num4, den4, 1);

    % Apply channel filter around common-mode voltage v_cm
    ch_tx_p = v_cm + filter(b, a, raw_tx_p - v_cm);
    ch_tx_n = v_cm + filter(b, a, raw_tx_n - v_cm);
    ch_v_diff = ch_tx_p - ch_tx_n;

    % =====================================================================
    % Plotting: After-Channel Waveforms & Before/After Eye Diagrams
    % =====================================================================
    fig2 = figure(2);
    if isempty(get(fig2, 'UserData'))
        set(fig2, 'Name', 'Channel Effect & Eye Diagrams (Before vs. After Channel)', ...
                  'NumberTitle', 'off', ...
                  'Color', [0.95 0.95 0.97], ...
                  'Units', 'normalized', ...
                  'OuterPosition', [0.50 0.10 0.48 0.82], ...
                  'UserData', true);
    end

    % ---------------------------------------------------------------------
    % Subplot 1: After-Channel Single-Ended Outputs (TX+ and TX-)
    % ---------------------------------------------------------------------
    subplot(2, 2, 1);
    plot(t, ch_tx_p, 'r-', 'LineWidth', 2.0);
    hold on;
    plot(t, ch_tx_n, 'b-', 'LineWidth', 2.0);
    yline(v_cm, 'k--', 'V_{CM} = 1.2 V', 'LineWidth', 1.1);
    hold off;
    grid on;
    ylim([0.8 1.6]);
    title('After Channel: TX+ and TX-');
    xlabel('Time (ns)');
    ylabel('Voltage (V)');
    legend('TX+', 'TX-', 'Location', 'northeast');

    % ---------------------------------------------------------------------
    % Subplot 2: After-Channel Differential Voltage (Vdiff)
    % ---------------------------------------------------------------------
    subplot(2, 2, 2);
    plot(t, ch_v_diff, 'm-', 'LineWidth', 2.2);
    yline(0, 'k-', 'LineWidth', 1.0);
    grid on;
    ylim([-0.6 0.6]);
    title('After Channel: Differential Voltage (V_{diff})');
    xlabel('Time (ns)');
    ylabel('Differential Voltage (V)');
    legend('V_{diff}', 'Location', 'northeast');

    % ---------------------------------------------------------------------
    % Eye Diagram Parameters (2-UI window)
    % ---------------------------------------------------------------------
    samples_per_eye = 2 * samples_per_bit;
    num_traces = floor((length(ch_v_diff) - samples_per_eye) / samples_per_bit) + 1;
    eye_t = (0:samples_per_eye-1) * (time_per_bit / samples_per_bit);

    % ---------------------------------------------------------------------
    % Subplot 3: Eye Diagram BEFORE Channel (TX FFE Output)
    % ---------------------------------------------------------------------
    subplot(2, 2, 3);
    cla;
    hold on;
    for k = 1:num_traces
        start_idx = (k-1)*samples_per_bit + 1;
        end_idx   = start_idx + samples_per_eye - 1;
        eye_seg_before = before_v_diff(start_idx:end_idx);
        plot(eye_t, eye_seg_before, 'Color', [0.85 0.2 0.5], 'LineWidth', 0.9);
    end
    xlim([0 2*time_per_bit]);
    ylim([-0.6 0.6]);
    yline(0, 'k--');
    grid on;
    title('Eye Diagram BEFORE Channel (FFE Output)');
    xlabel('Time (ns)');
    ylabel('Differential Voltage (V)');
    hold off;

    % ---------------------------------------------------------------------
    % Subplot 4: Eye Diagram AFTER Channel (Friend's Eye Diagram)
    % ---------------------------------------------------------------------
    subplot(2, 2, 4);
    cla;
    hold on;
    for k = 1:num_traces
        start_idx = (k-1)*samples_per_bit + 1;
        end_idx   = start_idx + samples_per_eye - 1;
        eye_seg_after = ch_v_diff(start_idx:end_idx);
        plot(eye_t, eye_seg_after, 'b-', 'LineWidth', 0.9);
    end
    xlim([0 2*time_per_bit]);
    ylim([-0.6 0.6]);
    yline(0, 'k--');
    grid on;
    title('Eye Diagram AFTER Channel');
    xlabel('Time (ns)');
    ylabel('Differential Voltage (V)');
    hold off;

    drawnow;
    shg;
end
