`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2026 11:06:21 PM
// Design Name: 
// Module Name: WB
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

module WB
(
    input wire [7:0] ALU_result,      // Data from the Execution stage
    input wire [7:0] read_data,       // Data from the Memory stage
    input wire mem_to_reg,            // Control signal deciding which data to keep
    output wire [7:0] wb_write_data   // The final data sent back to the Register File
);

    MUX_2to1 #(.N(8)) WriteBack_MUX (
        .D0(ALU_result),
        .D1(read_data),
        .S0(mem_to_reg),
        .Y(wb_write_data)
    );

endmodule
