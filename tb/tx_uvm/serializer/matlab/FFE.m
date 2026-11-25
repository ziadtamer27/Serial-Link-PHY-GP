function [bit_multiplier, valid, bit_multiplier_no_ffe] = get_bit_multiplier(bit_in, preset)
% GET_BIT_MULTIPLIER (FFE.m) 3-tap Feed-Forward Equalizer (FFE) model with PCIe preset lookup.
%   Returns:
%     bit_multiplier        - Equalized multiplier (with 3-tap FFE)
%     valid                 - True once the 1-UI pre-cursor pipeline is primed
%     bit_multiplier_no_ffe - Un-equalized NRZ multiplier (+1 or -1), time-aligned with bit_multiplier

    persistent prev_bit curr_bit count

    if isempty(count) 
        prev_bit = 0;
        curr_bit = 0;
        count = 0;
    end

    bit_multiplier = 0; %% bit_multiplier is the multiplier we use to get the actual analog output of a bit
    bit_multiplier_no_ffe = 0;
    valid = false;

    % Get FFE tap coefficients for the requested preset
    [c_pre, c_post] = set_preset(preset);
    c_main = 1 - abs(c_pre) - abs(c_post);

    % Map binary {0, 1} to NRZ {-1, +1}
    if bit_in
        next_bit = 1;
    else
        next_bit = -1;
    end

    if count == 0 
        % Store the first bit (1-UI pipeline delay for pre-cursor lookahead)
        curr_bit = next_bit;
        prev_bit = next_bit;
        count = 1;
        return;
    end

    % All subsequent bits: full three-tap FFE and time-aligned un-equalized bit
    bit_multiplier = c_pre * next_bit + c_main * curr_bit + c_post * prev_bit;
    bit_multiplier_no_ffe = curr_bit;

    valid = true;

    %% shift the bits
    prev_bit = curr_bit;
    curr_bit = next_bit;
end

function [c_pre, c_post] = set_preset(preset)
    switch upper(preset)
        case 'P4'
            c_pre = 0;
            c_post = 0;

        case 'P0'
            c_pre = 0;
            c_post = -0.250;

        case 'P1'
            c_pre = 0;
            c_post = -0.167;

        case 'P9'
            c_pre = -0.166;
            c_post = 0;

        case 'P7'
            c_pre = -0.100;
            c_post = -0.200;

        case 'P8'
            c_pre = -0.125;
            c_post = -0.125;

        otherwise
            error('Unsupported preset: %s', preset);
    end
end
