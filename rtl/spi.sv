module spi #(
  parameter int WordLength = 8
)(
  input logic                   clk_i,
  input logic                   rst_i,
  input logic  [WordLength-1:0] din_i,
  input logic  [15:0]           dvsr_i,
  input logic                   start_i,
  input logic                   cpol_i,
  input logic                   cpha_i,
  output logic [WordLength-1:0] dout_o,
  output logic                  spi_done_tick_o,
  output logic                  ready_o,
  output logic                  sclk_o,
  input logic                   miso_i,
  output logic                  mosi_o
);
    
  //fsm state type
  typedef enum {idle, cpha_delay, p0, p1} state_type;
  
  //declaration
  state_type state_reg, state_next;
  logic p_clk;
  logic [15:0] c_reg, c_next;
  logic spi_clk_reg, ready_i, spi_done_tick_i;
  logic spi_clk_next;
  logic [2:0] n_reg, n_next;
  logic [WordLength-1:0] si_reg, si_next;
  logic [WordLength-1:0] so_reg, so_next;
  
  always_ff @(posedge clk_i, posedge rst_i)
    if(rst_i) begin
      state_reg <= idle;
      si_reg <= 0;
      so_reg <= 0;
      n_reg <= 0;
      c_reg <= 0;
      spi_clk_reg <= 0;
    end
    else begin
      state_reg <= state_next;
      si_reg <= si_next;
      so_reg <= so_next;
      n_reg <= n_next;
      c_reg <= c_next;
      spi_clk_reg <= spi_clk_next;
    end
    
    always_comb
    begin
    //Retro
      state_next = state_reg;
      ready_i = 0;
      spi_done_tick_i = 0;
      si_next = si_reg;
      so_next = so_reg;
      n_next = n_reg;
      c_next = c_reg;
      case (state_reg)
        idle: begin
          ready_i = 1;
          if (start_i) begin
            so_next = din_i;
            n_next = 0;  
            c_next = 0;
            if (cpha_i)
              state_next = cpha_delay;
            else
              state_next = p0;
          end
        end
          
        cpha_delay: begin
          if (c_reg == dvsr_i) begin
            state_next = p0;
            c_next = 0;
          end
          else
              c_next = c_reg + 1;
        end
          
        p0: begin
            if (c_reg == dvsr_i) begin
              state_next = p1;
              si_next = {si_reg[6:0], miso_i};
              c_next = 0;
            end
            else
              c_next = c_reg + 1;
        end         

        p1: begin
          if (c_reg == dvsr_i)
            if (n_reg == WordLength-1) begin
              spi_done_tick_i = 1;
              state_next = idle;
            end
            else begin
              so_next = {so_reg[WordLength-2:0], 1'b0};
              state_next = p0;
              n_next = n_reg + 1;
              c_next = 0;
            end
          else
            c_next = c_reg + 1;
        end                             
       endcase
    end
    
    assign ready_o = ready_i;
    assign spi_done_tick_o = spi_done_tick_i;
    
    //lookahead output decoding
    assign p_clk = (state_next == p1 && ~cpha_i) || (state_next == p0 && cpha_i);
    assign spi_clk_next = (cpol_i) ? ~p_clk : p_clk;
    
    //output
    assign dout_o = si_reg;
    assign mosi_o = so_reg[7];
    assign sclk_o = spi_clk_reg;
    
endmodule