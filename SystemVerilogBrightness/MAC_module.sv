module MAC #(
    parameter bit_width = 16,
	 
    parameter acc_width = 40
)(
    input logic clk,
    input logic control,
    input logic reset,
    input logic [acc_width - 1:0] acc_in,
    input logic [bit_width - 1:0] data_in,
    input logic [bit_width - 1:0] wt_path_in,
    output logic [acc_width - 1:0] acc_out,
    output logic [bit_width - 1:0] data_out,
    output logic [bit_width - 1:0] wt_path_out
);

    logic [bit_width + bit_width - 1:0] result;
    logic [acc_width - 1:0] acc_reg;
    logic [bit_width - 1:0] weight_reg;

    always_ff @(posedge clk) begin
        if (reset) begin
            acc_out <= 0;
            wt_path_out <= 0;
				data_out <= 0;
        end
        else begin
				if (control) begin
					weight_reg <= wt_path_in; //Cargar nuevo peso
				end
            acc_out <= acc_reg;
            wt_path_out <= control ? wt_path_in: weight_reg;
            data_out <= data_in;
        end
    end

    always_comb begin
        //result = data_in * (control ? 8'b0 : weight_reg);
		  result = data_in * (control ? {bit_width{1'b0}} : weight_reg);
        acc_reg = acc_in + result;
    end
endmodule