module TPU #(
    parameter depth = 4,
    parameter bit_width = 16,
    parameter acc_width = 40,
    parameter size = 4
)(
    input logic clk,
    input logic control,
    input logic [(bit_width*depth)-1:0] data_arr,	//64 bits
    input logic [(bit_width*depth)-1:0] wt_arr,		//64 bits
    output logic [acc_width*size-1:0] acc_out,		//160 bits
	 output [acc_width-1:0] pe30_out,      // Salida individual PE(3,0)
    output [acc_width-1:0] pe31_out,      // Salida individual PE(3,1)
    output [acc_width-1:0] pe32_out,      // Salida individual PE(3,2)
    output [acc_width-1:0] pe33_out       // Salida individual PE(3,3)
	 
);

    // Señales intermedias
    wire [bit_width-1:0] data_out [depth][depth];
    wire [bit_width-1:0] wt_out [depth][depth];
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
                        .reset(1'b0),
                        .acc_in({acc_width{1'b0}}),
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
                        .acc_in({acc_width{1'b0}}),
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
	/*always_ff @(posedge clk) begin : acc_out_reg
		 for (int k = 0; k < depth; k++) begin
			  acc_out[k*acc_width+:acc_width] <= acc_out_temp[k][depth-1];  // Cambiado de [depth-1][k] a [k][depth-1]
		 end
	end
		  
    //end
    always_comb begin
        for (int i = 0; i < depth; i++) begin
            final_accs[i] = acc_out_temp[i][depth-1];  // PE[i][3]
        end
    end*/
	 
	 // Asignación de salidas concatenadas
	assign acc_out = {acc_out_temp[3][3], acc_out_temp[3][2], acc_out_temp[3][1], acc_out_temp[3][0]};

	// Asignación de salidas individuales
	assign pe30_out = acc_out_temp[3][0];
	assign pe31_out = acc_out_temp[3][1];
	assign pe32_out = acc_out_temp[3][2];
	assign pe33_out = acc_out_temp[3][3];

endmodule