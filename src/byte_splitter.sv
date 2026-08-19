`timescale 1ns / 1ps

module byte_splitter (
    input  logic               CLK,
    input  logic               rst_n,

    input  logic               start,

    input  logic signed [31:0] BRAM_DOUT,

    output logic        [31:0] ADDRB,
    output logic               EN,

    output logic signed [15:0] sample_out,
    output logic               valid
);

    logic high;
    logic cycle_delay;

    always_ff @(posedge CLK) begin

        if (!rst_n) begin

            ADDRB      <= 32'h00000000;
            EN         <= 1'b0;
            sample_out <= 16'sd0;
            valid      <= 1'b0;
            high       <= 1'b0;
            cycle_delay <= 1'b0;

        end
        else begin

            // Default
            valid <= 1'b0;

            if (!start) begin

                EN   <= 1'b0;
                high <= 1'b0;
                cycle_delay <= 1'b0;

            end

            else begin

                EN <= 1'b1;
                
                if (~cycle_delay) begin
                    ADDRB <= 32'd0;
                    high <= 1'b0;
                    cycle_delay <= 1'b1;
                end else 
                
                    if (!high) begin
    
                        // Low 16 bits
                        sample_out <= BRAM_DOUT[15:0];
                        valid      <= 1'b1;
    
                        high <= 1'b1;
    
                    end
                    else begin
    
                        // High 16 bits
                        sample_out <= BRAM_DOUT[31:16];
                        valid      <= 1'b1;
    
                        // Next 32-bit word
                        ADDRB <= ADDRB + 32'd4;
    
                        high <= 1'b0;
    
                    end

                end

            end

    end

endmodule
