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

module branch_decoder(input [8:0]pc_mem, rs2_resolved_mem,
                      input [2:0]branch_funct3_mem,
                      input beq, blt, bne, bgr,
                      output reg [8:0] pc_mem_resolved ,
                      output reg branch);

always@(*)
  begin
    pc_mem_resolved = pc_mem;
    branch = 1'b0;
    case(branch_funct3_mem)
     3'b000 : begin
               if(beq)
					begin
                pc_mem_resolved = pc_mem + rs2_resolved_mem;
                branch = 1'b1;
					 end
              end 
     3'b001 : begin
               if(bne)
					begin
                pc_mem_resolved = pc_mem + rs2_resolved_mem ;
                branch = 1'b1;
					 end
              end 
     3'b100 : begin
               if(blt)
					begin
                pc_mem_resolved = pc_mem + rs2_resolved_mem ;
                branch = 1'b1;
					 end
              end 
     3'b101 : begin
               if(bgr || beq)
					begin
                pc_mem_resolved = pc_mem + rs2_resolved_mem ;
                branch = 1'b1;
					 end
              end 
    endcase
  end

endmodule
