`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Darshan Dyamavvanahalli Rudreshi
// 
// Create Date:    22:24:09 02/17/2023 
// Design Name: 
// Module Name:    state_reg 
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


module state_IF_ID(new_inst_if,new_inst_id,en,pc_if, reset, clk, pc_id, thread_if, thread_id);

	input [8:0] pc_if;
	input [1:0] thread_if;
	output reg [1:0] thread_id;
	input [31:0] new_inst_if;
	output reg[31:0] new_inst_id;
	input reset, clk, en;
	output reg [8:0] pc_id;
	always@(posedge clk, posedge reset)
	 begin
		if(reset)
                    begin
			pc_id<= 0;
			thread_id<= 0;
			new_inst_id<= 0;
                    end
		else
                   begin
                     if(en)
                       begin
			new_inst_id<= new_inst_if;
			thread_id<= thread_if;
			pc_id<= pc_if;
                       end
                   end
	 end

endmodule

module state_ID_EX(en,reset, clk, mem_pattern_id, mem_pattern_ex, pattern_addr_id, pattern_addr_ex, rs2_updated_id, rs2_updated_ex, processing_done_id, processing_done_ex, thread_id, thread_ex, alu_op_id, mem_lw_id, mem_sw_id, reg_wr_en_id, source_reg_id, branch_funct3_id, inst_type_id, rs1_id, rs2_id, rs2_resolved_id, reg_wr_addr_id, pc_id,alu_op_ex, mem_lw_ex, mem_sw_ex, reg_wr_en_ex, source_reg_ex, branch_funct3_ex, inst_type_ex, rs1_ex, rs2_ex, rs2_resolved_ex, reg_wr_addr_ex, pc_ex );
	input reset, clk, en;
	input [1:0] thread_id;
	input processing_done_id;
	output reg processing_done_ex;
	output reg [1:0] thread_ex;
	input      mem_lw_id, mem_sw_id, reg_wr_en_id, source_reg_id;
	output reg mem_lw_ex, mem_sw_ex, reg_wr_en_ex, source_reg_ex;
	input      [63:0] rs1_id, rs2_id, rs2_resolved_id;
	output reg [63:0] rs1_ex, rs2_ex, rs2_resolved_ex;
	input      [63:0] rs2_updated_id;
	output reg [63:0] rs2_updated_ex;
	input [4:0]     reg_wr_addr_id;
	output reg[4:0] reg_wr_addr_ex;
	input [3:0]      alu_op_id, inst_type_id;
	output reg [3:0] alu_op_ex, inst_type_ex;
	input [2:0]      branch_funct3_id;
	output reg [2:0] branch_funct3_ex;
	input [8:0]      pc_id;
	output reg [8:0] pc_ex;
        input mem_pattern_id;
        output reg mem_pattern_ex;
        input [4:0] pattern_addr_id;
        output reg [4:0] pattern_addr_ex;
	
	always@(posedge clk, posedge reset)
	 begin
		if(reset)
			begin
                           mem_lw_ex     <= 0;
                           mem_sw_ex     <= 0;
                           reg_wr_en_ex  <= 0;
                           source_reg_ex <= 0;
                           thread_ex     <= 0;
                           rs1_ex        <= 0;
                           rs2_ex        <= 0;
                           rs2_resolved_ex <= 0;
                           reg_wr_addr_ex<= 0;
                           alu_op_ex     <= 0;
                           inst_type_ex  <= 0;
                           rs2_updated_ex <= 0;
                           branch_funct3_ex <= 3'b010;
                           pc_ex         <= 0;
                           mem_pattern_ex <= 0;
                           pattern_addr_ex <= 0;
									processing_done_ex <= 0;
			end
		else
			begin 
                         if(en)
                            begin
									 processing_done_ex <= processing_done_id;
                               mem_lw_ex     <= mem_lw_id;
                               mem_sw_ex     <= mem_sw_id;
                               thread_ex     <= thread_id;
                               reg_wr_en_ex  <= reg_wr_en_id;
                               source_reg_ex <= source_reg_id;
                               rs1_ex        <= rs1_id;
                               rs2_ex        <= rs2_id;
                               rs2_resolved_ex <= rs2_resolved_id;
                               rs2_updated_ex <= rs2_updated_id;
                               reg_wr_addr_ex<= reg_wr_addr_id;
                               alu_op_ex     <= alu_op_id;
                               inst_type_ex  <= inst_type_id;
                               branch_funct3_ex <= branch_funct3_id;
                               pc_ex         <= pc_id;
                               mem_pattern_ex <= mem_pattern_id;
                               pattern_addr_ex <= pattern_addr_id;
                            end
			end 
	 end
endmodule 

module state_EX_MEM(en,reset, clk, mem_pattern_mem, mem_pattern_ex, pattern_addr_mem, pattern_addr_ex, processing_done_mem, processing_done_ex, thread_ex, thread_mem, alu_out_ex, beq_ex, bne_ex, blt_ex, bgr_ex, alu_out_mem, beq_mem, bne_mem, blt_mem, bgr_mem,mem_lw_mem, mem_sw_mem, reg_wr_en_mem, branch_funct3_mem, inst_type_mem, rs2_mem,  reg_wr_addr_mem, pc_mem, mem_lw_ex, mem_sw_ex, reg_wr_en_ex, branch_funct3_ex, inst_type_ex, rs2_ex, reg_wr_addr_ex, pc_ex, rs2_resolved_ex, rs2_resolved_mem, alu_pc_ex, alu_pc_mem);
	input reset, clk, en;
	input [1:0] thread_ex;
	output reg [1:0] thread_mem;
	input processing_done_ex;
	output reg processing_done_mem;
	output  reg mem_lw_mem, mem_sw_mem, reg_wr_en_mem, beq_mem, blt_mem, bne_mem, bgr_mem;
	input       mem_lw_ex, mem_sw_ex, reg_wr_en_ex, beq_ex, bne_ex, blt_ex, bgr_ex;
	input      [63:0] alu_out_ex ,rs2_ex;
	output reg [63:0] alu_out_mem, rs2_mem;
	input [4:0]     reg_wr_addr_ex;
	output reg[4:0] reg_wr_addr_mem;
	input [3:0]      inst_type_ex;
	output reg [3:0] inst_type_mem;
	input [2:0]      branch_funct3_ex;
	output reg [2:0] branch_funct3_mem;
	input [8:0]      pc_ex;
	output reg [8:0] pc_mem;
	input [8:0]      rs2_resolved_ex;
	output reg [8:0] rs2_resolved_mem;
	input [8:0]      alu_pc_ex;
	output reg [8:0] alu_pc_mem;
        input mem_pattern_ex;
        output reg mem_pattern_mem;
        input [4:0] pattern_addr_ex;
        output reg [4:0] pattern_addr_mem;
	
	always@(posedge clk, posedge reset)
	 begin
		if(reset)
			begin
                           mem_lw_mem     <= 0;
                           mem_sw_mem     <= 0;
                           thread_mem     <= 0;
                           reg_wr_en_mem  <= 0;
                           alu_out_mem    <= 0;
                           beq_mem        <= 0;
                           bgr_mem        <= 0;
                           blt_mem        <= 0;
                           bne_mem        <= 0;
                           rs2_mem        <= 0;
                           reg_wr_addr_mem<= 0;
                           inst_type_mem  <= 0;
                           branch_funct3_mem <= 3'b010;
                           pc_mem         <= 0;
                           rs2_resolved_mem <= 0;
                           alu_pc_mem     <= 0;    
                           processing_done_mem <= 0;								
                           mem_pattern_mem  <= 0;
                           pattern_addr_mem <= 0;
			end
		else
			begin 
                         if(en)
                            begin
									  processing_done_mem <= processing_done_ex;
                               rs2_resolved_mem <= rs2_resolved_ex;
                               mem_lw_mem      <= mem_lw_ex;
                               thread_mem      <= thread_ex;
                               mem_sw_mem      <= mem_sw_ex;
                               reg_wr_en_mem   <= reg_wr_en_ex;
                               rs2_mem          <= rs2_ex;
                               reg_wr_addr_mem <= reg_wr_addr_ex;
                               alu_out_mem     <= alu_out_ex;
                               inst_type_mem    <= inst_type_ex;
                               branch_funct3_mem <= branch_funct3_ex;
                               pc_mem           <= pc_ex;
                               beq_mem           <= beq_ex;
                               blt_mem           <= blt_ex;
                               bgr_mem           <= bgr_ex;
                               bne_mem           <= bne_ex;
                               alu_pc_mem        <= alu_pc_ex;     
                               mem_pattern_mem <= mem_pattern_ex;
                               pattern_addr_mem <= pattern_addr_ex;
                            end
			end 
	 end
endmodule 

module state_MEM_WB(thread_mem, thread_wb, en,reset, clk,alu_out_wb, mem_pattern_wb, mem_pattern_mem, alu_out_mem, mem_lw_mem, reg_wr_en_mem,   reg_wr_addr_mem, mem_lw_wb, reg_wr_en_wb, reg_wr_addr_wb);
	input reset, clk, en;
	input [1:0] thread_mem;
	output reg [1:0] thread_wb;
	output  reg mem_lw_wb, reg_wr_en_wb;
	input       mem_lw_mem, reg_wr_en_mem;
	input      [63:0] alu_out_mem;
	output reg [63:0] alu_out_wb;
//	input      [63:0] memdata_mem;
//	output reg [63:0] memdata_wb;
	input [4:0]     reg_wr_addr_mem;
	output reg[4:0] reg_wr_addr_wb;
        input mem_pattern_mem;
        output reg mem_pattern_wb;
	
	always@(posedge clk, posedge reset)
	 begin
		if(reset)
			begin
                           mem_lw_wb        <= 0;
                           thread_wb        <= 0;
                           reg_wr_en_wb     <= 0;
                           alu_out_wb       <= 0;
//                           memdata_wb       <= 0;
                           reg_wr_addr_wb   <= 0;
                           mem_pattern_wb  <= 0;
			end
		else
			begin 
                         if(en)
                            begin
                               mem_lw_wb        <= mem_lw_mem;
                               thread_wb        <= thread_mem;
                               reg_wr_en_wb     <= reg_wr_en_mem;
                               reg_wr_addr_wb   <= reg_wr_addr_mem;
                               alu_out_wb       <= alu_out_mem;
//                              memdata_wb       <= memdata_mem;
                           mem_pattern_wb  <= mem_pattern_mem;
                            end
			end 
	 end
endmodule 




		
			
	
	
 

	
	
