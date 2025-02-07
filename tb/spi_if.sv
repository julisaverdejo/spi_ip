interface spi_if (
  input logic clk_i
 ); 
 
  logic         rst_i;
  logic [7:0]   din_i;
  logic  [15:0] dvsr_i;
  logic         start_i;
  logic         cpol_i;
  logic         cpha_i;
  logic [7:0]   dout_o;
  logic         spi_done_tick_o;
  logic         ready_o;
  logic         sclk_o;
  logic         miso_i;
  logic         mosi_o;
  
  clocking cb @(posedge clk_i); 
    default input #1ns output #5ns; //these times are applied after 1 clk cycle
	  output   rst_i;
    output   din_i;
    output   dvsr_i;
    output   start_i;
    output   cpol_i;
    output   cpha_i;
    input    dout_o;
    input    spi_done_tick_o;
    input    ready_o;
    input    sclk_o;
    output   miso_i;
    input    mosi_o;	
  endclocking
  
endinterface : spi_if