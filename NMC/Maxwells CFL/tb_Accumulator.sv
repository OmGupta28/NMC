module tb_Accumulator;

     logic clk;
     logic reset;
     logic new_IMO;
     logic [7 : 0] IMO;
     logic [4 : 0] BO;
     logic new_MAC;
     logic operate;
     logic sign;
     logic [31 : 0] MAC_0;
     logic [31 : 0] MAC_1;
     logic [31 : 0] MAC_2;
     logic BO_Split;
     logic done;

    Accumulator accu_dut (.*); 

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        new_MAC = 0;
        new_IMO = 0;
        reset = 1;
        repeat(2)@(posedge clk);
        reset = 0;

        new_IMO = 1;
        IMO = 8'b0010_0110;
        @(posedge clk);
        IMO = 8'b1011_1101;
        @(posedge clk);
        IMO = 8'b1111_0000;
        BO = 5'b10011;
        repeat(2)@(posedge clk);
        new_IMO = 0;

        repeat(7)@(posedge clk);

        new_IMO = 1;
        IMO = 8'b0110_0110;
        @(posedge clk);
        IMO = 8'b1111_1110;
        @(posedge clk);
        IMO = 8'b1111_1011;
        BO = 5'b10110;
        repeat(2)@(posedge clk);
        new_IMO = 0;

        repeat(7)@(posedge clk);

        new_IMO = 1;
        new_MAC = 1;
        IMO = 8'b0110_0110;
        @(posedge clk);
        IMO = 8'b1111_1110;
        @(posedge clk);
        IMO = 8'b1111_1011;
        BO = 5'b10110;
        repeat(2)@(posedge clk);
        new_IMO = 0;
        new_MAC = 0;

        repeat(7)@(posedge clk);

        // new_IMO = 1;
        // IMO = 8'b0010_0110;
        // BO = 5'b10011;
        // @(posedge clk);
        // new_IMO = 0;

        repeat(6)@(posedge clk);

        repeat(2)@(posedge clk);
        $finish;
    end

endmodule