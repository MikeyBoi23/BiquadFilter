`timescale 1ns / 1ps

module biquad(
    input clk,
    input rst_n,
    input valid,
    input signed [15:0] sample_in,
    output signed [15:0] y_n
    );
    
    parameter int WIDTH = 16;
    parameter int WIDTH_m1 = WIDTH - 1;
    parameter signed [WIDTH_m1:0] a1 = 16'h814a;
    parameter signed [WIDTH_m1:0] a2 = 16'h3eb9;
    parameter signed [WIDTH_m1:0] b0 = 16'h0001;
    parameter signed [WIDTH_m1:0] b1 = 16'h0002;
    parameter signed [WIDTH_m1:0] b2 = 16'h0001;
    
    parameter int mult_width = WIDTH * 2;
    parameter int mult_width_m1 = mult_width - 1;
    
    logic signed [WIDTH_m1:0] x1, x2, y1, y2;
    logic signed [mult_width_m1:0] y;
    
    always_comb begin
        y = (b0 * sample_in) + (b1 * x1) + (b2 * x2) - (a1 * y1) - (a2 * y2);
    end
    
    always @ (posedge clk) begin
      if (~rst_n) begin
    	x1 <= 'b0;
        x2 <= 'b0;
      	y1 <= 'b0;
      	y2 <= 'b0;
      end else begin
        if (valid) begin
      	  x2 <= x1;
          x1 <= sample_in;
      	  y1 <= y_q;
          y2 <= y1;
        end
      end 
  end
    
    logic signed [mult_width_m1:0] y_q;
    
    shift_and_select u0(y,y_q);
    
    assign y_n = y_q;
    
    
endmodule
