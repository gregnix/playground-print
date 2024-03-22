it
#!/usr/bin/env tclsh

package require twapi
# Brother SDK bPAc 
#brss, sdk 1.5 sdk 2.0

# Make a label with the P-Touch Editor from Brother, 
# create a text field there and save it under ../lbx/test1.lbx


set dirname [file dirname [info script]]
set filename [file tail [info script]]
set filerootname [file rootname [file tail [info script]]]
set liblbx [file join $dirname "lbx"]

set template  test1.lbx
set label [string map {/ \\} [file join $liblbx $template]]

proc brqlPrint {label {textOne " "}  {count 1}} {
  set result [list]
  set broDoc [::twapi::comobj BrssCom.Document]
  lappend result getsheetsize [$broDoc -call getsheetsize 0]  
  lappend result GetTextCount [$broDoc -call GetTextCount ]  
  lappend result Open [$broDoc -call Open $label]
  lappend result GetTextCount [$broDoc -call GetTextCount ]
  #SetText 0 $textOne , text position 0 in template
  #SetText 1 $textOne , text position 1 in template
  lappend result SetText [$broDoc -call SetText 0 $textOne]
  #doPrint 1 0,$count ,with cut
  #doPrint 2 0,$count ,without cut
  #doPrint 2 0,$count ,mirrored
  lappend result doPrint [$broDoc -call doPrint 1 0,$count]
  lappend result close [$broDoc -call close]
  return $result
}

puts [brqlPrint $label "text 1" 1]
# print a Label

  if {0} {
  Output:
  getsheetsize 62mm GetTextCount 0 Open 1 GetTextCount 1 SetText 1 doPrint {} close 1

}

