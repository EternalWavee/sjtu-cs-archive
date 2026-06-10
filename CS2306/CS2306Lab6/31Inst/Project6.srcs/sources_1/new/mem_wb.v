`timescale 1ns / 1ps

module mem_wb (
    output reg [31:0] wb_data,
    output reg [4:0]  wb_reg_dst,
    output reg        wb_reg_write,
    input  [31:0] mem_data,
    input  [31:0] alu_output,
    input  [4:0]  mem_reg_dst,
    input         mem_mem_to_reg,
    input         mem_reg_write,
    input         clock
);

    reg [31:0] nxt_mem;
    reg [31:0] nxt_alu;
    reg [4:0]  nxt_reg_dst;
    reg        nxt_mem_to_reg;
    reg        nxt_reg_write;

    always @(negedge clock) begin
        nxt_reg_write  = mem_reg_write;
        nxt_reg_dst    = mem_reg_dst;
        nxt_mem_to_reg = mem_mem_to_reg;
        nxt_alu        = alu_output;
        nxt_mem        = mem_data;
        wb_reg_write   = nxt_reg_write;
        wb_reg_dst     = nxt_reg_dst;
        wb_data        = mem_mem_to_reg ? nxt_mem : nxt_alu;
    end

endmodule
