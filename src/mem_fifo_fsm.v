`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Darshan Dyamavvanahalli Rudreshi
// 
// Create Date:    14:33:08 03/06/2023 
// Design Name: 
// Module Name:    mem_fifo_fsm 
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
module mem_fifo_fsm
     #(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2
   )
   (
      input  [DATA_WIDTH-1:0]             in_data,
      input  [CTRL_WIDTH-1:0]             in_ctrl,
      input                               in_wr,
      output                              in_rdy,

      output [DATA_WIDTH-1:0]             out_data,
      output [CTRL_WIDTH-1:0]             out_ctrl,
      output                              out_wr,
      input                               out_rdy,
		
		//processor
	input [63:0]                        rs2_mem, 
        input [7:0]                         alu_out_mem,
        input                               mem_sw_mem,
		
	input [31:0]                        soft_data,
	input [2:0]                         soft_cmd,
	input [9:0]                         soft_addr,
        input                               branch_done,
      
      // --- Register interface
     

      // misc
      input                                reset,
      input                                clk,
      input                                processing_done,
      output [7:0]                         waddr_mux, raddr_mux,                      
      output reg [1:0]                         state,
      output reg 	                   cpu_mode_bit,
      output [7:0]                         header_ptr,
      output reg                           end_of_pkt,
      output                               full,
      output                               empty,
      output                               logic_anlyz_en
   );
 
   //------------------------- Local assignments -------------------------------


	reg in_wr_reg;
	reg [7:0] in_ctrl_reg;
	reg [63:0] in_data_reg;
	reg cpu_mode_next;
	wire [7:0] depth;
	
	
	// internal state
   reg [1:0]                      state_next;
   reg                           end_of_pkt_next;
   reg                           begin_pkt, begin_pkt_next;
	reg 									 stop_in_rdy;
   // local parameter
   parameter                     START = 2'b00;
   parameter                     HEADER = 2'b01;
   parameter                     PAYLOAD = 2'b10;
	parameter 							CPU = 2'b11;
   
assign logic_anlyz_en = ((state == 2'b11) || in_wr || out_wr) ? 1'b1 : 1'b0;

wire out_rdy_mux = out_rdy &((state != CPU) && (!cpu_mode_bit));
fifo_memory_wrapper sram_fifo(.clk (clk), 
		.reset (reset),
		.rd_en (out_rdy_mux), 
		.wr_en (in_wr_reg), 
		.first_word (begin_pkt), 
		.last_word (end_of_pkt),
		.cpu_mode_bit (cpu_mode_bit),
		.din ({in_ctrl_reg, in_data_reg}),
		.dout ({out_ctrl,out_data}),
		.depth (depth),
		.valid_data (valid_data),
		.rs2_mem(rs2_mem),
		.alu_out_mem(alu_out_mem),
		.mem_sw_mem(mem_sw_mem),
		.soft_addr(soft_addr),
		.soft_cmd(soft_cmd),
		.soft_data(soft_data),
		.header_ptr(header_ptr),
                .waddr_mux(waddr_mux),
                .raddr_mux(raddr_mux),
                .branch_done(branch_done),
                .full(full),
                .empty(empty)
		);
		
	assign in_rdy = (depth < 9'h0fe) && ~stop_in_rdy;
	assign out_wr = valid_data ;
	//------------------------- Logic-------------------------------
   
 always @(*)
  begin
      state_next = state;
      end_of_pkt_next = 1'b0;//end_of_pkt;
      begin_pkt_next = 1'b0;//begin_pkt;
      cpu_mode_next = 1'b0;//cpu_mode_bit;
		stop_in_rdy =1'b0;
      if ((in_wr ) &&( state != CPU)) begin
         
         case(state)
            START: begin
                     if (in_ctrl != 0)
     						 begin
                        state_next = HEADER;
                        begin_pkt_next = 1;
                        end_of_pkt_next = 0;   
                      end
                   end
            HEADER: begin
                     begin_pkt_next = 0;
                       if (in_ctrl == 0) 
                         state_next = PAYLOAD;
                    end
            PAYLOAD: begin
                        if (in_ctrl != 0) 
					           begin
                            state_next = CPU;
			                   stop_in_rdy = 1'b1;
						          end_of_pkt_next = 1;   // will reset matcher
                          end
                     end
         endcase // case(state)
      end
		else if(state == CPU) 
		              begin
				          cpu_mode_next = 1'b1;
			             stop_in_rdy = 1'b1;
			
							 if(processing_done) 
							    begin 
				              state_next = START;
				              stop_in_rdy = 1'b0;
				              cpu_mode_next = 1'b0;
			                end
		                end
            						 
			
   end
   
   always @(posedge clk, posedge reset) begin
      if(reset) begin
         state <= START;
         begin_pkt <= 0;
         end_of_pkt <= 0;
         in_wr_reg <= 0;
			in_ctrl_reg <= 0;
			in_data_reg <= 0;
			cpu_mode_bit <= 0;
      end
      else begin
         state <= state_next;
         begin_pkt <= begin_pkt_next;
         end_of_pkt <= end_of_pkt_next;
         in_wr_reg <= in_wr;
			in_ctrl_reg <= in_ctrl;
			in_data_reg <= in_data;
			cpu_mode_bit <= cpu_mode_next;
      end // else: !if(reset)
   end // always @ (posedge clk)


endmodule
