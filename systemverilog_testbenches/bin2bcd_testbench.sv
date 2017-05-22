module bin2bcd_testbench;

logic [7:0] in;
logic [3:0] tens, ones;
logic clk, nrst, start, done;


bin2bcd b1 (.*);

initial
begin
  clk = '0;
  forever #5ns clk = ~clk;
end

initial
begin
	nrst = 1;
	in = 0;
	#10ns nrst = 0;
	#10ns nrst = 1;
	
	for(int i=0; i<10; i++)
	begin
	#10ns
	in = $urandom_range(0, 99);
	start = 1;
	@(posedge done);
	#25ns
	start = 0;
	end
	
end


endmodule