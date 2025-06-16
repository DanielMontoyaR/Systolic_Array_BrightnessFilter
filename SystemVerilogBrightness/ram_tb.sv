`timescale 1ns/1ps

module ram_tb;

  // Señales de prueba
  logic        clock;
  logic [5:0]  address;
  logic [7:0]  data = 8'h00;
  logic        wren = 1'b0;
  logic [7:0]  q;

  // Instancia del módulo RAM
  ram1 dut (
    .address(address),
    .clock(clock),
    .data(data),
    .wren(wren),
    .q(q)
  );

  // Generador de reloj: 10ns de periodo
  initial clock = 0;
  always #5 clock = ~clock;

  // Proceso de prueba
  initial begin
    // Espera un par de ciclos de reloj
    repeat (2) @(posedge clock);

    $display("Leyendo memoria inicializada desde .mif");
    $display("-----------------------------");
    $display("|  Addr  |   Dato en q      |");
    $display("-----------------------------");

    // Recorrido de direcciones
    for (int i = 0; i < 64; i++) begin
      address = i;
      @(posedge clock);
      $display("|   %2d   |       %3d       |", i, q);
    end

    $display("-----------------------------");
    $finish;
  end

endmodule
