//////////////////////////////////////////
//
//  SVA checker (version explicita)
//  archivo: sva2.sv
//  proyecto: rising-edge-detector
//  referencia: docs/red_specs.md (EDGE-HRS-001)
//
//  Misma cobertura que sva.sv, pero sin clocking block: cada
//  property declara su propio @(posedge clk_i), y las properties
//  se definen por separado de los assert/cover que las evaluan.
//
//////////////////////////////////////////

module sva2 (
    input logic clk_i,
    input logic rst_i,
    input logic level_i,
    input logic tick_o
);

  // -------------------------------------------------------- //
  // Reset (EDGE-REQ-012 / TEST-EDGE-006)
  // -------------------------------------------------------- //
  // Nota: estas dos NO llevan disable iff(rst_i): justamente
  // verifican lo que pasa durante/al salir del reset. Si se
  // deshabilitaran con rst_i quedarian siempre vacuas.
  property p_reset_tick_low;
    @(posedge clk_i) rst_i |-> !tick_o;
  endproperty

  property p_post_reset_tick_low;
    @(posedge clk_i) $fell(rst_i) |-> !tick_o;
  endproperty

  a_reset_tick_low: assert property (p_reset_tick_low)
    else $error("tick_o activo durante reset");

  a_post_reset_tick_low: assert property (p_post_reset_tick_low)
    else $error("tick_o activo justo al salir de reset");

  // -------------------------------------------------------- //
  // Sin pulsos cuando level_i=0 (EDGE-REQ-004 / TEST-EDGE-001)
  // -------------------------------------------------------- //
  property p_no_tick_level_low;
    @(posedge clk_i) disable iff (rst_i) !level_i |=> !tick_o;
  endproperty

  a_no_tick_level_low: assert property (p_no_tick_level_low)
    else $error("tick_o activo un ciclo despues de level_i=0");

  // -------------------------------------------------------- //
  // Generacion de pulso al detectar 0->1 (EDGE-REQ-001/002 / TEST-EDGE-002)
  // -------------------------------------------------------- //
  property p_edge_detected;
    @(posedge clk_i) disable iff (rst_i) $rose(level_i) |=> tick_o;
  endproperty

  a_edge_detected: assert property (p_edge_detected)
    else $error("flanco de subida en level_i no genero tick_o");

  // -------------------------------------------------------- //
  // Ancho de pulso = 1 ciclo (EDGE-REQ-003 / TEST-EDGE-003)
  // -------------------------------------------------------- //
  property p_pulse_width_one;
    @(posedge clk_i) disable iff (rst_i) tick_o |=> !tick_o;
  endproperty

  a_pulse_width_one: assert property (p_pulse_width_one)
    else $error("tick_o se mantuvo activo mas de un ciclo");

  // -------------------------------------------------------- //
  // Sin pulsos adicionales mientras level_i se mantiene en 1
  // (EDGE-REQ-004 / TEST-EDGE-004)
  // -------------------------------------------------------- //
  property p_no_extra_pulse_while_high;
    @(posedge clk_i) disable iff (rst_i)
      tick_o |=> (!tick_o throughout level_i[+]);
  endproperty

  a_no_extra_pulse_while_high: assert property (p_no_extra_pulse_while_high)
    else $error("tick_o se reactivo sin que level_i regresara a 0");

  // -------------------------------------------------------- //
  // Deteccion de multiples flancos independientes (TEST-EDGE-005)
  // -------------------------------------------------------- //
  property p_multiple_independent_edges;
    @(posedge clk_i) disable iff (rst_i)
      $rose(level_i) ##1 tick_o ##1 $fell(level_i) ##[1:$] $rose(level_i) ##1 tick_o;
  endproperty

  c_multiple_independent_edges: cover property (p_multiple_independent_edges);

  // -------------------------------------------------------- //
  // Sanidad de señales (EDGE-REQ-011: salidas sincronas al reloj)
  // -------------------------------------------------------- //
  property p_no_unknown;
    @(posedge clk_i) disable iff (rst_i) !$isunknown({level_i, tick_o});
  endproperty

  a_no_unknown: assert property (p_no_unknown)
    else $error("valor X/Z detectado en level_i o tick_o");

endmodule : sva2
