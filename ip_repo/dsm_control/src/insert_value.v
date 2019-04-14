`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/03/08 16:50:46
// Design Name: 
// Module Name: insert_value
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module insert_value(
        input clk,
        input rst_n,
        input signed [15:0] inpsig,
        output reg signed  [15:0] In1,
        output reg signed [15:0] In2,
        input signed [15:0] Out1,
        output reg enb_hbf1,
        output reg enb_hbf2,
        output reg enb_cic8
    );
    
    reg [10:0] counter;
    reg [4:0] counter_1;
    parameter CNT_END = 639;
    
    //CLK 46.305MHz
    always@(posedge clk, negedge rst_n)
    begin
        if(!rst_n)
            In1 <= 1'b0;
        else if(counter == 10'd319)
            In1 <= inpsig;
        else if(counter == 11'd639)
            In1 <= 1'b0;
    end
    
        always@(posedge clk, negedge rst_n)
    begin
        if(!rst_n)
            enb_hbf1 <= 1'b0;
        else if(counter == 10'd300)
            enb_hbf1 <= 1'b1;
        else if(counter == 11'd620)
            enb_hbf1 <= 1'b1;
        else
            enb_hbf1 <= 1'b0;
    end
    
    always@(posedge clk, negedge rst_n)
    begin
        if(!rst_n)
            counter <= 1'b0;
        else if(counter == CNT_END)
            counter <= 1'b0;
        else
            counter <= counter + 1'b1;
    end

    always@(posedge clk, negedge rst_n)
    begin
        if(!rst_n)
            counter_1 <= 1'b0;
        else if(counter_1 == 5'd19)
            counter_1 <= 1'b0;
        else
            counter_1 <= counter_1 + 1'b1;
    end
    
    always@(posedge clk, negedge rst_n)
    begin
        if(!rst_n)
            enb_hbf2 <= 1'b0;
        else if(counter == 10'd150 || counter == 10'd470)
            enb_hbf2 <= 1'b1;
        else if(counter == 11'd310 || counter == 10'd630)
            enb_hbf2 <= 1'b1;
        else
            enb_hbf2 <= 1'b0;
    end
    
    always@(posedge clk, negedge rst_n)
    begin
        if(!rst_n)
            enb_cic8 <= 1'b0;
        else if(counter_1 == 5'd5)
            enb_cic8 <= 1'b1;
        else
            enb_cic8 <= 1'b0;
    end
    
    always@(posedge clk, negedge rst_n)
    begin
        if(!rst_n)
            In2 <= 1'b0;
        else if(counter == 10'd159 || counter == 10'd479)
            In2 <= Out1;
        else if(counter == 11'd319 || counter == 10'd639)
            In2 <= 1'b0;
    end
    
endmodule
