`timescale 1ns / 1ps

module MMU_tb;
    // Parámetros configurables
    parameter DEPTH = 4;
    parameter BIT_WIDTH = 8;
    parameter ACC_WIDTH = 32;
    parameter CLK_PERIOD = 500; // 500 ns (250 ns cada flanco)

    // Señales
    logic clk;
    logic control;
    logic [BIT_WIDTH*DEPTH-1:0] data_arr;
    logic [BIT_WIDTH*DEPTH-1:0] wt_arr;
    logic [ACC_WIDTH*DEPTH-1:0] acc_out;
	 logic [ACC_WIDTH-1:0] final_accs [DEPTH];  // final_accs[0] = PE[0][3], ..., final_accs[3] = PE[3][3]

    // Instancia del módulo bajo prueba (TPU o MMU)
    TPU #(
        .depth(DEPTH),
        .bit_width(BIT_WIDTH),
        .acc_width(ACC_WIDTH),
        .size(DEPTH)
    ) uut (
        .clk(clk),
        .control(control),
        .data_arr(data_arr),
        .wt_arr(wt_arr),
        .acc_out(acc_out),
		  .final_accs(final_accs)
    );

    // Generación de reloj
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Secuencia de estímulos
    initial begin
        // Inicialización
        control = 0;
        data_arr = 0;
        wt_arr = 0;
        #5000; // Espera inicial

        // Fase de pesos (4 ciclos)
        @(posedge clk);
        control = 1;
        wt_arr = 32'h00000001; // W0, W1, W2, W3

        @(posedge clk);
        wt_arr = 32'h00000100;

        @(posedge clk);
        wt_arr = 32'h00010000;

        @(posedge clk);
        wt_arr = 32'h01000000;

        // Fase de datos (7 ciclos)
        @(posedge clk);
        control = 0;
        data_arr = 32'h00000001; // D0

        @(posedge clk);
        data_arr = 32'h00000102; // D1

        @(posedge clk);
        data_arr = 32'h00010200; // D2

        @(posedge clk);
        data_arr = 32'h00010100; // D3

        @(posedge clk);
        data_arr = 32'h02030200;

        @(posedge clk);
        data_arr = 32'h04010000;

        @(posedge clk);
        data_arr = 32'h05000000;
			
		  #1000
		  data_arr = 32'h00000000;
			
        // Finalización
        //#1000 $finish;
    end

    // Monitoreo de resultados
    initial begin
        $monitor("Time = %t: Final Accs -> PE[0][3] = %h, PE[1][3] = %h, PE[2][3] = %h, PE[3][3] = %h", $time,final_accs[0], final_accs[1], final_accs[2], final_accs[3]);
		end
endmodule
		  