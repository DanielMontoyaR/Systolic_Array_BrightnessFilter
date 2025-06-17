`timescale 1ns/1ps

module TPU_System_tb;

    logic clk;
    logic reset;
    logic start;
    logic done;
    logic [39:0] pe30_out, pe31_out, pe32_out, pe33_out;
    logic [15:0] pe30_norm_out, pe31_norm_out, pe32_norm_out, pe33_norm_out;

    logic [31:0] data_arr_internal;
    logic [63:0] wt_arr_internal;
    logic tpu_valid_internal;

    // Clock
    always #5 clk = ~clk;

    // DUT
    TPU_System uut (
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

    assign tpu_valid_internal = uut.tpu_valid;
    assign data_arr_internal  = uut.tpu_data_arr;
    assign wt_arr_internal    = uut.wt_arr;

    logic [7:0] d0, d1, d2, d3;
    assign {d3, d2, d1, d0} = data_arr_internal;

    initial begin
        $display("==== INICIO DE SIMULACI\u00d3N ====");
        clk = 0;
        reset = 1;
        start = 0;
        #20;

        reset = 0;
        #10;

        $display("Aplicando start...");
        start = 1;
        #10;
        start = 0;

        $display("Esperando a que 'done' se active...");
        wait (done);
        #100;

        print_results();

        $display("==== FIN DE SIMULACI\u00d3N ====");
        $stop;
    end

    always @(posedge clk) begin
        if (tpu_valid_internal) begin
            $display("\n[T=%0t ns] Flujo de datos hacia TPU:", $time);
            $display("  data_arr = {%0d, %0d, %0d, %0d} (hex = %h)", d3, d2, d1, d0, data_arr_internal);
            for (int i = 0; i < 4; i++) begin
                logic [15:0] wt;
                wt = wt_arr_internal >> ((3 - i) * 16);
                $display("  PE%d: %4h (dec %0d)", i, wt, $signed(wt));
            end
        end
    end

    task print_results;
        $display("\n==== Resultados acumulados ====");
        $display("PE(3,0) = %010h (dec %0d)", pe30_out, pe30_out);
        $display("PE(3,1) = %010h (dec %0d)", pe31_out, pe31_out);
        $display("PE(3,2) = %010h (dec %0d)", pe32_out, pe32_out);
        $display("PE(3,3) = %010h (dec %0d)", pe33_out, pe33_out);
        $display("Normalizados:");
        $display("PE(3,0)_norm = %0d", pe30_norm_out);
        $display("PE(3,1)_norm = %0d", pe31_norm_out);
        $display("PE(3,2)_norm = %0d", pe32_norm_out);
        $display("PE(3,3)_norm = %0d", pe33_norm_out);
    endtask

endmodule
