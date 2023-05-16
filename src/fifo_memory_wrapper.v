`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:       Darshan Dyamavvanahalli Rudreshi
// 
// Create Date:    12:02:56 03/06/2023 
// Design Name: 
// Module Name:    fifo_memory_wrapper 
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
module fifo_memory_wrapper
 #(parameter WIDTH = 72,
      parameter MAX_DEPTH_BITS = 8,
      parameter NEARLY_FULL = 2**MAX_DEPTH_BITS - 1)
    (
		   
     input [WIDTH-1:0] din,     // Data in
     input          wr_en,   // Write enable
	  input          first_word,
	  input          last_word,
	  
	  input          cpu_mode_bit,
	  
	  input [63:0]   rs2_mem, 
	  input [7:0]    alu_out_mem,
	  input          mem_sw_mem,
	  
	  input [31:0]   soft_data,
	  input [9:0]    soft_addr,
	  input [2:0]    soft_cmd,
          input          branch_done,     

     input          rd_en,   // Read the next word 
     
     output reg [WIDTH-1:0]  dout,    // Data out
     output reg     valid_data,
     output         full,
     output         nearly_full,
     output         empty,
     output reg [MAX_DEPTH_BITS : 0] depth,
     output reg [7:0] header_ptr,
     output [7:0] waddr_mux, raddr_mux,
     
     input          reset,
     input          clk
     );


parameter MAX_DEPTH        = 2 ** MAX_DEPTH_BITS;
   
reg [MAX_DEPTH_BITS - 1 : 0] rd_ptr;
reg [MAX_DEPTH_BITS - 1 : 0] wr_ptr;


//muxed outputs
wire [WIDTH-1:0] wdata;
wire [7:0] waddr;
wire write_en;
wire [7:0] raddr;
wire [WIDTH-1:0] rdata;
reg  [WIDTH-1:0] wdata_reg;
reg [7:0] begin_ptr;

//Fifo -in data

reg fifo_wr_en, fifo_rd_en;
reg first_word_reg;
reg last_word_reg;
wire valid_data_next;


//always@(posedge clk, negedge reset)
//  begin
//     if(!reset)
//	     wdata_reg <= 72'b0;
//	  else
//	     wdata_reg <= din;
//  end


//first and last word
//always@(posedge clk)
//  begin
//    first_word_reg <= first_word;
//	 last_word_reg  <= last_word;
//	 fifo_wr_en      <= wr_en;
//	 fifo_rd_en      <= rd_en;
//  end

always@(*)
  begin
    fifo_wr_en      = wr_en;
	 fifo_rd_en      = rd_en;
  end

always@(posedge clk, posedge reset)
   begin
	  if(reset)
	     header_ptr <= 0;
	  else if(first_word || last_word)
	     header_ptr <= wr_ptr;
          else if(branch_done)
	     header_ptr <= begin_ptr;
	end
always@(posedge clk, posedge reset)
   begin
	  if(reset)
	     begin_ptr <= 0;
	  else if(first_word )
	     begin_ptr <= wr_ptr;
	end

assign valid_data_next = ((rd_ptr != wr_ptr) && (rd_ptr != header_ptr) && fifo_rd_en ) ? 1'b1 : 1'b0;

always@(posedge clk, posedge reset)
begin
	  if(reset)
	     valid_data <= 0;
	  else 
	     valid_data <= valid_data_next;
	end

  
always @(posedge clk, posedge reset)
begin
   if (reset) begin
      rd_ptr <= 'h0;
      wr_ptr <= 'h0;
      depth  <= 'h0;
   end
   else begin
      if (fifo_wr_en) wr_ptr <= wr_ptr + 'h1;
      else if(branch_done)  wr_ptr <= begin_ptr;
      if (valid_data_next) rd_ptr <= rd_ptr + 'h1;
      if (wr_en & ~valid_data_next) depth <= 
				   // synthesis translate_off
				   #1
				   // synthesis translate_on
				   depth + 'h1;
      else if (~wr_en & valid_data_next) depth <= 
				   // synthesis translate_off
				   #1
				   // synthesis translate_on
				   depth - 'h1;
   end
end

//assign dout = queue[rd_ptr];
assign full = depth == MAX_DEPTH;
assign nearly_full = depth >= NEARLY_FULL;
assign empty = depth == 'h0;


//mux interface for processor and Fifo
assign waddr    = cpu_mode_bit ? alu_out_mem : wr_ptr;
assign wdata    = cpu_mode_bit ? {8'b0, rs2_mem}     : din;
assign write_en = cpu_mode_bit ? mem_sw_mem  : fifo_wr_en;
assign raddr    = cpu_mode_bit ? alu_out_mem : rd_ptr;

always@(*)
dout = rdata;

assign  waddr_mux = soft_cmd[0] ? soft_addr[7:0] : waddr;
assign  raddr_mux = soft_cmd[0] ? soft_addr[7:0] : raddr;
wire [71:0] wdata_mux = soft_cmd[0] ? {40'b0, soft_data} : wdata;
wire       write_en_mux = soft_cmd[0] ? (soft_addr[9] ? soft_cmd[2] : 1'b0) : write_en;


fifo_memory fifo_sram(.clka(clk), .clkb(clk), .addra(waddr_mux), .dina(wdata_mux), .wea(write_en_mux), .web(1'b0), .addrb(raddr_mux), .dinb(72'b0),.doutb(rdata) );



endmodule
