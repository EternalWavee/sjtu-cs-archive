`timescale 1ns / 1ps

module alu_control_unit (
    output reg [3:0] alu_ctr_out,
    input  [2:0] alu_op,
    input  [5:0] funct
);

    always @(alu_op or funct) begin
        casex ({alu_op, funct})
            9'b111_100111: alu_ctr_out <= 4'b1100;  // nor
            9'b000_xxxxxx: alu_ctr_out <= 4'b0010;  // add
            9'b111_000010: alu_ctr_out <= 4'b1111;  // srl
            9'b101_xxxxxx: alu_ctr_out <= 4'b0111;  // slt
            9'b111_100100: alu_ctr_out <= 4'b0000;  // and
            9'b011_xxxxxx: alu_ctr_out <= 4'b0001;  // or
            9'b111_000111: alu_ctr_out <= 4'b1000;  // srav
            9'b110_xxxxxx: alu_ctr_out <= 4'b0101;  // sltu
            9'b111_10001x: alu_ctr_out <= 4'b0110;  // sub, subu
            9'b001_xxxxxx: alu_ctr_out <= 4'b0011;  // lui
            9'b111_000000: alu_ctr_out <= 4'b1110;  // sll
            9'b111_000100: alu_ctr_out <= 4'b1001;  // sllv
            9'b111_101010: alu_ctr_out <= 4'b0111;  // slt
            9'b100_xxxxxx: alu_ctr_out <= 4'b1101;  // xor
            9'b111_10000x: alu_ctr_out <= 4'b0010;  // add, addu
            9'b111_000011: alu_ctr_out <= 4'b1010;  // sra
            9'b010_xxxxxx: alu_ctr_out <= 4'b0000;  // and
            9'b111_100101: alu_ctr_out <= 4'b0001;  // or
            9'b111_000110: alu_ctr_out <= 4'b1011;  // srlv
            9'b111_100110: alu_ctr_out <= 4'b1101;  // xor
            9'b111_101011: alu_ctr_out <= 4'b0101;  // sltu
            9'b111_001000: alu_ctr_out <= 4'b0100;  // jr
            default:       alu_ctr_out <= 4'b0;
        endcase
    end

endmodule
