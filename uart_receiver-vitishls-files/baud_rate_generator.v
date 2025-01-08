module baud_rate_generator (
    input wire clk,
    input wire rst,                         //high active reset
    output wire baud_rate_signal
);
    parameter BAUD_RATE_NUMBER = 14'd20;
    reg [13:0]count;

    always @(posedge clk or negedge rst) begin
        if (rst | baud_rate_signal) begin //rst only
            count <= BAUD_RATE_NUMBER;
        end else begin
            count <= count - 1;                 //可以不用寫，只是為了整齊
        end
    end
    assign baud_rate_signal = (count == 0); //當數到0，輸出高電平
endmodule