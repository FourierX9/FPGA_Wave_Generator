`timescale 1ns / 1ps

module noise(
    input clk,
    input rst,
	 input[15:0] total,
	 input[7:0] noise_choose,
    output reg noise_wave
    );

(* OPTIMIZE="OFF" *)                    //stop *xilinx* tools optimizing this away
wire [31:1] stage /* synthesis keep */; //stop *altera* tools optimizing this away
reg [9:0] meta1, meta2;	 //原来是只有8位的
	 
reg [7:0] slow_200;//产生一个更慢的时钟，控制快慢后期要改
reg[1:0] state_200;
reg noise_wave_insider_200;

reg [7:0] slow_100;//产生一个更慢的时钟，控制快慢后期要改
reg[1:0] state_100;
reg noise_wave_insider_100;

reg [7:0] slow_50;//产生一个更慢的时钟，控制快慢后期要改
reg[1:0] state_50;
reg noise_wave_insider_50;

reg [9:0]    rand_num;
reg [3:0] noise_choose_insider;//三个值，1，2，3对应不同的noise_wave_insider
reg noise_wave_insider;

wire clk_200;
wire clk_100;


sys_pll sys_pll(
.areset(~rst),
.inclk0(clk),
.c0(clk_200),
.c1(clk_100),
.locked()
);

always@(*)
begin
	rand_num <= total[9:0];
	noise_choose_insider <= noise_choose;
end

always@(noise_choose_insider)//三选一数据选择器
begin
	//noise_wave <= clk_200;
	case(noise_choose_insider)
		4'd1:
			begin
				noise_wave <= noise_wave_insider_200;
				//noise_wave <= clk_200;
			end
		4'd2:
			begin
				noise_wave <= noise_wave_insider_100;
				//noise_wave <= clk_100;
			end
		4'd3:
			begin
				noise_wave <= noise_wave_insider_50;
				//noise_wave <= clk;
			end
	endcase
end

always@(posedge clk_200 or negedge rst)
begin
	if(~rst)
		begin
		slow_200 <= 1'b0;
		state_200 <= 1'b0;
		noise_wave_insider_200 <= 1'b0;
		end
	else 
		begin
			case(state_200)
			1'b0:
				begin
					noise_wave_insider_200 <= 1'b0;
					if(meta2 < rand_num)//改这个值改变输出的频率，最小38，43，44 8'd53
						begin
							state_200 <= 1'b1;
						end
					else
						begin
							state_200 <= 1'b0;
						end
				end
			1'b1:
				begin
					slow_200 <= 1'b0;
					slow_200 <= slow_200 + 1'b1;
					noise_wave_insider_200 <= 1'b0;
					if(slow_200==1'b0)
						begin
							state_200 <= 2'd2;
						end
				end
			2'd2:
				begin
					slow_200 <= slow_200 + 1'b1;
					noise_wave_insider_200 <= 1'b1;
					if(slow_200==4'd8-1)//这个减一很重要啊
						begin
							slow_200 <= 1'b0;
							state_200 <= 1'b0;
						end
				end
			endcase
		end

end

always@(posedge clk_100 or negedge rst)
begin
	if(~rst)
		begin
		slow_100 <= 1'b0;
		state_100 <= 1'b0;
		noise_wave_insider_100 <= 1'b0;
		end
	else 
		begin
			case(state_100)
			1'b0:
				begin
					noise_wave_insider_100 <= 1'b0;
					if(meta2 < rand_num)//改这个值改变输出的频率 35 10'd35
						begin
							state_100 <= 1'b1;
						end
					else
						begin
							state_100 <= 1'b0;
						end
				end
			1'b1:
				begin
					slow_100 <= 1'b0;
					slow_100 <= slow_100 + 1'b1;
					noise_wave_insider_100 <= 1'b0;
					if(slow_100==1'b0)
						begin
							state_100 <= 2'd2;
						end
				end
			2'd2:
				begin
					slow_100 <= slow_100 + 1'b1;
					noise_wave_insider_100 <= 1'b1;
					if(slow_100==4'd4)//这个减一很重要啊
						begin
							slow_100 <= 1'b0;
							state_100 <= 1'b0;
						end
				end
			endcase
		end

end

always@(posedge clk or negedge rst)
begin
	if(~rst)
		begin
		slow_50 <= 1'b0;
		state_50 <= 1'b0;
		noise_wave_insider_50 <= 1'b0;
		end
	else 
		begin
			case(state_50)
			1'b0:
				begin
					noise_wave_insider_50 <= 1'b0;
					if(meta2 < rand_num)//改这个值改变输出的频率 34 可以到824kHz 先用41试一下，34不太行
						begin
							state_50 <= 1'b1;
						end
					else
						begin
							state_50 <= 1'b0;
						end
				end
			1'b1:
				begin
					slow_50 <= 1'b0;
					slow_50 <= slow_50 + 1'b1;
					noise_wave_insider_50 <= 1'b0;
					if(slow_50==1'b0)
						begin
							state_50 <= 2'd2;
						end
				end
			2'd2:
				begin
					slow_50 <= slow_50 + 1'b1;
					noise_wave_insider_50 <= 1'b1;
					if(slow_50==4'd2)//这个减一很重要啊
						begin
							slow_50 <= 1'b0;
							state_50 <= 1'b0;
						end
				end
			endcase
		end

end


always@(posedge clk_200 or negedge rst)
begin
	if(~rst)
		begin
			meta1 <= 1'b0;
			meta2 <= 1'b0;
		end
	else 
		begin
			meta1[0] <= stage[1];
			meta1[1] <= stage[3];
			meta1[2] <= stage[7];
			meta1[3] <= stage[4];
			meta1[4] <= stage[12];
			meta1[5] <= stage[20];
			meta1[6] <= stage[23];
			meta1[7] <= stage[28];//前8个是网上的
			meta1[8] <= stage[15];
			meta1[9] <= stage[30];
			meta2 <= meta1;
		end
end

assign stage[1] = ~{stage[2] ^ stage[1]};/*~&{stage[2] ^ stage[1],stop};*/
assign stage[2] = !stage[3];
assign stage[3] = !stage[4] ^ stage[1];
assign stage[4] = !stage[5] ^ stage[1];
assign stage[5] = !stage[6] ^ stage[1];
assign stage[6] = !stage[7] ^ stage[1];
assign stage[7] = !stage[8];
assign stage[8] = !stage[9] ^ stage[1];
assign stage[9] = !stage[10] ^ stage[1];
assign stage[10] = !stage[11];
assign stage[11] = !stage[12];
assign stage[12] = !stage[13] ^ stage[1];
assign stage[13] = !stage[14];
assign stage[14] = !stage[15] ^ stage[1];
assign stage[15] = !stage[16] ^ stage[1];
assign stage[16] = !stage[17] ^ stage[1];
assign stage[17] = !stage[18];
assign stage[18] = !stage[19];
assign stage[19] = !stage[20] ^ stage[1];
assign stage[20] = !stage[21] ^ stage[1];
assign stage[21] = !stage[22];
assign stage[22] = !stage[23];
assign stage[23] = !stage[24];
assign stage[24] = !stage[25];
assign stage[25] = !stage[26] ^ stage[1];
assign stage[26] = !stage[27] ^ stage[1];
assign stage[27] = !stage[28] ^ stage[1];
assign stage[28] = !stage[29];
assign stage[29] = !stage[30];
assign stage[30] = !stage[31] ^ stage[1];
assign stage[31] = !stage[1];


endmodule
