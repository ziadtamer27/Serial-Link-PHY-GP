% List of videos by Adam Panagos
% https://youtu.be/dmzikG1jZpU  | Butterworth Filter - 01 - Introduction
% https://youtu.be/-EHRFrDujhc  | Butterworth Filter - 02 - Normalized Filter
% https://youtu.be/XS4xibSOdmM  | Analyzing and Visualizing Data with MATLAB
% https://www.mathworks.com/help/matlab/ref/cla.html

function [smooth_tx_p, smooth_tx_n, smooth_v_diff] = channel_effect(t, raw_tx_p, raw_tx_n, v_cm, samples_per_bit, time_per_bit)

    % Apply realistic analog rise/fall smoothing (Gaussian/RC filter)
    % filter_span = 11;
    % smooth_tx_p = movmean(raw_tx_p, filter_span);
    % smooth_tx_n = movmean(raw_tx_n, filter_span);
    % smooth_v_diff = smooth_tx_p - smooth_tx_n;




    % Apply first-order RC Low-Pass Filter
    % ==============================================
    % Transfer function of a first-order RC Low-Pass Filter:
    % H(s) = 1 / (1 + sRC)
    % It describes how the filter attenuates high-frequency components
    % while allowing low-frequency components to pass.
    % ==============================================
    % Cutoff frequency of the RC Low-Pass Filter:
    % fc = 1 / (2*pi*R*C)
    % It represents the frequency at which the output amplitude
    % drops to approximately 70.7% (-3 dB) of the input amplitude.

    % RC filter parameters
    R = 50;          % Resistance (Ohms)
    C = 20e-12;      % Capacitance (Farads)
    fc = 1 / (2*pi*R*C);

    % Sampling parameters
    Fs = samples_per_bit / (time_per_bit * 1e-9); % Hz
  

    % Design a first-order digital Butterworth Low-Pass Filter.
    % 1: Filter order (first-order filter).
    % fc/(Fs/2): Normalized cutoff frequency (normalized to Nyquist frequency).
    % 'low': Specifies a low-pass filter.
    % b: Numerator coefficients of the filter transfer function.
    % a: Denominator coefficients of the filter transfer function.
    % [b, a] = butter(1, fc/(Fs/2), 'low');


    % Design a fourth-order Butterworth Low-Pass Filter.
    % 4: Fourth-order filter (four poles).
    % fc/(Fs/2): Normalized cutoff frequency.
    % 'low': Low-pass filter.
    % [b, a] = butter(4, fc/(Fs/2), 'low');
    % 
    % % Apply filter to transmitter signals
    % smooth_tx_p = filter(b, a, raw_tx_p);
    % smooth_tx_n = filter(b, a, raw_tx_n);
    
    % Calculate differential voltage
    % smooth_v_diff = smooth_tx_p - smooth_tx_n;



    % Apply fourth-order low-pass filter based on the reference transfer function
    % ==============================================
    Q = 0.7;                % Quality factor
    f0 = 2e9;               % Natural frequency (Hz), example: 2 GHz
    wnode = 2*pi*f0;        % Natural angular frequency (rad/s)
    % Second-order system coefficients
    % H2(s) = w0^2 / (s^2 + (w0/Q)*s + w0^2)
    num = [wnode^2];
    den = [1, wnode/Q, wnode^2];
    % Fourth-order system: cascade two identical second-order systems
    num4 = conv(num, num);
    den4 = conv(den, den);
    % Convert continuous-time filter into a digital filter
    [b, a] = bilinear(num4, den4, Fs);
    % Apply the fourth-order low-pass filter
    smooth_tx_p = filter(b, a, raw_tx_p);
    smooth_tx_n = filter(b, a, raw_tx_n);
    % Calculate differential voltage
    smooth_v_diff = smooth_tx_p - smooth_tx_n;



    % Plotting in MATLAB window
    % ==============================================
    fig = figure(2);
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
    % subplot(2, 1, 2);
    % plot(t, smooth_v_diff, 'm-', 'LineWidth', 2.5);
    % yline(0, 'k-', 'LineWidth', 1.0);
    % grid on;
    % ylim([-0.6 0.6]);
    % title('Differential Output Voltage: V_{diff} = TX+ - TX-', 'FontSize', 13, 'FontWeight', 'bold');
    % xlabel('Time (ns)', 'FontSize', 11);
    % ylabel('Differential Voltage (V)', 'FontSize', 11);
    % legend('V_{diff} (\pm 0.4 V)', 'Location', 'northeast');

    % Plot the Eye Diagram
    % ==============================================
    samples_per_eye = 2 * samples_per_bit; % Each eye trace contains 2 Unit Intervals (2 bits i.e 100 sample).
    % Calculate how many complete eye traces can be extracted.
    % We move forward by one bit each time, so the traces overlap.
    num_traces = floor((length(smooth_v_diff) - samples_per_eye) / samples_per_bit) + 1;
    
    % Time axis for one eye trace (in ns).
    % (time_per_bit/samples_per_bit) calculates the time interval between consecutive samples.
    eye_t = (0:samples_per_eye-1) * (time_per_bit/samples_per_bit); 
    
    subplot(2, 1, 2);
    cla; % Clears only the currently selected axes (clearing the previous eye diagram ploted in the last function call).
    hold on; % Keep the existing plotted objects when I execute subsequent plotting commands.    
        % Overlay all 2-UI segments.
        for k = 1:num_traces
            % Find the starting and ending sample of this segment.
            start_idx = (k-1)*samples_per_bit + 1;
            end_idx = start_idx + samples_per_eye - 1;
        
            % Extract the corresponding differential signal segment.
            eye_segment = smooth_v_diff(start_idx:end_idx);
        
            % Plot this segment on top of the previous ones.
            plot(eye_t, eye_segment, 'b-', 'LineWidth', 0.8);
        end
        xlim([0 2*time_per_bit]);
        ylim([-0.6 0.6]);
        
        % Reference zero differential voltage.
        yline(0, 'k--');
        
        title('Differential Transmitter Eye Diagram');
        xlabel('Time (ns)');
        ylabel('Differential Voltage (V)');
    hold off;

    drawnow;
    shg;
end
