module spi(
input logic [7:0] data, // from controller
input logic clk, nrst, enable, mode, // from controller
output logic ready, // to controller
output logic SCK, MOSI, DC, CS, LCD_reset // to LCD
);

// Internal storage
logic [7:0] reg_data; // locally stored data to be sent
logic [2:0] bit_cnt; // count bits sent
logic reg_mode; // '0' - data, '1' - command

// State machine
enum {idle, collect, transmit} present_state, next_state;
always_ff @(posedge clk, negedge nrst)
	present_state = ~nrst ? idle : next_state;

// Next state logic
always_comb
case(present_state)
	idle: next_state = enable ? collect : idle; 			
	collect: next_state = transmit;	
	transmit: next_state = (bit_cnt < 7) ? transmit : idle;
	default: next_state = idle;
endcase

// ready signal to controller
always_comb
case(present_state)
	idle: ready = 1'b1;
	collect: ready = 1'b0;
	transmit: ready = 1'b0;
	default: ready = 1'b0;
endcase

// Data collection, shifting and bit-counting
always_ff @(posedge clk, negedge nrst) 
if(~nrst)
begin
	reg_data <= '0; reg_mode <= 1'b0; 
	bit_cnt <= '1; 
end
else
	case(present_state)
		idle: ; // do nothing
		collect: begin
			reg_data <= data; // collect data
			reg_mode <= mode; // collect mode
		end
		transmit: 
			if(bit_cnt < 7) // sending byte
			begin
				bit_cnt <= bit_cnt + 1;
				reg_data <= {reg_data[6:0], 1'b0}; // shift data left one bit
			end
			else // done sending byte
				bit_cnt <= '0;
	endcase
	
// Output assignments
assign LCD_reset = nrst; // forward reset signal to LCD
assign SCK = (present_state==transmit) ? clk : 1'b0; // activate SCK only in transmit state
assign MOSI = reg_data[7]; // MSB first
assign CS = 1'b0; // Active low, must be controlled if >1 slave
assign DC = reg_mode;
endmodule

