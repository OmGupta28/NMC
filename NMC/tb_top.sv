module tb_top;

     logic clk;
     logic reset;
     logic write_en_MRAM;
     logic write_en_SRAM;
     logic[7 : 0] data_in_MRAM;
     logic[7 : 0] data_in_SRAM;
     logic data_written_MRAM;
     logic [31 : 0] MAC_0;
     logic [31 : 0] MAC_1;
     logic [31 : 0] MAC_2;

    top_MRAM_SRAM top_dut (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        write_en_MRAM = 0;
        write_en_SRAM = 0;
        data_in_MRAM = 0;
        data_in_SRAM = 0;
        reset = 1;
        repeat(4)@(posedge clk);
        reset = 0;

        repeat(60)@(posedge clk);
        $finish;
    end

endmodule