`timescale 1ns / 1ps

module instruction_memory (
    output [31:0] instr,
    input  [31:0] addr,
    input         reset,
    input         clock
);

    reg [31:0] mem [0:63];

    assign instr = reset ? mem[0] : mem[addr >> 2];

endmodule
