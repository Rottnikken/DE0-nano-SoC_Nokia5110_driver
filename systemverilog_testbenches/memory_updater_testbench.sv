module memory_updater_testbench;

logic clk, nrst;

logic [7:0] in;
logic [3:0] tens, ones;
logic start, done;


logic [47:0] mem_in, mem_out;
logic [7:0] mem_addr;
logic [7:0] bcd_out;
logic [7:0] destination, position, speed, distance;
logic [3:0] bcd_tens, bcd_ones;
logic [1:0] junction;
logic mem_wren;

assign bcd_ones = ones;
assign bcd_tens = tens;
assign in = bcd_out;


bin2bcd	BCD(.*);
memory_updater MU(.*);


initial
begin
  clk = '0;
  forever #5ns clk = ~clk;
end

initial
begin
	nrst = 1;
	mem_in = 12345;
	junction = 0;
	destination = 12;
	position = 34;
	speed = 56;
	distance = 78;
	#10ns nrst = 0;
	#10ns nrst = 1;
	#20ns
	destination = 11;
	position = 22;
	speed = 33;
	distance = 44;

		
end




endmodule