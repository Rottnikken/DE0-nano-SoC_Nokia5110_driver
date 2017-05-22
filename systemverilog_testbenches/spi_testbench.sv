module spi_testbench;

logic [7:0] data;
logic clk, nrst, enable, mode, ready;
logic SCK, MOSI, DC, CS, LCD_reset;


spi spi1 (.*);

// clk generator
initial
begin
  clk = '0;
  forever #5ns clk = ~clk;
end

initial
begin
	// initial values
	mode = 0;
	enable = 0;
	data = '0;
	
	// reset sequence
	nrst = 1;
	#10ns nrst = 0;
	#10ns nrst = 1;	
	#10ns
	
	// initial byte to send
	data = $urandom_range(0,255);
	#10ns
	enable = 1;
	@(negedge ready);
	#5ns
	enable = 0;
	
	// Send random data 10 times
	for(int i = 0; i < 10; i++)
	begin
		@(posedge ready);
		data = $urandom_range(0, 255); // random data value
		mode = $urandom_range(0,1); // random data/command selection
		#10ns
		enable = 1;
		@(negedge ready);
		#5ns
		enable = 0;
	end	
end

endmodule
