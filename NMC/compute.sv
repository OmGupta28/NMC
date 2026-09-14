module compute (
    input logic clk,
    input logic reset,
    input logic new_IMO,
    input logic operate,
    input logic sign,
    input logic [7 : 0] IMO,
    input logic BO, //broadcast operand is of a single bit (full number is available at the top)
    //but it is supplied bit by bit to the NMCs
    output logic [7 : 0] RES
);

reg signed [8 : 0] partial_RES;
assign RES = partial_RES[8 : 1];

always_ff @(posedge clk) begin
    if (reset) begin
        partial_RES <= 8'b0;
    end
    else if (new_IMO) begin
        partial_RES <= 8'b0;
    end
    else if (operate) begin
        if (sign) begin
            partial_RES <= (partial_RES >>> 1) + (IMO ^ 9'hFFF) + 1;
        end
        else if(BO == 1) begin
            partial_RES <= (partial_RES >>> 1) + IMO;
        end
        else if (BO == 0) begin
            partial_RES <= partial_RES >>> 1;
        end
    end
end

endmodule