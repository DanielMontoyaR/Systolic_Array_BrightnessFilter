`timescale 1ns / 1ps

module TPU_System_tb;

    // Parámetros
    localparam CLK_PERIOD = 20; // 50 MHz

    // Señales
    logic clk;
    logic reset;
    logic start;
    logic done;
    logic [39:0] pe30_out, pe31_out, pe32_out, pe33_out;
    logic [15:0] pe30_norm_out, pe31_norm_out, pe32_norm_out, pe33_norm_out;

    // Instancia del sistema
    TPU_System #(
        .MATRIX_SIZE(8)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .pe30_out(pe30_out),
        .pe31_out(pe31_out),
        .pe32_out(pe32_out),
        .pe33_out(pe33_out),
        .pe30_norm_out(pe30_norm_out),
        .pe31_norm_out(pe31_norm_out),
        .pe32_norm_out(pe32_norm_out),
        .pe33_norm_out(pe33_norm_out)
    );

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
        #100;
        reset = 0;

        // Iniciar procesamiento
        start = 1;
        #(CLK_PERIOD);
        start = 0;

        // Esperar a que termine
        wait (done);
        #200;

        // Mostrar resultados
        $display("Resultados:");
        $display("PE30: %d (Normalizado: %d)", pe30_out, pe30_norm_out);
        $display("PE31: %d (Normalizado: %d)", pe31_out, pe31_norm_out);
        $display("PE32: %d (Normalizado: %d)", pe32_out, pe32_norm_out);
        $display("PE33: %d (Normalizado: %d)", pe33_out, pe33_norm_out);

        $finish;
    end

endmodule