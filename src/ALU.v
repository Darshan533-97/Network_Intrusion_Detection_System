`timescale 1ns / 1ps
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
//module add_sub (input a,  b, cin, sub, output s,cout );
//wire bm = sub ? ~b : b;
//assign {cout, s} = a  + bm + cin;
//endmodule 


module ALU(
    input [63:0] a,
    input [63:0] b,
    input [3:0] op,
    output reg [63:0] out,
    output slt, sltu, beq, bne, grt, grtu
    );
wire [63:0]  sum, cout;
reg sub, cin;
wire soverflow;
reg C63;

reg        [63:0] a_unsigned, b_unsigned;
reg signed [63:0] a_signed, b_signed;

always@(*)
 begin
    a_unsigned = a;
    b_unsigned = b;
    a_signed = a;
    b_signed = b;
 end

assign soverflow = (~op[3] & ~op[2] & ~op[1] &
                    (~op[0] & ~a[63] & ~b[63] & out[63]) |
                    (~op[0] & a[63] & b[63] & ~out[63]) |
                    (op[0] & a[63] & ~b[63] & ~out[63]) |
                    (op[0] & ~a[63] & b[63] & out[63]) 
                     );
assign sltu = ~C63;
assign grtu = ~sltu;
assign slt = soverflow ^ out[63];
assign grt = ~slt;
assign beq = ~|out;
assign bne = ~beq;

//add_sub a0 (.a(a[0]), .b(b[0]), .cin(cin), .sub(sub), .s(sum[0]), .cout(cout[0]));

//genvar i;
//generate
//for(i=1; i<32; i=i+1)
//begin: add_sub_blocks
//add_sub ai(.a(a[i]), .b(b[i]), .cin(cout[i-1]), .sub(sub), .s(sum[i]), .cout(cout[i]));
//end
//endgenerate

always@(*)
begin
out = 0;
C63 = 0;
case(op)
4'b0000 :{C63,out} = a+b; //sum;			
4'b0001 :{C63,out} = a-b; // sum;
4'b0010 : out = a | b;
4'b0011 : out = a & b;
4'b0100 : out = a ^ b;
4'b0101 : out = a ~^ b;
4'b0110 : out = a_unsigned << b_unsigned[5:0];
4'b0111 : out = a_unsigned >> b_unsigned[5:0];
4'b1000 : out = a_signed <<< b_signed[5:0];
4'b1001 : out = a_signed >>> b_signed[5:0];
endcase
end


endmodule

