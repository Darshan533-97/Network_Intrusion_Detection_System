module control_unit(input [6:0] opcode, funct7,
        //            input [5:0] thread_logic_in, //new
          //          output reg [1:0] thread_sel_in, thread_mux_sel_in, thread_fixed_in,
            //        output reg thread_en,// new end
                    input [2:0] funct3,
                    output reg [3:0] alu_op,
                    output reg mem_lw, mem_sw,
                    output reg reg_wr_en,
                    output reg source_reg,
						  output reg processing_done,
                    output reg [3:0] inst_type,
                    output reg mem_pattern,
                    output reg[4:0] pattern_addr,
                    output reg [2:0] branch_specifier);
						  

always@(*)
   begin
      alu_op = 0;
      mem_lw = 0;
      mem_sw = 0;
      reg_wr_en = 0;
      source_reg = 0;
      inst_type = 0;
      branch_specifier = 3'b010;
      processing_done  = 1'b0;
      mem_pattern =0;
      pattern_addr =0;
 //     thread_sel_in = 0;    //new
 //     thread_mux_sel_in = 0;
 //     thread_en         = 0;
 //     thread_fixed_in   = 0;// new end

      case(opcode)
        7'b0110011 : begin //R-R type
                      reg_wr_en = 1'b1;
                      source_reg = 1'b1;
                      inst_type = 4'b0000;
                      case(funct3)
                        3'b000 :begin
                                 if(funct7[5])    
                                   alu_op = 4'b0001;
                                 else
                                   alu_op = 4'b0000;
                                end
                        3'b001 : alu_op = 4'b0110;
                        3'b101 : alu_op = 4'b0111;
                        3'b110 : alu_op = 4'b0010;
                        3'b111 : alu_op = 4'b0011;
                      endcase
                     end
        7'b0010011 : begin //R-I type
                      reg_wr_en = 1'b1;
                      inst_type = 4'b0001;
                      case(funct3)
                        3'b000 : alu_op = 4'b0000;
                        3'b001 : alu_op = 4'b0110;
                        3'b101 : alu_op = 4'b0111;
                        3'b110 : alu_op = 4'b0010;
                        3'b111 : alu_op = 4'b0011;
                      endcase
                     end
        7'b0000011 : begin // LD
                      reg_wr_en = 1'b1;
                      inst_type = 4'b0010;
                      if(funct3 == 001)
                       begin
                           mem_pattern =1'b1;
                           pattern_addr = funct7[6:2];
                       end
                      else
                      mem_lw = 1'b1;
                       alu_op = 4'b0000;
                     end
        7'b0100011 : begin // SD
                      inst_type = 4'b0011;
                      mem_sw = 1'b1;
                       alu_op = 4'b0000;
                     end
        7'b0110111 : begin // LUI
                      inst_type = 4'b0100;
                      reg_wr_en = 1'b1;
                     end
        7'b1100011 : begin // Branch
                      source_reg = 1'b1;
                      inst_type = 4'b0101;
                      alu_op = 4'b0001;
                      branch_specifier = funct3;
                     end
        7'b1101111 : begin // JAL
                      reg_wr_en = 1'b1;
                      inst_type = 4'b0110;
                     end
        7'b1100111 : begin // JALR
                      reg_wr_en = 1'b1;
                      inst_type = 4'b0111;
                      alu_op = 4'b0000;
                     end
        7'b1111111 : begin
                      case(funct3)
		       3'b000 :  processing_done =1'b1;
//		       3'b001 :  begin
  //                                  thread_sel_in = thread_logic_in[1:0];
      //                              thread_mux_sel_in = thread_lgic_in[3:2];
    //                                thread_en         = 1'b1;
        //                            thread_fixed_in   = thread_logic_in[5:4];
          //                       end
                       endcase
		     end
    endcase
 end
endmodule
