/////////////////////////////////////////
//  
//   TB
//   testbench rising-edge-detector
//   file: tb.sb
//
/////////////////////////////////////////

 module tb;

  timeunit      1ns;
  timeprecision 100ps;


  // Clock signal
  logic clk_i = 0;
  int unsigned MainClkPeriod = 10;  // 100 MHz -> 10 ns period
  always #(MainClkPeriod / 2) clk_i = ~clk_i;

  // Interface
  vif_if vif (clk_i);

  // Test
  test top_test (vif);

  // Instantiation
  edge_detect_moore
   dut (
      .clk_i(vif.clk_i),
      .rst_i(vif.rst_i),
      .level_i(vif.level_i),
      .tick_o(vif.tick_o)
  );
  

  initial begin
    $timeformat(-9, 1, "ns", 10);
  end
   
endmodule : tb