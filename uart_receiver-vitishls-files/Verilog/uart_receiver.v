module uart_receiver (
    input wire uart_rx,
    input wire baud_rate_signal,
    input wire clk,
    input wire rst,
    output reg [7:0]data,
    output reg valid_data
);

parameter idle = 0, receive = 1;                //receiver state
reg [3:0]bit_counter = 0;                       //count how many bit is recieve
reg state = idle;

reg [3:0]next_bit_counter = 0;
reg next_state = 0;
reg stop_bit;
reg valid_data_local;                           //if recieve complete, valid_data = 1
reg [7:0]d = 0;                                 //input data

always @(*) begin
    case (state)
        idle: begin                             //idle state
            if (baud_rate_signal == 1) begin
                if (uart_rx == 0) begin         //recieve start-bit(0)
                    next_state = receive;
                end else begin
                    next_state = state;
                end  
            end else begin
                next_state = idle;
            end
            valid_data_local = 0;               //recieve not complete
            next_bit_counter = 0;               //reset bit-counter
        end
        receive: begin
            if (baud_rate_signal == 1) begin
                if (bit_counter == 4'd8) begin  //if count to bit-8, the next bit should be stop-bit
                    stop_bit = uart_rx;
                    if (stop_bit == 1) begin    //stop-bit should be 1
                        valid_data_local = 1;   //data recieving complete
                    end else begin
                        valid_data_local = 0;   //data recieve wrong
                    end
                    next_bit_counter = 0;       //reset bit-counter
                    next_state = idle;
                end else begin                  //didn't count to bit-8, keep recieve data
                    d[bit_counter] = uart_rx;
                    next_bit_counter = bit_counter + 1;
                    next_state = receive;
                    valid_data_local = 0;       //data recieving didn't complete 
                end
            end else begin
                next_bit_counter = bit_counter;
                next_state = receive;
                valid_data_local = 0;
            end
        end
    endcase
end


always @(posedge clk) begin
    if (rst) begin
        state <= idle;
        bit_counter <= 0;
        data <= 0;
        valid_data <= 0;
    end else begin
        state <= next_state;
        bit_counter <= next_bit_counter;
        data <= d;
        valid_data <= valid_data_local;
    end
end

    
endmodule