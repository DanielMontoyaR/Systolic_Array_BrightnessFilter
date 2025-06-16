module Matrix_Controller #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 8,
    parameter MATRIX_SIZE = 8,
    parameter CHUNK_SIZE = 4
)(
    input logic clk,
    input logic start,
	 input logic reset,
    output logic done,
    // Interface con la RAM
    output logic [ADDR_WIDTH-1:0] ram_addr,
    input logic [DATA_WIDTH-1:0] ram_data,
    // Interface con el TPU
    output logic [63:0] tpu_data_arr, // 4x16 bits
    output logic tpu_control,
    input logic tpu_ready
);

    // Estados del controlador
    typedef enum {
        IDLE,
        LOAD_CHUNK,
        SEND_DIAGONAL,
        NEXT_CHUNK,
        DONE
    } state_t;

    state_t current_state, next_state;

    // Contadores y registros
    logic [7:0] row_offset, col_offset;
    logic [2:0] diag_counter;
    logic [15:0] chunk_buffer [0:CHUNK_SIZE-1][0:CHUNK_SIZE-1];

    // Máquina de estados
    always_ff @(posedge clk) begin
        if (reset) current_state <= IDLE;
        else current_state <= next_state;
    end

    // Lógica del próximo estado
    always_comb begin
        case (current_state)
            IDLE:       next_state = start ? LOAD_CHUNK : IDLE;
            LOAD_CHUNK: next_state = (chunk_loaded()) ? SEND_DIAGONAL : LOAD_CHUNK;
            SEND_DIAGONAL: next_state = (diag_sent()) ? 
                                      (last_chunk() ? DONE : NEXT_CHUNK) : SEND_DIAGONAL;
            NEXT_CHUNK: next_state = LOAD_CHUNK;
            DONE:       next_state = IDLE;
            default:    next_state = IDLE;
        endcase
    end

    // Cargar chunk desde la RAM
    always_ff @(posedge clk) begin
        if (current_state == LOAD_CHUNK) begin
            for (int i = 0; i < CHUNK_SIZE; i++) begin
                for (int j = 0; j < CHUNK_SIZE; j++) begin
                    ram_addr <= (row_offset + i) * MATRIX_SIZE + (col_offset + j);
                    chunk_buffer[i][j] <= {8'h00, ram_data}; // Extender a 16 bits
                end
            end
        end
    end

    // Generar patron diagonal para el TPU
    always_comb begin
        tpu_data_arr = 64'h0;
        tpu_control = (current_state == SEND_DIAGONAL);

        case (diag_counter)
            0: tpu_data_arr = {48'h0, chunk_buffer[3][0]};
            1: tpu_data_arr = {32'h0, chunk_buffer[2][0], chunk_buffer[3][1]};
            2: tpu_data_arr = {16'h0, chunk_buffer[1][0], chunk_buffer[2][1], chunk_buffer[3][2]};
            3: tpu_data_arr = {chunk_buffer[0][0], chunk_buffer[1][1], chunk_buffer[2][2], chunk_buffer[3][3]};
            4: tpu_data_arr = {chunk_buffer[0][1], chunk_buffer[1][2], chunk_buffer[2][3], 16'h0};
            5: tpu_data_arr = {chunk_buffer[0][2], chunk_buffer[1][3], 32'h0};
            6: tpu_data_arr = {chunk_buffer[0][3], 48'h0};
            default: tpu_data_arr = 64'h0;
        endcase
    end

    // Control de contadores
    always_ff @(posedge clk) begin
        if (reset) begin
            row_offset <= 0;
            col_offset <= 0;
            diag_counter <= 0;
            done <= 0;
        end
        else case (current_state)
            SEND_DIAGONAL: if (tpu_ready) diag_counter <= diag_counter + 1;
            NEXT_CHUNK: begin
                if (col_offset + CHUNK_SIZE >= MATRIX_SIZE) begin
                    col_offset <= 0;
                    row_offset <= row_offset + CHUNK_SIZE;
                end else begin
                    col_offset <= col_offset + CHUNK_SIZE;
                end
                diag_counter <= 0;
            end
            DONE: done <= 1;
        endcase
    end

    // Funciones helper
    function logic chunk_loaded();
        return (ram_addr == (row_offset + CHUNK_SIZE-1) * MATRIX_SIZE + (col_offset + CHUNK_SIZE-1));
    endfunction

    function logic diag_sent();
        return (diag_counter == 7);
    endfunction

    function logic last_chunk();
        return (row_offset + CHUNK_SIZE >= MATRIX_SIZE) && 
               (col_offset + CHUNK_SIZE >= MATRIX_SIZE);
    endfunction

endmodule