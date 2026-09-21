//+++++++++++++++++++++++++++++++++++++//
//
//  test
//  file: test.sv
//  proyecto: rising edge detector
//
//+++++++++++++++++++++++++++++++++++++//

module test (
    vif_if vif
);

  initial begin
    // Initial values
    $display("Begin Of Simulation.");
    //get_config_args();

    // Apply reset
    reset_init();
    
    // Test EDGE 002
    test_edge_002();
    
    // Test-EDGE 006
    reset();
    
    // Test EDGE 002_1
    test_edge_002_1();

    // Drain time
    #(100ns);
    $display("End Of Simulation.");
    $finish;
  end


  // ======================= TASKS ======================== //
  // ===== Definicion o generacion de señales del test ==== //

// Reset inicial
  task automatic reset_init();
    vif.rst_i = 1'b0;
    vif.level_i  = 1'b0;
    repeat (2) @(posedge vif.clk_i);
    vif.rst_i <= 1'b1;
    repeat (2) @(posedge vif.clk_i);
    vif.rst_i <= 1'b0;
    repeat (3) @(posedge vif.clk_i);
  endtask : reset_init

  
//TEST-EDGE-006: Verificación posterior a reset.
  task automatic reset();
    vif.rst_i = 1'b0;
    repeat (1) @(posedge vif.clk_i);
    vif.rst_i <= 1'b1;
    repeat (2) @(posedge vif.clk_i);
    vif.rst_i <= 1'b0;
    repeat (2) @(posedge vif.clk_i);
  endtask : reset

  task automatic test_edge_002 ();
    vif.level_i = 1'b1;
    @(posedge vif.clk_i);
    @(posedge vif.clk_i);
    vif.level_i= 1'b0;
  endtask : test_edge_002
  
    task automatic test_edge_002_2 ();
    vif.level_i = 1'b1;
    @(posedge vif.clk_i);
    vif.level_i= 1'b0;
  endtask : test_edge_002_2
  
  task automatic test_edge_002_1 ();
    vif.level_i = 1'b1;
    @(negedge vif.clk_i);
    vif.level_i= 1'b0;
    @(posedge vif.clk_i);
    vif.level_i = 1'b1;
    @(negedge vif.clk_i);
    vif.level_i= 1'b0;
  endtask : test_edge_002_1

endmodule : test