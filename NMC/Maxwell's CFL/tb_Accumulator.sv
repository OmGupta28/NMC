module tb_Accumulator;

     logic clk;
     logic reset;
     logic new_IMO;
     logic [7 : 0] IMO;
     logic [4 : 0] BO;
     logic operate;
     logic sign;
     logic [31 : 0] MAC;
     logic BO_Split;

    Accumulator accu_dut (.*); 

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        new_IMO = 0;
        reset = 1;
        repeat(2)@(posedge clk);
        reset = 0;

        new_IMO = 1;
        IMO = 8'b0010_0110;
        BO = 5'b10011;
        @(posedge clk);
        new_IMO = 0;

        repeat(7)@(posedge clk);

        new_IMO = 1;
        IMO = 8'b0010_0110;
        BO = 5'b10011;
        @(posedge clk);
        new_IMO = 0;

        repeat(6)@(posedge clk);

        repeat(2)@(posedge clk);
        $finish;
    end

endmodule