`timescale 1ns / 1ps

module TPU_System #(
    parameter BIT_WIDTH = 16,
    parameter ACC_WIDTH = 40,
    parameter DEPTH = 4,          // Tamaño del arreglo sistólico (4x4)
    parameter MATRIX_SIZE = 8,    // Tamaño de la matriz grande (8x8)
    parameter RAM_DATA_WIDTH = 8, // Ancho de datos de la RAM (8 bits)
    parameter RAM_ADDR_WIDTH = 6  // 6 bits para 64 posiciones (8x8)
)(
    input logic clk,
    input logic reset,
    input logic start,
    output logic done,
    // Salidas para monitoreo (opcional)
    output logic [ACC_WIDTH-1:0] pe30_out, pe31_out, pe32_out, pe33_out,
    output logic [15:0] pe30_norm_out, pe31_norm_out, pe32_norm_out, pe33_norm_out
);

    //-------------------------------------------
    // Señales de interconexión
    //-------------------------------------------
    logic [RAM_ADDR_WIDTH-1:0] ram_addr;
    logic [RAM_DATA_WIDTH-1:0] ram_data;
    logic [BIT_WIDTH*DEPTH-1:0] tpu_data_arr; // 64 bits (4x16)
    logic tpu_control;
    logic tpu_ready = 1'b1; // Asumimos que el TPU siempre está listo

    //-------------------------------------------
    // Instancia de la RAM (8x8, 8 bits por dato)
    //-------------------------------------------
    ram1 ram (
        .address(ram_addr),
        .clock(clk),
        .data(8'h00),     // No escribimos en la RAM
        .wren(1'b0),      // Solo lectura
        .q(ram_data)
    );

    //-------------------------------------------
    // Instancia del Controlador
    //-------------------------------------------
    Matrix_Controller #(
        .MATRIX_SIZE(MATRIX_SIZE),
        .ADDR_WIDTH(RAM_ADDR_WIDTH),
        .DATA_WIDTH(RAM_DATA_WIDTH)
    ) controller (
        .clk(clk),
        .start(start),
        .done(done),
        .ram_addr(ram_addr),
        .ram_data(ram_data),
        .tpu_data_arr(tpu_data_arr),
        .tpu_control(tpu_control),
        .tpu_ready(tpu_ready)
    );

    //-------------------------------------------
    // Instancia del TPU (arreglo sistólico 4x4)
    //-------------------------------------------
    TPU #(
        .bit_width(BIT_WIDTH),
        .acc_width(ACC_WIDTH),
        .depth(DEPTH)
    ) tpu (
        .clk(clk),
        .control(tpu_control),
        .data_arr(tpu_data_arr),
        .wt_arr(64'h0000_0001_0000_0001), // Pesos fijos (ejemplo)
        .pe30_out(pe30_out),
        .pe31_out(pe31_out),
        .pe32_out(pe32_out),
        .pe33_out(pe33_out),
        .pe30_norm_out(pe30_norm_out),
        .pe31_norm_out(pe31_norm_out),
        .pe32_norm_out(pe32_norm_out),
        .pe33_norm_out(pe33_norm_out)
    );

endmodule