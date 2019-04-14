`timescale 1ns / 1ps

module fsclk_def(
	input clk,
	input rst_n,
	input fs_enb,
	output fs_enb10,
	output fs_enb20,
	output fs_enb30
);

	reg [31:0] counter;
	reg start;
	
	parameter CNT_END = 32'd20;
	
   parameter FREQ_10 = 32'd5;
   parameter FREQ_20 = 32'd10;
   parameter FREQ_30 = 32'd15;
	 
	assign fs_enb10 = (counter==FREQ_10)?1'b1:1'b0;
   assign fs_enb20 = (counter==FREQ_20)?1'b1:1'b0;
   assign fs_enb30 = (counter==FREQ_30)?1'b1:1'b0;
	
	always@(posedge clk, negedge rst_n)
		if(~rst_n)
			start <= 1'b0;
		else if(fs_enb)
			start <= 1'b1;
		else if(counter == CNT_END)
			start <= 1'b0;
			
	always@(posedge clk, negedge rst_n)
		if(~rst_n)
			counter <= 1'b0;
		else if(start)
			counter <= counter + 1'b1;
		else
			counter <= 1'b0;

endmodule
