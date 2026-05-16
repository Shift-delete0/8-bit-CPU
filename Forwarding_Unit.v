`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2026 11:09:41 PM
// Design Name: 
// Module Name: Forwarding_Unit
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


module Forwarding_Unit (
    input wire [4:0] reg_RS1,
    input wire [4:0] reg_RS2,
    input wire [4:0] ex_mem_reg_RD,
    input wire [4:0] mem_wb_reg_RD,
    input wire ex_mem_regwrite,
    input wire mem_wb_regwrite,
    output reg [1:0] fwd_A,
    output reg [1:0] fwd_B
);

    always @(*) begin
        // Default to no forwarding
        fwd_A = 2'b00;
        fwd_B = 2'b00;

        // ----------------------------------------------------
        // FORWARD A LOGIC (Source 1)
        // ----------------------------------------------------
        // 1. EX Hazard (Highest Priority)
        if (ex_mem_regwrite && (ex_mem_reg_RD != 0) && (ex_mem_reg_RD == reg_RS1)) begin
            fwd_A = 2'b10;
        end 
        // 2. MEM Hazard (Only if EX hazard doesn't exist)
        else if (mem_wb_regwrite && (mem_wb_reg_RD != 0) && (mem_wb_reg_RD == reg_RS1)) begin
            fwd_A = 2'b01;
        end

        // ----------------------------------------------------
        // FORWARD B LOGIC (Source 2)
        // ----------------------------------------------------
        // 1. EX Hazard (Highest Priority)
        if (ex_mem_regwrite && (ex_mem_reg_RD != 0) && (ex_mem_reg_RD == reg_RS2)) begin
            fwd_B = 2'b10;
        end 
        // 2. MEM Hazard (Only if EX hazard doesn't exist)
        else if (mem_wb_regwrite && (mem_wb_reg_RD != 0) && (mem_wb_reg_RD == reg_RS2)) begin
            fwd_B = 2'b01;
        end
    end

endmodule