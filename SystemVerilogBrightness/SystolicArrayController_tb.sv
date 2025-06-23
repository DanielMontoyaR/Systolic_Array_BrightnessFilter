`timescale 1ns / 1ps

module SystolicArrayController_tb;

    // Parámetros
    localparam RAM_ADDR_WIDTH = 6;
    localparam RAM_DATA_WIDTH = 8;
    localparam PE_DATA_WIDTH = 16;
    localparam DEPTH = 4;
    localparam ACC_WIDTH = 40;

    // Señales
    logic clk;
    logic reset;
    logic start;
    logic done;
    
    // Señales de monitoreo
    logic [PE_DATA_WIDTH*DEPTH-1:0] current_data_out;
    logic [PE_DATA_WIDTH*DEPTH-1:0] current_weights_out;
    logic [ACC_WIDTH-1:0] pe30_out, pe31_out, pe32_out, pe33_out;
    logic [15:0] pe30_norm_out, pe31_norm_out, pe32_norm_out, pe33_norm_out;

    // Instancia del módulo bajo prueba
    SystolicArrayController #(
        .RAM_ADDR_WIDTH(RAM_ADDR_WIDTH),
        .RAM_DATA_WIDTH(RAM_DATA_WIDTH),
        .PE_DATA_WIDTH(PE_DATA_WIDTH),
        .DEPTH(DEPTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .current_data_out(current_data_out),
        .current_weights_out(current_weights_out),
        .pe30_out(pe30_out),
        .pe31_out(pe31_out),
        .pe32_out(pe32_out),
        .pe33_out(pe33_out),
        .pe30_norm_out(pe30_norm_out),
        .pe31_norm_out(pe31_norm_out),
        .pe32_norm_out(pe32_norm_out),
        .pe33_norm_out(pe33_norm_out)
    );

    // Generador de reloj (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Tarea para mostrar datos
    task print_data_block;
        input string tag;
        begin
            $display("T=%0t [%s]: Data=%h Weights=%h", 
                    $time, tag, current_data_out, current_weights_out);
            $display("  PE0: %h, PE1: %h, PE2: %h, PE3: %h",
                    current_data_out[15:0], current_data_out[31:16],
                    current_data_out[47:32], current_data_out[63:48]);
        end
    endtask

    // Tarea para mostrar resultados
    task print_results;
        begin
            $display("T=%0t [RESULTS]:", $time);
            $display("  PE30: %h (norm: %h)", pe30_out, pe30_norm_out);
            $display("  PE31: %h (norm: %h)", pe31_out, pe31_norm_out);
            $display("  PE32: %h (norm: %h)", pe32_out, pe32_norm_out);
            $display("  PE33: %h (norm: %h)", pe33_out, pe33_norm_out);
        end
    endtask

    // Proceso de prueba
    initial begin
        // Inicialización
        reset = 1;
        start = 0;
        #100 reset = 0;
        
        // Esperar un poco después del reset
        #50;
        
        // Iniciar la carga y procesamiento
        $display("\n=== INICIANDO PRUEBA DE INTEGRACIÓN ===");
        start = 1;
        #10 start = 0;
        
        // Esperar a que termine el procesamiento
        wait(done);
        
        // Mostrar resultados finales
        $display("\n=== RESULTADOS FINALES ===");
        print_results();
        
        // Verificación básica
        if (pe30_norm_out !== 0 || pe31_norm_out !== 0 || 
            pe32_norm_out !== 0 || pe33_norm_out !== 0) begin
            $display("TEST: Se detectaron resultados no cero");
        end else begin
            $display("TEST: Todos los resultados son cero (esperado para RAM no inicializada)");
        end
        
        $finish;
    end

    // Monitoreo de actividad
    always @(posedge clk) begin
        if (uut.ram_loader.data_valid) begin
            print_data_block("DATA_VALID");
        end
        
        if (uut.systolic_array.control) begin
            $display("T=%0t [CONTROL]: Cargando pesos en el arreglo sistólico", $time);
        end
    end

    // Monitoreo de estados
    always @(posedge clk) begin
        if (uut.ram_loader.current_state != uut.ram_loader.IDLE) begin
            $display("T=%0t [RAM_LOADER_STATE]: %s", $time,
                   uut.ram_loader.current_state == uut.ram_loader.IDLE ? "IDLE" :
                   uut.ram_loader.current_state == uut.ram_loader.LOAD ? "LOAD" :
                   uut.ram_loader.current_state == uut.ram_loader.WAIT_TPU ? "WAIT_TPU" :
                   uut.ram_loader.current_state == uut.ram_loader.FINISH ? "FINISH" : "DONE");
        end
    end
endmodule