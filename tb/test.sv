module test (
  spi_if vif
);

  initial begin
    $display("Begin Of Simulation.");
    
    reset();
    write();
    fork
      begin
      vif.cb.start_i <= 'b1;
      vif.cb.din_i <= 'h00;
      //vif.cb.din_i <= $urandom_range(0,255);
      @(vif.cb);
      vif.cb.start_i <= 'b0; 
      end
      
      begin
        read();
      end
        
    join
    
    $display("End Of Simulation.");
    $finish;
  end
  
  task automatic reset();
    vif.rst_i = 'b1;
    vif.din_i = 'h00;
    vif.dvsr_i = 'd64;
    vif.start_i = 'b0;
    vif.cpol_i = 'b0;  
    vif.cpha_i = 'b0;
    vif.miso_i = 'b0; 
    repeat (5) @(vif.cb); //line 35 and 36 occur simultaneously
    vif.cb.rst_i <= 'b0;  
    repeat (5) @(vif.cb);       
  endtask : reset 
  
  
  task automatic write();
  @(vif.cb);
  vif.cb.din_i <= 'hAA;
  //vif.cb.din_i <= $urandom_range(0,255);
  vif.cb.start_i <= 'b1;
  @(vif.cb);
  vif.cb.start_i <= 'b0;
  
  // waits for rising edge flag
  wait (vif.cb.spi_done_tick_o != 1);
  @(vif.cb iff (vif.cb.spi_done_tick_o == 1));
  
  repeat (200) @(vif.cb); 
  
  endtask : write
  
  
  task automatic read();
  byte data = 'h23;
  for (int i = 0; i < 8; i++) begin
    $display("iter %d: data[%d] = %b", i, i, data[i]);
  end
  
  //waits risign edge of start
  wait (vif.start_i != 1);
  @(vif.cb iff (vif.start_i == 1));
  vif.miso_i = data[7];
  
  for (int i = 6; i > 0; i--) begin
    wait (vif.cb.sclk_o != 1);
    @(vif.cb iff (vif.cb.sclk_o == 1)); 
    wait (vif.cb.sclk_o != 0);
    @(vif.cb iff (vif.cb.sclk_o == 0));
    vif.miso_i = data[i];       
  end
    
  wait (vif.cb.spi_done_tick_o != 1);
  @(vif.cb iff (vif.cb.spi_done_tick_o == 1));
  vif.miso_i = 'b0;    
  repeat (200) @(vif.cb);   
  endtask : read

  
endmodule : test
