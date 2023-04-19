//module parabola(LEDR, CLOCK_50);
//output [8:0] LEDR;
//input CLOCK_50;
//wire clk_1Hz;
//clockDivider dataset(.clk(CLOCK_50),
//.clk_div(clk_1Hz));
//assign LEDR[0]=clk_1Hz;
//endmodule
//
//module draw(sw, sw1, clk, reset, MTL2_DCLK, MTL2_R, MTL2_G, MTL2_B, MTL2_HSD, 
//MTL2_VSD); 
//input clk; 
//input reset; 
//input sw; 
//input sw1; 
//output MTL2_DCLK; 
//output [7:0] MTL2_R; 
//output [7:0] MTL2_G; 
//output [7:0] MTL2_B; 
//output MTL2_HSD; 
//output MTL2_VSD; 
//reg [7:0] red, green, blue; 
//wire res=~reset; 
//wire display_on; 
//wire [11:0] hpos; 
//wire [11:0] vpos; 
//reg clk25 = 0; 
//always @(posedge clk) 
// clk25<=~clk25; 
//hvsync test( 
// .clk(clk25), 
// .reset(0), 
// .data_enable(display_on), 
// .hsync(MTL2_HSD), 
// .vsync(MTL2_VSD), 
// .hpos(hpos), 
// .vpos(vpos) 
//);
//
//reg [3:0] oREG_TOUCH_COUNT;
//i2c_touch_config test2(
//	.oREG_TOUCH_COUNT(oREG_TOUCH_COUNT)
//);
//reg [11:0] posH; 
//initial posH = 40; 
//reg [11:0] posV; 
//initial posV = 60; 
//reg [11:0] shiftH; 
//initial shiftH = 3; 
//reg [11:0] shiftV; 
//initial shiftV = 2;
//
//reg [11:0] x;
//reg [11:0] y;
//
//always @(posedge clk25) 
//begin
//
// x <= hpos - 400;
// y <= vpos - 240;
//
// red <= 8'd0; 
// green <= 8'd0; 
// blue <= 8'd0; 
//// if (hpos >= posH && hpos <= posH + 20 && vpos >= posV && vpos <= posV + 20 && oREG_TOUCH_COUNT > 0) begin 
////  red <= 8'hcc; 
////  green <= 8'h00; 
////  blue <= 8'h00; 
//// end
//// else if (hpos >= posH && hpos <= posH + 20 && vpos >= posV && vpos <= posV + 20) begin
////	red <= 8'h00; 
////	green <= 8'hcc; 
////	blue <= 8'h00; 
//// end
// 
// if (y == x * x) begin
//	red <= 8'h00; 
//	green <= 8'hcc; 
//	blue <= 8'h00;
// end
// 
//end 
//always @(negedge MTL2_VSD) 
//begin 
//
//end 
//assign MTL2_DCLK=clk25; 
//assign MTL2_R=red; 
//assign MTL2_G=green; 
//assign MTL2_B=blue; 
//endmodule
module parabola(GPIO_0, clk, reset, MTL2_DCLK, MTL2_R, MTL2_G, MTL2_B, MTL2_HSD,
MTL2_VSD);
input [36:0] GPIO_0;
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

reg [11:0] x;
reg [11:0] y;
reg [11:0] yDistance;

reg [11:0] t;
initial t = 250;

wire pressed;
reg pressedPrev;
PushButton_Debouncer dber(
	.clk(clk25),
	.PB(GPIO_0[0]),
	.PB_up(pressed)
);

always @(posedge clk25)
begin
		red <= 8'hcc;
		green <= 8'hcc;
		blue <= 8'hcc;
	if (pressed) begin
		t <= t + 50;
		red<=8'h00;
		green<=8'h00;
		blue<=8'hcc;
	end
	
	if (hpos < t) begin
		red <= 8'h00;
		green <= 8'hcc;
		blue <= 8'h00;
	end
	pressedPrev <= pressed;
end
assign MTL2_DCLK=clk25;
assign MTL2_R=red;
assign MTL2_G=green;
assign MTL2_B=blue;
endmodule
