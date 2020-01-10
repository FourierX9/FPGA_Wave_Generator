`timescale 1ns/100ps

module uart_multi(
input clk,
input rst,
input rxd,
output reg[3:0] LED,
output reg[55:0] receive_data,
output reg data_ready//高电平有效
);

reg [4:0] state;
reg [4:0] state_choose;
reg [9:0] counter;//434
reg rxd_d0;
reg rxd_d1;
reg [7:0] rx_data;
reg [7:0] receive_judge;

reg[1:0] shinen2;
reg[1:0] shinen3;
reg[1:0] shinen4;
reg[1:0] shinen5;
reg[1:0] shinen6;

reg[1:0] finish_receive;



wire rsd_negedage;
assign rsd_negedage = rxd_d1 & ~rxd_d0;

parameter S_IDLE = 4'd0;
parameter S_START = 4'd1;
parameter S_BIT0 = 4'd2;
parameter S_BIT1 = 4'd3;
parameter S_BIT2 = 4'd4;
parameter S_BIT3 = 4'd5;
parameter S_BIT4 = 4'd6;
parameter S_BIT5 = 4'd7;
parameter S_BIT6 = 4'd8;
parameter S_BIT7 = 4'd9;
parameter S_STOP = 4'd10;

parameter byte_IDLE = 4'd0;
parameter byte_1 = 4'd1;
parameter byte_2 = 4'd2;
parameter byte_3 = 4'd3;
parameter byte_4 = 4'd4;
parameter byte_5 = 4'd5;
parameter byte_6 = 4'd6;
parameter byte_7 = 4'd7;
parameter byte_8 = 4'd8;
parameter byte_9 = 4'd9;
parameter byte_10 = 4'd10;
parameter byte_11 = 4'd11;
parameter byte_12 = 4'd12;
parameter byte_13 = 4'd13;
parameter byte_check = 4'd14;

always@(posedge clk or negedge rst)
begin
	if(~rst)
		begin
			rxd_d0 <= 1'b1;
			rxd_d1 <= 1'b1;
		end
	else
		begin
			rxd_d0 <= rxd;
			rxd_d1 <= rxd_d0;
		end
end

always@(posedge clk or negedge rst)
begin
	if(~rst)
		begin
			state <= S_IDLE;
			counter <= 8'd0;
			finish_receive <= 1'b0;
			receive_judge <= 8'hxx;
		end
	else
	begin
		case(state)
			S_IDLE:
				begin
				rx_data <= 8'd0;
				finish_receive <= 1'b0;
					if(rsd_negedage)
						begin
							state <= S_START;
							counter <= 8'd0;
						end
				end
			S_START:
				begin
					finish_receive <= 1'b0;
					if(counter == 10'd434)
						begin
							state <= S_BIT0;
							counter <= 8'd0;
						end
					else
						begin
							counter <= counter + 8'd1;
						end
				end
				
			S_BIT0:
				begin
					finish_receive <= 1'b0;
					if(counter == 10'd434)
						begin
							state <= S_BIT1;
							counter <= 8'd0;
						end
						
					else
						begin
							counter <= counter + 8'd1;
							if(counter == 8'd117)
								rx_data[0] <= rxd_d0;
						end
					
				end
			
			S_BIT1:
				begin
					finish_receive <= 1'b0;
					if(counter == 10'd434)
						begin
							state <= S_BIT2;
							counter <= 8'd0;
						end 
					else
						begin
							counter <= counter + 8'd1;
							if(counter == 8'd117)
								rx_data[1] <= rxd_d0;
						end
					
				end
			S_BIT2:
				begin
					finish_receive <= 1'b0;
					if(counter == 10'd434)
						begin
							state <= S_BIT3;
							counter <= 8'd0;
						end
					else
						begin
							counter <= counter + 8'd1;
							if(counter == 8'd117)
								rx_data[2] <= rxd_d0;
						end
					
				end
			S_BIT3:
				begin
					finish_receive <= 1'b0;
					if(counter == 10'd434)
						begin
							state <= S_BIT4;
							counter <= 8'd0;
						end
					else
						begin
							counter <= counter + 8'd1;
							if(counter == 8'd117)
								rx_data[3] <= rxd_d0;
						end
					
				end
			S_BIT4:
				begin
					finish_receive <= 1'b0;
					if(counter == 10'd434)
						begin
							state <= S_BIT5;
							counter <= 8'd0;
						end
					else
						begin
							counter <= counter + 8'd1;
							if(counter == 8'd117)
								rx_data[4] <= rxd_d0;
						end
					
				end
			S_BIT5:
				begin
					finish_receive <= 1'b0;
					if(counter == 10'd434)
						begin
							state <= S_BIT6;
							counter <= 8'd0;
						end
					else
						begin
							counter <= counter + 8'd1;
							if(counter == 8'd117)
								rx_data[5] <= rxd_d0;
						end
					
				end
			S_BIT6:
				begin
					finish_receive <= 1'b0;
					if(counter == 10'd434)
						begin
							state <= S_BIT7;
							counter <= 8'd0;
						end
					else
						begin
							counter <= counter + 8'd1;
							if(counter == 8'd117)
								rx_data[6] <= rxd_d0;
						end
					
				end
			S_BIT7:
				begin
					finish_receive <= 1'b0;
					if(counter == 10'd434)
						begin
							receive_judge <= rx_data;
							state <= S_STOP;
							counter <= 8'd0;
						end
					else
						begin
							counter <= counter + 8'd1;
							if(counter == 8'd117)
								begin
									rx_data[7] <= rxd_d0;
									receive_judge <= rx_data;
								end
						end
					
				end
			S_STOP :
				begin
					finish_receive <= 1'b1;
					if(counter == 10'd400)//434 but I change it to test
						begin
							receive_judge <= rx_data;
							finish_receive <= 1'b0;
							state <= S_IDLE;//
							counter <= 8'd0;
							finish_receive <= 1'b0;
						end
					else 
						counter <= counter + 8'd1;
				end

			default:
				begin
				state <= S_IDLE;
				end
		endcase
	end	
end

always@(posedge clk or negedge rst)
begin
	if(~rst)
		begin
			LED <= 4'b0000;
			data_ready <= 1'b0;
		end
		
	else
		begin
			case(state_choose)
				byte_IDLE:
					begin
						if(finish_receive == 1'b1)
							begin
								state_choose <= byte_1;
								data_ready <= 1'b0;
							end
					end
				byte_1:
					begin
						LED<= 4'b0001;
						data_ready <= 1'b0;
						receive_data[55:48]<=receive_judge;
						//full_width,//光子信号整个宽度,高8位
						state_choose <= byte_2;
					end
				byte_2:
					begin
						if(finish_receive == 1'b0)
							begin
								state_choose <= byte_3;
							end
					end
					
				byte_3:
					begin
						if(finish_receive == 1'b1)
							begin
								LED<= 4'b0010;
								receive_data[47:40]<=receive_judge;
								//full_width,//光子信号整个宽度，低8位
								state_choose <= byte_4;
							end
					end
					
				byte_4:
					begin
						if(finish_receive == 1'b0)
							begin
								state_choose <= byte_5;
							end
					end
					
				byte_5:
					begin
						if(finish_receive == 1'b1)
							begin
								LED<= 4'b0011;
								receive_data[39:32]<=receive_judge;
								//detect_efficiency,//探测效率
								state_choose <= byte_6;
							end
					end
					
				byte_6:
					begin
						if(finish_receive == 1'b0)
							begin
								state_choose <= byte_7;
							end
					end
					
				byte_7:
					begin
						if(finish_receive == 1'b1)
							begin
								LED<= 4'b0100;
								receive_data[31:24]<=receive_judge;
								//deadtime_width,//死时间
								data_ready <= 1'b1;
								state_choose <= byte_8;								
							end
					end
					
				byte_8:
					begin
						if(finish_receive == 1'b0)
							begin
								state_choose <= byte_9;
							end
					end
				byte_9:
					begin
						if(finish_receive == 1'b1)
							begin
								LED<= 4'b0101;
								receive_data[23:16]<=receive_judge;
								//选择clk
								data_ready <= 1'b1;
								state_choose <= byte_10;								
							end
					end
				byte_10:
					begin
						if(finish_receive == 1'b0)
							begin
								state_choose <= byte_11;
							end
					end
					
				byte_11:
					begin
						if(finish_receive == 1'b1)
							begin
								LED<= 4'b0110;
								receive_data[15:8]<=receive_judge;
								//个数高两位
								data_ready <= 1'b1;
								state_choose <= byte_12;								
							end
					end
				byte_12:
					begin
						if(finish_receive == 1'b0)
							begin
								state_choose <= byte_13;
							end
					end
					
				byte_13:
					begin
						if(finish_receive == 1'b1)
							begin
								LED<= 4'b0111;
								receive_data[7:0]<=receive_judge;
								//个数底两位
								data_ready <= 1'b1;
								state_choose <= byte_check;								
							end
					end
				byte_check:
					begin
						if(receive_data == 55'h01C83200030105)
								begin
									LED <= 4'b1111;
								end
						data_ready <= 1'b1;
						if(finish_receive == 1'b0)
							begin
								state_choose <= byte_IDLE;
							end
					end
				default: 
					begin
						data_ready <= 1'b0;
						state_choose <= byte_IDLE;
					end
				endcase
				
		end
		
end

endmodule

                                   