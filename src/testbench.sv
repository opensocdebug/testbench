
module testbench
  (
   input clk, rst,
   input glip_logic_rst,
   glip_channel.slave fifo_in,
   glip_channel.master fifo_out
   );

   localparam N = 3;

   dii_flit [N-1:0] dii_out; logic [N-1:0] dii_out_ready;
   dii_flit [N-1:0] dii_in; logic [N-1:0] dii_in_ready;   

   osd_him
     u_him(.*,
           .glip_in        ( fifo_in           ),
           .glip_out       ( fifo_out          ),
           .dii_out        ( dii_out[0]        ),
           .dii_out_ready  ( dii_out_ready[0]  ),
           .dii_in         ( dii_in[0]         ),
           .dii_in_ready   ( dii_in_ready[0]   )
           );

   osd_scm
     #(.SYSTEMID(16'hdead), .NUM_MOD(N-1))
   u_scm(.*,
         .id              ( 10'd1            ),
         .debug_in        ( dii_in[1]        ),
         .debug_in_ready  ( dii_in_ready[1]  ),
         .debug_out       ( dii_out[1]       ),
         .debug_out_ready ( dii_out_ready[1] )
         );

   logic [7:0] uart_char;
   logic       uart_valid;
   logic       uart_ready;
   reg [4:0]   counter;

   always_ff @(posedge clk) begin
      if (rst) begin
         counter <= 0;
      end else begin
         if (uart_ready & (counter < 14)) begin
            counter <= counter + 1;
         end
      end
   end

   always_comb begin
      uart_valid = 1;
      uart_char = 'x;
      
      case (counter)
        0: uart_char = 8'h48;
        1: uart_char = 8'h65;
        2: uart_char = 8'h6c;
        3: uart_char = 8'h6c;
        4: uart_char = 8'h6f;
        5: uart_char = 8'h20;
        6: uart_char = 8'h57;
        7: uart_char = 8'h6f;
        8: uart_char = 8'h72;
        9: uart_char = 8'h6c;
        10: uart_char = 8'h64;
        11: uart_char = 8'h21;
        12: uart_char = 8'h0a;
        default: uart_valid = 0;        
      endcase // case (counter)
   end
   
   osd_dem_uart
     u_uart (.*,
             .id              ( 10'd2            ),
             .debug_in        ( dii_in[2]        ),
             .debug_in_ready  ( dii_in_ready[2]  ),
             .debug_out       ( dii_out[2]       ),
             .debug_out_ready ( dii_out_ready[2] ),
             .out_char        ( uart_char        ),
             .out_valid       ( uart_valid       ),
             .out_ready       ( uart_ready       ),
             .in_char         (                  ),
             .in_valid        (                  ),
             .in_ready        ( '1               )
             );

   debug_ring
     #(.PORTS(N))
   u_ring(.*,
          .dii_in        ( dii_out       ),
          .dii_in_ready  ( dii_out_ready ),
          .dii_out       ( dii_in        ),
          .dii_out_ready ( dii_in_ready  )
          );

endmodule // testbench
