module comparator( input [55:0] in_data,
                    input [63:0] bloom_array,
                    output match);
  
  wire [5:0] i1, i2, i3;
  
  hash_function h1(.in_data(in_data), .i1(i1), .i2(i2), .i3(i3));
  
  assign match = bloom_array[i1] & bloom_array[i2] & bloom_array[i3];
  
endmodule
