module tb_compute;

     logic clk;
     logic reset;
     logic new_IMO;
     logic operate;
     logic sign;
     logic [7 : 0] IMO;
     logic BO;
   logic [7 : 0] RES;

   compute dut (.*);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

    initial begin
        BO = 0;
        new_IMO = 0;
        operate = 0;
        sign = 0;
        reset = 1;
        repeat(2)@(posedge clk);
        reset = 0;

        new_IMO = 1;
        IMO = 8'b0010_0110;
        @(posedge clk);
        new_IMO = 0;
        operate = 1;

        BO = 1;
        @(posedge clk);
        BO = 1;
        @(posedge clk);
        BO = 0;
        @(posedge clk);
        BO = 0;
        @(posedge clk);
        BO = 1;
        sign = 1;
        @(posedge clk);
        sign = 0;
        operate = 0;

        $finish;

    end

endmodule