`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2026 10:24:12 AM
// Design Name: 
// Module Name: Wrapper
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


module FPGA_Wrapper(
    input wire clk_sys,
    input wire btn_step,
    input wire sw_reset,
    input wire sw_rw,
    output wire [7:0] led_out
);

    reg [19:0] debounce_counter;
    reg btn_stable;
    reg btn_prev;
    wire cpu_clk_pulse;

    always @(posedge clk_sys) begin
        debounce_counter <= debounce_counter + 1;
        
        if (debounce_counter == 0) begin
            btn_stable <= btn_step;
        end
        
        btn_prev <= btn_stable;
    end

    assign cpu_clk_pulse = (btn_stable == 1'b1 && btn_prev == 1'b0);

    Top #(
        .PC_SIZE(10), 
        .DATA_MEM_SIZE(256), 
        .ADDRESS_LINE(8)
    ) my_custom_cpu (
        .clock(cpu_clk_pulse),
        .reset(sw_reset),
        .rw(sw_rw),
        .reset_IF_memory(1'b0),
        .PC_write(10'b0),
        .instruction_in(32'b0),
        .write_reg_data(led_out)
    );

endmodule