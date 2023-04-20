module parabola(GPIO_0, clk, reset, MTL2_DCLK, MTL2_R, MTL2_G, MTL2_B, MTL2_HSD, MTL2_VSD);

input [35:0] GPIO_0;
input clk;
input reset;
output MTL2_DCLK;
output [7:0] MTL2_R;
output [7:0] MTL2_G;
output [7:0] MTL2_B;
output MTL2_HSD;
output MTL2_VSD;
reg [7:0] red, green, blue;
wire res=~reset;
wire display_on;
wire [11:0] hpos;
wire [11:0] vpos;
reg clk25 = 0;
always @(posedge clk)
clk25<=~clk25;
hvsync test(
	.clk(clk25),
	.reset(0),
	.data_enable(display_on),
	.hsync(MTL2_HSD),
	.vsync(MTL2_VSD),
	.hpos(hpos),
	.vpos(vpos)
);
integer x;
integer y;
reg [11:0] yDistance;

reg [11:0] t; 
initial t = 250;

reg graph;
initial graph = 0;

wire pressed [35:0];
genvar gen;

generate
   for (gen = 0; gen < 36; gen = gen + 1) begin : gen_loop
      PushButton_Debouncer dber(
	.clk(clk25),
	.PB(GPIO_0[gen]),
	.PB_up(pressed[gen])
);
   end
endgenerate
integer shiftX = 400;
integer shiftY = 240;

integer degree = 0;
integer curCoef = 0;
integer sign = 1;

integer i;

integer graphX [800:0];
integer graphY [800:0];
initial begin
	for (i = 0; i < 800; i=i+1) begin 
		graphX[i] = i-shiftX;
	end
	for (i = 0; i < 800; i=i+1) begin 
		graphY[i] = (i-shiftX)*(i-shiftX);
	end
end

always @(posedge clk25) begin
	x <= hpos - shiftX;
	y <= shiftY - vpos;
	red <= 8'hcc;
	green <= 8'hcc;
	blue <= 8'hcc;
	if (pressed[1]) begin
		graph = ~graph;
	end
	if (graph) begin
		if (pressed[2])
			shiftX = shiftX + 10;
		if (pressed[3])
			shiftX = shiftX - 10;	
		if ((x === 0 || y === 0) && display_on) begin
			red <= 8'h00;
			green <= 8'h00;
			blue <= 8'h00;
		end
		if ((y >= x*x && (x+1)*(x+1) >= y)
		||	 ((x)*(x) >= y && y >= (x+1)*(x+1))) begin
			red <= 8'h00;
			green <= 8'hcc;
			blue <= 8'hcc;
		end
	end
	else begin
		if (pressed[2] && curCoef > 0) begin
			curCoef <= curCoef - 1;
		end
		if (pressed[3] && curCoef < 4) begin
			curCoef <= curCoef + 1;
		end

		else if (hpos < t) begin
			red <= 8'h00;
			green <= 8'hcc;
			blue <= 8'h00;
		end
		else begin
			red <= 8'hcc;
			green <= 8'hcc;
			blue <= 8'hcc;
		end
		for (i = 0; i < 5; i=i+1) begin
			if(hpos >= 20 + i*30 && vpos >= 20 &&
				40 + i*30 >= hpos && 50 >= vpos &&display_on) begin
				red <= 8'h00;
				green <= 8'h00;
				blue <= 8'h00;
			end
		end
		if (pressed[0])
			sign <= sign * (-1);
		if(hpos >= 20 + curCoef*30 && vpos >= 20 &&
			40 + curCoef*30 >= hpos && 50 >= vpos &&display_on) begin
			if (sign > 0) begin
				red <= 8'hcc;
				green <= 8'h00;
				blue <= 8'h00;
			end
			else if (sign < 0)begin
				red <= 8'h00;
				green <= 8'h00;
				blue <= 8'hcc;
			end
		end
	end
end
assign MTL2_DCLK=clk25;
assign MTL2_R=red;
assign MTL2_G=green;
assign MTL2_B=blue;
endmodule
