`timescale 1ns / 1ps

module Matrix_Controller_tb;

    // Parámetros
    parameter CLK_PERIOD = 10; // 100 MHz
    parameter MATRIX_SIZE = 8; // Matriz 8x8
    parameter CHUNK_SIZE = 4;  // Chunk 4x4

    // Señales
    logic clk;
    logic reset;
    logic start;
    logic done;
    logic [5:0] ram_addr;
    logic [7:0] ram_data;
    logic [63:0] tpu_data_arr;
    logic tpu_control;
    logic tpu_ready;

    // Instancia del módulo bajo prueba
    Matrix_Controller #(
        .MATRIX_SIZE(MATRIX_SIZE)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .ram_addr(ram_addr),
        .ram_data(ram_data),
        .tpu_data_arr(tpu_data_arr),
        .tpu_control(tpu_control),
        .tpu_ready(tpu_ready)
    );

    // Simulación de la RAM (8x8, valores del 1 al 64)
    logic [7:0] ram [0:63];
    initial begin
        for (int i = 0; i < 64; i++) begin
            ram[i] = i + 1; // Inicializa con valores 1..64
        end
    end
    assign ram_data = ram[ram_addr]; // Lectura de la RAM

    // Generación de reloj
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Secuencia de prueba
    initial begin
        // Inicialización
        reset = 1;
        start = 0;
        tpu_ready = 1; // TPU siempre listo
        #20;
        reset = 0;
        #20;

        // Caso de prueba 1: Procesar toda la matriz 8x8
        $display("=== Iniciando procesamiento ===");
        start = 1;
        #CLK_PERIOD;
        start = 0;

        // Monitorear salidas
        wait (done);
        $display("=== Procesamiento completado ===");
        #100;

        // Finalizar simulación
        $finish;
    end

    // Monitor: Imprime tpu_data_arr en cada flanco de reloj
    always @(posedge clk) begin
        if (tpu_control) begin
            $display("[T=%0t] tpu_data_arr = %h", $time, tpu_data_arr);
            // Desglose de los 4 valores de 16 bits
            $display("    Valores: %d, %d, %d, %d",
                tpu_data_arr[15:0],
                tpu_data_arr[31:16],
                tpu_data_arr[47:32],
                tpu_data_arr[63:48]);
        end
    end

endmodule