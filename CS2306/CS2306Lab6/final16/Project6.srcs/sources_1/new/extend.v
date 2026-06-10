`timescale 1ns / 1ps

module zero_extend (
    output [31:0] data_32,
    input  [15:0] data_16
);

    assign data_32 = {16'b0, data_16};

endmodule

module sign_extend (
    output [31:0] data_32,
    input  [15:0] data_16
);

    assign data_32 = {{16{data_16[15]}}, data_16};

endmodule
