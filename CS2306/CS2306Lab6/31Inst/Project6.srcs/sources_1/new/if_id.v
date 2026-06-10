`timescale 1ns / 1ps

module if_id (
    output reg [31:0] id_instr,
    output reg [31:0] id_pc,
    input  [31:0] if_instr,
    input  [31:0] if_pc,
    input         flush,
    input         stall,
    input         clock
);

    reg [31:0] nxt_instr;
    reg [31:0] nxt_pc;

    initial begin
        nxt_instr = 0;
        nxt_pc    = 0;
        id_pc     = 0;
        id_instr  = 0;
    end

    always @(negedge clock) begin
        if (flush) begin
            nxt_instr <= 32'b0;
            nxt_pc    <= 32'b0;
        end else if (stall) begin
            nxt_instr <= nxt_instr;
            nxt_pc    <= nxt_pc;
        end else begin
            nxt_instr <= if_instr;
            nxt_pc    <= if_pc;
        end
    end

    always @(posedge clock) begin
        id_instr <= nxt_instr;
        id_pc    <= nxt_pc;
    end

endmodule
