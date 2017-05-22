module lcd_driver(
input logic clk, nrst, request,// 50MHz clock
input logic [7:0] din, addr,
output logic [7:0] ARDUINO_IO
);

logic spi_sck, spi_mosi, spi_dc, spi_cs, spi_reset; // SPI signals to LCD

assign ARDUINO_IO[0] = 1'b0; 			// GND
assign ARDUINO_IO[1] = 1'b1; 			// LIGHT (0 gives backlight)
assign ARDUINO_IO[2] = 1'b1;			// VCC
assign ARDUINO_IO[3] = spi_sck;		// CLK
assign ARDUINO_IO[4] = spi_mosi;		// DIN
assign ARDUINO_IO[5] = spi_dc;		// DC
assign ARDUINO_IO[6] = spi_cs;		// CE
assign ARDUINO_IO[7] = spi_reset; 	// RST

logic [47:0] mem_data_in_a, mem_data_out_a, mem_data_in_b, mem_data_out_b;
logic [6:0] mem_address_a, mem_address_b;
logic wren_a, wren_b;

// disable write functionality for RAM port A
assign wren_a = 1'b0;
assign mem_data_in_a = '0;


// Memory bitmap manipulator
memory_updater MU(.mem_in(mem_data_out_b), .data_in(din), .addr_in(addr), .clk(clk), .nrst(nrst), 
						.request(request), .mem_out(mem_data_in_b), .mem_addr(mem_address_b), .mem_wren(wren_b));						

						
// spi controller
spi_controller SC1(.data_in(mem_data_out_a), .clk(clk), .nrst(nrst), .mem_address(mem_address_a),
							.SCK(spi_sck), .MOSI(spi_mosi), .DC(spi_dc), .CS(spi_cs), .LCD_reset(spi_reset));

	

// memory containing LCD bitmap logic SCK, MOSI, DC, CS, LCD_reset
	lcd_ram R(
	.address_a(mem_address_a),
	.address_b(mem_address_b),
	.clock(clk),
	.data_a(mem_data_in_a),
	.data_b(mem_data_in_b),
	.wren_a(wren_a),
	.wren_b(wren_b),
	.q_a(mem_data_out_a),
	.q_b(mem_data_out_b)
	);

endmodule