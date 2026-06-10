`timescale 1ns / 1ps

module forwarding (
    output reg [1:0] forwardA,
    output reg [1:0] forwardB,
    output reg [1:0] forward_id_rs,
    output reg [1:0] forward_id_rt,
    input  [4:0] ex_rs,
    input  [4:0] ex_rt,
    input  [4:0] ex_reg_dst,
    input        ex_reg_write,
    input  [4:0] id_rs,
    input  [4:0] id_rt,
    input        id_alu_src,
    input  [4:0] mem_reg_dst,
    input        mem_reg_write,
    input  [4:0] wb_reg_dst,
    input        wb_reg_write
);

    always @(*) begin
        forwardA = 2'b00;
        forwardB = 2'b00;

        if (mem_reg_write && (mem_reg_dst != 0) && (mem_reg_dst == ex_rs))
            forwardA = 2'b10;
        if (mem_reg_write && (mem_reg_dst != 0) && (mem_reg_dst == ex_rt))
            forwardB = 2'b10;

        if (wb_reg_write && (wb_reg_dst != 0) &&
            !(mem_reg_write && (mem_reg_dst != 0) && (mem_reg_dst == ex_rs)) &&
            (wb_reg_dst == ex_rs))
            forwardA = 2'b01;
        if (wb_reg_write && (wb_reg_dst != 0) &&
            !(mem_reg_write && (mem_reg_dst != 0) && (mem_reg_dst == ex_rt)) &&
            (wb_reg_dst == ex_rt))
            forwardB = 2'b01;

        forward_id_rs = 2'b00;
        if (id_rs != 0) begin
            if (ex_reg_write && (ex_reg_dst == id_rs))
                forward_id_rs = 2'b11;
            else if (mem_reg_write && (mem_reg_dst == id_rs))
                forward_id_rs = 2'b10;
            else if (wb_reg_write && (wb_reg_dst == id_rs))
                forward_id_rs = 2'b01;
        end

        forward_id_rt = 2'b00;
        if (id_rt != 0) begin
            if (ex_reg_write && (ex_reg_dst == id_rt) && !id_alu_src)
                forward_id_rt = 2'b11;
            else if (mem_reg_write && (mem_reg_dst == id_rt) && !id_alu_src)
                forward_id_rt = 2'b10;
            else if (wb_reg_write && (wb_reg_dst == id_rt) && !id_alu_src)
                forward_id_rt = 2'b01;
        end
    end

endmodule

module hazard_detection_unit (
    output reg   stall,
    input  [4:0] id_rs,
    input  [4:0] id_rt,
    input  [4:0] ex_rt,
    input        ex_mem_read,
    input        id_alu_src
);

    always @(*) begin
        if (ex_mem_read && ((ex_rt == id_rs) || (ex_rt == id_rt && !id_alu_src)))
            stall = 1'b1;
        else
            stall = 1'b0;
    end

endmodule
