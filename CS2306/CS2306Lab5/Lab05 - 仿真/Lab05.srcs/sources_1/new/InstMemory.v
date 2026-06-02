`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/26 08:19:51
// Design Name: 
// Module Name: InstMemory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module InstMemory(
    input Clk,
    input reset,
    input [31:0] address,
    output [31:0] inst
);

    reg [31:0] instFile [0:63];
    integer i;

    initial begin
        // 先全部初始化成 nop
        for (i = 0; i < 64; i = i + 1) begin
            instFile[i] = 32'b00000000000000000000000000000000;
        end

         $readmemb("Instruction", instFile);

    end

    assign inst = instFile[address[7:2]];

endmodule