`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/26 08:23:51
// Design Name: 
// Module Name: Top_tb
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

module Top_tb();

    reg Clk;
    reg reset;

    always #100 Clk = ~Clk;

    Top u0 (
        .Clk(Clk),
        .reset(reset),
        .a(4'd9),
        .b(4'd13)
    );

    initial begin
        Clk = 0;
        reset = 0;

        #100;
        reset = 1;

        #200;
        reset = 0;

        #30000;
        $finish;
    end

endmodule
