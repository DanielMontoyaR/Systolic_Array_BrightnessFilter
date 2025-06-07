module MMU #(
    parameter DEPTH = 4,          // Tamaño del arreglo (4x4)
    parameter BIT_WIDTH = 8,      // Ancho de dato (8 bits)
    parameter ACC_WIDTH = 32      // Ancho del acumulador (32 bits)
)(
    input  logic clk,
    input  logic control,
    input  logic reset,
    input  logic [(BIT_WIDTH*DEPTH)-1:0] data_arr,  // Entrada de datos (32 bits)
    input  logic [(BIT_WIDTH*DEPTH)-1:0] wt_arr,     // Entrada de pesos (32 bits)
    output logic [(ACC_WIDTH*DEPTH)-1:0] acc_out     // Salida de acumuladores (128 bits)
);

    // Señales intermedias para conexiones entre MACs
    logic [BIT_WIDTH-1:0] data_out [DEPTH][DEPTH];  // Datos propagados
    logic [BIT_WIDTH-1:0] wt_out [DEPTH][DEPTH];    // Pesos propagados
    logic [ACC_WIDTH-1:0] acc_out_temp [DEPTH][DEPTH]; // Acumuladores parciales

    //----------------------------------------------------------
    // Instancias de los MACs (conexiones hardcodeadas)
    //----------------------------------------------------------

    // Fila 0
    MAC m00 (.clk(clk), .control(control), .reset(reset),
             .acc_in(32'b0),                 // Primer MAC: acumulador inicia en 0
             .data_in(data_arr[7:0]),        // Dato entrada (byte 0)
             .wt_path_in(wt_arr[7:0]),       // Peso entrada (byte 0)
             .acc_out(acc_out_temp[0][0]),
             .data_out(data_out[0][0]),
             .wt_path_out(wt_out[0][0]));

    MAC m01 (.clk(clk), .control(control), .reset(reset),
             .acc_in(32'b0),
             .data_in(data_out[0][0]),       // Dato propagado desde m00
             .wt_path_in(wt_arr[15:8]),      // Peso entrada (byte 1)
             .acc_out(acc_out_temp[0][1]),
             .data_out(data_out[0][1]),
             .wt_path_out(wt_out[0][1]));

    MAC m02 (.clk(clk), .control(control), .reset(reset),
             .acc_in(32'b0),
             .data_in(data_out[0][1]),       // Dato propagado desde m01
             .wt_path_in(wt_arr[23:16]),     // Peso entrada (byte 2)
             .acc_out(acc_out_temp[0][2]),
             .data_out(data_out[0][2]),
             .wt_path_out(wt_out[0][2]));

    MAC m03 (.clk(clk), .control(control), .reset(reset),
             .acc_in(32'b0),
             .data_in(data_out[0][2]),       // Dato propagado desde m02
             .wt_path_in(wt_arr[31:24]),     // Peso entrada (byte 3)
             .acc_out(acc_out_temp[0][3]),
             .data_out(data_out[0][3]),
             .wt_path_out(wt_out[0][3]));

    // Fila 1
    MAC m10 (.clk(clk), .control(control), .reset(reset),
             .acc_in(acc_out_temp[0][0]),    // Acumulador desde m00 (arriba)
             .data_in(data_arr[15:8]),       // Dato entrada (byte 1)
             .wt_path_in(wt_out[0][0]),      // Peso propagado desde m00
             .acc_out(acc_out_temp[1][0]),
             .data_out(data_out[1][0]),
             .wt_path_out(wt_out[1][0]));

    MAC m11 (.clk(clk), .control(control), .reset(reset),
             .acc_in(acc_out_temp[0][1]),
             .data_in(data_out[1][0]),       // Dato propagado desde m10
             .wt_path_in(wt_out[0][1]),      // Peso propagado desde m01
             .acc_out(acc_out_temp[1][1]),
             .data_out(data_out[1][1]),
             .wt_path_out(wt_out[1][1]));

    MAC m12 (.clk(clk), .control(control), .reset(reset),
             .acc_in(acc_out_temp[0][2]),
             .data_in(data_out[1][1]),       // Dato propagado desde m11
             .wt_path_in(wt_out[0][2]),
             .acc_out(acc_out_temp[1][2]),
             .data_out(data_out[1][2]),
             .wt_path_out(wt_out[1][2]));

    MAC m13 (.clk(clk), .control(control), .reset(reset),
             .acc_in(acc_out_temp[0][3]),
             .data_in(data_out[1][2]),       // Dato propagado desde m12
             .wt_path_in(wt_out[0][3]),
             .acc_out(acc_out_temp[1][3]),
             .data_out(data_out[1][3]),
             .wt_path_out(wt_out[1][3]));

    // Fila 2
    MAC m20 (.clk(clk), .control(control), .reset(reset),
             .acc_in(acc_out_temp[1][0]),    // Acumulador desde m10
             .data_in(data_arr[23:16]),      // Dato entrada (byte 2)
             .wt_path_in(wt_out[1][0]),      // Peso propagado desde m10
             .acc_out(acc_out_temp[2][0]),
             .data_out(data_out[2][0]),
             .wt_path_out(wt_out[2][0]));

    MAC m21 (.clk(clk), .control(control), .reset(reset),
             .acc_in(acc_out_temp[1][1]),
             .data_in(data_out[2][0]),       // Dato propagado desde m20
             .wt_path_in(wt_out[1][1]),
             .acc_out(acc_out_temp[2][1]),
             .data_out(data_out[2][1]),
             .wt_path_out(wt_out[2][1]));

    MAC m22 (.clk(clk), .control(control), .reset(reset),
             .acc_in(acc_out_temp[1][2]),
             .data_in(data_out[2][1]),
             .wt_path_in(wt_out[1][2]),
             .acc_out(acc_out_temp[2][2]),
             .data_out(data_out[2][2]),
             .wt_path_out(wt_out[2][2]));

    MAC m23 (.clk(clk), .control(control), .reset(reset),
             .acc_in(acc_out_temp[1][3]),
             .data_in(data_out[2][2]),
             .wt_path_in(wt_out[1][3]),
             .acc_out(acc_out_temp[2][3]),
             .data_out(data_out[2][3]),
             .wt_path_out(wt_out[2][3]));

    // Fila 3
    MAC m30 (.clk(clk), .control(control), .reset(reset),
             .acc_in(acc_out_temp[2][0]),    // Acumulador desde m20
             .data_in(data_arr[31:24]),      // Dato entrada (byte 3)
             .wt_path_in(wt_out[2][0]),
             .acc_out(acc_out_temp[3][0]),
             .data_out(data_out[3][0]),
             .wt_path_out(wt_out[3][0]));

    MAC m31 (.clk(clk), .control(control), .reset(reset),
             .acc_in(acc_out_temp[2][1]),
             .data_in(data_out[3][0]),       // Dato propagado desde m30
             .wt_path_in(wt_out[2][1]),
             .acc_out(acc_out_temp[3][1]),
             .data_out(data_out[3][1]),
             .wt_path_out(wt_out[3][1]));

    MAC m32 (.clk(clk), .control(control), .reset(reset),
             .acc_in(acc_out_temp[2][2]),
             .data_in(data_out[3][1]),
             .wt_path_in(wt_out[2][2]),
             .acc_out(acc_out_temp[3][2]),
             .data_out(data_out[3][2]),
             .wt_path_out(wt_out[3][2]));

    MAC m33 (.clk(clk), .control(control), .reset(reset),
             .acc_in(acc_out_temp[2][3]),
             .data_in(data_out[3][2]),
             .wt_path_in(wt_out[2][3]),
             .acc_out(acc_out_temp[3][3]),
             .data_out(data_out[3][3]),
             .wt_path_out(wt_out[3][3]));

    //----------------------------------------------------------
    // Salida final: Concatenación de los acumuladores de la última fila
    //----------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            acc_out <= 128'b0;
        end else begin
            acc_out <= {acc_out_temp[3][3], acc_out_temp[3][2], 
                        acc_out_temp[3][1], acc_out_temp[3][0]};
        end
    end

endmodule