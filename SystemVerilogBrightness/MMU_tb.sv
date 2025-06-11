`timescale 1ns / 1ps

module MMU_tb;

    // Inputs
    reg clk;
    reg control;
    reg [31:0] data_arr;
    reg [31:0] wt_arr;

    // Outputs
    wire [95:0] acc_out;  // 24 bits * 4 = 96 bits
    wire [23:0] pe30_out, pe31_out, pe32_out, pe33_out;
	 
	 
	 // Señales para acceder a datos internos
    wire [7:0] pe_weights [3:0][3:0];  // [fila][columna]
    wire [7:0] pe_data_in [3:0][3:0];  // Datos de entrada a cada PE
    wire [7:0] pe_data_out [3:0][3:0]; // Datos de salida de cada PE
	 

	// Para fila 0
	assign pe_data_in[0][0] = uut.data_arr[7:0];
	assign pe_data_in[0][1] = uut.data_out[0][0];
	assign pe_data_in[0][2] = uut.data_out[0][1];
	assign pe_data_in[0][3] = uut.data_out[0][2];

	// Para filas 1-3
	
	// Conexiones internas para filas 1-3
	assign pe_data_in[1][0] = uut.data_arr[15:8];
	assign pe_data_in[1][1] = uut.data_out[1][0];
	assign pe_data_in[1][2] = uut.data_out[1][1];
	assign pe_data_in[1][3] = uut.data_out[1][2];

	assign pe_data_in[2][0] = uut.data_arr[23:16];
	assign pe_data_in[2][1] = uut.data_out[2][0];
	assign pe_data_in[2][2] = uut.data_out[2][1];
	assign pe_data_in[2][3] = uut.data_out[2][2];

	assign pe_data_in[3][0] = uut.data_arr[31:24];
	assign pe_data_in[3][1] = uut.data_out[3][0];
	assign pe_data_in[3][2] = uut.data_out[3][1];
	assign pe_data_in[3][3] = uut.data_out[3][2];

	// Salidas de todos los PEs
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
	assign pe_data_out[2][2] = uut.data_out[3][2];
	assign pe_data_out[2][3] = uut.data_out[3][3];
	
	assign pe_data_out[3][0] = uut.data_out[3][0];
	assign pe_data_out[3][1] = uut.data_out[3][1];
	assign pe_data_out[3][2] = uut.data_out[3][2];
	assign pe_data_out[3][3] = uut.data_out[3][3];
	
	
	
	 
	 
	 
	 
	 

    // Instantiate the Unit Under Test (UUT)
    TPU uut (
        .clk(clk),
        .control(control),
        .data_arr(data_arr),
        .wt_arr(wt_arr),
        .acc_out(acc_out),
        .pe30_out(pe30_out),
        .pe31_out(pe31_out),
        .pe32_out(pe32_out),
        .pe33_out(pe33_out)
    );

	  // Conexión a las señales internas de pesos
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

	 
	     // Función para mostrar los pesos
    function void print_weights;
        $display("\nPesos en los PEs:");
        $display("        Col0  Col1  Col2  Col3");
        for (int i = 0; i < 4; i++) begin
            $display("Fila%d:  %2h    %2h    %2h    %2h", 
                    i, 
                    pe_weights[i][0], 
                    pe_weights[i][1], 
                    pe_weights[i][2], 
                    pe_weights[i][3]);
        end
    endfunction
	 
	 
	 function void print_outputs;
		  $display("\nResultados:");
		  $display("PE(3,0) = 0x%h (%0d)", pe30_out, pe30_out);
        $display("PE(3,1) = 0x%h (%0d)", pe31_out, pe31_out);
        $display("PE(3,2) = 0x%h (%0d)", pe32_out, pe32_out);
        $display("PE(3,3) = 0x%h (%0d)", pe33_out, pe33_out);
	 endfunction
	 
	 
    // Función para mostrar datos

    function void print_data;
        $display("\nDatos en los PEs (Ciclo %0d):", $time/500);
        $display("        Col0     Col1     Col2     Col3");
        for (int i = 0; i < 4; i++) begin
            $display("Fila%d:  in:%2h/out:%2h  in:%2h/out:%2h  in:%2h/out:%2h  in:%2h/out:%2h", 
                    i,
                    pe_data_in[i][0], pe_data_out[i][0],
                    pe_data_in[i][1], pe_data_out[i][1],
                    pe_data_in[i][2], pe_data_out[i][2],
                    pe_data_in[i][3], pe_data_out[i][3]);
        end
    endfunction
	 
    // Clock generation
    initial begin
        clk = 0;
        forever #250 clk = ~clk;
    end

    initial begin
        // Initialize Inputs
        //control = 0;
        //data_arr = 0;
        //wt_arr = 0;
        
        // Wait for global reset
        //#500;
        
        // Load weights (column by column)
        @(posedge clk);
        control = 1;  // Weight loading mode
        
		  
		  $display("\nLOAD PROCESS STARTED:");
        // Column 0 weights: 1, 0, 0, 0
        wt_arr = 32'h01000000;
		  $display("T0:");
		  print_weights();
		  print_data();
        
        @(posedge clk);
        // Column 1 weights: 0, 1, 0, 0
        wt_arr = 32'h00010000;
		  $display("T1:");
		  print_weights();
		  print_data();
        
        @(posedge clk);
        // Column 2 weights: 0, 0, 1, 0
        wt_arr = 32'h00000100;
		  $display("T2:");
		  print_weights();
		  print_data();
        
        @(posedge clk);
        // Column 3 weights: 0, 0, 0, 1
        wt_arr = 32'h00000001;
		  $display("T3 FINISHED LOAD:");
		  print_weights();
		  print_data();
		  
		  @(posedge clk);
		  $display("T4");
		  print_weights();
		  print_data();
		  
		  
		  @(posedge clk);
		  $display("T5 Fully loaded:");
		  print_weights();
		  print_data();
		  
		  //@(posedge clk);
		  //print_weights();
        // Load data (row by row)
        //@(posedge clk);
        control = 0;  // Calculation mode
		  
        
        // Row 0 data: 0, 1, 2, 3
        data_arr = 32'h03020100;
		  
		  print_outputs();
		  print_weights();
		  $display("\nControl:", control);
        
        @(posedge clk);
        // Row 1 data: 4, 5, 6, 7
        data_arr = 32'h07060504;
		  $display("T6:");
		  print_outputs();
		  print_weights();
		  print_data();
		  $display("\nControl:", control);
		  
        @(posedge clk);
        // Row 2 data: 8, 9, 10, 11
        data_arr = 32'h0b0a0908;		  
		  $display("T7:");
        print_outputs();
		  print_weights();
		  print_data();
		  $display("\nControl:", control);
        
        @(posedge clk);
        // Row 3 data: 12, 13, 14, 15
        data_arr = 32'h0f0e0d0c;		  
		  $display("T8:");
        print_outputs();
		  print_weights();
		  print_data();
		  $display("\nControl:", control);
        
        // Wait for results to propagate
        @(posedge clk);
		  $display("T9");
        print_outputs();
		  print_data();
        
		  @(posedge clk);
		  $display("T10");
        print_outputs();
		  print_data();
        
		  @(posedge clk);
		  $display("T11");
        print_outputs();
		  print_data();
        
		  @(posedge clk);
		  $display("T12");
        print_outputs();
		  print_data();
        
		  @(posedge clk);
		  $display("T13");
        print_outputs();
		  print_data();
        
		  @(posedge clk);
		  $display("T14");
        print_outputs();
		  print_data();
        
		  @(posedge clk);
		  $display("T15");
        print_outputs();
		  print_data();
        
		  @(posedge clk);
		  $display("T16 FINISHED ALL");
        print_outputs();
		  print_data();
		  
		  
		  
		  repeat(10) @(posedge clk);
		  $display("T26 FINISHED ALL");
    
		 // Mostrar resultados solo cuando estén listos
		  print_outputs();
		  print_weights();
        $finish;
    end
endmodule