##=============================================================================
## [Filename]       run.tcl
## [Project]        spi
## [Author]         Julisa Verdejo - julisa.verdejopalacios@ba.infn.it
## [Language]       Tcl (Tool Command Language)
## [Created]        Nov 2024
## [Modified]       -
## [Description]    Tcl file fo run simulation
## [Notes]          This file is passed to the ./simv command 
##                  using the -ucli -do run.tcl flag
## [Status]         devel
## [Revisions]      -
##=============================================================================

dump -file novas.fsdb -type FSDB
dump -add tb.* -depth 4 -fid FSDB0
run
quit