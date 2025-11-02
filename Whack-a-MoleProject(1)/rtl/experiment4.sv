`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

// This is the top module
// It divides the 50 MHz clock into a 1 Hz clock
// It then uses edge detection and pulse generation for incrementing a counter every second
module experiment4 (
		/////// board clocks                      ////////////
		input logic CLOCK_50_I,                   // 50 MHz clock

		/////// pushbuttons/switches              ////////////
		input logic[17:0] SWITCH_I,               // toggle switches

		/////// 7 segment displays/LEDs           ////////////
		output logic[6:0] SEVEN_SEGMENT_N_O[7:0], // 8 seven segment displays
		output logic[8:0] LED_GREEN_O,            // 9 green LEDs
		output logic[17:0] LED_RED_O              // 18 red LEDs
);



logic resetn;


logic count_enable;
logic game_over;


logic [6:0] value_7_segment0, value_7_segment1, value_7_segment2, value_7_segment3;


logic [3:0] BCD_count[1:0];
logic [3:0] score_count[1:0];

logic [5:0] current_state;
logic [4:0] random;
logic [4:0] seed;
logic [15:0] switch_buf;
logic [15:0] switch_enable;
assign resetn = ~SWITCH_I[17];

parameter	MAX_1Hz_div_count = 24999999;


logic [24:0] clock_div_count;
logic one_sec_clock, one_sec_clock_buf;





// A counter for clock division
always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin
		clock_div_count <= 25'h0000000;
	end else begin
		if (clock_div_count < MAX_1Hz_div_count) begin
			clock_div_count <= clock_div_count + 25'd1;
		end else 
			clock_div_count <= 25'h0000000;		
	end
end

// The value of one_sec_clock flip-flop is inverted every time the counter is reset to zero
always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin
		one_sec_clock <= 1'b1;
	end else begin
		if (clock_div_count == 'd0) one_sec_clock <= ~one_sec_clock;
	end
end

// A buffer on one_sec_clock for edge detection
always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin
		one_sec_clock_buf <= 1'b1;	
	end else begin
		one_sec_clock_buf <= one_sec_clock;
	end
end

// Pulse generation, that generates one pulse every time a posedge is detected on one_sec_clock
assign count_enable = (one_sec_clock_buf == 1'b0 && one_sec_clock == 1'b1);






always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin
		BCD_count[1] <= 4'd2;
		BCD_count[0] <= 4'd0;
	
	end else begin
		if (count_enable) begin
			if (BCD_count[0] > 4'd0) BCD_count[0] <= BCD_count[0] - 4'h1;
			
			else begin
				if (BCD_count[1] > 4'd0) begin 
					BCD_count[1] <= BCD_count[1] - 4'h1;
					BCD_count[0] <= 4'h9;
				
				end else begin
					BCD_count[1] <= BCD_count[1];
					BCD_count[0] <= BCD_count[0];
					
				end
			end
		end
	end
end

assign seed = (SWITCH_I[15:0] % 31) + 1'd1;
assign game_over = (BCD_count[0] == 4'd0) && (BCD_count[1] == 4'd0);

always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin
		switch_buf[15:0] <= SWITCH_I;	
	end else begin
		switch_buf[15:0] <= SWITCH_I[15:0];
	end
end

// Pulse generation, that generates one pulse every time a posedge is detected on one_sec_clock
assign switch_enable[15:0] = switch_buf[15:0] ^ SWITCH_I[15:0];


always_ff @ (posedge CLOCK_50_I or negedge resetn) begin

	if (resetn == 1'b0) begin
		current_state <= 6'd0;
		LED_RED_O[17:0] <= 18'd0;
		score_count[1] <= 4'd0;
		score_count[0] <= 4'd0;
		random <= seed;
	end else begin
		
		case(current_state)

			6'd0: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd0;
			score_count[0] <= 4'd0;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd1;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd0;	
			end
			if (game_over) current_state <= 6'd33;
			end

			6'd1: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd0;
			score_count[0] <= 4'd1;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd2;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd1;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd2: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd0;
			score_count[0] <= 4'd2;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd3;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd2;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd3: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd0;
			score_count[0] <= 4'd3;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd4;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd3;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd4: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd0;
			score_count[0] <= 4'd4;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd5;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd4;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd5: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd0;
			score_count[0] <= 4'd5;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd6;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd5;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd6: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd0;
			score_count[0] <= 4'd6;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd7;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd6;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd7: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd0;
			score_count[0] <= 4'd7;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd8;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd7;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd8: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd0;
			score_count[0] <= 4'd8;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd9;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd8;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd9: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd0;
			score_count[0] <= 4'd9;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd10;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd9;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd10: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd1;
			score_count[0] <= 4'd0;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd11;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd10;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd11: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd1;
			score_count[0] <= 4'd1;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd12;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd11;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd12: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd1;
			score_count[0] <= 4'd2;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd13;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd12;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd13: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd1;
			score_count[0] <= 4'd3;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd14;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd13;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd14: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd1;
			score_count[0] <= 4'd4;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd15;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd14;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd15: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd1;
			score_count[0] <= 4'd5;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd16;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd15;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd16: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd1;
			score_count[0] <= 4'd6;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd17;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd16;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd17: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd1;
			score_count[0] <= 4'd7;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd18;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd17;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd18: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd1;
			score_count[0] <= 4'd8;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd19;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd18;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd19: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd1;
			score_count[0] <= 4'd9;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd20;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd19;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd20: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd2;
			score_count[0] <= 4'd0;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd21;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd20;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd21: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd2;
			score_count[0] <= 4'd1;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd22;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd21;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd22: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd2;
			score_count[0] <= 4'd2;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd23;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd22;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd23: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd2;
			score_count[0] <= 4'd3;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd24;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd23;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd24: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd2;
			score_count[0] <= 4'd4;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd25;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd24;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd25: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd2;
			score_count[0] <= 4'd5;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd26;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd25;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd26: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd2;
			score_count[0] <= 4'd6;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd27;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd26;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd27: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd2;
			score_count[0] <= 4'd7;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd28;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd27;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd28: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd2;
			score_count[0] <= 4'd8;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd29;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd28;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd29: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd2;
			score_count[0] <= 4'd9;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd30;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd29;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd30: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd3;
			score_count[0] <= 4'd0;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd31;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd30;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			
			6'd31: begin
			LED_RED_O[17:0] <= 18'd0;
			LED_RED_O[random[3:0]] <= 1'd1;
			score_count[1] <= 4'd3;
			score_count[0] <= 4'd1;

			if (LED_RED_O[random[3:0]] == 1'd1) begin
				if (switch_enable[random[3:0]]) begin
					current_state <= 6'd32;
					random <= {random[3:0], random[4] ^ random[2]};
				end else current_state <= 6'd31;	
			end
			if (game_over) current_state <= 6'd33;
			end
			
			6'd32: begin
			LED_RED_O[17:0] <= 18'd0;
			score_count[1] <= 4'd3;
			score_count[0] <= 4'd2;	
			current_state <= 6'd32;
			if (game_over) current_state <= 6'd33;
			end
			
			6'd33: begin
			LED_RED_O[17:0] <= 18'd0;
			score_count[1] <= score_count[1];
			score_count[0] <= score_count[0];
			current_state <= 6'd33;
			end
			
			default: begin
			current_state <= 6'd0;
			end
			
			
			
		endcase
	end
	
		
end		
	

					
// Instantiate modules for converting hex number to 7-bit value for the 7-segment display
convert_hex_to_seven_segment unit0 (
	.hex_value(BCD_count[0]), 
	.converted_value(value_7_segment0)
);

convert_hex_to_seven_segment unit1 (
	.hex_value(BCD_count[1]), 
	.converted_value(value_7_segment1)
);

convert_hex_to_seven_segment unit2 (
	.hex_value(score_count[0]), 
	.converted_value(value_7_segment2)
);

convert_hex_to_seven_segment unit3 (
	.hex_value(score_count[1]), 
	.converted_value(value_7_segment3)
);

assign	SEVEN_SEGMENT_N_O[0] = value_7_segment0,
		SEVEN_SEGMENT_N_O[1] = value_7_segment1,
		SEVEN_SEGMENT_N_O[2] = value_7_segment2,
		SEVEN_SEGMENT_N_O[3] = value_7_segment3,
		SEVEN_SEGMENT_N_O[4] = 7'h7f,
		SEVEN_SEGMENT_N_O[5] = 7'h7f,
		SEVEN_SEGMENT_N_O[6] = 7'h7f,
		SEVEN_SEGMENT_N_O[7] = 7'h7f;
		
assign LED_GREEN_O = 9'b000000000;
endmodule

