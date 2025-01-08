module uart_receiver (
    input wire uart_rx,
    input wire baud_rate_signal,
    input wire clk,
    input wire rst,
    output reg [7:0]data,
    output reg valid_data
);

parameter idle = 0, receive = 1;                //receiver state
reg [3:0]bit_counter = 0;                       //計算start-bit後收到幾個uart_rx，應該要可以收8-bit
reg state = idle;

reg [3:0]next_bit_counter = 0;
reg next_state = 0;
reg stop_bit;
reg valid_data_local;                           //標示數據是否接收完全。
reg [7:0]d = 0;                                     //data

always @(*) begin
    case (state)
        idle: begin                             //閒置狀態
            if (baud_rate_signal == 1) begin
                if (uart_rx == 0) begin         //接收到start-bit
                    next_state = receive;
                end else begin
                    next_state = state;
                end  
            end else begin
                next_state = idle;
            end
            valid_data_local = 0;               //不接收數據
            next_bit_counter = 0;               //重制bit-counter
        end
        receive: begin
            if (baud_rate_signal == 1) begin
                if (bit_counter == 4'd8) begin  //數到第八位了，所以這一位是stop-bit
                    stop_bit = uart_rx;
                    if (stop_bit == 1) begin    //正確停止位
                        valid_data_local = 1;   //資料接收完畢
                    end else begin
                        valid_data_local = 0;   //資料無效
                    end
                    next_bit_counter = 0;       //歸零
                    next_state = idle;
                end else begin                  //還沒數到第八位，可以接收資料
                    d[bit_counter] = uart_rx;
                    next_bit_counter = bit_counter + 1;
                    next_state = receive;
                    valid_data_local = 0;       //數據尚未接收完畢
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