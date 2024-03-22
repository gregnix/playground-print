#!/usr/bin/env tclsh

package require twapi
# Brother bPAC SDK
# Make a label with the P-Touch Editor from Brother,
# create a text field there and save it under ../lbx/company.lbx
# attribut name text2
# Brother QL 550 - print with SDK bPAC 32 bit
# Brother QL 560 - print with SDK bPAC 32 bit and 64 bit 

set dirname [file dirname [info script]]
set filename [file tail [info script]]
set filerootname [file rootname [file tail [info script]]]
set liblbx [file join $dirname "lbx"]

set template company.lbx
set label [string map {/ \\} [file join $liblbx $template]]

proc brqlPrint {label {textOne "test "} {count 1} {print 1} } {
  set result [list]
  lappend result label $label
  lappend result {file exists} [file exists $label]

  lappend result errcatch [catch {set bpacDoc [::twapi::comobj bpac.Document]} res] bpacDoc $res
#  lappend result errcatch [catch {set bpacPrinter [::twapi::comobj bpac.Printer]} res] bpacPrinter $res
#  lappend result errcatch [catch {set bpacObject [::twapi::comobj bpac.Object]} res] bpacObject $res  
  #Doc
#  lappend result errcatch [catch {set objPrinter [$bpacDoc printer]} res] objPrinter $res
#  lappend result errcatch [catch {set printerName [$objPrinter name]} res] printerName $res
#  lappend result errcatch [catch {set objObjects [$bpacDoc objects]} res] objObjects $res

  lappend result errcatch [catch {$bpacDoc -call open $label} res] bpacopenlabel $res
   
  set labelobjName "Text2"
  lappend result "labelobjName" $labelobjName
  lappend result errcatch [catch {set objName [$bpacDoc -call GetObject $labelobjName]} res] objName $res
  lappend result errcatch [catch {$objName -call text $textOne } res] objnametext $res
  lappend result errcatch [catch {$bpacDoc -call Startprint "" &H1} res] startprint $res
  lappend result errcatch [catch {$bpacDoc -call PrintOut 1 &H1} res] printout $res
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


set result [brqlPrint $label "text nam"  1 1]
puts [dict get $result prettyresult ]
#puts $result

# print a Label
#
if {[file tail [info nameofexecutable]] eq "wish.exe"} {
  text .t
  .t insert end [dict get $result prettyresult]
  pack .t
}

if {0} {

  Output:
label         = F:\tcltk\project\printing\brotherql\lbx\company.lbx
file exists   = 1
errcatch      = 0
bpacDoc       = ::oo::Obj26
#errcatch      = 0
#bpacPrinter   = ::oo::Obj28
#errcatch      = 0
#bpacObject    = ::oo::Obj30
#errcatch      = 0
#objPrinter    = ::oo::Obj32
#errcatch      = 0
#printerName   = Brother QL-550
#errcatch      = 0
#objObjects    = ::oo::Obj34
errcatch      = 0
bpacopenlabel = 1
labelobjName  = Text2
errcatch      = 0
objName       = ::oo::Obj36
errcatch      = 0
objnametext   =
errcatch      = 0
startprint    = 1
errcatch      = 0
printout      = 0
errcatch      = 0
endprint      = 1
errcatch      = 0
close         = 1

Drücken Sie eine beliebige Taste . . .
}
