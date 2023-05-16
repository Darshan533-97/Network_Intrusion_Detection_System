//////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// Module: ids_sim.v
// Project: 
// Engineer : Darshan Dyamavvanahalli Rudreshi 
// Description: Defines a simple ids module for the user data path.  The
// modules reads a 64-bit register that contains a pattern to match and
// counts how many packets match.  The register contents are 7 bytes of
// pattern and one byte of mask.  The mask bits are set to one for each
// byte of the pattern that should be included in the mask -- zero bits
// mean "don't care".
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

//`define UDP_REG_ADDR_WIDTH 16
//`define CPCI_NF2_DATA_WIDTH 16
//`define IDS_BLOCK_ADDR 1
//`define IDS_REG_ADDR_WIDTH 16

module ids 
   #(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2
   )
   (
      input  [DATA_WIDTH-1:0]             in_data,
      input  [CTRL_WIDTH-1:0]             in_ctrl,
      input                                in_wr,
      output                              in_rdy,

      output [DATA_WIDTH-1:0]             out_data,
      output [CTRL_WIDTH-1:0]             out_ctrl,
      output                              out_wr,
      input                               out_rdy,
      
      // --- Register interface
      input                               reg_req_in,
      input                               reg_ack_in,
      input                               reg_rd_wr_L_in,
      input  [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_in,
      input  [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_in,
      input  [UDP_REG_SRC_WIDTH-1:0]      reg_src_in,

      output                              reg_req_out,
      output                              reg_ack_out,
      output                              reg_rd_wr_L_out,
      output  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_out,
      output  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_out,
      output  [UDP_REG_SRC_WIDTH-1:0]     reg_src_out,

      // misc
      input                                reset,
      input                                clk
   );

   // Define the log2 function
   // `LOG2_FUNC

   //------------------------- Signals-------------------------------
   
  
  
  
   

   // software registers 
   wire [31:0]                   soft_cmd = 0;
   wire [31:0]                   soft_data = 0;
   wire [31:0]                   soft_addr = 0;
   // hardware registers
   reg [31:0]                    hard_data;

wire [255:0] logic_anylz_datain1;
wire [255:0] logic_anylz_datain0;
wire [31:0] logic_anylz_addr;
wire [255:0] logic_anylz_out0;
wire [255:0] logic_anylz_out1;
wire empty0, empty1;

reg [31:0] hard_data2, hard_data1,
           r1_id0,in_data20, in_data10, fifo_out20,
           fifo_out10, rdwr_ptrs_inout_ctrls0, inst_mem0,
           inst_pc_rst_proccesdone0;

reg [31:0] r1_id1,in_data21, in_data11, fifo_out21,
           fifo_out11, rdwr_ptrs_inout_ctrls1, inst_mem1,
           inst_pc_rst_proccesdone1;

   // internal state
  wire [63:0] dp_hard_data, alu_hard_data;
 
  wire                              in_rdy0;
  wire                              in_rdy1;
  wire                                in_wr0;
  wire                                in_wr1;
  wire [DATA_WIDTH-1:0]             out_data0;
  wire [DATA_WIDTH-1:0]             out_data1;
  wire [CTRL_WIDTH-1:0]             out_ctrl0;
  wire [CTRL_WIDTH-1:0]             out_ctrl1;
  wire                              out_wr0;
  wire                              out_wr1;
  wire                              out_rdy1;
  wire                              out_rdy0;
  wire                              grant_in;
  wire                              grant_out;
  wire                              lock_out;
  wire                              lock_in;
  wire [1:0]                        state_in0;
  wire [1:0]                        state_in1;
  wire [1:0]                        state_out0;
  wire [1:0]                        state_out1;
  wire                              bloom_match;
  wire  [31:0]                       bloom_pattern_high;
  wire  [31:0]                       bloom_pattern_low;
  wire [31:0]                       bloom_match_count;
  reg  [31:0]                       bloom_match_count_reg;
   //------------------------- Local assignments -------------------------------

always@(posedge clk, posedge reset)
  if(reset)
     bloom_match_count_reg <= 0;
  else if(logic_anylz_addr[30])
     bloom_match_count_reg <= 0;
  else
     bloom_match_count_reg <= bloom_match_count;
     
    	
	always@(posedge clk)
	 begin
	  if(soft_cmd[31])
           begin
	   hard_data1 <= 0;
	   hard_data2 <= 0;
           end
	  else
           begin
	   hard_data1 <= dp_hard_data[31:0];
	   hard_data2 <= dp_hard_data[63:32];
           end
	 end

bloom_filter b1(.clk(clk), .reset(reset), .in_wr(in_wr),
                .in_data(in_data), .in_ctrl(in_ctrl), .bloom_array_reg({bloom_pattern_high, bloom_pattern_low}), 
                .match(bloom_match), .matches_count(bloom_match_count));

arbiter a1(.clk(clk), .reset(reset), .in_wr(in_wr),.in_rdy0(in_rdy0),.in_rdy1(in_rdy1),
			  .in_ctrl(in_ctrl),.in_data(in_data),.in_wr0(in_wr0),
                          .grant(grant_in), .lock(lock_in),
                          .state0(state_in0), .state1(state_in1),
			  .in_wr1(in_wr1),.in_rdy(in_rdy));


datapath d0(.clk(clk), .rst_reg(reset), .bloom_match(bloom_match), 
            .soft_addr_reg(soft_addr), .soft_cmd_reg(soft_cmd), .soft_data_reg(soft_data),
				.hard_data(dp1_hard_data), .logic_anylz_datain(logic_anylz_datain0),
            .in_ctrl(in_ctrl), .out_ctrl(out_ctrl0), .in_data(in_data), .out_data(out_data0), .empty(empty0),
				.in_wr(in_wr0), .out_wr(out_wr0), .in_rdy(in_rdy0), .out_rdy(out_rdy0) );


datapath d1(.clk(clk), .rst_reg(reset), .bloom_match(bloom_match),
            .soft_addr_reg(soft_addr), .soft_cmd_reg(soft_cmd), .soft_data_reg(soft_data),
				.hard_data(dp2_hard_data), .logic_anylz_datain(logic_anylz_datain1),
            .in_ctrl(in_ctrl), .out_ctrl(out_ctrl1), .in_data(in_data), .out_data(out_data1), .empty(empty1),
				.in_wr(in_wr1), .out_wr(out_wr1), .in_rdy(in_rdy1), .out_rdy(out_rdy1) );
				

merge_cpu m1(.clk(clk), .reset(reset), .out_wr0(out_wr0),.out_wr1(out_wr1),.out_rdy(out_rdy),
			.in_ctrl0(out_ctrl0),.in_data0(out_data0),.in_ctrl1(out_ctrl1),
                        .grant(grant_out), .lock(lock_out),
                        .state0(state_out0), .state1(state_out1),
                        .empty0(empty0), .empty1(empty1),
			.in_data1(out_data1),.out_wr(out_wr),.out_rdy0(out_rdy0),
			.out_rdy1(out_rdy1),.out_ctrl(out_ctrl),.out_data(out_data));



logic_analyzer     baba0( .clk(clk),
                        .logic_anylz_cmd(soft_cmd),
                        .logic_anylz_addr(logic_anylz_addr),
                        .grant_in(grant_in), .grant_out(grant_out),
                        .lock_in(lock_in), .lock_out(lock_out),
                        .state_in1(state_in1), .state_out1(state_out1),
                        .state_in0(state_in0), .state_out0(state_out0),
                        .in_rdy0(in_rdy0), .in_rdy1(in_rdy1), .in_rdy(in_rdy),
                        .in_wr(in_wr), .in_wr0(in_wr0), .in_wr1(in_wr1),
                        .out_rdy(out_rdy), .out_rdy0(out_rdy0), .out_rdy1(out_rdy1),
                        .out_wr(out_wr), .out_wr0(out_wr0), .out_wr1(out_wr1),
                        .pipeline_data(logic_anylz_datain0),
                        .logic_anylz_out(logic_anylz_out0) );


logic_analyzer     baba1( .clk(clk),
                       .logic_anylz_cmd(soft_cmd),
                       .grant_in(grant_in), .grant_out(grant_out),
                       .lock_in(lock_in), .lock_out(lock_out),
                       .state_in0(state_in0), .state_out1(state_out1),
                       .state_in1(state_in1), .state_out0(state_out0),
                       .in_rdy0(in_rdy0), .in_rdy1(in_rdy1), .in_rdy(in_rdy),
                       .in_wr(in_wr), .in_wr0(in_wr0), .in_wr1(in_wr1),
                       .out_rdy(out_rdy), .out_rdy0(out_rdy0), .out_rdy1(out_rdy1),
                       .out_wr(out_wr), .out_wr0(out_wr0), .out_wr1(out_wr1),
                       .logic_anylz_addr(logic_anylz_addr),
                       .pipeline_data(logic_anylz_datain1),
                       .logic_anylz_out(logic_anylz_out1) );


always@(*)
  begin
  inst_pc_rst_proccesdone0 = logic_anylz_out0[31:0];
//  inst_mem0               = logic_anylz_out0[63:32];
  rdwr_ptrs_inout_ctrls0  = logic_anylz_out0[95:64];
  fifo_out10              = logic_anylz_out0[127:96];
  fifo_out20              = logic_anylz_out0[159:128];
  in_data10               = logic_anylz_out0[191:160];
  in_data20               = logic_anylz_out0[223:192];
//  r1_id0                  = logic_anylz_out0[255:224];
  end

always@(*)
  begin
  inst_pc_rst_proccesdone1 = logic_anylz_out1[31:0];
 // inst_mem1               = logic_anylz_out1[63:32];
  rdwr_ptrs_inout_ctrls1  = logic_anylz_out1[95:64];
  fifo_out11              = logic_anylz_out1[127:96];
  fifo_out21              = logic_anylz_out1[159:128];
  in_data11               = logic_anylz_out1[191:160];
  in_data21               = logic_anylz_out1[223:192];
//  r1_id1                  = logic_anylz_out1[255:224];
  end
   generic_regs
   #( 
      .UDP_REG_SRC_WIDTH   (UDP_REG_SRC_WIDTH),
      .TAG                 (`IDS_BLOCK_ADDR),         // Tag -- eg. MODULE_TAG
      .REG_ADDR_WIDTH      (`IDS_REG_ADDR_WIDTH),     // Width of block addresses -- eg. MODULE_REG_ADDR_WIDTH
      .NUM_COUNTERS        (0),                 // Number of counters
      .NUM_SOFTWARE_REGS   (3),                 // Number of sw regs
      .NUM_HARDWARE_REGS   (13)                  // Number of hw regs
   ) module_regs (
      .reg_req_in       (reg_req_in),
      .reg_ack_in       (reg_ack_in),
      .reg_rd_wr_L_in   (reg_rd_wr_L_in),
      .reg_addr_in      (reg_addr_in),
      .reg_data_in      (reg_data_in),
      .reg_src_in       (reg_src_in),

      .reg_req_out      (reg_req_out),
      .reg_ack_out      (reg_ack_out),
      .reg_rd_wr_L_out  (reg_rd_wr_L_out),
      .reg_addr_out     (reg_addr_out),
      .reg_data_out     (reg_data_out),
      .reg_src_out      (reg_src_out),
      // --- counters interface
      .counter_updates  (),
      .counter_decrement(),

      // --- SW regs interface
      .software_regs    ( {logic_anylz_addr, bloom_pattern_high, bloom_pattern_low}),

      // --- HW regs interface
      .hardware_regs    ({ bloom_match_count_reg,in_data20, in_data10, fifo_out20, fifo_out10, 
                         rdwr_ptrs_inout_ctrls0,  inst_pc_rst_proccesdone0,
                         in_data21, in_data11, fifo_out21, fifo_out11, 
                         rdwr_ptrs_inout_ctrls1,  inst_pc_rst_proccesdone1}),

      .clk              (clk),
      .reset            (reset)
    );

   //------------------------- Logic-------------------------------
   
    

endmodule 
