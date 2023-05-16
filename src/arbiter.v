`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Darshan Dyamavvanahalli Rudreshi
// 
// Create Date:    20:41:42 04/10/2023 
// Design Name: 
// Module Name:    arbiter 
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
module arbiter(
    input in_wr,
	 input in_rdy0,
	 input in_rdy1,
	 input [7:0] in_ctrl,
	 input [63:0] in_data,
	 output reg in_wr0,
	 output reg in_wr1,
	 output reg in_rdy,
	 input clk,
	 input reset,
         output reg grant, lock,
         output reg [1:0] state0, state1
	 );


reg [1:0]  n_state0, n_state1;
	 
always@(posedge clk, posedge reset)
  if(reset)
    grant <= 0;
  else
    begin
	    if(~lock) //(in_rdy0 && ~lock1)
		    grant <= ~grant;
//		 else if(in_rdy1 && ~lock0)
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
	in_rdy = 0;
	in_wr0 = 0;
	in_wr1 = 0;
	n_state0 =0;
	n_state1 =0;
	case (grant)
	1'b0  :  begin
	           in_rdy = in_rdy0;
				  in_wr0 = in_wr;
				  lock  = 1'b1;
                                  n_state0 = state0;
				  case(state0)
				  2'b00 : begin
				             if((in_ctrl != 0) && in_wr)
								 n_state0 = 2'b01;
				          end
				  2'b01 : begin
				             if((in_ctrl == 0) && in_wr)
								 n_state0 = 2'b10;
				          end
				  2'b10 : begin
				             if((in_ctrl != 0) && in_wr)
								 begin
								 n_state0 = 2'b00;
								 lock =0;
                                                                 in_rdy = in_rdy1;
								 end
				          end
				  endcase
	         end
    1'b1  :  begin
	           in_rdy = in_rdy1;
				  in_wr1 = in_wr;
				  lock  = 1'b1;
                                  n_state1 = state1;
				  case(state1)
				  2'b00 : begin
				             if((in_ctrl != 0) && in_wr)
								 n_state1 = 2'b01;
				          end
				  2'b01 : begin
				             if((in_ctrl == 0) && in_wr)
								 n_state1 = 2'b10;
				          end
				  2'b10 : begin
				             if((in_ctrl != 0) && in_wr)
								 begin
								 n_state1 = 2'b00;
								 lock =0;
                                                                 in_rdy = in_rdy0;
								 end
				          end
				  endcase
	         end	
    endcase

end	 
endmodule
