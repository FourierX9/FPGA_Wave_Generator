`timescale 1ns/100ps

module project_code(
input clk,
input rst,
input rxd,
output /*reg [3:0]*/ wire[3:0] LED,
output diode_wave,//J2 3 B1
output photon_wave,//J2 4 C2
output noise_wave//J2 9 B5
);

reg [15:0] full_width_inside;
reg [7:0] high_width_inside;
reg [7:0] detect_efficiency_inside;
reg [7:0] deadtime_width_inside;
reg [15:0] total_number_insider;
reg [7:0] noise_choose_insider;
wire [55:0] receive_data;
wire data_ready;

deadtime deadtime(
.clk(clk),
.rst(rst),
.full_width(full_width_inside),//光子信号整个宽度
.high_width(high_width_inside),//光子信号低电平宽度
.detect_efficiency(detect_efficiency_inside),//探测效率
.deadtime_width(deadtime_width_inside),//死时间
.data_ready(data_ready),
.total_number(total_number_insider),
.noise_choose(noise_choose_insider),
.diode_wave(diode_wave),//探测器输出信号  
.photon_wave(photon_wave),//光子信号
.noise_wave(noise_wave)//噪声信号 
);	 
	 
uart_multi uart_multi(
.clk(clk),
.rst(rst),
.rxd(rxd),
.LED(LED),
.receive_data(receive_data),
.data_ready(data_ready)//高电平有效
);	 

always@(posedge clk or negedge rst)
begin
	if(~rst)
		begin
			full_width_inside=8'd200;
			high_width_inside=8'd8;
			detect_efficiency_inside=8'd50;
			deadtime_width_inside=8'd8;
			noise_choose_insider = 8'd3;
			total_number_insider = 16'd41;
		end
	else
		begin
			if(data_ready == 1'b1)
				begin
					full_width_inside <= receive_data[55:40]-16'h0100;
					detect_efficiency_inside <= receive_data[39:32];
					deadtime_width_inside <= receive_data[31:24];
					noise_choose_insider <= receive_data[23:16];
					total_number_insider <= receive_data[15:0]-16'h0100;
				end
			else
				begin
					full_width_inside <= full_width_inside;
					detect_efficiency_inside <= detect_efficiency_inside;
					deadtime_width_inside <= deadtime_width_inside;
					noise_choose_insider <= noise_choose_insider;
					total_number_insider <= total_number_insider;
				end
		end
end

endmodule
