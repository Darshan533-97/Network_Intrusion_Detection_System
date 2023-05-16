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

module rs2_decoder(input [24:0] inst_7to31,
                   input [3:0] inst_type,
                   input [8:0] pc_id,
                   output reg [63:0] rs2_resolved);

always@(*)
  begin
    rs2_resolved = 0;
      case(inst_type)
        4'b0001 : rs2_resolved = {{52{inst_7to31[24]}},inst_7to31[24:13]};//R-I
        4'b0010 : rs2_resolved = {{52{inst_7to31[24]}},inst_7to31[24:13]};//LD
        4'b0111 : rs2_resolved = {{52{inst_7to31[24]}},inst_7to31[24:13]};//JALR
        4'b0110 : rs2_resolved = {{44{inst_7to31[24]}},inst_7to31[24:5]} + {55'b0, pc_id} ;//JAL
        4'b0011 : rs2_resolved = {{52{inst_7to31[24]}},inst_7to31[24:18],inst_7to31[4:0]};//SD
        4'b0100 : rs2_resolved = {{32{inst_7to31[24]}},inst_7to31[24:5],12'b0};//LUI
        4'b0101 : rs2_resolved = {{52{inst_7to31[24]}},inst_7to31[24:18],inst_7to31[4:0]};//BRANCH
      endcase
  end

   //     4'b0101 : rs2_resolved = {{19{inst_7to31[24]}},inst_7to31[24],inst_7to31[0],inst_7to31[23:18],inst_7to31[4:1],1'b0};//BRANCH
 //  4'b0110 : rs2_resolved = {{20{inst_7to31[24]}},inst_7to31[12:5],inst_7to31[13],inst_7to31[23:14],1'b0} + {23'b0, pc_id} -1;//JAL
endmodule
