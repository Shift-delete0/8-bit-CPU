`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2026 05:56:04 PM
// Design Name: 
// Module Name: IF_ Testbench
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

module tb_IF;

    parameter PC_SIZE = 10;
    
    // Inputs
    reg clock;
    reg reset;
    reg PCScr;
    reg PC_en;          // NEW: Register to drive the enable signal
    reg rw;
    reg reset_memory;
    reg [PC_SIZE-1:0] PC_jump;
    reg [PC_SIZE-1:0] PC_write;
    reg [31:0] instruction_in;
    
    // Outputs
    wire [PC_SIZE-1:0] PC_out;
    wire [31:0] instruction_out;
    
    // Instantiate the IF module
    IF #(.PC_SIZE(PC_SIZE)) uut (
        .clock(clock),
        .reset(reset),
        .PCScr(PCScr),
        .PC_en(PC_en),  // NEW: Connect the enable signal to the UUT
        .rw(rw),
        .reset_memory(reset_memory),
        .PC_jump(PC_jump),
        .PC_write(PC_write),
        .instruction_in(instruction_in),
        .PC_out(PC_out),
        .instruction_out(instruction_out)
    );
    
    // Clock generation: 100MHz (10ns period)
    always #5 clock = ~clock; 
    
    initial begin
        // 1. Initialize Inputs
        clock = 0;
        reset = 1;          
        PCScr = 0;          
        PC_en = 0;          // NEW: Keep PC paused during reset and initialization
        rw = 1;             
        reset_memory = 1;   
        PC_jump = 0;
        PC_write = 0;
        instruction_in = 0;
        
        // Wait for global reset to propagate
        #100;
        
        // 2. Deassert Resets
        reset = 0;
        reset_memory = 0;
        
        // 3. Write Phase (rw = 0)
        // PC_en is STILL 0 here! The PC is safely parked at address 0.
        rw = 0; 
        
        PC_write = 10'd0; instruction_in = 32'hAAAA_BBBB; #10;
        PC_write = 10'd1; instruction_in = 32'h1111_2222; #10;
        PC_write = 10'd2; instruction_in = 32'h3333_4444; #10;
        PC_write = 10'd7; instruction_in = 32'hDEAD_BEEF; #10;
        
        // 4. Read & Execute Phase (rw = 1)
        rw = 1; 
        PC_en = 1; // NEW: Turn on the Program Counter! Let the execution begin.
        
        // Let the PC increment naturally through addresses 0, 1, and 2
        #40; 
        
        // 5. Jump Test (PCScr = 1)
        PCScr = 1;
        PC_jump = 10'd7;
        #10; 
        
        PCScr = 0; 
        
        // Let it run for a few more cycles
        #40;
        
        $finish;
    end
    
    // Optional: Monitor changes in the console
    initial begin
        $monitor("Time=%0t | rst=%b | rw=%b | PC_en=%b | PCScr=%b | PC_out=%d | Instr_out=%h", 
                 $time, reset, rw, PC_en, PCScr, PC_out, instruction_out);
    end

endmodule