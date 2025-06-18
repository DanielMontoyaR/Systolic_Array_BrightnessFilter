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
    task print_status;
        input string tag;
        begin
            $display("T=%0t [%s]: Addr=%d, Data=%h, Valid=%b, Done=%b, Out=%h",
                    $time, tag, ram_address, ram_data, 
                    data_valid, done, data_out);
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
        
        // Monitorear todos los bloques
        while (!done) begin
            @(posedge data_valid);
            print_status("DATA");
        end
        
        // Verificación final
        $display("\n=== RESULTADOS ===");
        $display("Bloques completos cargados: %d", (2**RAM_ADDR_WIDTH)/DEPTH);
        $display("Última dirección accedida: %d", ram_address);
        
        if (ram_address == 0 && done) begin
            $display("TEST PASADO: Todos los datos se cargaron correctamente");
        end else begin
            $display("TEST FALLADO");
        end
        
        $finish;
    end
    
    // Monitoreo continuo
    always @(posedge clk) begin
        if (uut.current_state == uut.LOAD) begin
            print_status("MONITOR");
        end
    end
endmodule