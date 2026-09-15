module MRAM (
    input logic clk,
    input logic reset,
    input logic write_en,
    input logic read_en,
    input logic [4 : 0] addr,
    input logic [7 : 0] data_in_MRAM,
    output logic [7 : 0] data_out_MRAM
);

reg [7 : 0] MRAM_MEMORY [0 : 31];

//ill simulate read and write delays
//like 2-3x for read and 10x for write
reg [1 : 0] read_counter;
reg [3 : 0] write_counter; 

localparam read_delay = 2'd3;
localparam write_delay = 4'd10;

always_ff @(posedge clk) begin
    if (reset) begin
        for (integer i = 0; i < 32; i++) begin
            MRAM_MEMORY[i] <= 8'b0;
        end
        data_out_MRAM <= 8'b0;
        read_counter <= 2'b0;
        write_counter <= 4'b0; 
    end
    else begin
        if (write_en) begin
            if (write_counter == write_delay) begin
                MRAM_MEMORY[addr] <= data_in_MRAM;
                write_counter <= 4'b0;
            end
            else begin
                write_counter <= write_counter + 1;
            end
        end
        else if (read_en) begin
            if (read_counter == read_delay) begin
                data_out_MRAM <= MRAM_MEMORY[addr];
                read_counter <= 2'b0;
            end
            else begin
                read_counter <= read_counter + 1;
            end
        end
    end
end
    
endmodule