module SRAM (
    input logic clk,
    input logic reset,
    input logic write_en,
    input logic read_en,
    input logic [4 : 0] addr,
    input logic [7 : 0] data_in_SRAM,
    output logic [7 : 0] data_out_SRAM
);
    reg [7 : 0] SRAM_MEMORY [0 : 31];

    always_ff @(posedge clk) begin
        if (reset) begin
            for (integer i = 0; i < 32; i++) begin
                SRAM_MEMORY[i] <= i + 1;
            end
            data_out_SRAM <= SRAM_MEMORY[0];
        end 
        else begin
            if (write_en) begin
                SRAM_MEMORY[addr] <= data_in_SRAM;
            end
            else if (read_en) begin
                data_out_SRAM <= SRAM_MEMORY[addr];
            end
        end
    end
endmodule