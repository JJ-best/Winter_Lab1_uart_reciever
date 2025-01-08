/************************************************
Copyright (c) 2021, Mohammad Hosseinabady
	mohammad@highlevel-synthesis.com.
	https://highlevel-synthesis.com/

All rights reserved.
Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. // Copyright (c) 2020, Mohammad Hosseinabady.
************************************************/
#include "uart_receiver.h"

typedef enum{idle, receive} uart_receive_states_type;

void uart_receiver (bool uart_rx, bool baud_rate_signal, ap_uint<8> &data, bool &valid_data) {
#pragma HLS INTERFACE ap_none port=valid_data
#pragma HLS INTERFACE ap_none port=data
#pragma HLS INTERFACE ap_none port=baud_rate_signal
#pragma HLS INTERFACE ap_none port=uart_rx
#pragma HLS INTERFACE ap_ctrl_none port=return


	static ap_uint<8> d;
	static unsigned int bit_counter = 0;						//static使counter可以在多次呼叫函式中延續數值
	static uart_receive_states_type state = idle;				//閒置狀態


	uart_receive_states_type next_state;
	unsigned int next_bit_counter ;

	bool stop_bit;
	bool valid_data_local = 0;



	switch(state) {
	case idle:													//閒置狀態
		if (baud_rate_signal == 1) {							//如果被buad_rate_signal提醒要接收
			if (uart_rx == 0) {									//閒置狀態時如果起始位(start-bit)是低電平
				next_state =  receive;							//則RX切換到接收
			} else {
				next_state = idle;								//否則維持閒置狀態
			}
		} else {
			next_state = idle;									//如果buad_rate_signal沒有觸發則始終維持閒置狀態
		}
		valid_data_local = 0;
		next_bit_counter = 0;
		break;
	case receive:												//接收狀態
		if (baud_rate_signal == 1) {							//如果被buad_rate_signal提醒要接收
			if (bit_counter == 8) {								//如果發現讀完8-bit資料了
				stop_bit = uart_rx;								//檢查傳過來的停止位uart_rx
				if (stop_bit == 1) {							//如果停止位=1，數據有效
					valid_data_local = 1;
				} else {										//否則數據無效
					valid_data_local = 0;
				}
				next_bit_counter = 0;							//因為讀取完8-bit所以要把counter重置
				next_state = idle;								//切換回閒置狀態
			} else {											//因為在start-bit後可以接收8-bit data
				d[bit_counter] = uart_rx;						//寫入資料
				next_bit_counter = bit_counter+1;				//數目前寫入多少bit
				next_state = state;								//維持目前的state
				valid_data_local = 0;
			}
		} else {												//如果沒收到buad_rate_signal則維持原樣
			valid_data_local = 0;								//數據無效
			next_state = receive;
			next_bit_counter = bit_counter;
		}
		break;
	default:
		break;

	}

	state = next_state;
	bit_counter = next_bit_counter;
	data = d;
	valid_data = valid_data_local;
}
