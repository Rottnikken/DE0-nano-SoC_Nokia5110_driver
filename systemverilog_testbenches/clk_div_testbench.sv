module clk_div_testbench;

logic clk, SPI_clk, nrst;
clk_div scg1 (.*);

initial
begin
	nrst = 0;
	#10ns nrst = 1;
	#10ns nrst = 0;
	clk = '0;
	forever #5ns clk = ~clk;
end
endmodule
