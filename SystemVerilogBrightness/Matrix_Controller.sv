module Matrix_Controller(
    input logic clk,
    input logic reset,
    input logic start,
    input logic [7:0] data_in,
    output logic done,
    output logic [5:0] addr,
    output logic tpu_valid,
    output logic [31:0] data_arr,
    output logic [63:0] wt_arr
);

    typedef enum logic [1:0] {
        IDLE, READ, WEIGHT_LOAD, DONE
    } state_t;

    state_t state, next_state;
    logic [3:0] index;
    logic [7:0] buffer [0:15];

    // Address counter
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            index <= 0;
        else if (state == READ && index < 16)
            index <= index + 1;
    end

    // RAM read control
    always_comb begin
        if (state == READ)
            addr = index;
        else
            addr = 0;
    end

    // FSM
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE:
                if (start) next_state = READ;
            READ:
                if (index == 15) next_state = WEIGHT_LOAD;
            WEIGHT_LOAD:
                next_state = DONE;
            DONE:
                next_state = DONE;
        endcase
    end

    // Buffering data
    always_ff @(posedge clk) begin
        if (state == READ)
            buffer[index] <= data_in;
    end

    // Output control
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            data_arr <= 0;
            wt_arr <= 0;
            tpu_valid <= 0;
            done <= 0;
        end else begin
            case (state)
                WEIGHT_LOAD: begin
                    // Construye data_arr con 4 datos para cada ciclo
                    data_arr <= {buffer[12], buffer[9], buffer[6], buffer[3]};
                    wt_arr <= 64'h0001000000000000;  // Pesos estáticos de ejemplo
                    tpu_valid <= 1;
                end
                DONE: begin
                    done <= 1;
                    tpu_valid <= 0;
                end
                default: begin
                    tpu_valid <= 0;
                    done <= 0;
                end
            endcase
        end
    end
endmodule