`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/02/09 13:57:31
// Design Name: 
// Module Name: deadtime
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module deadtime(
    input clk,
    input rst,
	 input [15:0] full_width,//光子信号整个宽度
	 input [7:0] high_width,//光子信号低电平宽度
	 input [7:0] detect_efficiency,//探测效率
	 input [7:0] deadtime_width,//死时间
	 input data_ready,
	 input [15:0] total_number,//噪声的计数
	 input [7:0] noise_choose,//选择噪声波形产生的不同的clk
    output reg diode_wave,//探测器输出信号
	 output wire photon_wave,//光子信号
	 output wire noise_wave//噪声信号
    );
	 
reg [7:0] timer_deadtime;
reg [7:0] timer_length;

reg[3:0] switcher;
reg [7:0] deadtime;

reg without;//直接进行或运算

reg without_0;
reg without_1;
reg without_posedage;//高电平有效

wire photon_wave_insider;
wire photon_efficiency1_insider;
wire noise_wave_insider;

assign photon_wave = photon_efficiency1_insider;
assign noise_wave = noise_wave_insider;	 

wire [15:0] full_width_inside;//用来传递参数
wire [7:0] detect_efficiency_inside;//用来传递参数
wire [15:0] total_noise_number;
wire [7:0] noise_choose_insider;
wire clk_200;

assign detect_efficiency_inside = detect_efficiency;
assign full_width_inside = full_width;
assign total_noise_number = total_number;
assign noise_choose_insider = noise_choose;
photon photon(
.clk(clk),
.rst(rst),
.full_width(full_width_inside),//光子信号整个宽度
.detect_efficiency(detect_efficiency_inside),//探测效率
.photon_wave(photon_wave_insider),
.photon_efficiency1(photon_efficiency1_insider)
    );
 
noise noise(
.clk(clk),
.rst(rst),
.total(total_noise_number),//1s中有几个
.noise_choose(noise_choose_insider),
.noise_wave(noise_wave_insider) 
    );

sys_pll sys_pll(
.areset(~rst),
.inclk0(clk),
.c0(clk_200),
.locked()
);

always@(*)
begin
	without = photon_efficiency1_insider | noise_wave_insider;
	deadtime <= deadtime_width/*4'd2*/;
end

always@(posedge clk_200 or negedge rst)
begin
	if(~rst)
		begin
			without_0 <= 1'b1;
			without_1 <= 1'b1;
		end
	else
		begin
			without_0 <= without;
			without_1 <= without_0;
		end
end

always@(posedge clk_200 or negedge rst)
begin
  if(~rst)
    begin
      without_posedage <= 1'b0;
    end
  else
    begin
      if(without_0 == 1'b1)
        begin
          if(without_1 == 1'b0)
            begin
              without_posedage <= 1'b1;
            end
          else
            begin
              without_posedage <= 1'b0;
            end
        end
      
    end
end

always@(posedge clk_200 or negedge rst)
begin
  if(~rst)
    begin
      diode_wave <= 1'b0;
      timer_deadtime <= 1'b0;
      timer_length <= 1'b0;
    end
  else
    begin
    case (switcher)
      4'd0:
        begin
          timer_deadtime <= 1'b0;
          timer_length <= 1'b0;
          diode_wave <= 1'b0;
          if(without_posedage == 1'b1)
            begin
              switcher <= 4'd1;
            end
        end 
      4'd1:
        begin
          timer_length <= timer_length + 4'b1;
          if(timer_length < high_width)
            begin
              diode_wave <= 1'b1;
            end
          else
            begin
              diode_wave <= 1'b0;
              switcher <= 4'd2;              
            end
        end
      4'd2:
        begin
          timer_deadtime <= timer_deadtime + 1'b1;
          if(timer_deadtime < deadtime)
            begin
              
              diode_wave <= 1'b0;
            end
          else
            begin
              switcher <= 4'd0;
            end
        end
      default:
        begin
          switcher <= 4'd0;
        end 
    endcase
      
    end
end

endmodule