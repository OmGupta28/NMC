module MRAM (
    input logic clk,
    input logic reset,
    input logic write_en,
    input logic read_en,
    input logic [4 : 0] addr,
    input logic [7 : 0] data_in_MRAM,
    output logic data_written,
    output logic data_ready,
    output logic [7 : 0] data_out_MRAM
);

reg [7 : 0] MRAM_MEMORY [0 : 31];

//ill simulate read and write delays
//like 2-3x for read and 10x for write
reg [1 : 0] read_counter;
reg [3 : 0] write_counter; 

localparam read_delay = 2'd3;
localparam write_delay = 4'd10;

// i can only start the read_counter when read_en is high, after that, whenever the counter finishes, the data_out is ready 
//irrespective of read_en
//but this is very sensetive, what if the number of cycles required for read is different? 
//then this would break
always_ff @(posedge clk) begin
    if (reset) begin
        for (integer i = 0; i < 32; i++) begin
            MRAM_MEMORY[i] <= 5'h10 + i;
        end
        data_ready <= 1'b0;
        data_written <= 1'b0;
        data_out_MRAM <= MRAM_MEMORY[0];
        read_counter <= 2'b0;
        write_counter <= 4'b0; 
    end
    else begin
        if (write_en) begin
            if (write_counter == write_delay) begin
                MRAM_MEMORY[addr] <= data_in_MRAM;
                write_counter <= 4'b0;
                data_written <= 1'b1;
            end
            else begin
                data_written <= 1'b0;
                write_counter <= write_counter + 1;
            end
            //at least 1 cycle is required for write and read_en to go back to 0
            if (data_written) begin
                write_counter <= 4'b0;
            end
        end
        else if (read_en) begin
            if (read_counter == read_delay) begin
                // data_out_MRAM <= MRAM_MEMORY[addr];
                read_counter <= 2'b0;
                data_ready <= 1'b1;
            end
            else begin
                read_counter <= read_counter + 1;
                data_ready <= 1'b0;
            end
            if (data_ready) begin
                read_counter <= 2'b0;
            end
        end
        if (read_counter == read_delay) begin
            data_out_MRAM <= MRAM_MEMORY[addr];
        end
        if (!read_en) begin
            read_counter <= 2'b0;
        end
        if (!write_en) begin
            write_counter <= 4'b0;
        end
    end
end
    
endmodule