

module bloom_filter( input [63:0] in_data, bloom_array_reg,
                     input [7:0] in_ctrl,
                     input clk, reset, in_wr,
                     output match,
                     output reg [31:0] matches_count);
  

reg [63:0] bloom_array;

always@(posedge clk)
 bloom_array <= bloom_array_reg;

  //Parameters
  parameter START = 2'b00;
  parameter HEADER = 2'b01;
  parameter PAYLOAD = 2'b10;
  
  //variable Declarations
  reg begin_pkt, begin_pkt_next, end_of_pkt, end_of_pkt_next;
  reg in_pkt_body, in_pkt_body_next;
  reg [1:0] state, state_next;
  reg [63:0] in_data_reg;
  
    
  wire matcher_rst = reset | end_of_pkt;
  wire matcher_en = in_pkt_body;
  
 
  hash_logic hashfilter (.in_data(in_data_reg), .clk(clk), .rst(matcher_rst), .match(match), .match_en(matcher_en), .bloom_array(bloom_array));
  

  always@(*) 
  begin
    state_next = state;
    end_of_pkt_next = 1'b0;
    in_pkt_body_next = 1'b0;
    begin_pkt_next = 1'b0;
	 
    
    if (in_wr)
	begin
    case(state)
      START: 
	  begin
        if(in_ctrl != 0 ) begin
        	state_next = HEADER;
          	begin_pkt_next = 1; 
        end
      end
        
      HEADER: 
	  begin
        if(in_ctrl == 0)
            state_next = PAYLOAD;
      
      end
      
      
      PAYLOAD:
	  begin
        if(in_ctrl != 0) 
		begin
          state_next = START;
          end_of_pkt_next = 1; 
			 
        end
        else
          in_pkt_body_next = 1'b1;
      end
    endcase 
	end
    
  end

  always @(posedge clk, posedge reset) 
  begin
      if(reset) 
	  begin
         state <= START;
         begin_pkt <= 0;
         end_of_pkt <= 0;
         in_pkt_body <= 0;
		 in_data_reg <= 0;
		 matches_count <= 0;
      end
      else 
	  begin
	     if(end_of_pkt && match)
		  matches_count <= matches_count +1;
	     in_data_reg <= in_data;
         state <= state_next;
         begin_pkt <= begin_pkt_next;
         end_of_pkt <= end_of_pkt_next;
         in_pkt_body <= in_pkt_body_next;
      end 
   end 

endmodule
        
        
      
      
      
        
        
