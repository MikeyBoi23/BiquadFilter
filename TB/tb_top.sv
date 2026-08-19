`timescale 1ns / 1ps

module tb_top;

    localparam int NUM_SAMPLES = 55;
    localparam time UART_BIT_TIME = 8680ns;
    localparam time MB_BOOT_WAIT = 5_000_000ns;

    logic CLK_100MHZ;
    logic SW_0;

    logic uart_rtl_rxd;
    logic uart_rtl_txd;

    logic LED_0;

    logic start_bram_read;

    top dut (
        .CLK_100MHZ      (CLK_100MHZ),
        .SW_0            (SW_0),

        .uart_rtl_rxd    (uart_rtl_rxd),
        .uart_rtl_txd    (uart_rtl_txd),

        .LED_0           (LED_0),

        .start_bram_read (start_bram_read)
    );

    logic signed [15:0] samples [0:NUM_SAMPLES-1];

    integer i;
    integer bytes_sent;


    initial begin

        CLK_100MHZ = 1'b0;

        forever begin
            #5 CLK_100MHZ = ~CLK_100MHZ;
        end

    end


    // UART is idle when 1
    initial begin
        uart_rtl_rxd = 1'b1;
    end

  
    initial begin
        start_bram_read = 1'b0;
        bytes_sent      = 0;
    end

    // Start dumping wave
    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);

    end

    initial begin

        $display(" Loading samples_biquad.hex");
        $readmemh("samples_biquad.hex", samples);

        for (i = 0; i < NUM_SAMPLES; i = i + 1) begin
            $display(
                "sample[%0d] = %04h",
                i,
                samples[i]
            );
        end
    end

    task automatic uart_send_byte(
        input logic [7:0] data
    );
        integer bit_index;

        begin
            // Active
            uart_rtl_rxd = 1'b0;
            #(UART_BIT_TIME);

            for (
                bit_index = 0;
                bit_index < 8;
                bit_index = bit_index + 1
            ) begin
                uart_rtl_rxd = data[bit_index];
                #(UART_BIT_TIME);
            end
          
            uart_rtl_rxd = 1'b1;
            #(UART_BIT_TIME);

            bytes_sent = bytes_sent + 1;
        end
    endtask


    task automatic uart_send_sample(
        input logic [15:0] sample_value
    );

        begin
            uart_send_byte(sample_value[7:0]);
            uart_send_byte(sample_value[15:8]);
        end
    endtask

    // Byte splitter + BRAM read  
    always @(posedge dut.clk_sys) begin

        if (start_bram_read) begin

            if (dut.bram_en_b) begin

                $display(
                    "t=%0t  PORT B: EN=%b ADDR=%08h DOUT=%08h",
                    $time,
                    dut.bram_en_b,
                    dut.bram_addr_b,
                    dut.bram_dout_b
                );

            end

        end

    end


    // Biquad output
    always @(posedge dut.clk_sys) begin

        if (dut.sample_valid) begin
            $display(
                "t=%0t  SAMPLE=%04h  Y=%04h",
                $time,
                dut.sample,
                dut.y
            );
        end
    end

    // Begin test
    initial begin

        
        // Reset system
        SW_0 = 1'b0;

      $display(" UART -> MICROBlaze -> BRAM -> PORT B READ TEST");
        
        repeat (20) begin
            @(posedge CLK_100MHZ);
        end

        // De-assert reset
        SW_0 = 1'b1;

        $display(
            "Waiting %0t for MicroBlaze boot...",
            MB_BOOT_WAIT
        );

        #(MB_BOOT_WAIT);

       
        $display(" STARTING UART TRANSMISSION");
       
        for (
            i = 0;
            i < NUM_SAMPLES;
            i = i + 1
        ) begin
            $display(
                "Sending sample[%0d] = %04h",
                i,
                samples[i]
            );

            uart_send_sample(samples[i]);
        end

        uart_rtl_rxd = 1'b1;

        $display("UART transmission complete.");
        $display("Bytes sent = %0d", bytes_sent);

        #1_000_000ns;

        $display("STARTING PORT-B READER");

        start_bram_read = 1'b1;

        repeat (2000) begin
            @(posedge CLK_100MHZ);
        end

        $finish;

    end

endmodule
