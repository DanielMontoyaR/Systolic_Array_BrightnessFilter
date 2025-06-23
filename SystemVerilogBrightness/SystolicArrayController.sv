`timescale 1ns / 1ps

module SystolicArrayController #(
    parameter RAM_ADDR_WIDTH = 6,
    parameter RAM_DATA_WIDTH = 8,
    parameter PE_DATA_WIDTH = 16,
    parameter DEPTH = 4,
    parameter ACC_WIDTH = 40
)(
    input logic clk,
    input logic reset,
    input logic start,
    output logic done,
    
    // Salidas para monitoreo/debug
    output logic [PE_DATA_WIDTH*DEPTH-1:0] current_data_out,
    output logic [PE_DATA_WIDTH*DEPTH-1:0] current_weights_out,
    output logic [ACC_WIDTH-1:0] pe30_out, pe31_out, pe32_out, pe33_out,
    output logic [15:0] pe30_norm_out, pe31_norm_out, pe32_norm_out, pe33_norm_out
);

    // Definición de estados
    typedef enum logic [2:0] {
        IDLE,
        LOAD_WEIGHTS,
        WAIT_AFTER_WEIGHTS,
        PROCESS_DATA,
        FINISH
    } state_t;
    
    state_t current_state, next_state;

    // Señales de interconexión
    logic tpu_ready;
    logic load_next;
    logic [PE_DATA_WIDTH*DEPTH-1:0] data_to_tpu;
    logic [PE_DATA_WIDTH*DEPTH-1:0] weights_reg;
    logic data_valid;
    logic control_signal;
    
    // Contadores
    logic [1:0] weight_load_counter;
    logic [2:0] wait_counter;
    
    // Instancia del RAM_Loader
    RAM_Loader #(
        .RAM_ADDR_WIDTH(RAM_ADDR_WIDTH),
        .RAM_DATA_WIDTH(RAM_DATA_WIDTH),
        .PE_DATA_WIDTH(PE_DATA_WIDTH),
        .DEPTH(DEPTH)
    ) ram_loader (
        .clk(clk),
        .reset(reset),
        .start(start),
        .tpu_ready(tpu_ready),
        .data_out(data_to_tpu),
        .data_valid(data_valid),
        .done(done),
        .load_next(load_next)
    );
    
    // Registro para pesos
    always_ff @(posedge clk) begin
        if (reset) begin
            weights_reg <= 0;
        end else if (current_state == LOAD_WEIGHTS && data_valid) begin
            weights_reg <= data_to_tpu;
        end
    end
    
    // Instancia del TPU
    TPU #(
        .depth(DEPTH),
        .bit_width(PE_DATA_WIDTH),
        .acc_width(ACC_WIDTH),
        .size(DEPTH)
    ) systolic_array (
        .clk(clk),
        .control(control_signal),
        .data_arr(data_to_tpu),
        .wt_arr((current_state == LOAD_WEIGHTS) ? data_to_tpu : weights_reg),
        .acc_out(),
        .pe30_out(pe30_out),
        .pe31_out(pe31_out),
        .pe32_out(pe32_out),
        .pe33_out(pe33_out),
        .pe30_norm_out(pe30_norm_out),
        .pe31_norm_out(pe31_norm_out),
        .pe32_norm_out(pe32_norm_out),
        .pe33_norm_out(pe33_norm_out)
    );
    
    // Lógica de estado
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            weight_load_counter <= 0;
            wait_counter <= 0;
            control_signal <= 0;
        end else begin
            current_state <= next_state;
            
            // Contador para carga de pesos
            if (current_state == LOAD_WEIGHTS && data_valid) begin
                weight_load_counter <= weight_load_counter + 1;
            end
            
            // Contador para espera después de carga
            if (current_state == WAIT_AFTER_WEIGHTS) begin
                wait_counter <= wait_counter + 1;
            end else begin
                wait_counter <= 0;
            end
            
            // Control signal management
            control_signal <= (current_state == LOAD_WEIGHTS);
        end
    end
    
    // Lógica de próximo estado
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: if (start) next_state = LOAD_WEIGHTS;
            
            LOAD_WEIGHTS: 
                if (weight_load_counter == DEPTH-1 && data_valid)
                    next_state = WAIT_AFTER_WEIGHTS;
            
            WAIT_AFTER_WEIGHTS:
                if (wait_counter == 4) // Espera 4 ciclos después de cargar pesos
                    next_state = PROCESS_DATA;
            
            PROCESS_DATA:
                if (done)
                    next_state = FINISH;
            
            FINISH:
                next_state = IDLE;
        endcase
    end
    
    // Señal tpu_ready
    assign tpu_ready = (current_state == PROCESS_DATA);
    
    // Señales de monitoreo
    assign current_data_out = data_to_tpu;
    assign current_weights_out = (current_state == LOAD_WEIGHTS) ? data_to_tpu : weights_reg;
endmodule