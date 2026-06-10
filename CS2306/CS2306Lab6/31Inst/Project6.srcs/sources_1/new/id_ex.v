`timescale 1ns / 1ps

module id_ex (
    output reg [31:0] alu_src_1,
    output reg [31:0] alu_src_2,
    output reg [31:0] after_ext,
    output reg [31:0] ex_pc,
    output reg [10:0] ex_shamt_funct,
    output reg [4:0]  reg_dst,
    output reg [4:0]  ex_rs,
    output reg [4:0]  ex_rt,
    output reg [2:0]  ex_alu_op,
    output reg        ex_alu_src,
    output reg        ex_mem_to_reg,
    output reg        ex_reg_write,
    output reg        ex_mem_read,
    output reg        ex_mem_write,
    output reg        ex_branch,
    output reg        ex_jump_load,
    input  [31:0] reg_data_1,
    input  [31:0] reg_data_2,
    input  [31:0] after_sign_ext,
    input  [31:0] after_zero_ext,
    input  [31:0] id_pc,
    input  [10:0] id_shamt_funct,
    input  [9:0]  reg_dst_opt,
    input  [4:0]  id_rs,
    input  [4:0]  id_rt,
    input  [2:0]  id_alu_op,
    input         id_sign_ext,
    input         id_reg_dst,
    input         id_alu_src,
    input         id_mem_to_reg,
    input         id_reg_write,
    input         id_mem_read,
    input         id_mem_write,
    input         id_branch,
    input         id_jump_load,
    input         stall,
    input         clock
);

    // Data signals
    reg [31:0] nxt_reg_data_1;
    reg [31:0] nxt_reg_data_2;
    reg [31:0] nxt_signext;
    reg [31:0] nxt_zeroext;
    reg [31:0] nxt_pc;
    reg [10:0] nxt_shamt_funct;
    reg [9:0]  nxt_reg_dst_idx;
    reg [4:0]  nxt_rs;
    reg [4:0]  nxt_rt;
    reg [2:0]  nxt_alu_op;

    // Control signals
    reg        nxt_alu_src;
    reg        nxt_mem_to_reg;
    reg        nxt_reg_write;
    reg        nxt_mem_read;
    reg        nxt_mem_write;
    reg        nxt_branch;
    reg        nxt_jump_load;

    initial begin
        nxt_alu_src     = 0;
        nxt_mem_to_reg  = 0;
        nxt_reg_write   = 0;
        nxt_mem_read    = 0;
        nxt_mem_write   = 0;
        nxt_branch      = 0;
        nxt_alu_op      = 0;
        nxt_shamt_funct = 0;
        nxt_jump_load   = 0;
        nxt_pc          = 0;
        ex_alu_src      = 0;
        ex_mem_to_reg   = 0;
        ex_reg_write    = 0;
        ex_mem_read     = 0;
        ex_mem_write    = 0;
        ex_branch       = 0;
        ex_alu_op       = 0;
        ex_shamt_funct  = 0;
        ex_jump_load    = 0;
        ex_pc           = 0;
    end

    always @(negedge clock) begin
        if (stall) begin
            nxt_reg_data_1  = 0;
            nxt_reg_data_2  = 0;
            nxt_signext     = 0;
            nxt_zeroext     = 0;
            nxt_pc          = 0;
            nxt_shamt_funct = 0;
            nxt_reg_dst_idx = 0;
            nxt_rs          = 0;
            nxt_rt          = 0;
            nxt_alu_op      = 0;
            nxt_alu_src     = 0;
            nxt_mem_to_reg  = 0;
            nxt_reg_write   = 0;
            nxt_mem_read    = 0;
            nxt_mem_write   = 0;
            nxt_branch      = 0;
            nxt_jump_load   = 0;
        end else begin
            nxt_reg_data_1  = reg_data_1;
            nxt_reg_data_2  = reg_data_2;
            nxt_signext     = after_sign_ext;
            nxt_zeroext     = after_zero_ext;
            nxt_pc          = id_pc;
            nxt_shamt_funct = id_shamt_funct;
            nxt_reg_dst_idx = reg_dst_opt;
            nxt_rs          = id_rs;
            nxt_rt          = id_rt;
            nxt_alu_op      = id_alu_op;
            nxt_alu_src     = id_alu_src;
            nxt_mem_to_reg  = id_mem_to_reg;
            nxt_reg_write   = id_reg_write;
            nxt_mem_read    = id_mem_read;
            nxt_mem_write   = id_mem_write;
            nxt_branch      = id_branch;
            nxt_jump_load   = id_jump_load;
        end
    end

    always @(posedge clock) begin
        alu_src_1    = nxt_reg_data_1;
        alu_src_2    = nxt_reg_data_2;
        after_ext    = id_sign_ext ? nxt_signext : nxt_zeroext;
        ex_pc        = nxt_pc;
        ex_shamt_funct = nxt_shamt_funct;
        reg_dst      = id_jump_load ? 5'b11111 :
                       (id_reg_dst ? nxt_reg_dst_idx[4:0] :
                                     nxt_reg_dst_idx[9:5]);
        ex_rs        = nxt_rs;
        ex_rt        = id_reg_dst ? nxt_rt : 5'b00000;
        ex_alu_op    = nxt_alu_op;
        ex_alu_src   = nxt_alu_src;
        ex_mem_to_reg  = nxt_mem_to_reg;
        ex_reg_write   = nxt_reg_write;
        ex_mem_read    = nxt_mem_read;
        ex_mem_write   = nxt_mem_write;
        ex_branch      = nxt_branch;
        ex_jump_load   = nxt_jump_load;
    end

endmodule
