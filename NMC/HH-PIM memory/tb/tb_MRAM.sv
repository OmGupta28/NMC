module tb_MRAM;

    logic clk;
    logic reset;
    logic write_en;
    logic read_en;
    logic [4 : 0] addr;
    logic [7 : 0] data_in_MRAM;
    logic data_written;
    logic data_ready;
    logic [7 : 0] data_out_MRAM;

    MRAM dut (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        write_en = 0;
        read_en  = 0;
        reset = 1;
        repeat(2)@(posedge clk);
        reset = 0;

        write_en = 1;
        addr = 5'd0;
        data_in_MRAM = 8'hFF;
        repeat(12)@(posedge clk);
        write_en = 0;

        repeat(2)@(posedge clk);

        write_en = 1;
        addr = 5'd1;
        data_in_MRAM = 8'hFE;
        repeat(12)@(posedge clk);
        write_en = 0;

        repeat(2)@(posedge clk);

        write_en = 1;
        addr = 5'd2;
        data_in_MRAM = 8'hFD;
        repeat(14)@(posedge clk);
        write_en = 0;

        repeat(2)@(posedge clk);

        read_en = 1;
        addr = 5'd0;
        repeat(6)@(posedge clk);
        read_en = 0;

        repeat(2)@(posedge clk);

        read_en = 1;
        addr = 5'd1;
        repeat(6)@(posedge clk);
        read_en = 0;

        repeat(2)@(posedge clk);

        read_en = 1;
        addr = 5'd2;
        repeat(6)@(posedge clk);
        read_en = 0;

        repeat(15)@(posedge clk);
        $finish;
    end

endmodule