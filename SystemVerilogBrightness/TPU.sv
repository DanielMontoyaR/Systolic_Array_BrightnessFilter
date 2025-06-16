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
    output [acc_width-1:0] pe33_out,       // Salida individual PE(3,3)
	 output logic [7:0] pe30_norm_out, pe31_norm_out, pe32_norm_out, pe33_norm_out
	 
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

    // Función ReLU mejorada con validación de rango
    function automatic [acc_width-1:0] relu;
        input [acc_width-1:0] value;
        reg overflow;
        begin
            // Detectar si hay bits significativos más allá de los 16 bits
            overflow = |value[acc_width-1:bit_width];
            
            // Si hay overflow o el bit de signo de los 16 bits está activo
            if (overflow || value[bit_width-1]) begin
                relu = {acc_width{1'b0}}; // Cero
            end else begin
                relu = value; // Mantener valor original
            end
        end
    endfunction
	
	// Asignación de salidas con ReLU aplicado
   assign pe30_out = relu(acc_out_temp[3][0]);
   assign pe31_out = relu(acc_out_temp[3][1]);
   assign pe32_out = relu(acc_out_temp[3][2]);
   assign pe33_out = relu(acc_out_temp[3][3]);
	
	Normalizer #(
    .IN_WIDTH(acc_width),
    .OUT_WIDTH(8)
	) norm30 (
		 .in_value(pe30_out),
		 .out_value(pe30_norm_out)
	);

	Normalizer #(
		 .IN_WIDTH(acc_width),
		 .OUT_WIDTH(8)
	) norm31 (
		 .in_value(pe31_out),
		 .out_value(pe31_norm_out)
	);

	Normalizer #(
		 .IN_WIDTH(acc_width),
		 .OUT_WIDTH(8)
	) norm32 (
		 .in_value(pe32_out),
		 .out_value(pe32_norm_out)
	);

	Normalizer #(
		 .IN_WIDTH(acc_width),
		 .OUT_WIDTH(8)
	) norm33 (
		 .in_value(pe33_out),
		 .out_value(pe33_norm_out)
	);
	

	// Salida concatenada sin ReLU (para mantener precisión en pasos intermedios)
   assign acc_out = {acc_out_temp[3][3], acc_out_temp[3][2], acc_out_temp[3][1], acc_out_temp[3][0]};
	
	/*
	 // Asignación de salidas concatenadas
	assign acc_out = {acc_out_temp[3][3], acc_out_temp[3][2], acc_out_temp[3][1], acc_out_temp[3][0]};

	// Asignación de salidas individuales
	assign pe30_out = acc_out_temp[3][0];
	assign pe31_out = acc_out_temp[3][1];
	assign pe32_out = acc_out_temp[3][2];
	assign pe33_out = acc_out_temp[3][3];*/

endmodule