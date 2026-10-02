//this module will receive
// a pair of IMOxBO
// will also contain an accumulator for IMO1xBO1 + IMO2xBO2 + ...
// so will keep the BO width as 5 for now for simplicity
//ill instantiate multiple compute cores with separate resultant MAC registers
//a new IMO will come every cycle when we begin a new computation
//how can i change BO width would definately be a question
module Accumulator(
    input logic clk,
    input logic reset,
    input logic [7 : 0] IMO,
    input logic [4 : 0] BO,
    input logic new_MAC,
    output logic [31 : 0] MAC_0,
    output logic [31 : 0] MAC_1,
    output logic [31 : 0] MAC_2,
    output logic done,
    output logic ready
);


logic [7 : 0] RES_0;
logic [7 : 0] RES_1;
logic [7 : 0] RES_2;
logic operate;
logic sign;
logic BO_Split;
logic new_IMO;

logic[3 : 0] imo_collection_cycles;
logic[3 : 0] computing_cycles;
logic[3 : 0] restart_cycles;

typedef enum logic [2 : 0] {
    IDLE    = 3'b000,
    SPLIT   = 3'b001,
    COLLECT = 3'b010
} state_t;

reg[3 : 0] BO_counter; //to track the BO bits
reg[1 : 0] IMO_COLLECT_COUNTER;
reg[7 : 0] IMO_Collector [0 : 2]; //3 IMOs
state_t state_curr;

assign ready = (state_curr == IDLE && IMO_COLLECT_COUNTER < 2'b11);

always_ff @(posedge clk) begin
    if (reset) begin
        state_curr <= IDLE;
        operate <= 1'b0;
        sign <= 1'b0;
        MAC_0 <= 32'b0;
        MAC_1 <= 32'b0;
        MAC_2 <= 32'b0;
        BO_Split <= 1'b0;
        BO_counter <= 4'b0;
        IMO_COLLECT_COUNTER <= 2'b0;
        for (integer i = 0; i < 3; i++) begin
            IMO_Collector[i] <= 8'b0; 
        end
        done <= 1'b0;
        new_IMO <= 1'b0;
        restart_cycles <= 4'b0;
        imo_collection_cycles <= 4'b0;
        computing_cycles <= 4'b0;
    end
    else begin
        case (state_curr)
            IDLE: begin
                restart_cycles <= 4'b0;
                imo_collection_cycles <= imo_collection_cycles + 1;
                done <= 1'b0;
                new_IMO <= 1'b1;
                // if (new_IMO) begin
                    if (new_MAC) begin
                        MAC_0 <= 32'b0;
                        MAC_1 <= 32'b0;
                        MAC_2 <= 32'b0;
                    end
                    if (IMO_COLLECT_COUNTER == 2'b11) begin
                        state_curr <= SPLIT; // i can use data_ready to lock state transition from idle to split
                        operate <= 1'b1;
                        IMO_COLLECT_COUNTER <= 2'b00;
                        new_IMO <= 1'b0;
                    end
                    else begin // here cunt till counter != 2'b11
                        BO_counter <= 0;
                        IMO_Collector[IMO_COLLECT_COUNTER] <= IMO;
                        IMO_COLLECT_COUNTER <= IMO_COLLECT_COUNTER + 1;
                    end
                // end
            end
            SPLIT: begin
                imo_collection_cycles <= 4'b0;
                computing_cycles <= computing_cycles + 1;
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
                computing_cycles <= 4'b0;
                restart_cycles <= restart_cycles + 1;
                MAC_0 <= MAC_0 + RES_0;
                MAC_1 <= MAC_1 + RES_1;
                MAC_2 <= MAC_2 + RES_2;
                state_curr <= IDLE;
                BO_Split <= 1'b0;
                done <= 1'b1;
                for (integer i = 0; i < 3; i++) begin
                    IMO_Collector[i] <= 8'b0;
                end
            end
            default: state_curr <= IDLE;
        endcase
    end
end

compute compute_0 (
    .clk(clk),
    .reset(reset),
    .new_IMO(new_IMO),
    .operate(operate),
    .sign(sign),
    .IMO(IMO_Collector[0]),
    .BO(BO_Split),
    .RES(RES_0)
);

compute compute_1 (
    .clk(clk),
    .reset(reset),
    .new_IMO(new_IMO),
    .operate(operate),
    .sign(sign),
    .IMO(IMO_Collector[1]),
    .BO(BO_Split),
    .RES(RES_1)
);

compute compute_2 (
    .clk(clk),
    .reset(reset),
    .new_IMO(new_IMO),
    .operate(operate),
    .sign(sign),
    .IMO(IMO_Collector[2]),
    .BO(BO_Split),
    .RES(RES_2)
);
    
endmodule