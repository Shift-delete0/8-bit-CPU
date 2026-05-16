`timescale 1ns / 1ps

module tb_Top;

    parameter PC_SIZE = 10;
    parameter DATA_MEM_SIZE = 256;
    parameter ADDRESS_LINE = 8;

    // --- Inputs to CPU ---
    reg clock;
    reg reset;
    reg rw; // 0 = Bootload Mode (Pause PC), 1 = Run Mode
    reg reset_IF_memory;
    reg [PC_SIZE-1:0] PC_write;
    reg [31:0] instruction_in;

    // --- Outputs from CPU ---
    wire [7:0] write_reg_data;

    // --- Instantiate the Top-Level CPU ---
    Top #(
        .PC_SIZE(PC_SIZE), 
        .DATA_MEM_SIZE(DATA_MEM_SIZE), 
        .ADDRESS_LINE(ADDRESS_LINE)
    ) uut (
        .clock(clock),
        .reset(reset),
        .rw(rw),
        .reset_IF_memory(reset_IF_memory),
        .PC_write(PC_write),
        .instruction_in(instruction_in),
        .write_reg_data(write_reg_data)
    );

    // --- Clock Generation (10ns period) ---
    always #5 clock = ~clock;

    // --- Bootloader Task ---
    task load_instruction(input [PC_SIZE-1:0] addr, input [31:0] inst);
        begin
            @(negedge clock);
            PC_write = addr;
            instruction_in = inst;
        end
    endtask

    initial begin
        // 1. Initialize System & Trigger Resets
        clock = 0;
        rw = 0; // START IN WRITE MODE (PC is frozen)
        PC_write = 0;
        instruction_in = 0;
        
        // Assert resets to clear all pipeline registers and memory
        reset = 1;
        reset_IF_memory = 1;
        #25;
        reset = 0;
        reset_IF_memory = 0;

        $display("--- BOOTLOADING BULLETPROOF COUNTDOWN ---");

        $display("--- BOOTLOADING FIBONACCI GENERATOR ---");

        // Initialization
        load_instruction(10'd0,  32'h0000_2083); // ld x1, 0(x0)
        load_instruction(10'd1,  32'h0010_2103); // ld x2, 1(x0)
        load_instruction(10'd2,  32'h0000_0033); // NOP
        
        // --- LOOP START ---
        load_instruction(10'd3,  32'h0000_0033); // NOP (Landing Pad)
        
        // Math & Store
        load_instruction(10'd4,  32'h0020_81B3); // add x3, x1, x2
        load_instruction(10'd5,  32'h0030_2523); // sd x3, 10(x0)
        
        // Shift Registers
        load_instruction(10'd6,  32'h0020_00B3); // add x1, x0, x2
        load_instruction(10'd7,  32'h0030_0133); // add x2, x0, x3
        
        // Loop backward
        load_instruction(10'd8,  32'hFE00_0DE3); // beq x0, x0, -6 (Jump back to Landing Pad)
        
        // Branch Delay Slots
        load_instruction(10'd9,  32'h0000_0033); // NOP
        load_instruction(10'd10, 32'h0000_0033); // NOP
        load_instruction(10'd11, 32'h0000_0033); // NOP 
        
        $display("--- EXECUTING PROGRAM ---");
        
        // 3. Unleash the CPU!
        rw = 1;

        // 4. Let the pipeline run
        // 250 clock cycles will ensure it has enough time to loop 5 times through all the NOPs
        repeat(250) @(posedge clock);

        $display("--- SIMULATION COMPLETE ---");
        $finish;
    end

endmodule