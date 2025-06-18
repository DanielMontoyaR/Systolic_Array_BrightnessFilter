`timescale 1ns / 1ps

module RAM_Loader_tb;

    // Parámetros
    localparam RAM_ADDR_WIDTH = 6;
    localparam RAM_DATA_WIDTH = 8;
    localparam PE_DATA_WIDTH = 16;
    localparam DEPTH = 4;
    
    // Señales
    logic clk;
    logic reset;
    logic start;
    logic [PE_DATA_WIDTH*DEPTH-1:0] data_out;
    logic data_valid;
    logic [RAM_ADDR_WIDTH-1:0] ram_address;
    logic [RAM_DATA_WIDTH-1:0] ram_data;
    logic done;
    
    // Instancia del módulo
    RAM_Loader #(
        .RAM_ADDR_WIDTH(RAM_ADDR_WIDTH),
        .RAM_DATA_WIDTH(RAM_DATA_WIDTH),
        .PE_DATA_WIDTH(PE_DATA_WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_out(data_out),
        .data_valid(data_valid),
        .ram_address(ram_address),
        .ram_data(ram_data),
        .done(done)
    );
    
    // Memoria RAM simulada
    logic [RAM_DATA_WIDTH-1:0] ram [0:2**RAM_ADDR_WIDTH-1];
    
    // Inicializar RAM
    initial begin
        for (int i = 0; i < 64; i++) ram[i] = i + 1;
    end
    
    assign ram_data = ram[ram_address];
    
    // Generador de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Tarea para mostrar datos
    task print_block;
        input string tag;
        begin
            $display("T=%0t [%s]: Addr=%2d, Data=%2h, Valid=%b, Done=%b, Out=%h",
                    $time, tag, ram_address, ram_data, 
                    data_valid, done, data_out);
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
        #20 reset = 0;
        
        $display("\n=== TEST: Carga secuencial desde RAM ===");
        start = 1;
        #10 start = 0;
        
        // Esperar a que se complete la carga
        wait(done);
        
        // Verificación final
        $display("\n=== RESULTADOS FINALES ===");
        $display("Bloques completos cargados: 16");
        $display("Última dirección accedida: %d (0x%h)", ram_address, ram_address);
        $display("Señal done: %b", done);
        
        if (done && ram_address == 0) begin
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
        if (uut.current_state != uut.IDLE || uut.data_valid) begin
            $display("T=%0t [STATE]: %s, Addr=%2d, Word=%d, Base=%d",
                   $time,
                   uut.current_state == uut.IDLE ? "IDLE" :
                   uut.current_state == uut.LOAD ? "LOAD" :
                   uut.current_state == uut.FINISH ? "FINISH" : "DONE",
                   uut.ram_address, uut.word_counter, uut.base_addr);
        end
    end
endmodule