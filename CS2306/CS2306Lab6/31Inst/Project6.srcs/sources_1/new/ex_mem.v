`timescale 1ns / 1ps

module ex_mem (
    output reg [31:0] alu_output,
    output reg [31:0] mem_cont,
    output reg [4:0]  mem_reg_dst,
    output reg        mem_mem_to_reg,
    output reg        mem_reg_write,
    output reg        mem_mem_read,
    output reg        mem_mem_write,
    input  [31:0] alu_rst,
    input  [31:0] ex_cont,
    input  [4:0]  ex_reg_dst,
    input         ex_mem_to_reg,
    input         ex_reg_write,
    input         ex_mem_read,
    input         ex_mem_write,
    input         clock
);

    reg [31:0] nxt_alu;
    reg [31:0] nxt_cont;
    reg [4:0]  nxt_reg_dst;
    reg        nxt_mem_to_reg;
    reg        nxt_reg_write;
    reg        nxt_mem_read;
    reg        nxt_mem_write;

    always @(negedge clock) begin
        nxt_mem_to_reg <= ex_mem_to_reg;
        nxt_reg_write  <= ex_reg_write;
        nxt_mem_read   <= ex_mem_read;
        nxt_mem_write  <= ex_mem_write;
        nxt_reg_dst    <= ex_reg_dst;
        nxt_cont       <= ex_cont;
        nxt_alu        <= alu_rst;
    end

    always @(posedge clock) begin
        alu_output     <= nxt_alu;
        mem_cont       <= nxt_cont;
        mem_reg_dst    <= nxt_reg_dst;
        mem_mem_to_reg <= nxt_mem_to_reg;
        mem_reg_write  <= nxt_reg_write;
        mem_mem_read   <= nxt_mem_read;
        mem_mem_write  <= nxt_mem_write;
    end

endmodule
