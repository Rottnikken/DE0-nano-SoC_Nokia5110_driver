timeunit 1ns; timeprecision 100ps;
module spi_controller_testbench;

logic [47:0] data_in;
logic clk, nrst, ready;
logic [7:0] data_out;
logic [6:0] mem_address;
logic enable, mode;

logic [7:0] data; // from controller
logic SCK, MOSI, DC, CS, LCD_reset; // to LCD
logic slow_clk;


assign data = data_out;


spi_controller spicontroller1( .data_in(data_in), .clk(clk), .nrst(nrst), .ready(ready),
	.data_out(data_out), .mem_address(mem_address), .enable(enable), .mode(mode)
	);

spi spi1( .data(data), .clk(slow_clk), .nrst(nrst), .ready(ready), .enable(enable), .mode(mode),
	.SCK(SCK), .MOSI(MOSI), .DC(DC), .CS(CS), .LCD_reset(LCD_reset)
	);

clk_div #(.N(3)) spiclk1( .clk(clk), .nrst(nrst), .slow_clk(slow_clk) );
	
initial
begin
  clk = 0;
  forever #5 clk = ~clk;
end

initial
begin
	data_in = '1;
	nrst = 1;
	#10 nrst = 0;
	#20 nrst = 1;
	for(int i=0;i<10;i++)
	begin
	repeat(6) @(posedge ready);
	#5
	data_in = $urandom_range(0, 2047);
	end
	
end


endmodule
