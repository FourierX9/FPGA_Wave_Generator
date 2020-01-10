`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/17 21:37:59
// Design Name: 
// Module Name: photon
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


module photon(
    input clk,
    input rst,
	 input [15:0] full_width,//光子信号整个宽度
	 input [7:0] detect_efficiency,//探测效率
    output reg photon_wave,
    output photon_efficiency1
    );

wire photon_efficiency;
assign photon_efficiency1 = photon_efficiency;

wire photon_wave1;
assign photon_wave1 = photon_wave;

wire[7:0] detect_efficiency_insider;//传递参数
assign detect_efficiency_insider = detect_efficiency;

reg [17:0] counter;

m_sequence_efficiency m_sequence_efficiency(
.photon_wave(photon_wave1),
.rst(rst),
.detect_efficiency(detect_efficiency_insider),//探测效率
.photon_efficiency(photon_efficiency)
);

always@(posedge clk or negedge rst)
begin
  if(~rst)
  begin
    photon_wave <= 1'b0;
    counter <= 1'b0;
  end
  else 
  begin
    counter <= counter + 1'b1;
    if(counter <= 17'd1)//控制了高电平的长度
      begin
        photon_wave <= 1'b1;
      end
    else if(counter < full_width)//控制了整个周期的长度
      begin
        photon_wave <= 1'b0;
      end
	 else if(counter >= full_width)
		begin
			counter <= 1'b0;
		end
  end
end

  
endmodule
