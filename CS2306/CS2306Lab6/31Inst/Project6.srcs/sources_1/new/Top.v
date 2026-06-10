`timescale 1ns / 1ps

module Top (
    input         Reset,
    input         Clk
);

    // ---- Program Counter ----
    reg  [31:0] PC;
    wire [31:0] PC_plus4;
    wire [31:0] next_PC;
    wire [31:0] updated_PC;
    wire        Flush;
    wire        Stall;

    assign PC_plus4 = PC + 4;
    assign next_PC = Reset ? 32'b0 :
        (IF_instr[31:27] == 5'b00001 ? {PC_plus4[31:28], IF_instr[25:0], 2'b00} :
                                        PC_plus4);

    // ---- Forwarding mux outputs ----
    wire [1:0]  Forward_id_rs;
    wire [1:0]  Forward_id_rt;
    wire [31:0] ID_reg_data_1_fwd;
    wire [31:0] ID_reg_data_2_fwd;
    wire [31:0] MEM_alu_result;
    wire [31:0] WB_writeback_data;
    wire [31:0] EX_alu_result;

    // ---- Control signals ----
    wire       ID_reg_dst, ID_alu_src, ID_mem_to_reg;
    wire       ID_reg_write, ID_mem_read, ID_mem_write;
    wire       ID_branch, ID_jump, ID_jr;
    wire       ID_sign_ext, ID_jump_load;
    wire [2:0] ID_alu_op;

    wire       EX_alu_src, EX_mem_to_reg, EX_reg_write;
    wire       EX_mem_read, EX_mem_write, EX_branch;
    wire       EX_jump_load;
    wire [2:0] EX_alu_op;

    wire       MEM_mem_to_reg, MEM_mem_read, MEM_mem_write;
    wire       MEM_reg_write, WB_reg_write;
    wire [4:0] MEM_reg_dst, WB_reg_dst;

    // ---- Data paths ----
    wire [31:0] IF_instr;
    wire [31:0] ID_instr, ID_pc;
    wire [31:0] ID_reg_data_1, ID_reg_data_2;
    wire [31:0] ID_signext, ID_zeroext;
    wire [31:0] EX_pc, EX_reg_data_1, EX_reg_data_2, EX_imm_ext;
    wire [10:0] EX_shamt_funct;
    wire [4:0]  EX_reg_dst, EX_rs, EX_rt;
    wire [31:0] MEM_fwd_data, MEM_read_data;
    wire [31:0] EX_result;

    // ---- Branch / Jump logic ----
    wire        branch_taken;
    wire [31:0] branch_target;
    wire [31:0] jr_target;

    assign ID_reg_data_1_fwd = (Forward_id_rs == 2'b11) ? EX_alu_result :
                               (Forward_id_rs == 2'b10) ? MEM_alu_result :
                               (Forward_id_rs == 2'b01) ? WB_writeback_data :
                                                          ID_reg_data_1;

    assign ID_reg_data_2_fwd = (Forward_id_rt == 2'b11) ? EX_alu_result :
                               (Forward_id_rt == 2'b10) ? MEM_alu_result :
                               (Forward_id_rt == 2'b01) ? WB_writeback_data :
                                                          ID_reg_data_2;

    assign branch_taken  = ((ID_instr[31:26] == 6'b000100) & (ID_reg_data_1_fwd == ID_reg_data_2_fwd)) |
                           ((ID_instr[31:26] == 6'b000101) & (ID_reg_data_1_fwd != ID_reg_data_2_fwd));
    assign branch_target = ID_pc + (ID_signext << 2);
    assign jr_target     = ID_reg_data_1;
    assign updated_PC    = ID_jr        ? jr_target :
                           branch_taken ? branch_target :
                                          PC_plus4;
    assign Flush = branch_taken || ID_jr;

    always @(posedge Clk) begin
        if (Reset)      PC <= 32'b0;
        else if (Stall) PC <= PC;
        else if (Flush) PC <= updated_PC;
        else            PC <= next_PC;
    end

    // ==================== Pipeline Instances ====================

    instruction_memory u_instr_mem (
        .instr (IF_instr),
        .addr  (PC),
        .reset (Reset),
        .clock (Clk)
    );

    if_id u_if_id (
        .id_instr (ID_instr),
        .id_pc    (ID_pc),
        .if_instr (IF_instr),
        .if_pc    (PC_plus4),
        .flush    (Flush),
        .stall    (Stall),
        .clock    (Clk)
    );

    control_unit u_ctrl (
        .jump       (ID_jump),
        .jr         (ID_jr),
        .reg_dst    (ID_reg_dst),
        .alu_src    (ID_alu_src),
        .alu_op     (ID_alu_op),
        .branch     (ID_branch),
        .mem_read   (ID_mem_read),
        .mem_write  (ID_mem_write),
        .mem_to_reg (ID_mem_to_reg),
        .reg_write  (ID_reg_write),
        .sign_ext   (ID_sign_ext),
        .jump_load  (ID_jump_load),
        .funct      (ID_instr[5:0]),
        .op_code    (ID_instr[31:26])
    );

    registers u_reg_file (
        .rd_data_1 (ID_reg_data_1),
        .rd_data_2 (ID_reg_data_2),
        .wr_data   (WB_writeback_data),
        .rd_reg_1  (ID_instr[25:21]),
        .rd_reg_2  (ID_instr[20:16]),
        .wr_reg    (WB_reg_dst),
        .wr_en     (WB_reg_write),
        .reset     (Reset),
        .clock     (Clk)
    );

    sign_extend u_sign_ext (
        .data_32 (ID_signext),
        .data_16 (ID_instr[15:0])
    );

    zero_extend u_zero_ext (
        .data_32 (ID_zeroext),
        .data_16 (ID_instr[15:0])
    );

    id_ex u_id_ex (
        .alu_src_1      (EX_reg_data_1),
        .alu_src_2      (EX_reg_data_2),
        .after_ext      (EX_imm_ext),
        .ex_pc          (EX_pc),
        .ex_shamt_funct (EX_shamt_funct),
        .reg_dst        (EX_reg_dst),
        .ex_rs          (EX_rs),
        .ex_rt          (EX_rt),
        .ex_alu_op      (EX_alu_op),
        .ex_alu_src     (EX_alu_src),
        .ex_mem_to_reg  (EX_mem_to_reg),
        .ex_reg_write   (EX_reg_write),
        .ex_mem_read    (EX_mem_read),
        .ex_mem_write   (EX_mem_write),
        .ex_branch      (EX_branch),
        .ex_jump_load   (EX_jump_load),
        .reg_data_1     (ID_reg_data_1),
        .reg_data_2     (ID_reg_data_2),
        .after_sign_ext (ID_signext),
        .after_zero_ext (ID_zeroext),
        .id_pc          (ID_pc),
        .id_shamt_funct (ID_instr[10:0]),
        .reg_dst_opt    (ID_instr[20:11]),
        .id_rs          (ID_instr[25:21]),
        .id_rt          (ID_instr[20:16]),
        .id_alu_op      (ID_alu_op),
        .id_sign_ext    (ID_sign_ext),
        .id_reg_dst     (ID_reg_dst),
        .id_alu_src     (ID_alu_src),
        .id_mem_to_reg  (ID_mem_to_reg),
        .id_reg_write   (ID_reg_write),
        .id_mem_read    (ID_mem_read),
        .id_mem_write   (ID_mem_write),
        .id_branch      (ID_branch),
        .id_jump_load   (ID_jump_load),
        .stall          (Stall),
        .clock          (Clk)
    );

    wire [3:0] EX_alu_ctrl;

    alu_control_unit u_alu_ctrl (
        .alu_ctr_out (EX_alu_ctrl),
        .alu_op      (EX_alu_op),
        .funct       (EX_shamt_funct[5:0])
    );

    wire [1:0] ForwardA;
    wire [1:0] ForwardB;

    forwarding u_forwarding (
        .forwardA      (ForwardA),
        .forwardB      (ForwardB),
        .forward_id_rs (Forward_id_rs),
        .forward_id_rt (Forward_id_rt),
        .ex_rs         (EX_rs),
        .ex_rt         (EX_rt),
        .ex_reg_dst    (EX_reg_dst),
        .ex_reg_write  (EX_reg_write),
        .id_rs         (ID_instr[25:21]),
        .id_rt         (ID_instr[20:16]),
        .id_alu_src    (ID_alu_src),
        .mem_reg_dst   (MEM_reg_dst),
        .mem_reg_write (MEM_reg_write),
        .wb_reg_dst    (WB_reg_dst),
        .wb_reg_write  (WB_reg_write)
    );

    hazard_detection_unit u_hazard (
        .stall       (Stall),
        .id_rs       (ID_instr[25:21]),
        .id_rt       (ID_instr[20:16]),
        .ex_rt       (EX_rt),
        .ex_mem_read (EX_mem_read),
        .id_alu_src  (ID_alu_src)
    );

    // ---- EX forwarding muxes ----
    wire [31:0] EX_fwd_mux_a;
    wire [31:0] EX_fwd_mux_b;
    wire [31:0] EX_alu_src_b;
    wire        EX_zero;

    assign EX_alu_src_b = EX_alu_src ? EX_imm_ext : EX_reg_data_2;
    assign EX_fwd_mux_a = (ForwardA == 2'b10) ? MEM_alu_result :
                           (ForwardA == 2'b01) ? WB_writeback_data :
                                                 EX_reg_data_1;
    assign EX_fwd_mux_b = (ForwardB == 2'b10) ? (MEM_mem_to_reg ? MEM_read_data : MEM_alu_result) :
                           (ForwardB == 2'b01) ? WB_writeback_data :
                                                 EX_alu_src_b;

    alu u_alu (
        .alu_result (EX_alu_result),
        .zero       (EX_zero),
        .alu_ctr    (EX_alu_ctrl),
        .reg_1      (EX_fwd_mux_a),
        .reg_2      (EX_fwd_mux_b),
        .shamt      (EX_shamt_funct[10:6])
    );

    assign EX_result = EX_jump_load ? EX_pc : EX_alu_result;

    ex_mem u_ex_mem (
        .alu_output     (MEM_alu_result),
        .mem_cont       (MEM_fwd_data),
        .mem_reg_dst    (MEM_reg_dst),
        .mem_mem_to_reg (MEM_mem_to_reg),
        .mem_reg_write  (MEM_reg_write),
        .mem_mem_read   (MEM_mem_read),
        .mem_mem_write  (MEM_mem_write),
        .alu_rst        (EX_result),
        .ex_cont        (EX_reg_data_2),
        .ex_reg_dst     (EX_reg_dst),
        .ex_mem_to_reg  (EX_mem_to_reg),
        .ex_reg_write   (EX_reg_write),
        .ex_mem_read    (EX_mem_read),
        .ex_mem_write   (EX_mem_write),
        .clock          (Clk)
    );

    data_memory u_data_mem (
        .rd_data (MEM_read_data),
        .mem_rd  (MEM_mem_read),
        .mem_wr  (MEM_mem_write),
        .wr_data (MEM_fwd_data),
        .addr    (MEM_alu_result),
        .clock   (Clk)
    );

    mem_wb u_mem_wb (
        .wb_data        (WB_writeback_data),
        .wb_reg_dst     (WB_reg_dst),
        .wb_reg_write   (WB_reg_write),
        .mem_data       (MEM_read_data),
        .alu_output     (MEM_alu_result),
        .mem_reg_dst    (MEM_reg_dst),
        .mem_mem_to_reg (MEM_mem_to_reg),
        .mem_reg_write  (MEM_reg_write),
        .clock          (Clk)
    );

endmodule
