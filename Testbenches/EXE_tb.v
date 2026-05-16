`timescale 1ns / 1ps

module tb_EXE;

    parameter PC_SIZE = 10;

    // --- Inputs to UUT ---
    reg clock;
    reg reset;
    reg [PC_SIZE-1:0] PC_out;
    reg [7:0] data1;
    reg [7:0] data2;
    reg [11:0] immediate;
    reg [9:0] funct; 
    reg [1:0] alu_op;
    reg alu_src;
    reg branch_in;
    reg mem_read_in;
    reg mem_to_reg_in;
    reg mem_write_in;
    reg reg_write_in;
    reg [1:0] fwd_A;
    reg [1:0] fwd_B;
    reg [4:0] write_register_in;
    reg [7:0] wb_write_data;
    reg [7:0] ex_mem_alu_result;

    // --- Outputs from UUT ---
    wire [4:0] write_register_out;
    wire [PC_SIZE-1:0] PC_jump;
    wire zero;
    wire [7:0] ALU_result;
    wire branch_out;
    wire mem_read_out;
    wire mem_to_reg_out;
    wire mem_write_out;
    wire [7:0] write_data;
    wire reg_write_out;

    // --- Instantiate the EXE Module ---
    EXE #(.PC_SIZE(PC_SIZE)) uut (
        .clock(clock), .reset(reset), .PC_out(PC_out),
        .data1(data1), .data2(data2), .immediate(immediate),
        .funct(funct), .alu_op(alu_op), .alu_src(alu_src),
        .branch_in(branch_in), .mem_read_in(mem_read_in),
        .mem_to_reg_in(mem_to_reg_in), .mem_write_in(mem_write_in),
        .reg_write_in(reg_write_in), .fwd_A(fwd_A), .fwd_B(fwd_B),
        .write_register_in(write_register_in), .wb_write_data(wb_write_data),
        .ex_mem_alu_result(ex_mem_alu_result), .write_register_out(write_register_out),
        .PC_jump(PC_jump), .zero(zero), .ALU_result(ALU_result),
        .branch_out(branch_out), .mem_read_out(mem_read_out),
        .mem_to_reg_out(mem_to_reg_out), .mem_write_out(mem_write_out),
        .write_data(write_data), .reg_write_out(reg_write_out)
    );

    // --- Clock Generation ---
    always #5 clock = ~clock;

    initial begin
        // 1. Initialize Inputs Safely
        clock = 0; reset = 1; PC_out = 0; data1 = 0; data2 = 0;
        immediate = 0; funct = 0; alu_op = 0; alu_src = 0;
        branch_in = 0; mem_read_in = 0; mem_to_reg_in = 0;
        mem_write_in = 0; reg_write_in = 0; fwd_A = 0; fwd_B = 0;
        write_register_in = 0; wb_write_data = 0; ex_mem_alu_result = 0;

        #25 reset = 0; // Release reset

        // ---------------------------------------------------------
        // TEST 1: Normal R-Type ADD (No Forwarding)
        // ---------------------------------------------------------
        @(negedge clock);
        alu_op = 2'b10;                 // R-Type
        funct = 10'b00_0000_0000;       // ADD mapping from your ALU_Control
        alu_src = 0;                    // Use data2
        fwd_A = 2'b00;                  // ID/EX normal path
        fwd_B = 2'b00;                  // ID/EX normal path
        data1 = 8'd10;
        data2 = 8'd20;

        @(posedge clock); @(negedge clock);
        $display("--- TEST 1: R-Type ADD (No Forwarding) ---");
        $display("ALU Result: %d (Expected 30)", ALU_result);
        $display("");

        // ---------------------------------------------------------
        // TEST 2: I-Type / Load Address Calc (Using Immediate)
        // ---------------------------------------------------------
        @(negedge clock);
        alu_op = 2'b00;                 // I-Type forces ADD
        funct = 10'b0;                  // Ignored
        alu_src = 1;                    // KEY: Use immediate!
        fwd_A = 2'b00;
        fwd_B = 2'b00;
        data1 = 8'd50;                  // Base address
        immediate = 12'd15;             // Offset

        @(posedge clock); @(negedge clock);
        $display("--- TEST 2: I-Type / Load Address (Using Immediate) ---");
        $display("ALU Result: %d (Expected 65)", ALU_result);
        $display("");

        // ---------------------------------------------------------
        // TEST 3: Forwarding A from EX/MEM stage (Data Hazard)
        // ---------------------------------------------------------
        @(negedge clock);
        alu_op = 2'b10;
        funct = 10'b00_0000_0000;       // ADD
        alu_src = 0;
        fwd_A = 2'b10;                  // KEY: Forward from EX/MEM
        fwd_B = 2'b00;
        data1 = 8'd99;                  // STALE DATA: Should be ignored!
        data2 = 8'd5;
        ex_mem_alu_result = 8'd100;     // FORWARDED DATA: Should be used!

        @(posedge clock); @(negedge clock);
        $display("--- TEST 3: Forwarding A (EX/MEM Hazard) ---");
        $display("ALU Result: %d (Expected 105 - 100+5)", ALU_result);
        $display("");

        // ---------------------------------------------------------
        // TEST 4: Forwarding B from MEM/WB stage (Data Hazard)
        // ---------------------------------------------------------
        @(negedge clock);
        alu_op = 2'b10;
        funct = 10'b01_0000_0000;       // SUBTRACT mapping
        alu_src = 0;
        fwd_A = 2'b00;                  
        fwd_B = 2'b01;                  // KEY: Forward from MEM/WB
        data1 = 8'd50;                  
        data2 = 8'd99;                  // STALE DATA: Should be ignored!
        wb_write_data = 8'd10;          // FORWARDED DATA: Should be used!

        @(posedge clock); @(negedge clock);
        $display("--- TEST 4: Forwarding B (MEM/WB Hazard) ---");
        $display("ALU Result: %d (Expected 40 - 50-10)", ALU_result);
        $display("");

        // ---------------------------------------------------------
        // TEST 5: Branch Target Calculation
        // ---------------------------------------------------------
        @(negedge clock);
        PC_out = 10'd200;               // Current PC
        immediate = 12'd16;             // Branch offset

        @(posedge clock); @(negedge clock);
        $display("--- TEST 5: Branch Target Adder ---");
        $display("PC Jump Target: %d (Expected 216)", PC_jump);
        $display("==========================================");

        #20 $finish;
    end
endmodule