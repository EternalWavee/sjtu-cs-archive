`timescale 1ns / 1ps

module alu_control_unit (
    output reg [3:0] alu_ctr_out,
    input  [2:0] alu_op,
    input  [5:0] funct
);

    always @(alu_op or funct) begin
        casex ({alu_op, funct})
            9'b1xx000010: alu_ctr_out <= 4'b1111;  // srl
            9'b000xxxxxx: alu_ctr_out <= 4'b0010;  // add
            9'b1xx100100: alu_ctr_out <= 4'b0000;  // and
            9'b011xxxxxx: alu_ctr_out <= 4'b0001;  // or
            9'b1xx101010: alu_ctr_out <= 4'b0111;  // slt
            9'b1xx000000: alu_ctr_out <= 4'b1110;  // sll
            9'b001xxxxxx: alu_ctr_out <= 4'b0110;  // sub
            9'b1xx100010: alu_ctr_out <= 4'b0110;  // sub
            9'b1xx001000: alu_ctr_out <= 4'b0100;  // jr
            9'b010xxxxxx: alu_ctr_out <= 4'b0000;  // and
            9'b1xx100000: alu_ctr_out <= 4'b0010;  // add
            9'b1xx100101: alu_ctr_out <= 4'b0001;  // or
            default:      alu_ctr_out <= 4'b0;
        endcase
    end

endmodule
