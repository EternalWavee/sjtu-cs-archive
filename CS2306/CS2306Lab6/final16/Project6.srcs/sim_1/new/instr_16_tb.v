`timescale 1ns / 1ps

module instr_16_tb;

    reg sys_clk;
    reg reset;

    Top u_cpu (
        .Clk   (sys_clk),
        .Reset (reset)
    );

    always #(100) sys_clk = ~sys_clk;

    initial begin
        u_cpu.PC = 0;
        sys_clk  = 0;
        reset    = 0;
        $readmemh("lab06dat_tb", u_cpu.u_data_mem.mem);
        $readmemb("lab06instr_tb", u_cpu.u_instr_mem.mem);
        #100;
        reset = 1;
        #100;
        reset = 0;
    end

endmodule
