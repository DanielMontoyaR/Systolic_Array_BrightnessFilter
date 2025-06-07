module TPU #(
    parameter depth = 4,
    parameter bit_width = 8,
    parameter acc_width = 24,
    parameter size = 4
)(
    input logic clk,
    input logic control,
    input logic [(bit_width*depth)-1:0] data_arr,
    input logic [(bit_width*depth)-1:0] wt_arr,
    output logic [acc_width*size-1:0] acc_out,
	 output logic [acc_width-1:0] final_accs [depth]  // final_accs[0] = PE[0][3], ..., final_accs[3] = PE[3][3]
);

    // Señales intermedias
    logic [bit_width-1:0] data_out [depth][depth];
    logic [bit_width-1:0] wt_out [depth][depth];
    logic [acc_width-1:0] acc_out_temp [depth][depth];

    //----------------------------------------------------------
    // Generación de MACs (sintaxis SystemVerilog válida)
    //----------------------------------------------------------
generate
    genvar i, j;  // Declara genvar FUERA de los bucles (estilo Verilog-2001)
    
    for (i = 0; i < depth; i = i + 1) begin : gen_row
        for (j = 0; j < depth; j = j + 1) begin : gen_col
                if (i == 0 && j == 0) begin
                    MAC mac_instance (
                        .clk(clk),
                        .control(control),
                        .reset(1'b0),       // Asegúrate de tener 'reset' en el módulo MAC
                        .acc_in(24'b0),
                        .acc_out(acc_out_temp[i][j]),
                        .data_in(data_arr[i*bit_width+:bit_width]),
                        .wt_path_in(wt_arr[j*bit_width+:bit_width]),
                        .data_out(data_out[i][j]),
                        .wt_path_out(wt_out[i][j])
                    );
                end
                else if (i == 0 && j != 0) begin
                    MAC mac_instance (
                        .clk(clk),
                        .control(control),
                        .reset(1'b0),
                        .acc_in(24'b0),
                        .acc_out(acc_out_temp[i][j]),
                        .data_in(data_out[i][j-1]),
                        .wt_path_in(wt_arr[j*bit_width+:bit_width]),
                        .data_out(data_out[i][j]),
                        .wt_path_out(wt_out[i][j])
                    );
                end
                else if (i != 0 && j == 0) begin
                    MAC mac_instance (
                        .clk(clk),
                        .control(control),
                        .reset(1'b0),
                        .acc_in(acc_out_temp[i-1][j]),
                        .acc_out(acc_out_temp[i][j]),
                        .data_in(data_arr[i*bit_width+:bit_width]),
                        .wt_path_in(wt_out[i-1][j]),
                        .data_out(data_out[i][j]),
                        .wt_path_out(wt_out[i][j])
                    );
                end
                else begin // i != 0 && j != 0
                    MAC mac_instance (
                        .clk(clk),
                        .control(control),
                        .reset(1'b0),
                        .acc_in(acc_out_temp[i-1][j]),
                        .acc_out(acc_out_temp[i][j]),
                        .data_in(data_out[i][j-1]),
                        .wt_path_in(wt_out[i-1][j]),
                        .data_out(data_out[i][j]),
                        .wt_path_out(wt_out[i][j])
                    );
                end
            end
        end
    endgenerate

    //----------------------------------------------------------
    // Registro de salida (acumuladores finales)
    //----------------------------------------------------------
    always_ff @(posedge clk) begin : acc_out_reg
        for (int k = 0; k < depth; k++) begin
            acc_out[k*acc_width+:acc_width] <= acc_out_temp[depth-1][k];
        end
		  
    end
    always_comb begin
        for (int i = 0; i < depth; i++) begin
            final_accs[i] = acc_out_temp[i][depth-1];  // PE[i][3]
        end
    end
	 
	 

endmodule