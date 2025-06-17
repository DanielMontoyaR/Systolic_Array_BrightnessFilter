`timescale 1ns / 1ps

module MMU_tb;
    parameter BIT_WIDTH = 16;
    parameter ACC_WIDTH = 40;
    parameter DEPTH = 4;
    
    // Inputs
    reg clk;
    reg control;
    reg [BIT_WIDTH*DEPTH-1:0] data_arr;  // 64 bits
    reg [BIT_WIDTH*DEPTH-1:0] wt_arr;    // 64 bits

    // Outputs
    wire [ACC_WIDTH*DEPTH-1:0] acc_out;      wire [7:0] pe30_norm_out, pe31_norm_out, pe32_norm_out, pe33_norm_out;
// 160 bits
    wire [ACC_WIDTH-1:0] pe30_out, pe31_out, pe32_out, pe33_out;

    // Señales para monitoreo interno
    wire [BIT_WIDTH-1:0] pe_weights [0:DEPTH-1][0:DEPTH-1];
    wire [BIT_WIDTH-1:0] pe_data_in [0:DEPTH-1][0:DEPTH-1];
    wire [BIT_WIDTH-1:0] pe_data_out [0:DEPTH-1][0:DEPTH-1];

    // Instantiate the Unit Under Test (UUT)
    TPU #(
        .bit_width(BIT_WIDTH),
        .acc_width(ACC_WIDTH)
    ) uut (
        .clk(clk),
        .control(control),
        .data_arr(data_arr),
        .wt_arr(wt_arr),
        .acc_out(acc_out),
        .pe30_out(pe30_out),
        .pe31_out(pe31_out),
        .pe32_out(pe32_out),
        .pe33_out(pe33_out),
    
        .pe30_norm_out(pe30_norm_out),
        .pe31_norm_out(pe31_norm_out),
        .pe32_norm_out(pe32_norm_out),
        .pe33_norm_out(pe33_norm_out));

    // Conexiones para monitoreo
	// Asignaciones directas para pesos
	assign pe_weights[0][0] = uut.wt_out[0][0];
	assign pe_weights[0][1] = uut.wt_out[0][1];
	assign pe_weights[0][2] = uut.wt_out[0][2];
	assign pe_weights[0][3] = uut.wt_out[0][3];

	assign pe_weights[1][0] = uut.wt_out[1][0];
	assign pe_weights[1][1] = uut.wt_out[1][1];
	assign pe_weights[1][2] = uut.wt_out[1][2];
	assign pe_weights[1][3] = uut.wt_out[1][3];

	assign pe_weights[2][0] = uut.wt_out[2][0];
	assign pe_weights[2][1] = uut.wt_out[2][1];
	assign pe_weights[2][2] = uut.wt_out[2][2];
	assign pe_weights[2][3] = uut.wt_out[2][3];

	assign pe_weights[3][0] = uut.wt_out[3][0];
	assign pe_weights[3][1] = uut.wt_out[3][1];
	assign pe_weights[3][2] = uut.wt_out[3][2];
	assign pe_weights[3][3] = uut.wt_out[3][3];

	// Asignaciones directas para data_out
	assign pe_data_out[0][0] = uut.data_out[0][0];
	assign pe_data_out[0][1] = uut.data_out[0][1];
	assign pe_data_out[0][2] = uut.data_out[0][2];
	assign pe_data_out[0][3] = uut.data_out[0][3];

	assign pe_data_out[1][0] = uut.data_out[1][0];
	assign pe_data_out[1][1] = uut.data_out[1][1];
	assign pe_data_out[1][2] = uut.data_out[1][2];
	assign pe_data_out[1][3] = uut.data_out[1][3];

	assign pe_data_out[2][0] = uut.data_out[2][0];
	assign pe_data_out[2][1] = uut.data_out[2][1];
	assign pe_data_out[2][2] = uut.data_out[2][2];
	assign pe_data_out[2][3] = uut.data_out[2][3];

	assign pe_data_out[3][0] = uut.data_out[3][0];
	assign pe_data_out[3][1] = uut.data_out[3][1];
	assign pe_data_out[3][2] = uut.data_out[3][2];
	assign pe_data_out[3][3] = uut.data_out[3][3];

	// Asignaciones directas para data_in (16 bits)
	assign pe_data_in[0][0] = uut.data_arr[15:0];  // PE(0,0) toma bits 15-0
	assign pe_data_in[0][1] = uut.data_out[0][0];  // PE(0,1) toma salida de PE(0,0)
	assign pe_data_in[0][2] = uut.data_out[0][1];  // PE(0,2) toma salida de PE(0,1)
	assign pe_data_in[0][3] = uut.data_out[0][2];  // PE(0,3) toma salida de PE(0,2)

	assign pe_data_in[1][0] = uut.data_arr[31:16]; // PE(1,0) toma bits 31-16
	assign pe_data_in[1][1] = uut.data_out[1][0];  // PE(1,1) toma salida de PE(1,0)
	assign pe_data_in[1][2] = uut.data_out[1][1];  // PE(1,2) toma salida de PE(1,1)
	assign pe_data_in[1][3] = uut.data_out[1][2];  // PE(1,3) toma salida de PE(1,2)

	assign pe_data_in[2][0] = uut.data_arr[47:32]; // PE(2,0) toma bits 47-32
	assign pe_data_in[2][1] = uut.data_out[2][0];  // PE(2,1) toma salida de PE(2,0)
	assign pe_data_in[2][2] = uut.data_out[2][1];  // PE(2,2) toma salida de PE(2,1)
	assign pe_data_in[2][3] = uut.data_out[2][2];  // PE(2,3) toma salida de PE(2,2)

	assign pe_data_in[3][0] = uut.data_arr[63:48]; // PE(3,0) toma bits 63-48
	assign pe_data_in[3][1] = uut.data_out[3][0];  // PE(3,1) toma salida de PE(3,0)
	assign pe_data_in[3][2] = uut.data_out[3][1];  // PE(3,2) toma salida de PE(3,1)
	assign pe_data_in[3][3] = uut.data_out[3][2];  // PE(3,3) toma salida de PE(3,2)
	 
	 

    // Clock generation
    initial begin
        clk = 0;
        forever #250 clk = ~clk;
    end

    // Función para mostrar pesos
    function void print_weights;
        $display("\nPesos en los PEs (T=%0t):", $time);
        $display("        Col0        Col1        Col2        Col3");
        for (int i = 0; i < DEPTH; i++) begin
            $display("Fila%d:  %4h        %4h        %4h        %4h", 
                    i, 
                    pe_weights[i][0], 
                    pe_weights[i][1], 
                    pe_weights[i][2], 
                    pe_weights[i][3]);
        end
    endfunction

    // Función para mostrar datos
    function void print_data_flow;
        $display("\nFlujo de Datos (T=%0t):", $time);
        $display("        Col0               Col1               Col2               Col3");
        for (int i = 0; i < DEPTH; i++) begin
            $display("Fila%d:  in:%4h/out:%4h  in:%4h/out:%4h  in:%4h/out:%4h  in:%4h/out:%4h", 
                    i,
                    pe_data_in[i][0], pe_data_out[i][0],
                    pe_data_in[i][1], pe_data_out[i][1],
                    pe_data_in[i][2], pe_data_out[i][2],
                    pe_data_in[i][3], pe_data_out[i][3]);
        end
    endfunction

    // Función para mostrar resultados
    function void print_results;
        $display("\nResultados Acumulados (T=%0t):", $time);
        $display("PE(3,0) = %10h (dec %0d)", pe30_out, pe30_out);
        $display("PE(3,1) = %10h (dec %0d)", pe31_out, pe31_out);
        $display("PE(3,2) = %10h (dec %0d)", pe32_out, pe32_out);
        $display("PE(3,3) = %10h (dec %0d)", pe33_out, pe33_out);
    endfunction

    initial begin
        // Inicialización
        control = 0;
        data_arr = 0;
        wt_arr = 0;
        #500;
        
        // Fase 1: Carga de pesos (matriz identidad)
        $display("\n=== FASE 1: CARGA DE PESOS ===");
        control = 1;
        
        // Carga por columnas (weight stationary)
        @(posedge clk);
        wt_arr = 64'h000a000000000000;  // Columna 0: [-1, 0, 0, 0]
        print_weights();
        
        @(posedge clk);
        wt_arr = 64'h0000000a00000000;  // Columna 1: [0, -1, 0, 0]
        print_weights();
        
        @(posedge clk);
        wt_arr = 64'h00000000000a0000;  // Columna 2: [0, 0, 1, 0]
        print_weights();
        
        @(posedge clk);
        wt_arr = 64'h000000000000000a;  // Columna 3: [0, 0, 0, 1]
        print_weights();
		  
        @(posedge clk);
        // Verificación final de pesos
		  control = 0;
        @(posedge clk);
        $display("\nPesos finales cargados:");
        print_weights();
        
        // Fase 2: Carga de datos en patrón diagonal
        $display("\n=== FASE 2: CARGA DE DATOS (PATRÓN DIAGONAL) ===");
        print_weights();
        // Ciclo 1: D0
        @(posedge clk);
        data_arr = 64'hxxxx_xxxx_xxxx_0000;  // [x, x, x, 0]
        print_data_flow();
		  print_weights();
        
        // Ciclo 2: D1, D0
        @(posedge clk);
        data_arr = 64'hxxxx_xxxx_0004_0001;  // [x, x, 4, 1]
        print_data_flow();
        
        // Ciclo 3: D2, D1, D0
        @(posedge clk);
        data_arr = 64'hxxxx_0008_0005_0002;  // [x, 8, 5, 2]
        print_data_flow();
        
        // Ciclo 4: D3, D2, D1, D0
        @(posedge clk);
        data_arr = 64'h000c_0009_0006_0003;  // [c, 9, 6, 3]
        print_data_flow();

		  @(posedge clk);
        data_arr = 64'h000d_000a_0007_xxxx;  // [d, a, 7, x]
        print_data_flow();
		  
		  @(posedge clk);
        data_arr = 64'h000e_000b_xxxx_xxxx;  // [e, b, x, x]
        print_data_flow();
		  
		  @(posedge clk);
        data_arr = 64'h001e_xxxx_xxxx_xxxx;  // [f, x, x, x]
        print_data_flow();
        
        // Ciclos adicionales para completar el flujo
        repeat(8) begin
            @(posedge clk);
            data_arr = 64'hxxxx_xxxx_xxxx_xxxx;  // Solo propagación
            print_data_flow();
            print_results();
        end
        
        // Verificación final
        $display("\n=== RESULTADOS FINALES ===");
        print_results();
        
        // Verificación automática (matriz identidad)
        if (pe30_out == 0 && pe31_out == 0 && pe32_out == 0 && pe33_out == 3) begin
            $display("TEST PASADO: Resultados correctos para patrón diagonal");
        end else begin
            $display("TEST FALLADO: Resultados incorrectos");
        end
        
        $finish;
    end
endmodule