module clk_div #(parameter N = 14)(
input logic clk, nrst,
output logic slow_clk
);
// MSB of N-bit counter running at 50MHz will act as a 50/(2^N) MHz clock
logic [N-1:0] clk_div;

assign slow_clk = clk_div[N-1];

always_ff @(posedge clk, negedge nrst)
	clk_div = ~nrst ? '0 : (clk_div + 1);

endmodule
