module top (
    input                           CLOCK_50_B5B,
    input                           CPU_RESET_n,
    input              [3:0]        KEY,
    input              [9:0]        SW,
    output             [7:0]        LEDG,
    output             [9:0]        LEDR,
    output             [6:0]        HEX0,
    output             [6:0]        HEX1,
    output             [6:0]        HEX2,
    output             [6:0]        HEX3,
    input                           UART_RX,
    output                          UART_TX
);

    localparam int DW = 16;

    wire clk         = CLOCK_50_B5B;
    wire resetn      = CPU_RESET_n;
    wire configure   = ~KEY[0];
    wire up          = ~KEY[1];
    wire down        = ~KEY[2];
    wire ready       = ~KEY[3];

    wire tdi, tdo;
    wire [1:0] ir_in;
    wire virtual_state_cdr, virtual_state_sdr, virtual_state_udr;
    wire tck;

    wire [DW-1:0] jtag_data;
    logic [DW-1:0] jtag_data_sync;
    logic [DW-1:0] counter;

    assign {LEDR[9], LEDR[8]} = ir_in;

    u_vjtag vjtag (
        .tdi(tdi), .tdo(tdo), .ir_in(ir_in), .ir_out(),
        .virtual_state_cdr(virtual_state_cdr),
        .virtual_state_sdr(virtual_state_sdr),
        .virtual_state_e1dr(), .virtual_state_pdr(),
        .virtual_state_e2dr(), .virtual_state_udr(virtual_state_udr),
        .virtual_state_cir(), .virtual_state_uir(),
        .tck(tck)
    );

    vjtag_interface #(.DW(DW)) u_vjtag_interface (
        .tck(tck),
        .tdi(tdi),
        .aclr(resetn),
        .ir_in(ir_in),
        .v_sdr(virtual_state_sdr),
        .v_cdr(virtual_state_cdr),
        .udr(virtual_state_udr),
        .data_out(jtag_data),
        .data_in(counter),
        .tdo(tdo),
        .debug_dr1(LEDG),
        .debug_dr2(LEDR[7:0])
    );

    // RAM de 8 bits, 64 palabras
    wire [7:0] ram_q;
    wire [5:0] ram_addr;
    wire ram_clk = clk;
    wire ram_en = 1'b1;
	
	/*
    ram1 RAM_inst (
        .address(ram_addr),
        .clock(ram_clk),
        .data(8'd0),
        .rden(ram_en),
        .wren(1'b0),
        .q(ram_q)
    );*/
	 
	 // --- Instancia de la RAM ---
    ram1 ram_inst (
        .address(ram_address),
        .clock(clk),
        .data(8'h00),       // No usado en modo lectura
        .wren(1'b0),        // Siempre lectura (0)
        .q(ram_data)        // Datos de salida de la RAM
    );
	 
	 

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn)
            jtag_data_sync <= 16'd0;
        else
            jtag_data_sync <= jtag_data;
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn)
            counter <= '0;
        else if (configure)
            counter <= jtag_data_sync;
        else begin
            if (up)
                counter <= counter + 1;
            if (down)
                counter <= counter - 1;
        end
    end

endmodule