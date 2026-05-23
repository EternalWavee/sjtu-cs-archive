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
    
    reg [31:0] memFile[0:63];    // 64 ¡Á 32 
    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1)
            memFile[i] = 32'b0;
    end

    always @(negedge Clk) begin
        if (memWrite)
            memFile[address] <= writeData;   // ·Ç×èÈû¸³Öµ
    end

    always @(*) begin
        if (memRead && !memWrite)
            readData = memFile[address];     // ×èÈû¸³Öµ
        else
            readData = 32'b0;
    end
    
endmodule
