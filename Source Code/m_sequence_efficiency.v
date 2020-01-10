`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/01/20 20:40:39
// Design Name: 
// Module Name: m_sequence_efficiency
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


module m_sequence_efficiency(
    input				photon_wave,
	 input				rst,
	 input [7:0] detect_efficiency,//探测效率
	 output	wire		photon_efficiency
    );

(* OPTIMIZE="OFF" *)                    //stop *xilinx* tools optimizing this away
wire [31:1] stage /* synthesis keep */; //stop *altera* tools optimizing this away
reg [9:0] meta1, meta2;
reg m_seq_efficiency;
	 
reg [9:0]	shift_choice;


always@(*)
begin
	shift_choice = detect_efficiency+detect_efficiency+detect_efficiency+detect_efficiency+detect_efficiency+detect_efficiency+detect_efficiency+detect_efficiency+detect_efficiency+detect_efficiency;
end

always@(posedge photon_wave or negedge rst)
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
			meta1[7] <= stage[28];
			meta1[8] <= stage[31];
			meta1[9] <= stage[16];
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
assign stage[25] = !stage[26];
assign stage[26] = !stage[27] ^ stage[1];
assign stage[27] = !stage[28];
assign stage[28] = !stage[29];
assign stage[29] = !stage[30];
assign stage[30] = !stage[31];
assign stage[31] = !stage[1];

always@(posedge photon_wave)
begin
	if(meta2[9:0] <= shift_choice)
		begin
			m_seq_efficiency <= 1'b1;
		end
	else
		begin
			m_seq_efficiency <= 1'b0;
		end
end

assign photon_efficiency = photon_wave && m_seq_efficiency;

endmodule
