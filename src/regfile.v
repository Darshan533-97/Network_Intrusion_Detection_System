//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Darshan Dyamavvanahalli Rudreshi
// 
// Create Date:    21:49:16 02/14/2023 
// Design Name: 
// Module Name:    ALU 
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

module Reg_file (input wen, clk,rst, end_of_pkt, input [63:0] din, input [6:0] r0addr, r1addr, waddr, output [63:0] r0out, r1out, input [7:0] header_ptr);


wire wen_mux          =  end_of_pkt ? 1'b1                  : wen && (waddr != 0) && (waddr != 7'd32) && (waddr != 7'd64) && (waddr != 7'd96);
wire [63:0] din_mux   =  end_of_pkt ? ({56'b0, header_ptr}) : din;
wire [6:0]  waddr_mux =  end_of_pkt ? 7'd31                 : waddr;

wire [63:0] r0out_muxin, r1out_muxin;
wire [6:0] r0addr_mux = ((r0addr == 7'd31) || (r0addr == 7'd63) || (r0addr == 7'd95) || (r0addr == 7'd127)) ? 7'd31 : r0addr;
wire [6:0] r1addr_mux = ((r1addr == 7'd31) || (r1addr == 7'd63) || (r1addr == 7'd95) || (r1addr == 7'd127)) ? 7'd31 : r1addr;

regfile_mem mem1(.clka(~clk), .clkb(clk), .addra(r0addr_mux), .addrb(waddr_mux), .dinb(din_mux), .web(wen_mux), .douta(r0out_muxin));
regfile_mem mem2(.clka(~clk), .clkb(clk), .addra(r1addr_mux), .addrb(waddr_mux), .dinb(din_mux), .web(wen_mux), .douta(r1out_muxin));



assign r0out = (r0addr == waddr_mux) ? din : r0out_muxin;
assign r1out = (r1addr == waddr_mux) ? din : r1out_muxin;

    



endmodule 
