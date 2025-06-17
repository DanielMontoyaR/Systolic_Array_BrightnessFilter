module TPU_System (
    input  logic clk,
    input  logic reset,
    input  logic start,
    output logic done,

    output logic [39:0] pe30_out, pe31_out, pe32_out, pe33_out,
    output logic [15:0] pe30_norm_out, pe31_norm_out, pe32_norm_out, pe33_norm_out
);

    // Señales internas
    logic [31:0] data_arr;
    logic [63:0] wt_arr;
    logic        tpu_valid;

    // Conexión a la RAM
    logic [5:0] addr;
    logic [7:0] q;

    ram1 RAM_inst (
        .address(addr),
        .clock(clk),
        .data(8'b0),
        .rden(1'b1),
        .wren(1'b0),
        .q(q)
    );

    // Controlador que genera datos y pesos
    Matrix_Controller controller_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .ram_data(q),
        .addr(addr),
        .data_arr(data_arr),
        .wt_arr(wt_arr),
        .tpu_valid(tpu_valid)
    );

    // TPU: se mantiene sin modificar según tu solicitud
    TPU tpu_inst (
        .clk(clk),
        .data_arr(data_arr),
        .wt_arr(wt_arr),
        .valid(tpu_valid),
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
