module slave(
  input logic         clk_i,
  input logic         rst_i,
  input logic  [7:0]  din_i,
  input logic  [15:0] dvsr_i,
  input logic         start_i,
  input logic         cpol_i,
  input logic         cpha_i,
  output logic [7:0]  dout_o,
  output logic        spi_done_tick_o,
  output logic        ready_o,
  output logic        sclk_o,
  input logic         miso_i,
  output logic        mosi_o
);
    
    
endmodule