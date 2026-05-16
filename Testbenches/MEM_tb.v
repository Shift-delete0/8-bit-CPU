`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2026 11:01:01 PM
// Design Name: 
// Module Name: MEM_tb
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


`timescale 1ns / 1ps

module tb_MEM;

    parameter ADDRESS_LINE = 8;
    parameter DATA_MEM_SIZE = 256;

    // --- Inputs to UUT ---
    reg clock;
    reg reset;
    reg reg_write_in;
    reg branch;
    reg mem_read;
    reg mem_to_reg_in;
    reg mem_write;
    reg zero;
    reg [7:0] ALU_result_in; // This acts as the memory address!
    reg [7:0] write_data;
    reg [4:0] write_register_in;

    // --- Outputs from UUT ---
    wire [4:0] write_register_out;
    wire [7:0] ALU_result_out;
    wire [7:0] read_data;
    wire mem_to_reg_out;
    wire PCScr;
    wire reg_write_out;

    // --- Instantiate the MEM Module ---
    MEM #(.ADDRESS_LINE(ADDRESS_LINE), .DATA_MEM_SIZE(DATA_MEM_SIZE)) uut (
        .clock(clock), .reset(reset),
        .reg_write_in(reg_write_in), .branch(branch),
        .mem_read(mem_read), .mem_to_reg_in(mem_to_reg_in),
        .mem_write(mem_write), .zero(zero),
        .ALU_result_in(ALU_result_in), .write_data(write_data),
        .write_register_in(write_register_in),
        
        .write_register_out(write_register_out),
        .ALU_result_out(ALU_result_out), .read_data(read_data),
        .mem_to_reg_out(mem_to_reg_out), .PCScr(PCScr),
        .reg_write_out(reg_write_out)
    );

    // --- Clock Generation ---
    always #5 clock = ~clock;

    initial begin
        // 1. Initialize Inputs Safely
        clock = 0; reset = 1;
        reg_write_in = 0; branch = 0; mem_read = 0; mem_to_reg_in = 0;
        mem_write = 0; zero = 0; ALU_result_in = 0; write_data = 0;
        write_register_in = 0;

        #25 reset = 0; // Release reset and let the initial block populate memory

        // ---------------------------------------------------------
        // TEST 1: Read Pre-loaded Data (Load Instruction)
        // ---------------------------------------------------------
        @(negedge clock);
        mem_read = 1;
        ALU_result_in = 8'd2; // Let's read address 2
        
        // Wait for the posedge to latch the read data into the pipeline register
        @(posedge clock); @(negedge clock);
        $display("--- TEST 1: Read Pre-loaded Memory ---");
        $display("Address 2 Data: %d (Expected 10)", read_data);
        $display("");
        
        mem_read = 0; // Turn off read

        // ---------------------------------------------------------
        // TEST 2: Write Data to Memory (Store Instruction)
        // ---------------------------------------------------------
        @(negedge clock);
        mem_write = 1;
        ALU_result_in = 8'd15;     // Address to write to
        write_data = 8'hFF;        // Data to write (Decimal 255)
        
        @(posedge clock); @(negedge clock);
        mem_write = 0; // Turn off write so we don't accidentally overwrite later
        $display("--- TEST 2: Write Data to Memory ---");
        $display("Data 8'hFF written to Address 15.");
        $display("");

        // ---------------------------------------------------------
        // TEST 3: Read Back the Stored Data
        // ---------------------------------------------------------
        @(negedge clock);
        mem_read = 1;
        ALU_result_in = 8'd15; // Read back from address 15
        
        @(posedge clock); @(negedge clock);
        $display("--- TEST 3: Read Back Stored Data ---");
        $display("Address 15 Data: %h (Expected ff)", read_data);
        $display("");
        
        mem_read = 0;

        // ---------------------------------------------------------
        // TEST 4: Branch Logic Testing (BEQ)
        // ---------------------------------------------------------
        @(negedge clock);
        
        // Scenario A: Branch instruction, but ALU result is NOT zero
        branch = 1;
        zero = 0;
        #1; // Micro-delay to let combinational logic settle
        $display("--- TEST 4: Branch Logic ---");
        $display("Branch=1, Zero=0 -> PCScr: %b (Expected 0)", PCScr);
        
        // Scenario B: Branch instruction, and ALU result IS zero
        branch = 1;
        zero = 1;
        #1;
        $display("Branch=1, Zero=1 -> PCScr: %b (Expected 1)", PCScr);
        $display("===========================================");

        #20 $finish;
    end
endmodule
