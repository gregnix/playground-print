#!/usr/bin/env tclsh

package require twapi
# Version 24.03.2024 0340
# Brother bPAC SDK
# Make a label with the P-Touch Editor from Brother,
# create a text field there and save it under ../lbx/company.lbx

namespace eval Bpac {
  variable bpoVariable
  variable result

  set bpoVariable [dict create]
  dict set bpoVariable default {
    bpoDefault 0x0
    bpoAutoCut 0x1
    bpoCutPause 0x1
    bpoCutMark 0x2
    bpoHalfCut 0x200
    bpoChainPrint 0x400
    bpoTailCut 0x800
    bpoSpecialTape 0x00080000
    bpoCutAtEnd 0x04000000
    bpoNoCut 0x10000000
    bpoMirroring 0x4
    bpoQuality 0x0010000
    bpoHighResolution 0x10000000
    bpoColor 0x8
    bpoMono 0x10000000
    bpoContinue 0x40000000
  }
  dict set bpoVariable "Brother QL-550" {
    bpoAutoCut &H1
    bpoNoCut &H10000000
  }
  dict set bpoVariable "Brother QL-560" {
    bpoAutoCut &H1
    bpoNoCut &H10000000
    bpoCutAtEnd &H4000000
  }
  dict set bpoVariable "ExportType" {
    bexOpened 0x0
    bexLbx 0x1
    bexLbl 0x2
    bexBmp 0x4
    bexPAF 0x5
  }
}
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

proc ::Bpac::pPrintOptionConstants {printerName bpov} {
  variable bpoVariable
  if {$bpov in [dict keys [dict get $bpoVariable default]]} {
    puts "ok"
  } else {
    puts "error"
  }
  if {[dict exists $bpoVariable $printerName $bpov]} {
    set res [dict get $bpoVariable $printerName $bpov]
  }  else {
    set res [dict get $bpoVariable default $bpov]
  }
  return $res
}

proc ::Bpac::brqlPrint {label expbmp {textOne "test "} {count 1} {print 1} } {
  variable result
  variable bpoVariable
  set result [list]
  lappend result patchlevel [info patchlevel]
  #  lappend result auto_path $::auto_path
  #  lappend result tcl__tm__path [::tcl::tm::path list]
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
  lappend result err_bpacDoc [catch {set bpacDoc [::twapi::comobj bpac.Document]} res] bpacDoc $res
  lappend result err_bpacPrinter [catch {set bpacPrinter [::twapi::comobj bpac.Printer]} res] bpacPrinter $res
  lappend result err_bpacObject [catch {set bpacObject [::twapi::comobj bpac.Object]} res] bpacObject $res
  #Doc
  lappend result err_objPrinter [catch {set objPrinter [$bpacDoc printer]} res] objPrinter $res
  lappend result err_printerName [catch {set printerName [$objPrinter name]} res] printerName $res
  lappend result err_objObjects [catch {set objObjects [$bpacDoc objects]} res] objObjects $res

  lappend result err_bpacopenlabel [catch {$bpacDoc -call open $label} res] bpacopenlabel $res

  set labelobjName "Text2"
  lappend result "labelobjName" $labelobjName
  lappend result err_labelobjName [catch {set objGetObject [$bpacDoc -call GetObject $labelobjName]} res] objGetObject $res
  lappend result err_objnametext [catch {$objGetObject -call text $textOne } res] objnametext $res

  lappend result err_GetMediaID [catch {set objMediaID [$bpacDoc -call GetMediaID ]} res] objGetMediaID $res
  lappend result err_objGetMediaName [catch {set objMediaName [$bpacDoc -call GetMediaName ]} res] objGetMediaName $res

  lappend result err_GetText [catch {set objGetText [$bpacDoc -call GetText 1 0,Company  ]} res] objGetText $res
  lappend result err_GetTextCount [catch {set objGetTextCount [$bpacDoc -call GetTextCount ]} res] objGetTextCount $res
  foreach LabelfieldName {Company Name nowordfound } {
    lappend result "LabelfieldName" $LabelfieldName
    lappend result err_GetTextIndex [catch {$bpacDoc -call GetTextIndex $LabelfieldName} res] objGetTextIndex $res
  }
  
  lappend result err_ExportType [catch {set ExportType [dict get $bpoVariable ExportType bexBmp]} res] Exporttype $res
  lappend result err_expbmp [catch {$bpacDoc -call export $ExportType $expbmp 300 } res] export $res
  lappend result err_bpoAutoCut [catch {set bpoAutoCut [pPrintOptionConstants $printerName bpoAutoCut]} res] bpoAutoCut $res

  lappend result err_startprint [catch {$bpacDoc -call Startprint "" $bpoAutoCut} res] startprint $res
  if {$print} {
    lappend result err_printout [catch {$bpacDoc -call PrintOut 1 0} res] printout $res
  }
  lappend result err_endprint [catch {$bpacDoc -call EndPrint} res] endprint $res
  lappend result err_close [catch {$bpacDoc -call Close} res] close $res

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
set print 1
set result [::Bpac::brqlPrint $label $expbmp "text name\ncompany"  $count $print]

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

