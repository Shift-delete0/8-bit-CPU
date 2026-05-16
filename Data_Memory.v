`timescale 1ns / 1ps

module Data_Memory #(parameter ADDRESS_LINE=8, parameter MEM_SIZE=256)
(
    input wire clock,
    input wire reset,
    input wire [7:0] write_data,
    input wire [ADDRESS_LINE-1:0] address,
    input wire mem_write,
    input wire mem_read,
    output wire [7:0] read_data,
    output wire [7:0] probe_mem_10  // Keeping your LED probe!
);

    // The Memory Array
    reg [7:0] memory[MEM_SIZE-1:0];
    
    // Hardwire the probe directly to address 10
    assign probe_mem_10 = memory[10]; 
    
    // --- INITIALIZATION ---
    // Load data from the external file during simulation/synthesis
    initial begin
        // $readmemh reads hexadecimal values. 
        // If you want to use binary, you would use $readmemb instead.
        $readmemh("data_init.mem", memory);
    end

    // --- WRITE LOGIC ---
    always @(posedge clock) begin
        if (mem_write) begin
            memory[address] <= write_data;
        end
    end

    // --- READ LOGIC ---
    assign read_data = (mem_read) ? memory[address] : 8'h00;

endmodule