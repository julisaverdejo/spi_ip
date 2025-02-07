# Activate Signal List Panel
srcSignalView -on
verdiSetActWin -dock widgetDock_<Signal_List>

# Add Digital Signals
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "tb.vif" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBDrag -win $_nTrace1
wvSetPosition -win $_nWave2 {("vif(spi_if)" 0)}
wvRenameGroup -win $_nWave2 {G1} {vif(spi_if)}
wvAddSignal -win $_nWave2 "/tb/vif/clk_i" "/tb/vif/rst_i" "/tb/vif/din_i\[7:0\]" \
           "/tb/vif/dvsr_i\[15:0\]" "/tb/vif/start_i" "/tb/vif/cpol_i" \
           "/tb/vif/cpha_i" "/tb/vif/dout_o\[7:0\]" "/tb/vif/spi_done_tick_o" \
           "/tb/vif/ready_o" "/tb/vif/sclk_o" "/tb/vif/miso_i" \
           "/tb/vif/mosi_o"
wvSetPosition -win $_nWave2 {("vif(spi_if)" 0)}
wvSetPosition -win $_nWave2 {("vif(spi_if)" 13)}
wvSetPosition -win $_nWave2 {("vif(spi_if)" 13)}
wvSetPosition -win $_nWave2 {("G2" 0)}

# Add Analog Signals

# Zoom to fit
verdiSetActWin -win $_nWave2
wvZoomAll -win $_nWave2