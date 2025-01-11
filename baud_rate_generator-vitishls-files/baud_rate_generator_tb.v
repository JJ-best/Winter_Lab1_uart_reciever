`include "baud_rate_generator.v"
`timescale  1ns / 1ps

module tb_baud_rate_generator;

// baud_rate_generator Parameters
parameter PERIOD            = 10    ;
parameter BAUD_RATE_NUMBER  = 14'd20;
integer i;
integer error = 0;
reg [13:0]count_clk = 14'd20;

// baud_rate_generator Inputs
reg clk = 0;
reg count_en = 0;
reg rst;

// baud_rate_generator Outputs
wire  baud_rate_signal                     ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

baud_rate_generator #(
    .BAUD_RATE_NUMBER ( BAUD_RATE_NUMBER ))
 u_baud_rate_generator (
    .clk(clk),
    .count_en(count_en),
    .rst(rst),

    .baud_rate_signal(baud_rate_signal)
);

//dump waveform 
initial begin
    $dumpfile("tb_baud_rate_generator.vcd");
    $dumpvars(0, tb_baud_rate_generator);
end

initial begin
    rst = 1;
    #(PERIOD*2);
    rst = 0;
    count_en = 0;
    #(PERIOD*2);
    count_en = 1;
    #(PERIOD*50);
end

initial begin
    wait(count_en == 1);
    for (i = 0; i < 50; i = i + 1) begin
        @(posedge clk);
        if (count_clk == 0) begin
            if (baud_rate_signal != 1) begin
            error = error + 1;
            $display("Error: baud_rate_signal != 1 at time %t", $time);
            end
        end else begin
            if (baud_rate_signal != 0) begin
                error = error + 1;
                $display("Error: baud_rate_signal != 0 at time %t", $time);
            end 
        end
    end

    if (error != 0) $display("wrong!");
    else $display("correct!");

    $finish;
        
end

always @(posedge clk) begin
    if (rst) begin
        count_clk <= BAUD_RATE_NUMBER;  // 當 reset 有效時，重置計數器
    end else if (count_en) begin
        if (count_clk == 0) begin
            count_clk <= BAUD_RATE_NUMBER; // 當計數到 0 時，重置計數器
        end else begin
            count_clk <= count_clk - 1;   // 當 count_en = 1 時，計數器遞減
        end
    end
end
endmodule