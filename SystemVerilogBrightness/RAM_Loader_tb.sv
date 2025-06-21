`timescale 1ns / 1ps

module RAM_Loader_tb;

    // Parámetros
    localparam RAM_ADDR_WIDTH = 6;
    localparam RAM_DATA_WIDTH = 8;
    localparam PE_DATA_WIDTH = 16;
    localparam DEPTH = 4;
    localparam LATENCY = 3;  // Latencia de la RAM

    // Señales
    logic clk;
    logic reset;
    logic start;
    logic [PE_DATA_WIDTH*DEPTH-1:0] data_out;
    logic data_valid;
    logic done;

    // Instancia del módulo bajo prueba
    RAM_Loader #(
        .RAM_ADDR_WIDTH(RAM_ADDR_WIDTH),
        .RAM_DATA_WIDTH(RAM_DATA_WIDTH),
        .PE_DATA_WIDTH(PE_DATA_WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_out(data_out),
        .data_valid(data_valid),
        .done(done)
    );

    // Generador de reloj (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Tarea para mostrar datos
    task print_block;
        input string tag;
        begin
            $display("T=%0t [%s]: Valid=%b, Done=%b, Out=%h",
                    $time, tag, data_valid, done, data_out);
            $display("  PE0: %h, PE1: %h, PE2: %h, PE3: %h",
                    data_out[15:0], data_out[31:16],
                    data_out[47:32], data_out[63:48]);
        end
    endtask

    // Proceso de prueba
    initial begin
        // Inicialización
        reset = 1;
        start = 0;
        #40 reset = 0;  // Reset por LATENCY+1 ciclos
        
        $display("\n=== TEST: Carga secuencial desde RAM ===");
        #10 start = 1;
        #10 start = 0;
        
        // Esperar a que se complete la carga
        wait(done);
        
        // Verificación final
        $display("\n=== RESULTADOS FINALES ===");
        $display("Bloques completos cargados: 16");
        $display("Señal done: %b", done);
        
        // Verificación explícita del primer y último bloque
        if (uut.data_buffer[0] == 16'h0009 && 
            uut.data_buffer[1] == 16'h0002 &&
            uut.data_buffer[2] == 16'h0003 &&
            uut.data_buffer[3] == 16'h0004) begin
            $display("Primer bloque CORRECTO");
        end else begin
            $display("ERROR en primer bloque");
        end
        
        if (done) begin
            $display("TEST PASADO: Todos los datos se cargaron correctamente");
        end else begin
            $display("TEST FALLADO");
        end
        
        $finish;
    end

    // Monitoreo de bloques completos
    always @(posedge data_valid) begin
        print_block("BLOCK");
    end

    // Monitoreo de estados
    always @(posedge clk) begin
        if (uut.current_state != uut.IDLE || data_valid) begin
            $display("T=%0t [STATE]: %s, Word=%d, Base=%d, Addr=%d",
                   $time,
                   uut.current_state == uut.IDLE ? "IDLE" :
                   uut.current_state == uut.LOAD ? "LOAD" :
                   uut.current_state == uut.FINISH ? "FINISH" : "DONE",
                   uut.word_counter, uut.base_addr, uut.ram_address);
        end
    end
endmodule