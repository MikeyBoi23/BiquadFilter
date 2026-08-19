# BiquadFilter
Digital Biquad Filter implementation in Vivado with SystemVerilog, C, and Python. PC end user sends traffic using UART, through a Python Script, to Microblaze instance which then writes into BRAM through AXI4-Lite interface. Another module reads every word stored in the RAM block, splitting them into half-words or samples to be processed by the filter. The biquad filter module itself uses 2q14 (16-bit signed) Fixed-Point Arithmetic to process the samples and can be used to implement different types of filters.

Next Steps:
  - Send a control signal from MB to the word splitter in order to simplify TB and avoid manufactured wait times for reading/processing to begin
  - Write processed samples back into BRAM instead of dumping output through the TB
  - Employ UART TX path to send the output file back to end user to generate new plot through our python script

Note:
This repository is meant to showcase the code and cannot be lifted and used in Vivado directly, many other files and directories, such as our .xsa/Vitis platform and component, would be needed.
