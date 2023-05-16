module alu_wrapper(input [63:0] a,
                   input [63:0] b,
                   input [3:0] op,
                   input [8:0] pc_ex,
                   input [3:0] inst_type_ex,
                   output reg [63:0] out_pc,
                   output reg [63:0] out_reg,
                   output slt, sltu, beq, bne, grt, grtu
);
wire [63:0] out_wire;

ALU alu(.a(a), .b(b), .op(op), .slt(slt), .sltu(sltu), .beq(beq), .bne(bne), .grt(grt), .grtu(grtu), .out(out_wire));

always@(*)
 begin
    case(inst_type_ex)
      4'b0100 : out_reg = b;
      4'b0111 : begin out_pc = out_wire & 64'hfffffffe;
                      out_reg = pc_ex;
                end
      4'b0110 :  out_reg = pc_ex;
      default : begin out_reg = out_wire;
                      out_pc  = 0;
                end
     endcase
 end   
endmodule    

