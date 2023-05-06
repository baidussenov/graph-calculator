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

reg graph;
initial graph = 0;

integer curCoef = 0;

integer shiftX = 400;
integer shiftY = 240;
reg [11:0] t;
initial t = 500;
reg signed [16:0] x;
reg signed [36:0] y;
reg signed [16:0] coefs [4:0];
integer i, j;

reg [11:0] nums [0:4];
wire pressed [35:0];
genvar gen;

reg signed [4:0] zoom = 1;

reg [7:0] plus = 1; // start with 0 => "positive" (not negative)

generate
   for (gen = 0; gen < 36; gen = gen + 1) begin : debounce_loop
      PushButton_Debouncer dber(
			.clk(clk25),
			.PB(GPIO_0[gen]),
			.PB_up(pressed[gen])
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

reg signed [16:0] buff;

function reg signed [36:0] poly(input reg signed [16:0] x, a4, a3, a2, a1, a0);
    begin
        poly = ((((a4 * x + a3) * x) + a2) * x + a1)*x + a0; 
    end
endfunction

always @(posedge clk25) begin
	x <= (hpos - shiftX) / zoom;
	y <= shiftY - vpos;
	red <= 8'hcc;
	green <= 8'hcc;
	blue <= 8'hcc;
	if (pressed[33]) begin // switch mode
		coefs[curCoef] = nums[0] + nums[1] * 10 + nums[2] * 100 + nums[3] * 1000 + nums[4] * 10000;
		if (plus == 0) coefs[curCoef] = coefs[curCoef] * -1;
		graph = ~graph;
	end
	if (graph) begin
		if (pressed[34]) //left
			shiftX = shiftX + 10;
		if (pressed[35]) //right
			shiftX = shiftX - 10;	
		if ((x === 0 || y === 0) && display_on) begin
			red <= 8'h00;
			green <= 8'h00;
			blue <= 8'h00;
		end
		if (pressed[29] && zoom < 5)
			zoom = zoom * 2;
		else if (pressed[31] && zoom > 1)
			zoom = zoom / 2;
		if ((x % 10 === 0 && y > -4 && 4 > y))begin
			red <= 8'h00;
			green <= 8'h00;
			blue <= 8'h00;
		end
		if ((x % 100 === 0 && y > -10 && 10 > y))begin
			red <= 8'h00;
			green <= 8'h00;
			blue <= 8'h00;
		end
		if ((y % 10 === 0 && x > -4 && 4 > x))begin
			red <= 8'h00;
			green <= 8'h00;
			blue <= 8'h00;
		end
		if ((y % 100 === 0 && x > -10 && 10 > x))begin
			red <= 8'h00;
			green <= 8'h00;
			blue <= 8'h00;
		end
		if ((y >= poly(x, coefs[4], coefs[3], coefs[2], coefs[1], coefs[0]) 
				&& poly(x + 1, coefs[4], coefs[3], coefs[2], coefs[1], coefs[0]) >= y)
				||	 (poly(x, coefs[4], coefs[3], coefs[2], coefs[1], coefs[0]) >= y 
				&& y >= poly(x + 1, coefs[4], coefs[3], coefs[2], coefs[1], coefs[0]))) begin
					red <= 8'hcc;
					green <= 8'h00;
					blue <= 8'h00;
		end
	end
	else begin
		if (pressed[30]) begin // sign change
			if (plus == 0) begin plus <= 1; end
			else begin plus <= 0; end
		end
		if (pressed[34] && curCoef > 0) begin //left
			coefs[curCoef] = nums[0] + nums[1] * 10 + nums[2] * 100 + nums[3] * 1000 + nums[4] * 10000; //save coef
			if (plus == 0) coefs[curCoef] = coefs[curCoef] * -1; //save sign
			curCoef = curCoef - 1; //move coef
			buff = coefs[curCoef];
			if (buff < 0) begin
				plus <= 0;
				buff = buff * -1;
			end
			else begin //sign bug fixed
				plus <= 1;
			end
			nums[0] = buff % 10;
			buff = buff / 10;
			nums[1] = buff % 10;
			buff = buff / 10;
			nums[2] = buff % 10;
			buff = buff / 10;
			nums[3] = buff % 10;
			buff = buff / 10;
			nums[4] = buff % 10;
		end
		else if (pressed[35] && curCoef < 4) begin //right
			coefs[curCoef] = nums[0] + nums[1] * 10 + nums[2] * 100 + nums[3] * 1000 + nums[4] * 10000;
			if (plus == 0) coefs[curCoef] = coefs[curCoef] * -1;
			curCoef = curCoef + 1;
			buff = coefs[curCoef];
			if (buff < 0) begin
				plus <= 0;
				buff = buff * -1;
			end
			else begin //sign bug fixed
				plus <= 1;
			end
			nums[0] = buff % 10;
			buff = buff / 10;
			nums[1] = buff % 10;
			buff = buff / 10;
			nums[2] = buff % 10;
			buff = buff / 10;
			nums[3] = buff % 10;
			buff = buff / 10;
			nums[4] = buff % 10;
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
		for (i = 0; i < 5; i=i+1) begin //Selecting coefs
			if (hpos >= 20 + i*80 && vpos >= 20 &&
				56 + i*80 >= hpos && 80 >= vpos && display_on) begin
				red <= 8'h00;
				green <= 8'h00;
				blue <= 8'h00;
			end
		end

		if (hpos >= 20 + curCoef*80 && vpos >= 20 && //Red selected coef
			56 + curCoef*80 >= hpos && 80 >= vpos && display_on) begin
			red <= 8'hcc;
			green <= 8'h00;
			blue <= 8'h00;
		end
		
		for (i = 0; i < 5; i=i+1) begin //Form digits
			if (i == 0) begin //Form 0
				if (hpos >= 32 + i*80 && vpos >= 32 &&
					44 + i*80 >= hpos && 68 >= vpos && display_on) begin
					red <= 8'h00;
					green <= 8'hcc;
					blue <= 8'h00;
				end
			end
			if (i == 1) begin //Form 1
				if (hpos >= 20 + i*80 && vpos >= 20 &&
					32 + i*80 >= hpos && 80 >= vpos && display_on) begin
					red <= 8'h00;
					green <= 8'hcc;
					blue <= 8'h00;
				end
				if (hpos >= 44 + i*80 && vpos >= 20 &&
					56 + i*80 >= hpos && 80 >= vpos && display_on) begin
					red <= 8'h00;
					green <= 8'hcc;
					blue <= 8'h00;
				end
			end
			if (i == 2) begin //Form 2
				if (hpos >= 20 + i*80 && vpos >= 32 &&
					44 + i*80 >= hpos && 44 >= vpos && display_on) begin
					red <= 8'h00;
					green <= 8'hcc;
					blue <= 8'h00;
				end
				if (hpos >= 32 + i*80 && vpos >= 56 &&
					68 + i*80 >= hpos && 68 >= vpos && display_on) begin
					red <= 8'h00;
					green <= 8'hcc;
					blue <= 8'h00;
				end
			end
			if (i == 3) begin //Form 3
				if (hpos >= 20 + i*80 && vpos >= 32 &&
					44 + i*80 >= hpos && 44 >= vpos && display_on) begin
					red <= 8'h00;
					green <= 8'hcc;
					blue <= 8'h00;
				end
				if (hpos >= 20 + i*80 && vpos >= 56 &&
					44 + i*80 >= hpos && 68 >= vpos && display_on) begin
					red <= 8'h00;
					green <= 8'hcc;
					blue <= 8'h00;
				end
			end
			if (i == 4) begin //Form 4
				if (hpos >= 32 + i*80 && vpos >= 20 &&
					44 + i*80 >= hpos && 44 >= vpos && display_on) begin
					red <= 8'h00;
					green <= 8'hcc;
					blue <= 8'h00;
				end
				if (hpos >= 20 + i*80 && vpos >= 56 &&
					44 + i*80 >= hpos && 80 >= vpos && display_on) begin
					red <= 8'h00;
					green <= 8'hcc;
					blue <= 8'h00;
				end
			end
		end
		
		if (pressed[32]) begin // delete
			nums[0] = nums[1];
			nums[1] = nums[2];
			nums[2] = nums[3];
			nums[3] = nums[4];
			nums[4] = 0;
		end

		if (nums[4] != 0) begin
			// temporarily empty
		end
		else begin // number input:
			if (pressed[0]) begin
				nums[4] = nums[3];
				nums[3] = nums[2];
				nums[2] = nums[1];
				nums[1] = nums[0];
				nums[0] = 0;
			end
			else if (pressed[1]) begin
				nums[4] = nums[3];
				nums[3] = nums[2];
				nums[2] = nums[1];
				nums[1] = nums[0];
				nums[0] = 1;
			end
			else if (pressed[2]) begin
				nums[4] = nums[3];
				nums[3] = nums[2];
				nums[2] = nums[1];
				nums[1] = nums[0];
				nums[0] = 2;
			end
			else if (pressed[3]) begin
				nums[4] = nums[3];
				nums[3] = nums[2];
				nums[2] = nums[1];
				nums[1] = nums[0];
				nums[0] = 3;
			end
			else if (pressed[4]) begin
				nums[4] = nums[3];
				nums[3] = nums[2];
				nums[2] = nums[1];
				nums[1] = nums[0];
				nums[0] = 4;
			end
			else if (pressed[5]) begin
				nums[4] = nums[3];
				nums[3] = nums[2];
				nums[2] = nums[1];
				nums[1] = nums[0];
				nums[0] = 5;
			end
			else if (pressed[6]) begin
				nums[4] = nums[3];
				nums[3] = nums[2];
				nums[2] = nums[1];
				nums[1] = nums[0];
				nums[0] = 6;
			end
			else if (pressed[7]) begin
				nums[4] = nums[3];
				nums[3] = nums[2];
				nums[2] = nums[1];
				nums[1] = nums[0];
				nums[0] = 7;
			end
			else if (pressed[8]) begin
				nums[4] = nums[3];
				nums[3] = nums[2];
				nums[2] = nums[1];
				nums[1] = nums[0];
				nums[0] = 8;
			end
			else if (pressed[9]) begin
				nums[4] = nums[3];
				nums[3] = nums[2];
				nums[2] = nums[1];
				nums[1] = nums[0];
				nums[0] = 9;
			end
		end
	end
end
assign MTL2_DCLK=clk25;
assign MTL2_R=red;
assign MTL2_G=green;
assign MTL2_B=blue;
endmodule