function [y, valid] = presets(bit_in, preset, reset)
% PRESETS 3-tap Feed-Forward Equalizer (FFE) model with PCIe preset lookup.

    persistent prev_bit curr_bit count

    if nargin < 3
        reset = false;
    end

    if isempty(count) || reset
        prev_bit = 0;
        curr_bit = 0;
        count = 0;
    end

    y = 0;
    valid = false;

    if reset
        return;
    end

    % Get FFE tap coefficients for the requested preset
    [c_pre, c_post] = set_preset(preset);
    c_main = 1 - abs(c_pre) - abs(c_post);

    % Map binary {0, 1} to NRZ {-1, +1}
    next_bit = 2 * double(bit_in) - 1;

    if count == 0
        % Store the first bit (1-UI pipeline delay for pre-cursor lookahead)
        curr_bit = next_bit;
        count = 1;
        return;
    end

    if count == 1
        % First valid output bit: no previous bit available yet (prev_bit = 0)
        y = c_pre * next_bit + c_main * curr_bit;
        valid = true;

        prev_bit = curr_bit;
        curr_bit = next_bit;
        count = 2;
        return;
    end

    % All subsequent bits: full three-tap FFE
    y = c_pre  * next_bit ...
      + c_main * curr_bit ...
      + c_post * prev_bit;

    valid = true;

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
