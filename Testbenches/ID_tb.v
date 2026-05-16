`timescale 1ns / 1ps

module tb_ID;

    parameter PC_SIZE = 10;

    // --- Inputs to UUT ---
    reg clock;
    reg reset;
    reg [PC_SIZE-1:0] PC_out_in;
    reg [31:0] instruction;
    reg [7:0] write_reg_data;
    reg reg_write_in;
    reg [4:0] write_register_in;

    // --- Outputs from UUT ---
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] write_register_out;
    wire reg_write_out;
    wire branch;
    wire mem_read;
    wire mem_to_reg;
    wire [1:0] alu_op;
    wire mem_write;
    wire alu_src;
    wire [PC_SIZE-1:0] PC_out_out;
    wire [7:0] read_data1;
    wire [7:0] read_data2;
    wire [11:0] immediate;
    wire [9:0] funct;

    // --- Instantiate the Unit Under Test (UUT) ---
    ID #(.PC_SIZE(PC_SIZE)) uut (
        .clock(clock), .reset(reset), .PC_out_in(PC_out_in),
        .instruction(instruction), .write_reg_data(write_reg_data),
        .reg_write_in(reg_write_in), .write_register_in(write_register_in),
        .rs1(rs1), .rs2(rs2), .write_register_out(write_register_out),
        .reg_write_out(reg_write_out), .branch(branch), .mem_read(mem_read),
        .mem_to_reg(mem_to_reg), .alu_op(alu_op), .mem_write(mem_write),
        .alu_src(alu_src), .PC_out_out(PC_out_out),
        .read_data1(read_data1), .read_data2(read_data2),
        .immediate(immediate), .funct(funct)
    );

    // --- Clock Generation ---
    always #5 clock = ~clock;

    initial begin
        // 1. Initialize Inputs
        clock = 0; reset = 1; PC_out_in = 0; instruction = 0;
        write_reg_data = 0; reg_write_in = 0; write_register_in = 0;

        // Wait a bit, then release reset
        #25 reset = 0;

        // ---------------------------------------------------------
        // PHASE 1: Pre-load the Register File (Paced out)
        // ---------------------------------------------------------
        
        // Write 8'h0A into Register x1
        @(negedge clock);
        reg_write_in = 1; write_register_in = 5'd1; write_reg_data = 8'h0A;

        @(negedge clock);
        reg_write_in = 0; // Stop writing, give it a cycle to breathe
        
        @(negedge clock); // Dead cycle

        // Write 8'h14 into Register x2
        @(negedge clock);
        reg_write_in = 1; write_register_in = 5'd2; write_reg_data = 8'h14;
        
        @(negedge clock);
        reg_write_in = 0;
        
        @(negedge clock); // ← ADD THIS dead cycle (matches x1's pattern)
                // ---------------------------------------------------------
        // PHASE 2: Test an R-Type Instruction (ADD x3, x1, x2)
        // ---------------------------------------------------------
        
        // Explicitly build instruction: funct7 | rs2 | rs1 | funct3 | rd | opcode
        instruction = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
        PC_out_in = 10'd4;

        // Let the pipeline clock naturally
        @(posedge clock); // ID stage samples the inputs
        @(negedge clock); // Wait for wires to settle completely
        
        $display("--- R-Type (ADD x3, x1, x2) ---");
        $display("read_data1 (x1): %h (Expected 0a)", read_data1);
        $display("read_data2 (x2): %h (Expected 14)", read_data2);
        $display("alu_op         : %b (Expected 10)", alu_op);
        $display("reg_write_out  : %b (Expected 1)", reg_write_out);
        $display("");

        // ---------------------------------------------------------
        // PHASE 3: Test a Load Instruction (LD x4, 12(x1))
        // ---------------------------------------------------------
        @(negedge clock);
        
        // Explicitly build instruction: imm(12) | rs1 | funct3 | rd | opcode
        instruction = {12'd12, 5'd1, 3'b010, 5'd4, 7'b0000011};
        PC_out_in = 10'd8;

        @(posedge clock); 
        @(negedge clock); 
        
        $display("--- Load Instruction (LD x4, 12(x1)) ---");
        $display("read_data1 (x1): %h (Expected 0a)", read_data1);
        $display("immediate      : %d (Expected 12)", immediate);
        $display("alu_src        : %b (Expected 1)", alu_src);
        $display("mem_read       : %b (Expected 1)", mem_read);

        #40 $finish;
    end
endmodule