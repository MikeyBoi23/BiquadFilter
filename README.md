# BiquadFilter
Digital Biquad Filter implementation in Vivado with SystemVerilog and C. PC end user sends traffic using UART to Microblaze instance which then writes into BRAM through AXI4-Lite interface. Another module reads every word stored in the RAM block, splitting them into half-words or samples to be processed by the filter.
