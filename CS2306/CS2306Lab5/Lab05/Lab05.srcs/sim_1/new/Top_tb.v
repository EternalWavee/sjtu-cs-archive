`timescale 1ns / 1ps

module Top_tb();

    reg clk_p;
    wire clk_n;
    reg _reset;

    reg [3:0] a;
    reg [3:0] b;

    wire led_clk;
    wire led_do;
    wire led_en;

    wire seg_clk;
    wire seg_en;
    wire seg_do;

    assign clk_n = ~clk_p;

    // 100MHz clock: period = 10ns
    always #5 clk_p = ~clk_p;

    Top u0 (
        .clk_p(clk_p),
        .clk_n(clk_n),
        .a(a),
        .b(b),
        ._reset(_reset),

        .led_clk(led_clk),
        .led_do(led_do),
        .led_en(led_en),

        .seg_clk(seg_clk),
        .seg_en(seg_en),
        .seg_do(seg_do)
    );

    initial begin
        clk_p = 0;
        a = 4'd0;
        b = 4'd0;

        // Top 里面是 assign reset = !_reset;
        // 所以 _reset = 0 表示复位
        _reset = 0;
        #200;

        // 释放复位
        _reset = 1;

        #30000;
        $finish;
    end

endmodule