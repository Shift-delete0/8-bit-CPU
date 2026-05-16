
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2026 03:45:20 PM
// Design Name: 
// Module Name: Program_Counter
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

module Program_Counter #(parameter PC_SIZE=32)
(   
    input wire clock,
    input wire reset,
    input wire PC_en,          // NEW: Enable signal
    input wire [PC_SIZE-1:0] PC_in,
    output reg [PC_SIZE-1:0] PC_out
);
    always@(posedge clock) begin
        if(reset)begin
            PC_out <= 0;
        end
        else if (PC_en) begin  // NEW: Only update if enabled
            PC_out <= PC_in;
        end
    end
endmodule
