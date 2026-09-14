//this module will receive
// a pair of IMOxBO
// will also contain an accumulator for IMO1xBO1 + IMO2xBO2 + ...
// so will keep the BO width as 5 for now for simplicity
// im not parameterizing it because im lazy lol
module Accumulator(
    input logic clk,
    input logic reset,
    input logic new_IMO,
    input logic [7 : 0] IMO,
    input logic [4 : 0] BO,
    output logic operate,
    output logic sign,
    output logic [31 : 0] MAC,
    output logic BO_Split
);

logic [7 : 0] RES;

typedef enum logic [2 : 0] {
    IDLE    = 3'b000,
    SPLIT   = 3'b001,
    COLLECT = 3'b010
} state_t;

reg[3 : 0] BO_counter; //to track the BO bits

state_t state_curr;

always_ff @(posedge clk) begin
    if (reset) begin
        state_curr <= IDLE;
        operate <= 1'b0;
        sign <= 1'b0;
        MAC <= 32'b0;
        BO_Split <= 1'b0;
        BO_counter <= 4'b0;
    end
    else begin
        case (state_curr)
            IDLE: begin
                if (new_IMO) begin
                    state_curr <= SPLIT;
                    operate <= 1'b1;
                    BO_counter <= 0;
                end
            end
            SPLIT: begin
                if (BO_counter >= 5) begin
                    BO_counter <= 0;
                    state_curr <= COLLECT;
                    sign <= 1'b0;
                    operate <= 1'b0;
                end
                else if (BO_counter == 4) begin
                    sign <= 1'b1;
                    BO_counter <= BO_counter + 1;
                    BO_Split <= BO[BO_counter]; 
                end
                else begin
                    BO_counter <= BO_counter + 1;
                    BO_Split <= BO[BO_counter]; 
                end
            end
            COLLECT: begin
                MAC <= MAC + RES;
                state_curr <= IDLE;
                BO_Split <= 1'b0;
            end
            default: state_curr <= IDLE;
        endcase
    end
end

compute compute_1 (
    .clk(clk),
    .reset(reset),
    .new_IMO(new_IMO),
    .operate(operate),
    .sign(sign),
    .IMO(IMO),
    .BO(BO_Split),
    .RES(RES)
);
    
endmodule