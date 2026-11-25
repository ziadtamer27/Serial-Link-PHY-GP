% TEST_DIFFERENTIAL
% That is a test script for the calc_differential function in order to test everything in matlab first and after that we would feel free to test the code with our verilog compiler of choice

clc;
clear;
close all;

% Reset persistent variables inside calc_diff2 / calc_differential / FFE / channel_effect / plotting
clear calc_diff2 calc_differential FFE get_bit_multiplier channel_effect plotting;

% Test input bit stream
test_bits = [1 1 1 0 0 0 1 0 1 0 1 1 0 0 1 0];

fprintf('Starting Differential Transmitter Test\n');
fprintf('--------------------------------------\n');

for k = 1:length(test_bits)
    bit_val = test_bits(k);
    [tx_p, tx_n, v_diff, valid] = calc_diff2(bit_val, 'P7'); % Calling the function under test
    fprintf('Cycle %2d | bit_in = %d | valid = %d | TX+ = %0.3f V | TX- = %0.3f V | Vdiff = %+0.3f V\n', ...
            k, bit_val, valid, tx_p, tx_n, v_diff);
end

fprintf('--------------------------------------\n');
fprintf('Test completed successfully!\n');
