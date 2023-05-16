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
  module hash_function (
    input [55:0] in_data,
    output reg [5:0] i1, i2, i3
  );
    
	
	
	wire [5:0] b1 = 6'b000010 & in_data[5:0];
	wire [5:0] b2 = 6'b010010 & in_data[11:6];
	wire [5:0] b3 = 6'b011010 & in_data[17:12];
	wire [5:0] b4 = 6'b011110 & in_data[23:18];
	wire [5:0] b5 = 6'b000010 & in_data[29:24];
	wire [5:0] b6 = 6'b100010 & in_data[35:30];
	wire [5:0] b7 = 6'b000011 & in_data[41:36];
	wire [5:0] b8 = 6'b000000 & in_data[47:42];
	wire [5:0] b9 = 6'b110010 & in_data[53:48];
	wire [5:0] b10 = 6'b111111 & {in_data[55:54], 4'b0};
	
	wire [5:0] c1 = 6'b000010 ^ in_data[5:0];
	wire [5:0] c2 = 6'b010010 ^ in_data[11:6];
	wire [5:0] c3 = 6'b011010 ^ in_data[17:12];
	wire [5:0] c4 = 6'b011110 ^ in_data[23:18];
	wire [5:0] c5 = 6'b000010 ^ in_data[29:24];
	wire [5:0] c6 = 6'b100010 ^ in_data[35:30];
	wire [5:0] c7 = 6'b000011 ^ in_data[41:36];
	wire [5:0] c8 = 6'b000000 ^ in_data[47:42];
	wire [5:0] c9 = 6'b110010 ^ in_data[53:48];
	wire [5:0] c10 = 6'b111111 ^ {in_data[55:54], 4'b0};

   wire [5:0] a1 = 6'b000010 | in_data[5:0];
	wire [5:0] a2 = 6'b010010 | in_data[11:6];
	wire [5:0] a3 = 6'b011010 | in_data[17:12];
	wire [5:0] a4 = 6'b011110 | in_data[23:18];
	wire [5:0] a5 = 6'b000010 | in_data[29:24];
	wire [5:0] a6 = 6'b100010 | in_data[35:30];
	wire [5:0] a7 = 6'b000011 | in_data[41:36];
	wire [5:0] a8 = 6'b000000 | in_data[47:42];
	wire [5:0] a9 = 6'b110010 | in_data[53:48];
	wire [5:0] a10 = 6'b111111 | {in_data[55:54], 4'b0};



    always@(*)
	 begin
      i1 = a1 ^ a2 ^ a3 ^ a4 ^ a5 ^ a6 ^ a7 ^ a8 ^ a9 ^ a10;
		i2 = b1 ^ b2 ^ b3 ^ b4 ^ b5 ^ b6 ^ b7 ^ b8 ^ b9 ^ b10;
		i3 = c1 ^ c2 ^ c3 ^ c4 ^ c5 ^ c6 ^ c7 ^ c8 ^ c9  ^c10;
    end
  endmodule
