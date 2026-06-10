`timescale 1ns / 1ps

module control_unit (
    output reg       jump,
    output reg       jr,
    output reg       reg_dst,
    output reg       alu_src,
    output reg [2:0] alu_op,
    output reg       branch,
    output reg       mem_read,
    output reg       mem_write,
    output reg       mem_to_reg,
    output reg       reg_write,
    output reg       sign_ext,
    output reg       jump_load,
    input  [5:0] funct,
    input  [5:0] op_code
);

    initial begin
        jump       = 0;
        jr         = 0;
        reg_dst    = 0;
        alu_src    = 0;
        alu_op     = 3'b000;
        branch     = 0;
        mem_read   = 0;
        mem_write  = 0;
        mem_to_reg = 0;
        reg_write  = 0;
        sign_ext   = 0;
        jump_load  = 0;
    end

    always @(op_code or funct) begin
        casex (op_code)
            6'b001111: begin  // lui
                jump       = 0;
                jr         = 0;
                reg_dst    = 0;
                alu_src    = 1;
                alu_op     = 3'b001;
                branch     = 0;
                mem_read   = 0;
                mem_write  = 0;
                mem_to_reg = 0;
                reg_write  = 1;
                sign_ext   = 0;
                jump_load  = 0;
            end
            6'b000000: begin  // R-type
                jump       = 0;
                reg_dst    = 1;
                alu_src    = 0;
                alu_op     = 3'b111;
                branch     = 0;
                mem_read   = 0;
                mem_write  = 0;
                mem_to_reg = 0;
                reg_write  = 1;
                sign_ext   = 0;
                jump_load  = 0;
                jr         = (funct == 6'b001000) ? 1 : 0;
            end
            6'b000010: begin  // j
                jump       = 1;
                jr         = 0;
                reg_dst    = 0;
                alu_src    = 0;
                alu_op     = 3'b000;
                branch     = 0;
                mem_read   = 0;
                mem_write  = 0;
                mem_to_reg = 0;
                reg_write  = 0;
                sign_ext   = 0;
                jump_load  = 0;
            end
            6'b001101: begin  // ori
                jump       = 0;
                jr         = 0;
                reg_dst    = 0;
                alu_src    = 1;
                alu_op     = 3'b011;
                branch     = 0;
                mem_read   = 0;
                mem_write  = 0;
                mem_to_reg = 0;
                reg_write  = 1;
                sign_ext   = 0;
                jump_load  = 0;
            end
            6'b101011: begin  // sw
                jump       = 0;
                jr         = 0;
                reg_dst    = 0;
                alu_src    = 1;
                alu_op     = 3'b000;
                branch     = 0;
                mem_read   = 0;
                mem_write  = 1;
                mem_to_reg = 0;
                reg_write  = 0;
                sign_ext   = 1;
                jump_load  = 0;
            end
            6'b001100: begin  // andi
                jump       = 0;
                jr         = 0;
                reg_dst    = 0;
                alu_src    = 1;
                alu_op     = 3'b010;
                branch     = 0;
                mem_read   = 0;
                mem_write  = 0;
                mem_to_reg = 0;
                reg_write  = 1;
                sign_ext   = 0;
                jump_load  = 0;
            end
            6'b001010: begin  // slti / sltiu
                jump       = 0;
                jr         = 0;
                reg_dst    = 0;
                alu_src    = 1;
                alu_op     = (op_code == 6'b001010) ? 3'b101 : 3'b110;
                branch     = 0;
                mem_read   = 0;
                mem_write  = 0;
                mem_to_reg = 0;
                reg_write  = 1;
                sign_ext   = 0;
                jump_load  = 0;
            end
            6'b001110: begin  // xori
                jump       = 0;
                jr         = 0;
                reg_dst    = 0;
                alu_src    = 1;
                alu_op     = 3'b100;
                branch     = 0;
                mem_read   = 0;
                mem_write  = 0;
                mem_to_reg = 0;
                reg_write  = 1;
                sign_ext   = 0;
                jump_load  = 0;
            end
            6'b000100: begin  // beq
                jump       = 0;
                jr         = 0;
                reg_dst    = 0;
                alu_src    = 0;
                alu_op     = 3'b001;
                branch     = 1;
                mem_read   = 0;
                mem_write  = 0;
                mem_to_reg = 0;
                reg_write  = 0;
                sign_ext   = 1;
                jump_load  = 0;
            end
            6'b100011: begin  // lw
                jump       = 0;
                jr         = 0;
                reg_dst    = 0;
                alu_src    = 1;
                alu_op     = 3'b000;
                branch     = 0;
                mem_read   = 1;
                mem_write  = 0;
                mem_to_reg = 1;
                reg_write  = 1;
                sign_ext   = 1;
                jump_load  = 0;
            end
            6'b000011: begin  // jal
                jump       = 1;
                jr         = 0;
                reg_dst    = 0;
                alu_src    = 0;
                alu_op     = 3'b000;
                branch     = 0;
                mem_read   = 0;
                mem_write  = 0;
                mem_to_reg = 0;
                reg_write  = 1;
                sign_ext   = 0;
                jump_load  = 1;
            end
            6'b00100x: begin  // addi, addiu
                jump       = 0;
                jr         = 0;
                reg_dst    = 0;
                alu_src    = 1;
                alu_op     = 3'b000;
                branch     = 0;
                mem_read   = 0;
                mem_write  = 0;
                mem_to_reg = 0;
                reg_write  = 1;
                sign_ext   = (op_code[0] == 0) ? 1 : 0;
                jump_load  = 0;
            end
            default: begin
                jump       = 0;
                jr         = 0;
                reg_dst    = 0;
                alu_src    = 0;
                alu_op     = 3'b000;
                branch     = 0;
                mem_read   = 0;
                mem_write  = 0;
                mem_to_reg = 0;
                reg_write  = 0;
                sign_ext   = 0;
                jump_load  = 0;
            end
        endcase
    end

endmodule
