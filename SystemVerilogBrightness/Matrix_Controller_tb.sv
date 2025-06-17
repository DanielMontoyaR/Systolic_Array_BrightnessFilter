`timescale 1ns/1ps

module Matrix_Controller_tb;

    parameter ADDR_WIDTH = 6;
    parameter DATA_WIDTH = 16;

    logic clk, rst, start, done;
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] tpu_data_arr [0:6][0:3];

    // RAM simulada
    logic [DATA_WIDTH-1:0] ram [0:63];

    // Instancia del DUT
    Matrix_Controller #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) dut (
        .clk(clk), .rst(rst), .start(start), .done(done),
        .addr(addr), .data_in(data_in),
        .tpu_data_arr(tpu_data_arr)
    );

    // Clock
    always #5 clk = ~clk;

    // Cargar RAM desde MIF
    initial begin
        $readmemb("ram_data_test1.mif", ram);
    end

    // Estímulo
    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        #10;
        rst = 0;
        #10;
        start = 1;
        #10;
        start = 0;

        // Esperar a que termine
        wait (done);
        #20;

        // Mostrar resultados
        $display("Diagonal data:");
        for (int d = 0; d < 7; d++) begin
            $write("D%0d: ", d);
            for (int i = 0; i <= d && i < 4; i++) begin
                $write("%0h ", tpu_data_arr[d][i]);
            end
            $display("");
        end

        $finish;
    end

    // RAM simulation: lectura directa
    always_comb begin
        data_in = ram[addr];
    end

endmodule
