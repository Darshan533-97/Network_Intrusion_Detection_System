module logic_analyzer(input clk,  input [31:0] logic_anylz_cmd,
                      logic_anylz_addr, input [255:0] pipeline_data,
                      input grant_in, grant_out, lock_in, lock_out, 
                      in_wr, in_wr0, in_wr1,
                      out_wr, out_wr1, out_wr0,
                      in_rdy, in_rdy0, in_rdy1,
                      out_rdy, out_rdy0, out_rdy1,
                      input [1:0] state_in0, state_in1, state_out0, state_out1,
                      output reg [255:0] logic_anylz_out );

reg start;
reg [255:0] pipeline_data_reg;
wire [255:0]logic_anylz_mem_out;
reg [8:0] counter;

wire full = (counter == 9'h1ff) ? 1'b1 : 1'b0;
wire reset = ~logic_anylz_cmd[0] && ~logic_anylz_cmd[4] && ~logic_anylz_addr[31];

always@(posedge clk)
pipeline_data_reg <=  {32'b0,  pipeline_data[223:12],
                       out_wr1, out_wr0, out_rdy0, out_rdy1,lock_out,
                       grant_out, in_wr0, in_wr1, in_rdy0,
                       in_rdy1,lock_in,grant_in} ;

wire enable = ~logic_anylz_cmd[3] && (!full);
wire wen = (!reset || !enable) ? 1'b0 : 1'b1;

always@(posedge clk, negedge reset)
 begin
     if(!reset)
          begin
          start <=0;
          counter <= 0;
          end
     else if(enable &&( pipeline_data_reg[30] || pipeline_data_reg[28] || (pipeline_data_reg[17:16] == 2'b11)))// ((in_ctrl == 8'hff) || start))
          begin
          start <= 1'b1;
          counter <= counter + 1;
          end
  end

                             t_mem memory(.clka(clk),
                                  .clkb(clk),
                                  .dinb(pipeline_data_reg),
                                  .addrb(counter),
                                  .addra(logic_anylz_addr),
                                  .web(wen),
                                  .douta(logic_anylz_mem_out) );

wire [31:0] last_word = full ? 32'hFAFAFAFA : 32'hFEDCBAAA;
always@(posedge clk, negedge reset)
   begin
      if(!reset)
         logic_anylz_out <= {32'hABCDEFFF, 224'b0};
      else
         logic_anylz_out <= {last_word[31:16],  logic_anylz_mem_out[239:0]};
   end
  

endmodule













