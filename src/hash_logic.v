

module hash_logic( input [63:0] in_data, bloom_array,
                    input clk, rst, match_en,
                    output reg match);
  
 
  reg [63:0] prev_data;
  reg rst_reg;
  
  always@(posedge clk)
    rst_reg <= rst;

	
  wire [111:0] data = {prev_data[47:0], in_data};
  
 
  wire match_1, match_2, match_3, match_4, match_5, match_6, match_7, match_8;
  
 
  comparator c1 (.in_data(data[55:0]), .bloom_array(bloom_array), .match(match_1));
  
  comparator c2 (.in_data(data[63:8]), .bloom_array(bloom_array), .match(match_2));
  
  comparator c3 (.in_data(data[71:16]), .bloom_array(bloom_array), .match(match_3));

  comparator c4 (.in_data(data[79:24]), .bloom_array(bloom_array), .match(match_4));

  comparator c5 (.in_data(data[87:32]), .bloom_array(bloom_array), .match(match_5));

  comparator c6 (.in_data(data[95:40]), .bloom_array(bloom_array), .match(match_6));

  comparator c7 (.in_data(data[103:48]), .bloom_array(bloom_array), .match(match_7));
  
  comparator c8 (.in_data(data[111:56]), .bloom_array(bloom_array), .match(match_8));
  
 
  wire match_or = match_1 | match_2 | match_3 | match_4 | match_5 | match_6 | match_7 | match_8;
  
  
 
  always @ (posedge clk, posedge rst_reg)
    if (rst_reg) 
      prev_data <= 0;
    else 
      prev_data <= in_data;
 
  
  wire match_qual = ~match & match_en & match_or;
  wire clock_en = match_qual;
  
 
  always @ (posedge clk, posedge rst_reg) begin
    if (rst_reg) begin
      match <= 0;
    end else if (clock_en) begin
      match <= match_qual;
    end
  end
  
        
endmodule

