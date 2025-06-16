module Normalizer #(
    parameter IN_WIDTH = 24,
    parameter OUT_WIDTH = 8
)(
    input  logic signed [IN_WIDTH-1:0] in_value,
    output logic [OUT_WIDTH-1:0] out_value
);

    always_comb begin
        if (in_value < 0)
            out_value = 8'd0;
        else if (in_value > 255)
            out_value = 8'd255;
        else
            out_value = in_value[OUT_WIDTH-1:0];
    end

endmodule