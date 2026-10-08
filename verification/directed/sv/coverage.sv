//////////////////////////////////////////
//
//  Cobertura funcional
//  archivo: coverage.sv
//  proyecto: rising-edge-detector
//  referencia: docs/red_specs.md (EDGE-HRS-001)
//
//  Covergroup a nivel de interfaz (clk_i/rst_i/level_i/tick_o).
//  No referencia estado interno, igual que sva.sv, para ser
//  valido ante cualquier arquitectura permitida por la spec
//  (Moore, Mealy, comparacion con estado previo, etc).
//
//  Se instancia mediante bind en el top (ver tb/tb.sv).
//
//////////////////////////////////////////

module coverage (
    input logic clk_i,
    input logic rst_i,
    input logic level_i,
    input logic tick_o
);

  timeunit      1ns;
  timeprecision 100ps;

  // -------------------------------------------------------- //
  // Señales auxiliares solo para cobertura (no afectan al DUT)
  // -------------------------------------------------------- //

  // cuenta flancos detectados desde el ultimo reset, para
  // cobertura de multiples flancos independientes (TEST-EDGE-005)
  int unsigned edge_count;
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i)
      edge_count <= '0;
    else if (tick_o)
      edge_count <= edge_count + 1;
  end

  // registro de rst_i del ciclo anterior, para ubicar el ciclo
  // exacto en que se libera el reset (TEST-EDGE-006)
  logic rst_i_q;
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i)
      rst_i_q <= 1'b1;
    else
      rst_i_q <= rst_i;
  end
  wire reset_release = rst_i_q && !rst_i;

  // -------------------------------------------------------- //
  // Covergroup
  // -------------------------------------------------------- //
  covergroup cg_edge_detector @(posedge clk_i);
    option.per_instance = 1;
    option.name         = "cg_edge_detector";

    // EDGE-REQ-012 / TEST-EDGE-006: comportamiento del reset
    cp_reset: coverpoint rst_i {
      bins asserted    = (0 => 1);
      bins deasserted  = (1 => 0);
      bins held_active = (1 => 1);
    }

    // EDGE-REQ-001/005: transiciones de level_i
    cp_level: coverpoint level_i iff (!rst_i) {
      bins rising_edge  = (0 => 1);
      bins falling_edge = (1 => 0);
      bins steady_high  = (1 => 1);
      bins steady_low   = (0 => 0);
    }

    // EDGE-REQ-002/003: forma del pulso de tick_o (0=>1=>0)
    // "stuck_high" es ilegal: tick_o nunca deberia durar 2+ ciclos
    // (mismo invariante que la assertion a_pulse_width_one en sva.sv)
    cp_tick: coverpoint tick_o iff (!rst_i) {
      bins one_cycle_pulse   = (0 => 1 => 0);
      bins idle              = (0 => 0);
      illegal_bins stuck_high = (1 => 1);
    }

    // valores simples (no transiciones) para poder cruzarlos
    cp_level_val: coverpoint level_i iff (!rst_i) {
      bins low  = {0};
      bins high = {1};
    }

    cp_tick_val: coverpoint tick_o iff (!rst_i) {
      bins low  = {0};
      bins high = {1};
    }

    // TEST-EDGE-001/004: level_i=0 nunca debe coincidir con tick_o=1
    cx_level_tick: cross cp_level_val, cp_tick_val {
      illegal_bins level_low_with_tick =
        binsof(cp_level_val) intersect {0} && binsof(cp_tick_val) intersect {1};
    }

    // TEST-EDGE-005: multiples flancos independientes en una corrida
    cp_edge_count: coverpoint edge_count iff (!rst_i) {
      bins one_edge   = {1};
      bins few_edges  = {[2:4]};
      bins many_edges = {[5:$]};
    }

    // TEST-EDGE-006: level_i justo en el ciclo en que se libera el reset
    cp_level_at_reset_release: coverpoint level_i iff (reset_release) {
      bins low_at_release  = {0};
      bins high_at_release = {1};
    }
  endgroup : cg_edge_detector

  cg_edge_detector cg_inst = new();

endmodule : coverage
