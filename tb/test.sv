module test (
  spi_if vif
);

  int reps = 10;

  initial begin
    $display("Begin Of Simulation.");  
    reset();

    // fork
    //   begin
    //     repeat(reps) write();
    //   end

    //   begin
    //     repeat(reps) check();   
    //   end
            
    // join   

    // fork
    //   begin
    //     repeat(reps) read();
    //   end
      
    //   begin
    //     repeat(reps) spi_slave();
    //   end
        
    // join
    fork
      begin
        repeat(10) write();
        repeat(10) read();
        $finish;
      end

      begin 
        forever check();
      end

      begin
        forever spi_slave();
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
    repeat (5) @(vif.cb); // This line and the next one
    vif.cb.rst_i <= 'b0;  // occur simultaneosly
    repeat (5) @(vif.cb);       
  endtask : reset 
  
  
  task automatic write();
    @(vif.cb);
    vif.cb.din_i <= $urandom_range(0,16777215);
    vif.cb.start_i <= 'b1;
    @(vif.cb);
    vif.cb.start_i <= 'b0;
    
    // waits for rising edge flag
    wait (vif.cb.spi_done_tick_o != 1);
    @(vif.cb iff (vif.cb.spi_done_tick_o == 1));
    
    repeat (1000) @(vif.cb); 
  endtask : write


task automatic read();
  // byte data_check = 'd0;

  @(vif.cb);
  vif.cb.din_i <= 'h0;
  vif.cb.start_i <= 'b1;
  @(vif.cb);
  vif.cb.start_i <= 'b0;

  // for (int i = 0; i < $size(data_check); i++) begin
  //   wait (vif.cb.sclk_o != 1);
  //   @(vif.cb iff (vif.cb.sclk_o == 1));
  //   data_check[7-i] = vif.miso_i;
  // end
  
  // waits for rising edge flag
  wait (vif.cb.spi_done_tick_o != 1);
  @(vif.cb iff (vif.cb.spi_done_tick_o == 1));

  //  if (data_check == vif.dout_o) begin
  //   $display("The received data has no errors: %h", vif.dout_o);
  // end else begin
  //   $display("The received data has errors: dout_o = %h, data_check = %h", vif.dout_o, data_check); 
  // end
  
  repeat (1000) @(vif.cb); 
endtask : read
  
  
  task automatic spi_slave();
  //byte data = $urandom_range(0,255);
  int data = $urandom_range(0,16777215);
  
  //waits risign edge of start
  wait (vif.start_i != 1);
  @(vif.cb iff (vif.start_i == 1));
  vif.miso_i = data[23];
  
  for (int i = 22; i > 0; i--) begin
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
  task automatic check();
  int cnt_error = 0;
  int mosi_data = 0; //vif.mosi_o copy
  int miso_data = 0; //vif.miso_i copy
  int data_in = 0; //vif.din_i copy
  int data_out = 0; //vif.dout_o copy

  wait (vif.start_i != 1);
  @(vif.cb iff (vif.start_i == 1));
  data_in = vif.din_i;

  for (int i = 0; i < 24; i++) begin
    wait (vif.cb.sclk_o != 1);
    @(vif.cb iff (vif.cb.sclk_o == 1));
    mosi_data[23-i] = vif.mosi_o;
    miso_data[23-i] = vif.miso_i;
    // if (data_in[7-i] != vif.mosi_o) begin
    //   cnt_error++;
    // end
  end

  wait (vif.cb.spi_done_tick_o != 1);
  @(vif.cb iff (vif.cb.spi_done_tick_o == 1));
  data_out = vif.dout_o;

  if (data_in == mosi_data) begin
    $display("[INFO]: mosi was sent correctly: %h", mosi_data);
  end else begin
    $display("[ERROR]: mosi = %h, data_in = %h", mosi_data, data_in);
  end

  if (data_out == miso_data) begin
    $display("[INFO]: miso was received correctly: %h", miso_data);
  end else begin
    $display("[ERROR]: miso = %h, data_out = %h", miso_data, data_out);
  end

  // $display("There are: %2d errors", cnt_error);
  // if (data_in == mosi_data) begin
  //   $display("The sent data has no errors: %h", mosi_data);
  // end else begin
  //   $display("The sent data has errors: din_i = %h, mosi_data = %h", data_in, mosi_data); 
  // end

  endtask : check
  
endmodule : test
