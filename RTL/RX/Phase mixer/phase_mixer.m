clc;
clear;
close all;

%% Phase Mixer Parameters

f_clk = 2.5e9;        % Clock frequency = 2.5 GHz
T = 1/f_clk;          % Clock period = 400 ps
A = 1;                % Clock amplitude = 1 V

N = 1000;             % Samples per clock period
fs = N*f_clk;         % Sampling frequency
dt = 1/fs;            % Sampling interval

num_cycles = 5;       % Number of clock cycles
t = 0:dt:num_cycles*T-dt;

%% Generate Four Quadrature Clocks

omega = 2*pi*f_clk;

CLK0   = A*cos(omega*t);
CLK90  = A*cos(omega*t - pi/2);
CLK180 = A*cos(omega*t - pi);
CLK270 = A*cos(omega*t - 3*pi/2);

%% Plot Input Clocks

figure;

plot(t*1e12, CLK0, 'LineWidth', 1.5);
hold on;
plot(t*1e12, CLK90, 'LineWidth', 1.5);
plot(t*1e12, CLK180, 'LineWidth', 1.5);
plot(t*1e12, CLK270, 'LineWidth', 1.5);

xlabel('Time (ps)');
ylabel('Amplitude (V)');
title('Four Quadrature Input Clocks');

legend('CLK0', 'CLK90', 'CLK180', 'CLK270');
grid on;
xlim([0 2*T*1e12]);

%% 8 bit input 

phase_code = '01010011';
phase_quadrant = phase_code(1:2);   % First 2 bits
phase_angle = phase_code(3:8);  % Remaining 6 bits
decimal_quad = bin2dec(phase_quadrant);
decimal_angle = bin2dec(phase_angle);

disp(decimal_quad);
disp(decimal_angle);

%% calculate theta

theta = (90/64)*decimal_angle;


%% Quadrant Selection

switch decimal_quad

    case 0
        CLK_A = CLK0;
        CLK_B = CLK90;

    case 1
        CLK_A = CLK90;
        CLK_B = CLK180;

    case 2
        CLK_A = CLK180;
        CLK_B = CLK270;

    case 3
        CLK_A = CLK270;
        CLK_B = CLK0;

end

%% calculating wa and wb

wa = cos(theta*(pi/180));
wb = sin(theta*(pi/180)); 

%% output clock calculating

CLK_OUT = wa * CLK_A + wb * CLK_B;


%% phase comparison

phase_desired = decimal_quad*90 + theta;
phase_actual = decimal_quad*90 + atan2d(wb, wa) ;

phase_error = phase_actual - phase_desired;

%% Plot Selected Clocks and Output

figure;

plot(t*1e12, CLK_A, '--', 'LineWidth', 1.5);
hold on;

plot(t*1e12, CLK_B, '--', 'LineWidth', 1.5);

plot(t*1e12, CLK_OUT, 'k', 'LineWidth', 2);

xlabel('Time (ps)');
ylabel('Amplitude (V)');

title(['Phase Mixer Output - Code = ', phase_code]);

legend('CLK A', 'CLK B', 'CLK OUT');

grid on;
xlim([0 2*T*1e12]);

%% Plot Reference Clock vs Output Clock

figure;

plot(t*1e12, CLK0, 'b', 'LineWidth', 1.5);
hold on;

plot(t*1e12, CLK_OUT, 'r', 'LineWidth', 2);

xlabel('Time (ps)');
ylabel('Amplitude (V)');

title('Reference Clock vs Phase Mixer Output');

legend('CLK0 (Reference)', 'CLK OUT');

grid on;
xlim([0 2*T*1e12]);

%% Plot Desired vs Actual Phase

figure;

bar([phase_desired phase_actual]);

set(gca, 'XTickLabel', {'Desired Phase', 'Actual Phase'});

ylabel('Phase (degrees)');
title('Desired vs Actual Output Phase');

grid on;

%% Display Phase Error

fprintf('\n--- Phase Mixer Results ---\n');

fprintf('Quadrant       = %d\n', decimal_quad);
fprintf('Fine Code      = %d\n', decimal_angle);
fprintf('Theta          = %.4f degrees\n', theta);

fprintf('Desired Phase  = %.4f degrees\n', phase_desired);
fprintf('Actual Phase   = %.4f degrees\n', phase_actual);

fprintf('Phase Error    = %.8f degrees\n', phase_error);

