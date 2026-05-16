
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2026 10:19:01 PM
// Design Name: 
// Module Name: MUX_2x1
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


module MUX_2to1 #(parameter N=32)
(
    input wire [N-1:0] D0,
    input wire [N-1:0] D1,
    input wire S0,
    output wire [N-1:0] Y
);

    // N-Bit MUX

    assign Y = (S0)? D1 : D0;

endmodule