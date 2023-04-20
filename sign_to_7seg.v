module sign_to_7seg (out, in);

output [6:0] out;
input [7:0] in;

reg [6:0] out;

always @(*)
	case (in)
		0: out = 7'b0111111;
		1: out = 7'b1111111;
	endcase
endmodule