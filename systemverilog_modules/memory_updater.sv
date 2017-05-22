module memory_updater(
input logic [47:0] mem_in,
input logic [7:0] data_in, // data to be written on LCD
input logic [7:0] addr_in, // address on LCD to write value to
input logic clk, nrst, request,
output logic [47:0] mem_out,
output logic [7:0] mem_addr,
output logic mem_wren
);


// binary to binary-coded decimal converter
bin2bcd BCD(.clk(clk), .nrst(nrst), .in(bcd_data), .start(start), .tens(bcd_tens), .ones(bcd_ones), .done(done));

logic [47:0] digit_one, digit_two; // bitmaps for two digits to be shown on LCD
logic [7:0] val_reg, addr_reg; // data and address to be updated on LCD
logic [3:0] tens_reg;
logic [3:0] ones_reg;
logic [3:0] bcd_tens, bcd_ones;
logic [7:0] bcd_data;
logic done;

enum {idle, load, convert, readmem1, readmem2, readmem3, readmem4, writemem1, writemem2} present_state, next_state;

// State machine
always_ff @(posedge clk, negedge nrst)
if(~nrst)
	present_state <= load;
else
	present_state <= next_state;

// Next state logic
always_comb
case(present_state)
	idle: next_state = request ? load : idle;
	load: next_state = convert;
	convert: next_state = done ? readmem1 : convert;
	readmem1: next_state = readmem2;
	readmem2: next_state = readmem3;
	readmem3: next_state = readmem4;
	readmem4: next_state = writemem1;
	writemem1: next_state = writemem2;
	writemem2: next_state = idle;
	default: next_state = idle;
endcase

// output logic
always_comb begin
	mem_addr = '0;
	start = 0;
	bcd_data = '0;
	mem_wren = 0;
	mem_out = 0;
	case(present_state)
		idle: ;
		load: ;
		convert: 
			if(~done) begin
				start = 1;
				bcd_data = val_reg;
			end
		readmem1: mem_addr = 84 + tens_reg;
		readmem2: ;
		readmem3: mem_addr = 84 + ones_reg;
		readmem4: ;
		writemem1: begin
			mem_wren = 1;
			mem_addr = addr_reg;
			mem_out = digit_one;
		end
		writemem2: begin
			mem_wren = 1;
			mem_addr = addr_reg + 1;
			mem_out = digit_two;
		end
	endcase
end

always_ff @(posedge clk, negedge nrst)
if(~nrst)
begin
	val_reg <= '0;
	addr_reg <= '0;
	tens_reg <= '0;
	ones_reg <= '0;
	digit_one <= '0;
	digit_two <= '0;
end
else
	case(present_state)
		idle: ;
		load: begin // load input data and address
			val_reg <= data_in;
			addr_reg <= addr_in;
		end
		convert: // convert values to BCD format
			if(done)
			begin
				tens_reg <= bcd_tens;
				ones_reg <= bcd_ones;
			end
		readmem1: ;
		readmem2: digit_two <= mem_in;
		readmem3: ;
		readmem4: digit_one <= mem_in;	
		writemem1: ;	
		writemem2: ;
	endcase
endmodule