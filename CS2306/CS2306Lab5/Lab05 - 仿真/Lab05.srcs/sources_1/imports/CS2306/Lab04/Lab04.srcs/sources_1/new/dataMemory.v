`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/19 08:29:30
// Design Name: 
// Module Name: dataMemory
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


module dataMemory(
    input Clk,
    input [31:0] address,
    input [31:0] writeData,
    input memWrite,
    input memRead,
    output reg [31:0] readData
);

    reg [31:0] memFile [0:63];
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1) begin
            memFile[i] = 32'b0;
        end

        $readmemh("Data", memFile);
    end

    always @(negedge Clk) begin
        if (memWrite) begin
            memFile[address[7:2]] <= writeData;
        end
    end

    always @(*) begin
        if (memRead) begin
            readData = memFile[address[7:2]];
        end
        else begin
            readData = 32'b0;
        end
    end

endmodule