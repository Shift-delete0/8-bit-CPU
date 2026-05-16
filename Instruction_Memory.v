`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2026 05:32:26 PM
// Design Name: 
// Module Name: Instruction_Memory
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


module Instruction_Memory #(parameter PC_SIZE=10, INSTRUCTION_LENGTH=32)
(
    input wire [PC_SIZE-1:0] read_address,
    input wire [PC_SIZE-1:0] write_address,
    input wire rw,   // rw=1 READ, rw=0 WRITE
    input wire reset_memory,
    input wire clock,
    input wire [INSTRUCTION_LENGTH-1:0] instruction_in,
    output reg [INSTRUCTION_LENGTH-1:0] instruction_out
);

    reg [INSTRUCTION_LENGTH-1:0] Memory[99:0]; // 1024 - 32bit instructions
    integer i=0;

    always@(posedge clock)begin 
         if(reset_memory)begin
            for(i=0; i<100; i=i+1)begin
                Memory[i] <= 0;
            end
            instruction_out <= 0;
        end 
        else begin
            if(rw)begin // Rread
                instruction_out <= Memory[read_address];
            end
            else begin // Write
                Memory[write_address] <= instruction_in;
                instruction_out <= 0;
            end
        end
    end
    
endmodule