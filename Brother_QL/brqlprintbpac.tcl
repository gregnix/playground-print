#!/usr/bin/env tclsh

package require twapi
# Version 23.03.2024 1340
# Brother bPAC SDK
# Make a label with the P-Touch Editor from Brother,
# create a text field there and save it under ../lbx/company.lbx


set dirname [file dirname [info script]]
set filename [file tail [info script]]
set filerootname [file rootname [file tail [info script]]]
set liblbx [file join $dirname "lbx"]
set exportdir [file join $dirname "export"]
catch {file mkdir export}
set logdir [file join $dirname "log"]
catch {file mkdir $logdir}

set template company.lbx
set label [string map {/ \\} [file join $liblbx $template]]
set expbmp [string map {/ \\} [file join $exportdir [file rootname $template]-${::tcl_platform(pointerSize)}.bmp]]

proc writeFile {filename data} {
  set f [open $filename "w"]
  puts -nonewline $f $data
  close $f
}

proc brqlPrint {label expbmp {textOne "test "} {count 1} {print 1} } {
  set result [list]
  lappend result patchlevel [info patchlevel]
  lappend result tcl_platform(os) $::tcl_platform(os)
  lappend result tcl_platform(osVersion) $::tcl_platform(osVersion)
  lappend result tcl_platform(pointerSize) $::tcl_platform(pointerSize)
  lappend result tcl_platform(machine)  $::tcl_platform(machine)
  lappend result ::env(PROCESSOR_ARCHITECTURE) $::env(PROCESSOR_ARCHITECTURE)
  lappend result ::env(SESSIONNAME) $::env(SESSIONNAME)
  lappend result nameofexecutable [info nameofexecutable]
  lappend result label $label
  lappend result {file exists} [file exists $label]
  lappend result expbmp $expbmp
  lappend result errcatch [catch {set bpacDoc [::twapi::comobj bpac.Document]} res] bpacDoc $res
  lappend result errcatch [catch {set bpacPrinter [::twapi::comobj bpac.Printer]} res] bpacPrinter $res
  lappend result errcatch [catch {set bpacObject [::twapi::comobj bpac.Object]} res] bpacObject $res
  #Doc
  lappend result errcatch [catch {set objPrinter [$bpacDoc printer]} res] objPrinter $res
  lappend result errcatch [catch {set printerName [$objPrinter name]} res] printerName $res
  lappend result errcatch [catch {set objObjects [$bpacDoc objects]} res] objObjects $res

  lappend result errcatch [catch {$bpacDoc -call open $label} res] bpacopenlabel $res

  set labelobjName "Text2"
  lappend result "labelobjName" $labelobjName
  lappend result errcatch [catch {set objGetObject [$bpacDoc -call GetObject $labelobjName]} res] objGetObject $res
  lappend result errcatch [catch {$objGetObject -call text $textOne } res] objnametext $res

  lappend result errcatch [catch {set objMediaID [$bpacDoc -call GetMediaID ]} res] objGetMediaID $res
  lappend result errcatch [catch {set objMediaName [$bpacDoc -call GetMediaName ]} res] objGetMediaName $res
  lappend result errcatch [catch {set objGetTextCount [$bpacDoc -call GetTextCount ]} res] objGetTextCount $res
  lappend result errcatch [catch {set objGetTextIndex [$bpacDoc -call GetTextIndex "Text2"  ]} res] objGetTextIndex $res
  lappend result errcatch [catch {$bpacDoc -call export 0x4 $expbmp 300 } res] export $res
  
  lappend result errcatch [catch {$bpacDoc -call Startprint "" &H1} res] startprint $res
  if {$print} {
  lappend result errcatch [catch {$bpacDoc -call PrintOut 1 &H1} res] printout $res
  }
  lappend result errcatch [catch {$bpacDoc -call EndPrint} res] endprint $res
  lappend result errcatch [catch {$bpacDoc -call Close} res] close $res

  #pretty result
  set longest 0
  foreach key [dict keys $result] {
    set l [string length $key]
    if {$l > $longest} {set longest $l}
  }
  lmap {k v} $result {append prettyresult [format "%-*s = %s" $longest $k $v] "\n"}
  return [lappend result prettyresult $prettyresult]
}

# 
set count 1
set print 0
set result [brqlPrint $label $expbmp "text name\ncompany"  $count $print]

#Output conole
puts [dict get $result prettyresult ]

#Output a file in ./log/log-x.txt
#tcl_platform(pointerSize) 4 -> 32 Bit  8 -> 64 Bit
writeFile [file join $logdir log-${::tcl_platform(pointerSize)}.txt] [dict get $result prettyresult ]

#Output text widget
if {[file tail [info nameofexecutable]] eq "wish.exe"} {
  text .t
  .t insert end [dict get $result prettyresult]
  pack .t -expand 1 -fill both
}

