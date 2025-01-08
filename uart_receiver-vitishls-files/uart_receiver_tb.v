`include "uart_reciever.v"
`timescale  1ns / 1ps

module tb_uart_receiver;

// uart_receiver Parameters
parameter PERIOD = 10;
parameter idle  = 0;

//output of TX = input of RX
reg [9:0]in_data = {1'b1, 8'b01001011, 1'b0};

// uart_receiver Inputs
reg uart_rx = 0 ;
reg baud_rate_signal = 0 ;
reg clk = 0 ;
reg rst = 1 ;

// uart_receiver Outputs
wire  [7:0]  data                          ;
wire  valid_data                           ;

integer i;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end



uart_receiver #(
    .idle ( idle ))
 u_uart_receiver (
    .uart_rx(uart_rx),
    .baud_rate_signal( baud_rate_signal),
    .clk(clk),
    .rst(rst),
    .data(data[7:0]),
    .valid_data(valid_data)
);

initial begin
    $dumpfile("uart_receiver_tb.vcd");
    $dumpvars;
end

//system reset
initial
begin
    rst  =  1;
    #(PERIOD*5) 
    rst  =  0;
end


//buad_rate_signal
initial begin
    wait(rst == 1);
    wait(rst == 0);
    forever begin
        #(PERIOD)baud_rate_signal = ~baud_rate_signal; //
    end
end

initial begin
    wait(rst == 1);
    wait(rst == 0);
    for (i = 0; i < 10; i = i + 1) begin
        @(posedge baud_rate_signal) uart_rx = in_data[i];
    end

    if ({1'b1, data, 1'b0} == in_data) begin
        $display("correct");
    end else begin
        $display("wrong");
    end
    $finish;
end


endmodule