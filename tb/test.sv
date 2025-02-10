module test (
  spi_if vif
);

  int reps = 10;

  initial begin
    $display("Begin Of Simulation.");  
    reset();

    fork
      begin
        repeat(reps) write();
      end

      begin
        repeat(reps) check_write();   
      end
            
    join   

    fork
      begin
        repeat(reps) read();
      end
      
      begin
        repeat(reps) spi_slave();
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
  //vif.cb.din_i <= 'hAA;
  vif.cb.din_i <= $urandom_range(0,255);
  vif.cb.start_i <= 'b1;
  @(vif.cb);
  vif.cb.start_i <= 'b0;
  
  // waits for rising edge flag
  wait (vif.cb.spi_done_tick_o != 1);
  @(vif.cb iff (vif.cb.spi_done_tick_o == 1));
  
  repeat (1000) @(vif.cb); 
  
  endtask : write


task automatic read();
  byte data_check = 'd0;

  @(vif.cb);
  vif.cb.din_i <= 'h0;
  vif.cb.start_i <= 'b1;
  @(vif.cb);
  vif.cb.start_i <= 'b0;

  for (int i = 0; i < $size(data_check); i++) begin
    wait (vif.cb.sclk_o != 1);
    @(vif.cb iff (vif.cb.sclk_o == 1));
    data_check[7-i] = vif.miso_i;
  end
  
  // waits for rising edge flag
  wait (vif.cb.spi_done_tick_o != 1);
  @(vif.cb iff (vif.cb.spi_done_tick_o == 1));

   if (data_check == vif.dout_o) begin
    $display("The received data has no errors: %h", vif.dout_o);
  end else begin
    $display("The received data has errors: dout_o = %h, data_check = %h", vif.dout_o, data_check); 
  end
  
  repeat (1000) @(vif.cb); 
endtask : read
  
  
  task automatic spi_slave();
  byte data = $urandom_range(0,255);
  
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

  endtask : spi_slave

/* ################## CHECK ################## */
  task automatic check_write();
  int cnt_error = 0;
  byte mosi_data = 0;
  byte data_in = 0;

  // 
  wait (vif.start_i != 1);
  @(vif.cb iff (vif.start_i == 1));
  data_in = vif.din_i;

  for (int i = 0; i < $size(data_in); i++) begin
    wait (vif.cb.sclk_o != 1);
    @(vif.cb iff (vif.cb.sclk_o == 1));
    mosi_data[7-i] = vif.mosi_o;
    if (data_in[7-i] != vif.mosi_o) begin
      cnt_error++;
    end
  end
  $display("There are: %2d errors", cnt_error);
  if (data_in == mosi_data) begin
    $display("The sent data has no errors: %h", mosi_data);
  end else begin
    $display("The sent data has errors: din_i = %h, mosi_data = %h", data_in, mosi_data); 
  end

  endtask : check_write
  
endmodule : test
