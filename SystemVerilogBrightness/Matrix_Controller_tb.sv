`timescale 1ns / 1ps

module Matrix_Controller_tb;

  // Parámetros de prueba
  parameter addr_width = 8;
  parameter data_width = 8;
  parameter chunk_size = 4;
  parameter matrix_size = 8;

  // Señales
  logic clk;
  logic rst;
  logic enable;
  logic start;

  logic [addr_width-1:0] out_addr;
  logic [data_width-1:0] out_data;
  logic out_valid;

  // Instancia del DUT
  Matrix_Controller #(
    .addr_width(addr_width),
    .data_width(data_width),
    .chunk_size(chunk_size),
    .matrix_size(matrix_size)
  ) uut (
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .start(start),
    .out_addr(out_addr),
    .out_data(out_data),
    .out_valid(out_valid)
  );

  // Generar reloj de 10ns
  always #5 clk = ~clk;

  // Inicialización
  initial begin
    clk = 0;
    rst = 1;
    enable = 0;
    start = 0;

    // Reset por 20ns
    #20 rst = 0;

    // Iniciar sistema
    #10 enable = 1;
         start = 1;

    // Esperar procesamiento completo
    #2000;

    $display("FIN de simulación.");
    $finish;
  end

  // Monitor de actividad de lectura
  always_ff @(posedge clk) begin
    if (out_valid) begin
      $display("Time=%0t | READ -> Addr=%0d Data=%0h",
                $time, out_addr, out_data);
    end
  end

endmodule
