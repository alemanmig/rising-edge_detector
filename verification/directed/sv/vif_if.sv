//--------------------------------------
//   Interfaz
//   archivo: vif_if.sv
//   Proyecto: rising-edge-detector
//
//---------------------------------------

interface vif_if(
    input logic clk_i
); 

  timeunit      1ns;
  timeprecision 100ps;
  
  
  logic rst_i;
  logic level_i;
  logic tick_o;


endinterface : vif_if