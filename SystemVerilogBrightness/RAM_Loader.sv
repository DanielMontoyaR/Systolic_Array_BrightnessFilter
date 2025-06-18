`timescale 1ns / 1ps

module RAM_Loader #(
    parameter RAM_ADDR_WIDTH = 6,   // 64 posiciones (0-63)
    parameter RAM_DATA_WIDTH = 8,
    parameter PE_DATA_WIDTH = 16,
    parameter DEPTH = 4             // Tamaño del arreglo sistólico (4x4)
)(
    input logic clk,
    input logic reset,
    input logic start,
    output logic [PE_DATA_WIDTH*DEPTH-1:0] data_out,
    output logic data_valid,
    output logic [RAM_ADDR_WIDTH-1:0] ram_address,
    input logic [RAM_DATA_WIDTH-1:0] ram_data,
    output logic done
);

    // Estados
    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        FINISH,
        DONE_ST
    } state_t;

    state_t current_state, next_state;
    
    // Registros
    logic [RAM_ADDR_WIDTH-1:0] base_addr;
    logic [1:0] word_counter;
    logic [PE_DATA_WIDTH-1:0] data_buffer [DEPTH];
    logic last_block;
    
    // Lógica de estado
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            base_addr <= 0;
            word_counter <= 0;
            data_valid <= 0;
            done <= 0;
            last_block <= 0;
            for (int i = 0; i < DEPTH; i++) data_buffer[i] <= 0;
        end else begin
            current_state <= next_state;
            
            case (current_state)
                LOAD: begin
                    // Capturar dato
                    data_buffer[word_counter] <= {8'h00, ram_data};
                    
                    if (word_counter == DEPTH-1) begin
                        word_counter <= 0;
                        base_addr <= base_addr + DEPTH;
                        data_valid <= 1;
                        last_block <= (base_addr + DEPTH >= 2**RAM_ADDR_WIDTH - DEPTH);
                    end else begin
                        word_counter <= word_counter + 1;
                        data_valid <= 0;
                    end
                end
                
                FINISH: begin
                    data_valid <= 1;
                end
                
                DONE_ST: begin
                    done <= 1;
                    data_valid <= 0;
                end
                
                default: begin
                    data_valid <= 0;
                end
            endcase
        end
    end
    
    // Lógica de próximo estado
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: if (start) next_state = LOAD;
            LOAD: if (last_block && word_counter == DEPTH-1) next_state = FINISH;
            FINISH: next_state = DONE_ST;
            DONE_ST: next_state = IDLE;
        endcase
    end
    
    // Dirección de RAM
    assign ram_address = (current_state == LOAD) ? (base_addr + word_counter) : 0;
    
    // Salida concatenada
    assign data_out = (current_state == FINISH) ? 
                     {data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0]} :
                     {data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0]};
endmodule