`timescale 1ns / 1ps

module alu (
    input  [3:0]  alu_ctr,
    input  [31:0] reg_1,
    input  [31:0] reg_2,
    input  [4:0]  shamt,
    output reg        zero,
    output reg [31:0] alu_result
);

    always @(reg_1 or reg_2 or alu_ctr) begin
        case (alu_ctr)
            4'b1101: alu_result = reg_1 ^ reg_2;                            // xor
            4'b0010: alu_result = reg_1 + reg_2;                            // add
            4'b1110: alu_result = reg_2 <<< shamt;                          // sll
            4'b0111: alu_result = ($signed(reg_1) < $signed(reg_2)) ? 1 : 0;// slt
            4'b1100: alu_result = ~(reg_1 | reg_2);                         // nor
            4'b1001: alu_result = reg_2 <<< reg_1;                          // sllv
            4'b0110: alu_result = reg_1 - reg_2;                            // sub
            4'b0000: alu_result = reg_1 & reg_2;                            // and
            4'b1111: alu_result = reg_2 >>> shamt;                          // srl
            4'b0011: alu_result = reg_2 << 16;                              // lui
            4'b0101: alu_result = (reg_1 < reg_2) ? 1 : 0;                 // sltu
            4'b1010: alu_result = reg_2 >> shamt;                           // sra
            4'b1011: alu_result = reg_2 >>> reg_1;                          // srlv
            4'b0001: alu_result = reg_1 | reg_2;                            // or
            4'b1000: alu_result = reg_2 >> reg_1;                           // srav
            4'b0100: alu_result = 32'h00000000;                             // jr
            default: alu_result = 32'h00000000;
        endcase

        if (alu_result == 0)
            zero = 1;
        else
            zero = 0;
    end

endmodule
