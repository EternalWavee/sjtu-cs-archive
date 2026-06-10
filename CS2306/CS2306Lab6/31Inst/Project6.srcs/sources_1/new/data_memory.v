`timescale 1ns / 1ps

module data_memory (
    output [31:0] rd_data,
    input         mem_rd,
    input         mem_wr,
    input  [31:0] wr_data,
    input  [31:0] addr,
    input         clock
);

    reg [31:0] mem [0:63];

    assign rd_data = (mem_rd && !mem_wr) ? mem[addr >> 2] : 0;

    always @(negedge clock)
        if (mem_wr)
            mem[addr >> 2] = wr_data;

endmodule
