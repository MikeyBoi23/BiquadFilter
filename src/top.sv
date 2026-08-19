`timescale 1ns / 1ps

module top (
    input  logic CLK_100MHZ,
    input  logic SW_0,

    input  logic uart_rtl_rxd,
    output logic uart_rtl_txd,
    output logic LED_0,
  
    // Should be unused in final revision
    input logic start_bram_read
);

    // System clock from Clocking Wizard
    logic clk_sys;

    // BRAM Port B
    logic [31:0] bram_addr_b;
    logic        bram_en_b;
    logic [31:0] bram_dout_b;

    logic signed [15:0] sample;
    logic               sample_valid;

    logic signed [15:0] y;

    // Active-low reset from Processor System Reset block
    logic peripheral_aresetn;

    // system_wrapper is the block design containing MB + UARTLITE + BRAM
    system_wrapper wrap_inst (
        .CLK_100MHZ         (CLK_100MHZ),
        .SW_0               (SW_0),

        .peripheral_aresetn (peripheral_aresetn),
        .LED_0              (LED_0),

        .clk_out1           (clk_sys),

        .addrb_0            (bram_addr_b),
        .clkb_0             (clk_sys),
        .doutb_0            (bram_dout_b),
        .enb_0              (bram_en_b),

        .uart_rtl_rxd       (uart_rtl_rxd),
        .uart_rtl_txd       (uart_rtl_txd)
    );


    byte_splitter split_inst (
        .CLK        (clk_sys),
        .rst_n      (peripheral_aresetn),

        .start      (start_bram_read),

        .BRAM_DOUT  (bram_dout_b),

        .ADDRB      (bram_addr_b),
        .EN         (bram_en_b),

        .sample_out (sample),
        .valid      (sample_valid)
    );

    biquad biquad_inst (
        .clk        (clk_sys),
        .rst_n      (peripheral_aresetn),

        .valid      (sample_valid),
        .sample_in  (sample),

        .y_n        (y)
    );

endmodule
