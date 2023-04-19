module clockDivider (
	input clk,
	output reg clk_div
);
localparam constantNumber = 50000000;
reg [31:0] count;
always @ (posedge(clk))
begin
	if (count == constantNumber - 1)
	begin
		count <= 32'b0;
		clk_div <= ~clk_div;
	end
	else
	begin
		count <= count + 1;
		clk_div <= clk_div;
	end
end
endmodule