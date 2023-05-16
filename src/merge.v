`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:06:18 04/10/2023 
// Design Name: 
// Module Name:    merge 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module merge_cpu(
    input out_wr0,
	 input out_wr1,
	 input out_rdy,
	 input [7:0] in_ctrl0,
	 input [63:0] in_data0,
	 input [7:0] in_ctrl1,
	 input [63:0] in_data1,
	 output reg out_wr,
	 output reg out_rdy0,
	 output reg out_rdy1,
	 output  [7:0] out_ctrl,
	 output  [63:0] out_data,
	 input clk,
         input empty0, empty1,
	 input reset,
         output reg grant, lock,
         output reg [1:0] state0, state1
	 );


reg [1:0] n_state0, n_state1;
	 
always@(posedge clk, posedge reset)
  if(reset)
    grant <= 0;
  else
    begin
	    if(~lock) //(out_wr0 && ~lock1)
		    grant <= ~grant;
//		 else if(out_wr1 && ~lock0)
//		    grant <= 1'b1;
	 end
	 
	 

always@(posedge clk, posedge reset)
   if(reset)
	  begin
	     state0  <= 0;
		  state1  <= 0;
	  end
	else
	   begin
		  state0 <= n_state0;
		  state1 <= n_state1;
		end



always@(*)
begin
  // lock0 = 0;
//	lock1 = 0;
        lock =0;
	out_wr = 0;
	out_rdy0 = 0;
	out_rdy1 = 0;
	n_state0 =0;
	n_state1 =0;
	case (grant)
	1'b0  :  begin
	           out_wr = out_wr0;
				  out_rdy0 = out_rdy;
				  lock  = 1'b1;
                                  n_state0 = state0;
				  case(state0)
				  2'b00 : begin
				             if((in_ctrl0 != 0) && out_wr0)
								 n_state0 = 2'b01;
				          end
				  2'b01 : begin
				             if((in_ctrl0 == 0) && out_wr0)
								 n_state0 = 2'b10;
				          end
				  2'b10 : begin
				             if((in_ctrl0 != 0) && out_wr0)
								 begin
								 n_state0 = 2'b00;
								 lock =0;
                                                                 out_rdy0 =0;
								 end
				          end
				  endcase
	         end
    1'b1  :  begin
	           out_wr = out_wr1;
				  out_rdy1 = out_rdy;
				  lock  = 1'b1;
                                  n_state1 = state1;
				  case(state1)
				  2'b00 : begin
				             if((in_ctrl1 != 0) && out_wr1)
								 n_state1 = 2'b01;
				          end
				  2'b01 : begin
				             if((in_ctrl1 == 0) && out_wr1)
								 n_state1 = 2'b10;
				          end
				  2'b10 : begin
				             if((in_ctrl1 != 0) && out_wr1)
								 begin
								 n_state1 = 2'b00;
								 lock =0;
                                                                 out_rdy1 =0;
								 end
				          end
				  endcase
	         end	
    endcase

end	 

assign out_data = grant ? in_data1 : in_data0;
assign out_ctrl = grant ? in_ctrl1 : in_ctrl0;
endmodule
