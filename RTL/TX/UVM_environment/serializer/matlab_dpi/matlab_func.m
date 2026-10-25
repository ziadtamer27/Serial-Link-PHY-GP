function result = matlab_func(a, b)
    %#codegen
    % Trivial MATLAB function to test SystemVerilog / UVM DPI-C connection
    % Returns (a + b) * 2
    result = int32((int64(a) + int64(b)) * 2);
end
