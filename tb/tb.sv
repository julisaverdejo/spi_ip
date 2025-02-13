module tb;

  // clock signal
  localparam time ClkPeriod = 10ns;
  logic clk_i = 0;
  always #(ClkPeriod / 2) clk_i = ~clk_i;
  
  // interface
  spi_if #(
    .WordLength(8)
  ) vif (clk_i);
  
  // test
  test top_test (vif);
  
  // instantiation
  spi #(
    .WordLength(8)
  ) dut (
    .clk_i(vif.clk_i),
    .rst_i(vif.rst_i),
    .din_i(vif.din_i),
    .dvsr_i(vif.dvsr_i),
    .start_i(vif.start_i),
    .cpol_i(vif.cpol_i),
    .cpha_i(vif.cpha_i),
    .dout_o(vif.dout_o),
    .spi_done_tick_o(vif.spi_done_tick_o),
    .ready_o(vif.ready_o),
    .sclk_o(vif.sclk_o),
    .miso_i(vif.miso_i),
    .mosi_o(vif.mosi_o)
  );
  
  initial begin
    $timeformat(-9, 1, "ns", 10);
  end
endmodule
