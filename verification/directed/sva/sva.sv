//////////////////////////////////////////
//
//  SVA checker
//  archivo: sva.sv
//  proyecto: rising-edge-detector
//  referencia: docs/red_specs.md (EDGE-HRS-001)
//
//  Assertions a nivel de interfaz (clk_i/rst_i/level_i/tick_o).
//  No referencian estado interno para que el checker sea valido
//  para cualquier arquitectura permitida por la especificacion
//  (Moore, Mealy, comparacion con estado previo, etc).
//
//  Se instancia mediante bind en el top (ver tb/tb.sv).
//
//////////////////////////////////////////

module sva (
    input logic clk_i,
    input logic rst_i,
    input logic level_i,
    input logic tick_o
);

  timeunit      1ns;
  timeprecision 100ps;

  default clocking cb @(posedge clk_i); endclocking
  default disable iff (rst_i);

  // -------------------------------------------------------- //
  // Reset (EDGE-REQ-012 / TEST-EDGE-006)
  // -------------------------------------------------------- //
  a_reset_tick_low: assert property (
    rst_i |-> !tick_o
  ) else $error("tick_o activo durante reset");

  a_post_reset_tick_low: assert property (
    $fell(rst_i) |-> !tick_o
  ) else $error("tick_o activo justo al salir de reset");

  // -------------------------------------------------------- //
  // Sin pulsos cuando level_i=0 (EDGE-REQ-004 / TEST-EDGE-001)
  // -------------------------------------------------------- //
  a_no_tick_level_low: assert property (
    !level_i |=> !tick_o
  ) else $error("tick_o activo un ciclo despues de level_i=0");

  // -------------------------------------------------------- //
  // Generacion de pulso al detectar 0->1 (EDGE-REQ-001/002 / TEST-EDGE-002)
  // -------------------------------------------------------- //
  a_edge_detected: assert property (
    $rose(level_i) |=> tick_o
  ) else $error("flanco de subida en level_i no genero tick_o");

  // -------------------------------------------------------- //
  // Ancho de pulso = 1 ciclo (EDGE-REQ-003 / TEST-EDGE-003)
  // -------------------------------------------------------- //
  a_pulse_width_one: assert property (
    tick_o |=> !tick_o
  ) else $error("tick_o se mantuvo activo mas de un ciclo");

  // -------------------------------------------------------- //
  // Sin pulsos adicionales mientras level_i se mantiene en 1
  // (EDGE-REQ-004 / TEST-EDGE-004)
  // -------------------------------------------------------- //
  a_no_extra_pulse_while_high: assert property (
    tick_o |=> (!tick_o throughout level_i[+])
  ) else $error("tick_o se reactivo sin que level_i regresara a 0");

  // -------------------------------------------------------- //
  // Deteccion de multiples flancos independientes (TEST-EDGE-005)
  // -------------------------------------------------------- //
  c_multiple_independent_edges: cover property (
    $rose(level_i) ##1 tick_o ##1 $fell(level_i) ##[1:$] $rose(level_i) ##1 tick_o
  );

  // -------------------------------------------------------- //
  // Sanidad de señales (EDGE-REQ-011: salidas sincronas al reloj)
  // -------------------------------------------------------- //
  a_no_unknown: assert property (
    !$isunknown({level_i, tick_o})
  ) else $error("valor X/Z detectado en level_i o tick_o");

endmodule : sva
