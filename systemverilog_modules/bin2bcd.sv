/*
Binary to binary-coded decimal converter
Implemented as a finite state machine

Takes an 8-bit unsigned input in the range 0-255 and converts it to
binary coded decimals to be used as a RAM memory index offset to load digit bitpatterns.

ex. an input value of 176 will give the outputs hundreds=1 (0001), tens=7 (0111) and ones=6 (0101)

Hundreds are not converted, so 112 will yield the result 1 and 2, 209 will give 0 and 9 and so on.
*/

module bin2bcd(
input clk, nrst,
input [7:0] in,
input start,
output [3:0] hundreds, tens, ones,
output done
);

enum{idle, shift, check_shift, add, finished} present_state, next_state;   
   
logic [7:0] in_val;
logic [3:0] hundreds_val, tens_val, ones_val, cnt;                       
logic done_val;

// assign outputs
assign hundreds = hundreds_val;
assign tens = tens_val;
assign ones = ones_val;
assign done = done_val;

// State machine
always @(posedge clk, negedge nrst)
	present_state = ~nrst ? idle : next_state;

// Next state logic
always_comb
case(present_state)
	idle: 			next_state = (start && ~done_val) ? shift : idle;
	shift: 			next_state = check_shift;
	add:			next_state = (cnt==7) ? finished : shift;
	finished:		next_state = idle;
	default: 		next_state = idle;
endcase

// Conversion algorithm
always @(posedge clk, negedge nrst)
if(~nrst)
begin
	in_val <= '0;
	done_val <= 1'b0;
	hundreds_val <= '0; tens_val <= '0; ones_val <= '0;
	cnt <= '0;
end
else
	case (present_state) 
		idle: begin 
            if (start && ~done_val) // conversion request received
            begin
				in_val <= in;
				hundreds_val <= '0;
				tens_val <= '0;
				ones_val <= '0;
				cnt <= '0;
            end
            else // wait until new conversion request
				if(~start && done_val) // recently
					done_val <= 1'b0;
		end        
        shift: begin
			hundreds_val 	<= {hundreds_val[2:0], tens_val[3]};
			tens_val 		<= {tens_val[2:0], ones_val[3]};
			ones_val 		<= {ones_val[2:0], in_val[7]};
			in_val 			<= in_val << 1;
        end          
        add: begin // Add 3 if value is 5 or more
			hundreds_val 	<= (hundreds_val>4) ? (hundreds_val+3) : hundreds_val;
			tens_val 		<= (tens_val>4) ? (tens_val+3) : tens_val;
			ones_val 		<= (ones_val>4) ? (ones_val+3) : ones_val;
			cnt 			<= (cnt==7) ? 0 : (cnt+1);
        end
        finished: done_val <= 1'b1; // signal complete conversion and return to idle state 
        default: ;     
      endcase
endmodule