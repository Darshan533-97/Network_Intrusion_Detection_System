`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Darshan Dyamavvanahalli Rudreshi
// 
// Create Date:    22:12:06 02/17/2023 
// Design Name: 
// Module Name:    Data_p 
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
////////////////////////////////////////////////////////////////////////////////// output reg [31:0] hard_data);//

module datapath(input clk, rst_reg, bloom_match,
                input [31:0] soft_addr_reg, soft_cmd_reg, soft_data_reg, 
					 output reg [31:0] hard_data, 
					 output reg [255:0] logic_anylz_datain,
                output             logic_anlyz_en,
                input  [63:0]      in_data,
                input  [7:0]       in_ctrl,
                input              in_wr,
                output             in_rdy,
                output             empty,

                output [63:0]      out_data,
                output [7:0]       out_ctrl,
                output             out_wr,
                input              out_rdy);


//wire clk = (end_of_pkt || (fsm_state == 2'b11) || cpu_mode_bit) ? clk_in : 1'b0; 
reg [31:0] soft_addr, soft_cmd, soft_data;
wire cpu_mode_bit;
reg processing_done, cpu_mode_bit_reg;
reg bloom_match_reg;


always@(posedge clk)
soft_addr <= soft_addr_reg;

always@(posedge clk)
soft_data <= soft_data_reg;


always@(posedge clk)
soft_cmd <= 0;

wire enable =~soft_cmd[0];
wire rst = rst_reg || (~cpu_mode_bit )|| (cpu_mode_bit && ~bloom_match_reg) || soft_cmd[0];


//wire [8:0]PC; 
//assign PC = 0;


//IF_ID
reg [8:0] pc_out;
reg [8:0] pc_0;
reg [8:0] pc_1;
reg [8:0] pc_2;
reg [8:0] pc_3;
reg [1:0] thread_if;
wire [1:0] thread_id;
wire [31:0] new_inst;
wire [8:0] pc_if;
wire [7:0] header_ptr;
wire end_of_pkt;


//ID_EX
wire mem_lw_id, mem_sw_id, reg_wr_en_id, source_reg_id;
wire mem_lw_ex, mem_sw_ex, reg_wr_en_ex, source_reg_ex;
wire [63:0] rs1_id, rs2_id, rs2_resolved_id;
wire [63:0] rs1_ex, rs2_ex, rs2_resolved_ex;
wire [1:0] thread_ex;
wire [4:0] reg_wr_addr_id;
wire [4:0] reg_wr_addr_ex;
wire [3:0]      alu_op_id, inst_type_id;
wire [3:0] alu_op_ex, inst_type_ex;
wire [2:0]      branch_funct3_id;
wire [8:0]      pc_id;
wire [2:0] branch_funct3_ex;
wire [8:0] pc_ex;
wire processing_done_id;
	
//EX_MEM
wire beq_ex, bne_ex, blt_ex, bgr_ex;
wire mem_lw_mem, mem_sw_mem, reg_wr_en_mem, beq_mem, blt_mem, bne_mem, bgr_mem;
wire [1:0] thread_mem;
wire [63:0] alu_out_ex;
wire [63:0] alu_out_mem, rs2_mem;
wire [4:0] reg_wr_addr_mem;
wire [3:0] inst_type_mem;
wire [2:0] branch_funct3_mem;
wire [8:0] pc_mem;
wire processing_done_ex;
wire [7:0] waddr_mux, raddr_mux;
wire [1:0] fsm_state;

//MEM_WB
wire [1:0] thread_wb;
wire mem_lw_wb, reg_wr_en_wb;
wire [63:0] alu_out_wb;
wire [4:0] reg_wr_addr_wb;
wire [63:0] Data;
wire processing_done_mem;
	
// extra regs
wire enable_ifid;
wire [63:0] rs2_updated;
wire [63:0] rs2_updated_id;
wire [63:0] rs2_ex_updated;
wire [63:0] rs1_ex_updated;
wire [63:0] wdata_wb;
wire branch;
wire [8:0] pc_mem_resolved;
wire jalr;
wire jal;
wire [63:0] alu_pc_ex;
wire [8:0] alu_pc_mem;
wire [8:0] target_pc_mem;
wire [8:0] rs2_resolved_mem;
wire [31:0] new_inst_if;
wire [63:0] memdata_mem;
wire        branch_done;
wire rst_bloom = rst_reg || (~cpu_mode_bit && ~end_of_pkt)|| (cpu_mode_bit && ~bloom_match_reg) || soft_cmd[0];
wire mem_pattern_id, mem_pattern_ex, mem_pattern_mem, mem_pattern_wb;
wire [63:0] pattern_out;
wire [4:0] pattern_addr_id, pattern_addr_ex, pattern_addr_mem;
wire       full ;



always@(posedge clk, posedge rst_bloom)
 if(rst_bloom)
  bloom_match_reg <= 0;
 else if (bloom_match && end_of_pkt) 
  bloom_match_reg <=  1'b1;

// software muxed pc
	wire [8:0] muxed_pc = (soft_cmd[0]) ? soft_addr[8:0] : pc_out;
        wire instmem_en     = (soft_cmd[0]) ? ((!soft_addr[9]) ? soft_cmd[2] : 1'b0) : 1'b0;

// hardware data out
   always@(posedge clk)
	 begin
	  if(soft_cmd[1] && (!soft_addr[9]) && (soft_cmd[0]))
	   hard_data <= new_inst;
	  else if((!soft_cmd[1]) && soft_addr[9] && (soft_cmd[0]))
	   hard_data <= Data[31:0];
          else
           hard_data <= 32'b0;
	 end
	
imem i_mem(.clk(clk), .addr(muxed_pc), .dout(new_inst), .din(soft_data), .we(soft_cmd[2]));


	


always@(posedge clk, posedge rst)
  begin
     if(rst)
       thread_if <= 0;
     else if(enable)
       thread_if <= thread_if + 1;
  end

assign enable_ifid = enable;
// wb_ff_in, pc_in

// PC_0
always@(posedge clk, posedge rst)
 begin
   if(rst)
     pc_0 <= 0; 
   else if(enable)
       begin
        if((branch || jalr) && (thread_mem == 2'b00))
          pc_0 <= target_pc_mem;
        else if(jal && (thread_id == 2'b00))
          pc_0 <= rs2_resolved_id[8:0];
        else if(thread_if == 2'b00)
          pc_0 <= pc_0 + 1;
       end
 end

// PC_1
always@(posedge clk, posedge rst)
 begin
   if(rst)
     pc_1 <= 9'h080; 
   else if(enable)
       begin
        if((branch || jalr) && (thread_mem == 2'b01))
          pc_1 <= target_pc_mem;
        else if(jal && (thread_id == 2'b01))
          pc_1 <= rs2_resolved_id[8:0];
        else if(thread_if == 2'b01)
          pc_1 <= pc_1 + 1;
       end
 end
 
// PC_2
always@(posedge clk, posedge rst)
 begin
   if(rst)
     pc_2 <= 9'h100; 
   else if(enable)
       begin
        if((branch || jalr) && (thread_mem == 2'b10))
          pc_2 <= target_pc_mem;
        else if(jal && (thread_id == 2'b10))
          pc_2 <= rs2_resolved_id[8:0];
        else if(thread_if == 2'b10)
          pc_2 <= pc_2 + 1;
       end
 end
 
// PC_3
always@(posedge clk, posedge rst)
 begin
   if(rst)
     pc_3 <= 9'h180; 
   else if(enable)
       begin
        if((branch || jalr) && (thread_mem == 2'b11))
          pc_3 <= target_pc_mem;
        else if(jal && (thread_id == 2'b11))
          pc_3 <= rs2_resolved_id[8:0];
        else if(thread_if == 2'b11)
          pc_3 <= pc_3 + 1;
       end
 end

// Muxed PC
always@(*)
 begin
   case(thread_if)
    2'b00 : pc_out = pc_0;
    2'b01 : pc_out = pc_1;
    2'b10 : pc_out = pc_2;
    2'b11 : pc_out = pc_3;
	 endcase
 end

assign pc_if = pc_out + 1;

state_IF_ID i_id(.thread_if(thread_if), .thread_id(thread_id), .new_inst_id(),.new_inst_if(), .en(enable_ifid), .pc_if(pc_if),  .reset(rst), .clk(clk), .pc_id(pc_id) );

// ID stage


//assign stall_qualified = (~jal) && stall;

 //Instantiate the module
Reg_file Register(
    .r0addr({thread_id, new_inst[19:15]}), 
    .r1addr({thread_id,new_inst[24:20]}), 
    .waddr({thread_wb, reg_wr_addr_wb}), 
    .din(wdata_wb), 
    .clk(clk), 
    .wen(reg_wr_en_wb), 
    .r0out(rs1_id), 
    .r1out(rs2_id),
	 .rst(rst),
     .header_ptr(header_ptr),
	 .end_of_pkt(end_of_pkt));
	 
assign reg_wr_addr_id = new_inst[11:7];


control_unit CU(.opcode(new_inst[6:0]), .funct7(new_inst[31:25]),
                           .funct3(new_inst[14:12]),
                           .alu_op(alu_op_id),
                           .mem_lw(mem_lw_id), .mem_sw(mem_sw_id),
                           .reg_wr_en(reg_wr_en_id),
                           .source_reg(source_reg_id),
                           .inst_type(inst_type_id),
                           .branch_specifier(branch_funct3_id),
		           .processing_done(processing_done_id),
                           .pattern_addr(pattern_addr_id), .mem_pattern(mem_pattern_id));


rs2_decoder rs2decode(.inst_7to31(new_inst[31:7]),
                          .inst_type(inst_type_id),
                          .pc_id(pc_id),
                          .rs2_resolved(rs2_resolved_id));

assign rs2_updated_id = source_reg_id ? rs2_id: rs2_resolved_id;

assign jal = (inst_type_id == 4'b0110) ? 1'b1 : 1'b0;

state_ID_EX id_ex(.en(enable),.reset(rst), .clk(clk), 
                  .thread_id(thread_id), .thread_ex(thread_ex),
                  .alu_op_id(alu_op_id), .mem_lw_id(mem_lw_id) , .mem_sw_id(mem_sw_id),
                  .reg_wr_en_id(reg_wr_en_id), .source_reg_id(source_reg_id),
                  .branch_funct3_id(branch_funct3_id),
                  .inst_type_id(inst_type_id), .rs1_id(rs1_id), .rs2_id(rs2_id),
                  .rs2_resolved_id(rs2_resolved_id),
                  .reg_wr_addr_id(reg_wr_addr_id), .pc_id(pc_id),
                  .alu_op_ex(alu_op_ex), 
                  .mem_lw_ex(mem_lw_ex), .mem_sw_ex(mem_sw_ex),
                  .reg_wr_en_ex(reg_wr_en_ex) ,
                  .source_reg_ex(source_reg_ex),
                  .branch_funct3_ex(branch_funct3_ex),
                  .inst_type_ex(inst_type_ex) ,
                  .rs1_ex(rs1_ex), .rs2_ex(rs2_ex), .rs2_resolved_ex(rs2_resolved_ex),
                  .reg_wr_addr_ex(reg_wr_addr_ex), .pc_ex(pc_ex),
                  .rs2_updated_ex(rs2_updated), .rs2_updated_id(rs2_updated_id),
                  .mem_pattern_id(mem_pattern_id), .mem_pattern_ex(mem_pattern_ex), 
                  .pattern_addr_id(pattern_addr_id), .pattern_addr_ex(pattern_addr_ex),
                  .processing_done_id(processing_done_id), .processing_done_ex(processing_done_ex));



// EX stage



assign rs2_ex_updated =   rs2_ex;
assign rs1_ex_updated =   rs1_ex;



alu_wrapper alu(.a(rs1_ex_updated),
                .b(rs2_updated),
                .op(alu_op_ex),
                .inst_type_ex(inst_type_ex),
                .out_reg(alu_out_ex),
                .pc_ex(pc_ex),
                .out_pc(alu_pc_ex),
                .slt(blt_ex), .beq(beq_ex), .bne(bne_ex), .grt(bgr_ex)
       );

state_EX_MEM ex_mem(.en(enable),.reset(rst), .clk(clk),
                    .thread_ex(thread_ex), .thread_mem(thread_mem),
                    .alu_out_ex(alu_out_ex), .beq_ex(beq_ex), .bne_ex(bne_ex),
                    .blt_ex(blt_ex), .bgr_ex(bgr_ex), .alu_out_mem(alu_out_mem),
                    .beq_mem(beq_mem), .bne_mem(bne_mem), .blt_mem(blt_mem), 
                    .bgr_mem(bgr_mem),.mem_lw_mem(mem_lw_mem), .mem_sw_mem(mem_sw_mem),
                    .reg_wr_en_mem(reg_wr_en_mem),
                    .branch_funct3_mem(branch_funct3_mem),
                    .inst_type_mem(inst_type_mem), .rs2_mem(rs2_mem), 
                    .reg_wr_addr_mem(reg_wr_addr_mem), 
                    .pc_mem(pc_mem),
                    .mem_lw_ex(mem_lw_ex), .mem_sw_ex(mem_sw_ex),
                    .reg_wr_en_ex(reg_wr_en_ex),
                    .branch_funct3_ex(branch_funct3_ex),
                    .inst_type_ex(inst_type_ex), .rs2_ex(rs2_ex_updated),
                    .reg_wr_addr_ex(reg_wr_addr_ex), .pc_ex(pc_ex), 
                    .rs2_resolved_ex(rs2_resolved_ex[8:0]),
                    .mem_pattern_mem(mem_pattern_mem), .mem_pattern_ex(mem_pattern_ex), 
                    .pattern_addr_mem(pattern_addr_mem), .pattern_addr_ex(pattern_addr_ex),
                    .rs2_resolved_mem(rs2_resolved_mem),
                    .alu_pc_ex(alu_pc_ex[8:0]), .alu_pc_mem(alu_pc_mem),
						  .processing_done_mem(processing_done_mem), .processing_done_ex(processing_done_ex));



// MEM stage
// software muxed data mem signals
//	 wire muxed_dwmem_en = (soft_cmd[0]) ? ((soft_addr[9]) ? soft_cmd[2] : 1'b0) : mem_sw_mem;
//	 wire [7:0] muxed_daddr = (soft_cmd[0]) ? soft_addr[7:0] : alu_out_mem[7:0];
//	 wire [63:0] muxed_Mem_in =  (soft_cmd[0]) ? {32'b0, soft_data} : {32'b0,rs2_mem};



	always@(posedge clk)
			cpu_mode_bit_reg <= cpu_mode_bit;
		
wire processing_done_flag;
reg [2:0] flag_counter;

always@(posedge clk, posedge rst)
 begin
    if(rst )
	   flag_counter <= 0;
     else if(flag_counter == 3'd4)
           flag_counter <= 0;
		else if(processing_done_ex)
		flag_counter <= flag_counter +1;
  end

assign branch_done = beq_mem && branch;
assign processing_done_flag = (cpu_mode_bit && rst) ? 1'b1 : ((flag_counter == 3'd4) || branch_done);

 mem_fifo_fsm memory(.clk(clk), .reset(rst_reg),
                         .in_data(in_data),
                         .branch_done(branch_done),
                                                       .in_ctrl(in_ctrl),
                                                      .in_wr(in_wr),
                                                      .in_rdy(in_rdy),
                                                      .out_data(out_data),
                                                      .out_rdy(out_rdy),
                                                      .out_ctrl(out_ctrl),
                                                      .out_wr(out_wr),
                                                      .alu_out_mem(alu_out_mem[7:0]),
                                                      .rs2_mem(rs2_mem),
                                                      .mem_sw_mem(mem_sw_mem),
                                                      .soft_cmd(soft_cmd[2:0]),
                                                      .soft_addr(soft_addr[9:0]),
                                                      .soft_data(soft_data),
                                                      .processing_done(processing_done_flag),
                                                      .cpu_mode_bit(cpu_mode_bit),
                                                      .header_ptr(header_ptr),
                                                      .waddr_mux(waddr_mux),
                                                      .raddr_mux(raddr_mux),
                                                      .state(fsm_state),
                                                      .logic_anlyz_en(logic_anlyz_en),
                                                      .full(full),
                                                      .empty(empty),
                                                      .end_of_pkt(end_of_pkt));
    
ptmem p1(.clka(clk), .clkb(clk), 
         .web(1'b0), .dinb(64'b0), .addrb(5'b0),
         .addra(pattern_addr_mem), .douta(pattern_out));



						  
						  
branch_decoder BRANCH(.pc_mem(pc_mem), .rs2_resolved_mem(rs2_resolved_mem),
                             .branch_funct3_mem(branch_funct3_mem),
                              .beq(beq_mem), .blt(blt_mem), .bne(bne_mem), .bgr(bgr_mem),
                             .pc_mem_resolved(pc_mem_resolved) ,
                              .branch(branch));

assign target_pc_mem = (inst_type_mem == 4'b0111) ? alu_pc_mem: pc_mem_resolved;
assign jalr                 = (inst_type_mem == 4'b0111) ? 1'b1 : 1'b0;

state_MEM_WB mem_wb(.en(enable),.reset(rst), .clk(clk),
                    .thread_mem(thread_mem), .thread_wb(thread_wb),
                    .alu_out_wb(alu_out_wb), .alu_out_mem(alu_out_mem),
                    .mem_lw_mem(mem_lw_mem), .reg_wr_en_mem(reg_wr_en_mem),  
                    .mem_pattern_mem(mem_pattern_mem), .mem_pattern_wb(mem_pattern_wb), 
                    .reg_wr_addr_mem(reg_wr_addr_mem), .mem_lw_wb(mem_lw_wb),
                    .reg_wr_en_wb(reg_wr_en_wb), .reg_wr_addr_wb(reg_wr_addr_wb));


assign wdata_wb = mem_pattern_wb ? pattern_out : (mem_lw_wb ? out_data : alu_out_wb);

	 
	 

wire [63:0] in_data_x = cpu_mode_bit ? rs2_id : in_data;
wire [63:0] out_data_x = cpu_mode_bit ? wdata_wb : out_data;
// logic analyzer output
wire rst_anylz = ~soft_cmd[0] && ~soft_cmd[4];
     always@(posedge clk, negedge rst_anylz)
       begin
         if(!rst_anylz)
           logic_anylz_datain <= 0;
         else
           logic_anylz_datain <= {32'b0, in_data_x, out_data_x,in_ctrl,out_ctrl,
                                  waddr_mux, raddr_mux, new_inst, in_rdy, in_wr,
                                  out_rdy, out_wr,header_ptr,processing_done_flag,cpu_mode_bit,
                                  fsm_state,bloom_match_reg, empty, full, branch_done, processing_done_ex,
                                  rst_reg, logic_anlyz_en, pc_out};
       end
		

endmodule
