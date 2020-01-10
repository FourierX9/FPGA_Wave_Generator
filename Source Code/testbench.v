module testbench(
    
    );

reg clk;
reg rst;
reg[15:0] full_width;
reg[7:0] detect_efficiency;
wire photon_wave;
wire photon_efficiency1;

always #10 clk = ~clk;


initial
    begin
        clk= 1'b0;
        rst =1'b1;
        #5 rst = 1'b0;
        #5 rst = 1'b1;
        //rxd = 1'b1;
    end

photon photon(
.clk(clk),
.rst(rst),
.full_width(full_width),//光子信号整个宽度
.detect_efficiency(detect_efficiency),//探测效率
.photon_wave(photon_wave),
.photon_efficiency1(photon_efficiency1)
    );

/*project_code project_code(
.clk(clk),
.rst(rst),
.rxd(rxd),
.LED(LED),
.diode_wave(diode_wave)
);*/

endmodule
