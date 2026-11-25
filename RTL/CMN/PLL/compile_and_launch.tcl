proc vsimulink {args} {

  lappend sllibarg -foreign \{simlinkserver \{D:/DIGITAL/MATLAB/toolbox/edalink/extensions/modelsim/windows64/liblfmhdls_tmwvs.dll\}
  if {[catch {lsearch -exact $args -socket} idx]==0  && $idx >= 0} {
    set socket [lindex $args [expr {$idx + 1}]]
    set args [lreplace $args $idx [expr {$idx + 1}]]
    append socketarg " \; -socket " "$socket"
    lappend sllibarg $socketarg
  }
  set runmode "GUI"
  if { $runmode == "Batch" || $runmode == "Batch with Xterm"} {
    lappend sllibarg " \; -batch"
  }
  lappend sllibarg \}
  set args [linsert $args 0 vsim]
  lappend args [join $sllibarg]
  uplevel 1 [join $args]
}
proc vsimmatlab {args} {

  lappend mllibarg -foreign \{matlabclient \{D:/DIGITAL/MATLAB/toolbox/edalink/extensions/modelsim/windows64/liblfmhdlc_tmwvs.dll\}
  lappend mllibarg \}
  lappend mlinput 
  lappend mlinput [join $args]
  lappend mlinput [join $mllibarg]
   set mlinput [linsert $mlinput 0 vsim]
  uplevel 1 [join $mlinput]
}
proc vsimmatlabsysobj {args} {

  lappend sllibarg -foreign \{matlabsysobjserver \{D:/DIGITAL/MATLAB/toolbox/edalink/extensions/modelsim/windows64/liblfmhdls_tmwvs.dll\}
  if {[catch {lsearch -exact $args -socket} idx]==0  && $idx >= 0} {
    set socket [lindex $args [expr {$idx + 1}]]
    set args [lreplace $args $idx [expr {$idx + 1}]]
    append socketarg " \; -socket " "$socket"
    lappend sllibarg $socketarg
  }
  set runmode "GUI"
  if { $runmode == "Batch" || $runmode == "Batch with Xterm"} {
    lappend sllibarg " \; -batch"
  }
  lappend sllibarg \}
  set args [linsert $args 0 vsim]
  lappend args [join $sllibarg]
  uplevel 1 [join $args]
}
vsimulink pll_pfd_freq -t 1fs -voptargs=+acc  -f parameter_pll_pfd_freq.cfg -socket 63521;
add wave pll_pfd_freq/*;

