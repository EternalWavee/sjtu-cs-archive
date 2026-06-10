`timescale 1ns / 1ps

module registers (
    output [31:0] rd_data_1,
    output [31:0] rd_data_2,
    input  [31:0] wr_data,
    input  [4:0]  rd_reg_1,
    input  [4:0]  rd_reg_2,
    input  [4:0]  wr_reg,
    input         wr_en,
    input         reset,
    input         clock
);

    reg [31:0] regs [0:31];
    integer i;

    assign rd_data_1 = regs[rd_reg_1];
    assign rd_data_2 = regs[rd_reg_2];

    always @(reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 0;
        end
    end

    always @(posedge clock)
        if (wr_en)
            regs[wr_reg] = wr_data;

endmodule
