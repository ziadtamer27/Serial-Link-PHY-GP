% List of videos by Adam Panagos
% https://youtu.be/dmzikG1jZpU  | Butterworth Filter - 01 - Introduction
% https://youtu.be/-EHRFrDujhc  | Butterworth Filter - 02 - Normalized Filter
% https://youtu.be/XS4xibSOdmM  | Analyzing and Visualizing Data with MATLAB
% https://www.mathworks.com/help/matlab/ref/cla.html

function [smooth_tx_p, smooth_tx_n, smooth_v_diff] = channel_effect(raw_tx_p, raw_tx_n, samples_per_bit, time_per_bit)
% CHANNEL_EFFECT Pure channel filter model (4th-order low-pass channel response).
%   Applies bandwidth-limiting channel ISI to oversampled TX+ and TX- waveforms.

    % Sampling frequency (Hz)
    Fs = samples_per_bit / (time_per_bit * 1e-9);

    % Apply fourth-order low-pass filter based on the reference transfer function
    % ==============================================
    Q = 0.7;                % Quality factor
    f0 = 2e9;               % Natural frequency (Hz), example: 2 GHz
    wnode = 2*pi*f0;        % Natural angular frequency (rad/s)

    % Second-order system coefficients: H2(s) = w0^2 / (s^2 + (w0/Q)*s + w0^2)
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

    % Calculate differential voltage after the channel
    smooth_v_diff = smooth_tx_p - smooth_tx_n;
end
