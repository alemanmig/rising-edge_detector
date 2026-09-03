# Especificación de Requisitos de Hardware
# Detector de Flanco de Subida (Rising Edge Detector)

**ID del Documento:** EDGE-HRS-001  
**Versión:** 1.0  
**Estado:** Approved

**Tecnología Objetivo:** FPGA  
**Lenguaje de Implementación:** Verilog HDL / SystemVerilog

# 1. Propósito

El objetivo de este proyecto es diseñar e implementar un Detector de Flanco de Subida utilizando Verilog HDL o SystemVerilog.

El circuito deberá detectar transiciones de una señal de entrada desde lógica '0' hacia lógica '1' y generar un pulso de un ciclo de reloj indicando la ocurrencia del flanco de subida.

La implementación deberá ser completamente sintetizable y operar de manera síncrona con un único reloj del sistema.

# 2. Alcance

El diseño deberá incluir:

- Lógica de detección de flanco de subida
- Operación síncrona al reloj
- Generación de pulsos de un ciclo
- Soporte de reset

No forman parte del alcance:

- Detección de flanco de bajada
- Detección de doble flanco
- Debouncing
- Pulse stretching
- Clock-domain crossing
- Filtrado de glitches

# 3. Arquitectura de Referencia

## 3.1 Diagrama Funcional

```text
                  +----------------------+
 level ---------->| Detector de Flanco  |----------> tick
                  |      de Subida      |
                  +----------+-----------+
                             |
                            clk
```

## 3.2 Libertad de Diseño

La implementación interna queda a criterio del diseñador.

Son válidas arquitecturas basadas en:

- FSM Moore
- FSM Mealy
- Comparación con estado previo
- Arquitecturas síncronas equivalentes

# 4. Requisitos Funcionales

## EDGE-REQ-001
El detector deberá identificar transiciones de '0' a '1'.

## EDGE-REQ-002
El detector deberá generar una señal denominada `tick` al detectar un flanco de subida.

## EDGE-REQ-003
La señal `tick` deberá permanecer activa exactamente un ciclo de reloj.

## EDGE-REQ-004
No deberán generarse pulsos adicionales mientras la entrada permanezca en lógica '1'.

## EDGE-REQ-005
Después de regresar a lógica '0', el detector deberá poder detectar un nuevo flanco de subida.

## EDGE-REQ-006
Por cada flanco de subida válido deberá generarse exactamente un pulso.

# 5. Requisitos de Clock y Reset

## EDGE-REQ-010
El diseño deberá operar utilizando un único dominio de reloj.

## EDGE-REQ-011
Todas las salidas deberán ser síncronas al reloj del sistema.

## EDGE-REQ-012
El diseño deberá incluir una entrada de reset.

# 6. Interfaz

```systemverilog
module rising_edge_detector(
    input  logic clk,
    input  logic reset,
    input  logic level,
    output logic tick
);
```

# 7. Restricciones de Diseño

## EDGE-REQ-030
La implementación deberá ser completamente sintetizable.

## EDGE-REQ-031
No se permite utilizar delays (`#`).

## EDGE-REQ-032
No se permite generar relojes derivados.

## EDGE-REQ-033
No se permite clock gating.

# 8. Requisitos de Verificación

- TEST-EDGE-001: Sin pulsos cuando level=0.
- TEST-EDGE-002: Generación de pulso al ocurrir 0→1.
- TEST-EDGE-003: Verificación de ancho de pulso de un ciclo.
- TEST-EDGE-004: Sin pulsos adicionales mientras level=1.
- TEST-EDGE-005: Detección de múltiples flancos independientes.
- TEST-EDGE-006: Verificación posterior a reset.

# 9. Criterios de Aceptación

1. Todos los flancos de subida son detectados correctamente.
2. Se genera exactamente un pulso por cada flanco.
3. El pulso dura exactamente un ciclo.
4. No se generan pulsos espurios.
5. Todas las pruebas pasan.
6. El RTL es sintetizable.
