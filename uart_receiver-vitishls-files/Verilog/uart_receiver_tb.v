`include "uart_receiver.v"
`include "baud_rate_generator.v"
`timescale  1ns / 1ps

module tb_uart_receiver;

// uart_receiver Parameters
parameter PERIOD = 10;
parameter idle  = 0;
parameter NUM_DATA = 256; //the number of data

//output of TX = input of RX
reg [9:0]in_data;
reg [7:0]input_data;
//random data pattern or for-loop.

// uart_receiver Inputs
reg uart_rx = 0 ;
wire baud_rate_signal ;
reg clk = 0 ;
reg rst = 1 ;

// uart_receiver Outputs
wire  [7:0]  data                          ;
wire  valid_data                           ;

integer i, j, k, m;
integer error;

// there you can read data from the solution file,and store in the register.
reg [9:0] solution [0:255];
initial begin
  $readmemb("solution.dat",solution);
end

uart_receiver #(
    .idle ( idle ))
 u_uart_receiver (
    .uart_rx(uart_rx),
    .baud_rate_signal(baud_rate_signal),
    .clk(clk),
    .rst(rst),
    .data(data[7:0]),
    .valid_data(valid_data)
);

baud_rate_generator u_baud_rate_generator (
    .clk(clk),
    .rst(rst),
    .baud_rate_signal(baud_rate_signal)
);

//dump waveform
initial begin
    $dumpfile("uart_receiver_tb.vcd");
    $dumpvars;
end
//clk generate
initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

//system reset
initial
begin
    rst  =  1;
    #(PERIOD*5) 
    rst  =  0;
end

//data input
initial begin
    input_data = 0;
    wait(rst == 1);
    wait(rst == 0);
    for (j = 0; j < NUM_DATA ; j = j + 1) begin
        in_data = {1'b1, input_data, 1'b0};
        for (i = 0; i < 10 ; i = i + 1 ) begin
            @(posedge baud_rate_signal) uart_rx = in_data[i];
        end
        input_data = input_data + 1;
    end
    //$finish;
end

//auto check
initial begin
    error = 0;
    wait(rst == 1);
    wait(rst == 0);
    wait(baud_rate_signal == 1);
    for (m = 0; m < NUM_DATA ; m = m + 1) begin
        for (k = 0; k < 10; k = k + 1 ) begin
            @(negedge baud_rate_signal);
            if (uart_rx == solution[m][k]) begin
                error = error;
            end else begin
                error = error + 1;
                $display("pattern number No.%d, bit.%d is wrong at time:%t", m+1, k, $time);
                $display("your answer is %b, but the correct answer is %b", uart_rx, solution[j][k]);
            end
        end
    end

    if(error == 0) begin
        $display("Your answer is correct!");
    end else begin
        $display("Your answer is wrong! number of error =%d", error);
    end
    $finish;
end



endmodule