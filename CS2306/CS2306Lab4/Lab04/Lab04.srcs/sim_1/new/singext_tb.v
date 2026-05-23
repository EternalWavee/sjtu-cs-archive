`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/19 08:42:28
// Design Name: 
// Module Name: singext_tb
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


module singext_tb(

    );
    reg [15:0] inst;
    wire [31:0] data;
    
    signext u0 (
    .inst(inst),
    .data(data)
    );
    
    initial begin
        inst = 0;

        #100;
        inst = 7;

        #100;
        inst = -7;

        #100;
        inst = 2;

        #100;
        inst = -2;
    end
    
endmodule
