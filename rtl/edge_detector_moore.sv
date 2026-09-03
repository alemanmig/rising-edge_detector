module edge_detect_moore(
    input logic clk, 
    input logic rst, 
    input logic level, 
    output logic tick
);

// fsm state type

typedef enum {zero, edg, one} state_type;

// signal declaration
state_type state_reg, state_next;

// state register
always_ff @(posedge clk, posedge reset) 
  begin
    if (reset)
      begin 
        state_reg <= zero:
      end
    else
      begin
        state_reg <= state_next:
      end
  end
// next-state logic and ouput logic 
always_comb 
  begin 
    state_next = state_reg;   // default state: the samme
    tick = 1'b0;
    case (state_reg)
      zero:
        if (level)
           state_next = edg;
      edg:
        begin
          tick  = 1'b1;
          if (level) 
             state_next = one;
          else 
             state_next = zero;
        end
      one: 
        if (~level)
           state_next = zero;
      default: state_next = zero;
    endcase 

  end

endmodule