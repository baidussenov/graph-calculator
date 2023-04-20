module inp_handler(SW, GPIO_0, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, clk, reset, MTL2_DCLK, MTL2_R, MTL2_G, MTL2_B, MTL2_HSD,
MTL2_VSD);
input [3:0] SW;
input [35:0] GPIO_0;
output [6:0] HEX0;
output [6:0] HEX1;
output [6:0] HEX2;
output [6:0] HEX3;
output [6:0] HEX4;
output [6:0] HEX5;
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

reg [11:0] nums [0:4];
wire pressed [35:0];
genvar i;

reg [7:0] plus;

generate
   for (i = 0; i < 36; i = i + 1) begin : debounce_loop
      PushButton_Debouncer dber(
			.clk(clk25),
			.PB(GPIO_0[i]),
			.PB_up(pressed[i])
		);
   end
	
	dec_to_7seg conv0 (
		.out(HEX0), 
		.in(nums[0])
	);
	dec_to_7seg conv1 (
		.out(HEX1), 
		.in(nums[1])
	);
	dec_to_7seg conv2 (
		.out(HEX2), 
		.in(nums[2])
	);
	dec_to_7seg conv3 (
		.out(HEX3), 
		.in(nums[3])
	);
	dec_to_7seg conv4 (
		.out(HEX4), 
		.in(nums[4])
	);
	sign_to_7seg sign_conv (
		.out(HEX5),
		.in(plus)
	);
endgenerate

always @(posedge clk25) begin
	if (pressed[10]) begin
		if (plus == 0) begin plus <= 1; end
		else begin plus <= 0; end
	end

	if (nums[4] != 0) begin
	end
	else begin
		if (pressed[0]) begin
			nums[4] <= nums[3];
			nums[3] <= nums[2];
			nums[2] <= nums[1];
			nums[1] <= nums[0];
			nums[0] <= 0;
		end
		else if (pressed[1]) begin
			nums[4] <= nums[3];
			nums[3] <= nums[2];
			nums[2] <= nums[1];
			nums[1] <= nums[0];
			nums[0] <= 1;
		end
		else if (pressed[2]) begin
			nums[4] <= nums[3];
			nums[3] <= nums[2];
			nums[2] <= nums[1];
			nums[1] <= nums[0];
			nums[0] <= 2;
		end
		else if (pressed[3]) begin
			nums[4] <= nums[3];
			nums[3] <= nums[2];
			nums[2] <= nums[1];
			nums[1] <= nums[0];
			nums[0] <= 3;
		end
		else if (pressed[4]) begin
			nums[4] <= nums[3];
			nums[3] <= nums[2];
			nums[2] <= nums[1];
			nums[1] <= nums[0];
			nums[0] <= 4;
		end
		else if (pressed[5]) begin
			nums[4] <= nums[3];
			nums[3] <= nums[2];
			nums[2] <= nums[1];
			nums[1] <= nums[0];
			nums[0] <= 5;
		end
		else if (pressed[6]) begin
			nums[4] <= nums[3];
			nums[3] <= nums[2];
			nums[2] <= nums[1];
			nums[1] <= nums[0];
			nums[0] <= 6;
		end
		else if (pressed[7]) begin
			nums[4] <= nums[3];
			nums[3] <= nums[2];
			nums[2] <= nums[1];
			nums[1] <= nums[0];
			nums[0] <= 7;
		end
		else if (pressed[8]) begin
			nums[4] <= nums[3];
			nums[3] <= nums[2];
			nums[2] <= nums[1];
			nums[1] <= nums[0];
			nums[0] <= 8;
		end
		else if (pressed[9]) begin
			nums[4] <= nums[3];
			nums[3] <= nums[2];
			nums[2] <= nums[1];
			nums[1] <= nums[0];
			nums[0] <= 9;
		end
	end
end
assign MTL2_DCLK=clk25;
assign MTL2_R=red;
assign MTL2_G=green;
assign MTL2_B=blue;
endmodule