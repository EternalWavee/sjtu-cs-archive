`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/26 08:14:32
// Design Name: 
// Module Name: Top
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

module Top(
    input Clk,
    input reset,
    input [3:0] a,
    input [3:0] b
);

    // =========================
    // PC / Instruction
    // =========================
    wire [31:0] pc;
    wire [31:0] newpc;
    wire [31:0] pcplus4;
    wire [31:0] inst;

    // =========================
    // Control signals
    // =========================
    wire [1:0] regDst;
    wire aluSrc;
    wire memToReg;
    wire regWrite;
    wire memRead;
    wire memWrite;
    wire branch;
    wire [2:0] aluOp;
    wire [1:0] jump;
    wire extOp;

    // =========================
    // ALU control
    // =========================
    wire aluSrc1;
    wire [3:0] aluCtrOut;

    // =========================
    // Register file
    // =========================
    wire [4:0] writeReg;
    wire [31:0] writeData;
    wire [31:0] readData1;
    wire [31:0] readData2;
    wire [7:0] sum;

    // =========================
    // ALU
    // =========================
    wire [31:0] input1;
    wire [31:0] input2;
    wire zero;
    wire [31:0] aluRes;

    // =========================
    // Memory / Immediate
    // =========================
    wire [31:0] readData;
    wire [31:0] imm;

    // =========================
    // PC + 4
    // =========================
    assign pcplus4 = pc + 4;

    // =========================
    // Main Control
    // =========================
    Ctr ctr (
        .opCode(inst[31:26]),
        .funct(inst[5:0]),
        .regDst(regDst),
        .aluSrc(aluSrc),
        .memToReg(memToReg),
        .regWrite(regWrite),
        .memRead(memRead),
        .memWrite(memWrite),
        .branch(branch),
        .aluOp(aluOp),
        .jump(jump),
        .extOp(extOp)
    );

    // =========================
    // ALU Control
    // =========================
    ALUCtr aluCtr (
        .funct(inst[5:0]),
        .aluOp(aluOp),
        .aluSrc1(aluSrc1),
        .aluCtrOut(aluCtrOut)
    );

    // =========================
    // Register File
    // =========================
    Registers registers (
        .Clk(Clk),
        .reset(reset),
        .readReg1(inst[25:21]),
        .readReg2(inst[20:16]),
        .writeReg(writeReg),
        .writeData(writeData),
        .regWrite(regWrite),
        .readData1(readData1),
        .readData2(readData2),
        .sum(sum)
    );

    // =========================
    // ALU
    // =========================
    ALU alu (
        .input1(input1),
        .input2(input2),
        .aluCtr(aluCtrOut),
        .zero(zero),
        .aluRes(aluRes)
    );

    // =========================
    // Data Memory
    //
    // =========================
    dataMemory dataMemory_inst (
        .Clk(Clk),
//        .reset(1'b0),
        .address(aluRes),
        .writeData(readData2),
        .memWrite(memWrite),
        .memRead(memRead),
        .readData(readData)
    );

    // =========================
    // Sign / Zero Extension
    // =========================
    signext signext_inst (
        .extOp(extOp),
        .inst(inst[15:0]),
        .data(imm)
    );

    // =========================
    // Instruction Memory
    // =========================
    InstMemory instMemory (
        .Clk(Clk),
        .reset(reset),
        .address(pc),
        .inst(inst)
    );

    // =========================
    // Program Counter
    // =========================
    PC pc_reg (
        .Clk(Clk),
        .reset(reset),
        .in(newpc),
        .out(pc)
    );

    // =========================
    // Write Register MUX
    //
    // regDst = 00: rt
    // regDst = 01: rd
    // regDst = 10: $31, for jal
    // =========================
    assign writeReg = regDst[1] ? 5'd31 :
                      regDst[0] ? inst[15:11] :
                                  inst[20:16];

    // =========================
    // Write Data MUX
    //
    // jal: write PC + 4
    // lw : write memory data
    // R/I: write ALU result
    // =========================
    assign writeData = regDst[1] ? pcplus4 :
                       memToReg  ? readData :
                                   aluRes;

    // =========================
    // ALU input MUX
    //
    // aluSrc1 = 1: use shamt, for sll/srl
    // aluSrc  = 1: use immediate
    // =========================
    assign input1 = aluSrc1 ? {27'b0, inst[10:6]} : readData1;
    assign input2 = aluSrc  ? imm : readData2;

    // =========================
    // Next PC Logic
    //
    // jump = 01: j / jal
    // jump = 10: jr
    // branch && zero: beq taken
    // =========================
    assign newpc = jump[0] ? {pcplus4[31:28], inst[25:0], 2'b00} :
                   jump[1] ? readData1 :
                   (branch && zero) ? pcplus4 + (imm << 2) :
                                      pcplus4;

endmodule