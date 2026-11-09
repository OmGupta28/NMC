module tb_SRAM;

    logic clk;
    logic reset;
    logic write_en;
    logic read_en;
    logic [4 : 0] addr;
    logic [7 : 0] data_in_SRAM;
    logic [7 : 0] data_out_SRAM;

    SRAM dut (.*);

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
        data_in_SRAM = 8'hFF;
        repeat(2)@(posedge clk);
        write_en = 0;

        repeat(2)@(posedge clk);

        write_en = 1;
        addr = 5'd1;
        data_in_SRAM = 8'hFE;
        repeat(2)@(posedge clk);
        write_en = 0;

        repeat(2)@(posedge clk);

        write_en = 1;
        addr = 5'd2;
        data_in_SRAM = 8'hFD;
        repeat(2)@(posedge clk);
        write_en = 0;

        repeat(2)@(posedge clk);

        read_en = 1;
        addr = 5'd0;
        repeat(2)@(posedge clk);
        read_en = 0;

        repeat(2)@(posedge clk);

        read_en = 1;
        addr = 5'd1;
        repeat(2)@(posedge clk);
        read_en = 0;

        repeat(2)@(posedge clk);

        read_en = 1;
        addr = 5'd2;
        repeat(2)@(posedge clk);
        read_en = 0;

        repeat(5)@(posedge clk);
        $finish;
    end


endmodule