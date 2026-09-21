//////////////////////////////
// Ejercicio Verificacion
// edge_detector
// referencia: Pong Chu
// fecha: 07/09/26
//
////////////////////////////////

module edge_detect_moore(
    input logic clk_i, 
    input logic rst_i, 
    input logic level_i, 
    output logic tick_o
);

// fsm state type

typedef enum {zero, edg, one} state_type;

// signal declaration
state_type state_reg, state_next;

// state register
  always_ff @(posedge clk_i, posedge rst_i) 
  begin
    if (rst_i)
      begin 
        state_reg <= zero;
      end
    else
      begin
        state_reg <= state_next;
      end
  end
// next-state logic and ouput logic 
always_comb 
  begin 
    state_next = state_reg;   // default state: the samme
    tick_o = 1'b0;
    case (state_reg)
      zero:
        if (level_i)
           state_next = edg;
      edg:
        begin
          tick_o  = 1'b1;
          if (level_i) 
             state_next = one;
          else 
             state_next = zero;
        end
      one: 
        if (~level_i)
           state_next = zero;
      default: state_next = zero;
    endcase 

  end

endmodule