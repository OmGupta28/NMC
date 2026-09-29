module top_MRAM_SRAM (
    input logic clk,
    input logic reset,
    input logic write_en_MRAM,
    input logic write_en_SRAM,
    input logic[7 : 0] data_in_MRAM,
    input logic[7 : 0] data_in_SRAM,
    output logic data_written_MRAM,
    output logic [31 : 0] MAC_0,
    output logic [31 : 0] MAC_1,
    output logic [31 : 0] MAC_2
);

//increment from 0
logic [4 : 0] addr_MRAM;
logic [4 : 0] addr_SRAM;

//accumulator signals
logic done;
logic ready;
logic new_MAC;
// logic new_IMO;
logic [4 : 0] BO;
logic [7 : 0] IMO;

//MRAM signals
logic data_ready_MRAM;

//i might need a few counters and flags to correctly synvhronize reads and writes
//for now, exactly after 2 MACs, ill give a new_MAC
logic [1 : 0] new_MAC_Counter;


//i cannot drive read_en based on readu from the accumulator directly, once i have given a read, the only once it should activate
//ill see tomorrow
always_ff @(posedge clk) begin
    if (reset) begin
        new_MAC_Counter <= 2'b0;
        addr_MRAM <= 5'd0;
        addr_SRAM <= 5'd1;
        new_MAC <= 1'b0;
        // new_IMO <= 1'b0;
    end
    else begin
        if (ready) begin
            addr_SRAM <= addr_SRAM + 1;
            // new_IMO <= 1'b1;
            if (new_MAC_Counter == 2'b10) begin
                new_MAC <= 1'b1;
                new_MAC_Counter <= 2'b00;
            end
            else if (done) begin
                new_MAC <= 1'b0;
                new_MAC_Counter <= new_MAC_Counter + 1;
            end
            else begin
                new_MAC <= 1'b0;
            end
            if (done) begin
                addr_MRAM <= addr_MRAM + 1;
            end
        end
    end
end


MRAM mram_dut (
    .clk(clk),
    .reset(reset),
    .write_en(write_en_MRAM),
    .read_en(ready),
    .addr(addr_MRAM),
    .data_in_MRAM(data_in_MRAM),
    .data_written(data_written_MRAM),
    .data_ready(data_ready_MRAM),
    .data_out_MRAM(BO)
);

SRAM sram_dut (
    .clk(clk),
    .reset(reset),
    .write_en(write_en_SRAM),
    .read_en(ready),
    .addr(addr_SRAM),
    .data_in_SRAM(data_in_SRAM),
    .data_out_SRAM(IMO)
);

Accumulator accumulator_dut (
    .clk(clk),
    .reset(reset),
    .IMO(IMO),
    .BO(BO),
    .new_MAC(new_MAC),
    // .new_IMO(new_IMO),
    .MAC_0(MAC_0),
    .MAC_1(MAC_1),
    .MAC_2(MAC_2),
    .done(done),
    .ready(ready)
);
    
endmodule