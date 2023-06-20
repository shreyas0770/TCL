#! /bin/env tclsh

#-----------------------------------------------------------#
#----- Checks whether panda usage is correct or not -----#
#-----------------------------------------------------------#

set generate_sdc 1
set enable_prelayout_timing 1
set working_dir [exec pwd]
set pan_array_length [llength [split [lindex $argv 0] .]]
set input [lindex [split [lindex $argv 0] .] $pan_array_length-1]

if {![regexp {^csv} $input] || $argc!=1 } {
puts "Error in usage"
puts "Usage: ./panda <.csv>"
puts "where <.csv> file has below inputs"
exit
} else {
#-----------------------------------------------------------------------------------------------------------------------------------------------------#
#------ converts .csv to matrix and creates initial variables "DesignName OutputDirectory NetlistDirectory EarlyLibraryPath LateLibraryPath"----------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------#
	set filename [lindex $argv 0]
	package require csv
	package require struct::matrix
	struct::matrix m
	set f [open $filename]
	csv::read2matrix $f m , auto
	close $f
	set columns [m columns]
	m add columns $columns
	m link my_arr
	set num_of_rows [m rows]
	set i 0
	while {$i < $num_of_rows} {
		 puts "\nInfo: Setting $my_arr(0,$i) as '$my_arr(1,$i)'"
		 if {$i == 0} {
			 set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
		 } else {
			 set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
		 }
		  set i [expr {$i+1}]
	}
} 

puts "\nInfo: Below are the list of initial variables and their values. User can use these variables for further debug. Use 'puts <variable name>' command to query value of below variables"
puts "DesignName = $DesignName"
puts "OutputDirectory = $OutputDirectory"
puts "NetlistDirectory = $NetlistDirectory"
puts "EarlyLibraryPath = $EarlyLibraryPath"
puts "LateLibraryPath = $LateLibraryPath"
puts "ConstraintsFile = $ConstraintsFile"


#------------------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------To check if directories and files in .csv file are valid-------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------------------------------------#

if {![file isdirectory $OutputDirectory]} {
	puts "\n Info: Couln't find output directory in the path $OutputDirectory. Creating it.."
	file mkdir $OutputDirectory
} else {
	puts "\n Found output directory in the path $OutputDirectory"
}

if {! [file exists $EarlyLibraryPath] } {
	puts "\nError: Cannot find early cell library in path $EarlyLibraryPath. Exiting... "
	exit
} else {
	puts "\nInfo: Early cell library found in path $EarlyLibraryPath"
}


if {! [file exists $LateLibraryPath]} {
        puts "\nError: Cannot find late cell library in path $LateLibraryPath. Exiting... "
        exit
} else {
	puts "\nInfo: Late cell library found in path $LateLibraryPath"
}

if {! [file isdirectory $NetlistDirectory]} {
	puts "\nError: Cannot find RTL netlist directory in path $NetlistDirectory. Exiting..."
	exit
} else {
	puts "\nInfo: RTL netlist directory found in path $NetlistDirectory"
}

if {! [file exists $ConstraintsFile] } {
        puts "\nError: Cannot find constraints file in path $ConstraintsFile. Exiting... "
        exit
} else {
        puts "\nInfo: Constraints file found in path $ConstraintsFile"
}


#-------------------------------------------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------Converting Contraint file to SDC format------------------------------------------------------------------#
#-------------------------------------------------------------------------------------------------------------------------------------------------------#

puts "\nInfo: Dumping SDC constraints for $DesignName"
::struct::matrix constraints
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints  , auto
close $chan
set number_of_rows [constraints rows]
set number_of_columns [constraints columns]

set clock_start [lindex [lindex [constraints search all CLOCKS] 0 ] 1]
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0 ] 0]

#-----check row number for "inputs" section in constraints.csv---##
set input_ports_start [lindex [lindex [constraints search all INPUTS] 0 ] 1]

#-----check row number for "outputs" section in constraints.csv---##
set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0 ] 1]

puts "\n clock_start = $clock_start"
puts "\n clock_start_column = $clock_start_column"
puts "\n input_ports_start = $input_ports_start"
puts "\n output_ports_start = $output_ports_start"

#-------------------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------- Code snippet to add  clock contraints from .csv file to SDC file ---------------------------------------------#
#-------------------------------------------------------------------------------------------------------------------------------------------------------#

set clock_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  early_rise_delay] 0 ] 0]

set clock_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  early_fall_delay] 0 ] 0]

set clock_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  late_rise_delay] 0 ] 0]

set clock_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  late_fall_delay] 0 ] 0]

#-------------------clock transition constraints-------------------#

set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  early_rise_slew] 0 ] 0]

set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  early_fall_slew] 0 ] 0]

set clock_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  late_rise_slew] 0 ] 0]

set clock_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}]  late_fall_slew] 0 ] 0]

set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
set i [expr {$clock_start+1}]
set end_of_ports [expr {$input_ports_start-1}]
puts "\nInfo-SDC: Working on clock constraints....."
while { $i < $end_of_ports } {
        puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell 0 $i] -period [constraints get cell 1 $i] -waveform \{0 [expr {[constraints get cell 1 $i]*[constraints get cell 2 $i]/100}]\} \[get_ports [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_input_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_input_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_input_transition -rise -max [constraints get cell $clock_late_rise_slew_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_input_transition -fall -max [constraints get cell $clock_late_fall_slew_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_input_delay  -min -rise [constraints get cell $clock_early_rise_delay_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_input_delay  -min -fall [constraints get cell $clock_early_fall_delay_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_input_delay  -max -rise [constraints get cell $clock_late_rise_delay_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_input_delay  -max -fall [constraints get cell $clock_late_fall_delay_start $i] -clock [constraints get cell 0 $i] \[get_ports [constraints get cell 0 $i]\]"
        set i [expr {$i+1}]
}

#------------------------------------------------------------------------------##
#-------------------create input delay and slew constraints--------------------##
#------------------------------------------------------------------------------##

set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_rise_delay] 0 ] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_fall_delay] 0 ] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_rise_delay] 0 ] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_fall_delay] 0 ] 0]

set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_rise_slew] 0 ] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_fall_slew] 0 ] 0]
set input_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_rise_slew] 0 ] 0]
set input_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_fall_slew] 0 ] 0]


set related_clock [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  clocks] 0 ] 0]
set bussed_status [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  bussed] 0 ] 0]

set i [expr {$input_ports_start+1}]
set end_of_ports [expr {$output_ports_start-1}]
puts "\nInfo-SDC: Working on IO constraints....."
puts "\nInfo-SDC: Categorizing input ports as bits and bussed"

while { $i < $end_of_ports } {
#--------------------------optional script----differentiating input ports as bussed and bits------#
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open ./temp/1 w]
foreach f $netlist {
        set fd [open $f]
        while {[gets $fd line] != -1} {
		set pattern1 " [constraints get cell 0 $i];"
                if {[regexp -all -- $pattern1 $line]} {
			set pattern2 [lindex [split $line ";"] 0]
			if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {	
			set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
			puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
			}
                }
        }
close $fd
}
close $tmp_file


set tmp_file [open ./temp/1 r]
set tmp2_file [open ./temp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open ./temp/2 r]
set count [split [llength [read $tmp2_file]] " "]
if {$count > 2} { 
	set inp_ports [concat [constraints get cell 0 $i]*] 
	} else {
	set inp_ports [constraints get cell 0 $i]
	}
        puts -nonewline $sdc_file "\nset_input_delay -clock  [constraints get cell $related_clock $i] -min -rise  [constraints get cell $input_early_rise_delay_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock  [constraints get cell $related_clock $i] -min -fall  [constraints get cell $input_early_fall_delay_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock  [constraints get cell $related_clock $i] -max -rise  [constraints get cell $input_late_rise_delay_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock  [constraints get cell $related_clock $i] -max -fall  [constraints get cell $input_late_fall_delay_start $i] \[get_ports $inp_ports\]"

        puts -nonewline $sdc_file "\nset_input_transition -clock  [constraints get cell $related_clock $i] -min -rise  [constraints get cell $input_early_rise_slew_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock  [constraints get cell $related_clock $i] -min -fall  [constraints get cell $input_early_fall_slew_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock  [constraints get cell $related_clock $i] -max -rise  [constraints get cell $input_late_rise_slew_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock  [constraints get cell $related_clock $i] -max -fall  [constraints get cell $input_late_fall_slew_start $i] \[get_ports $inp_ports\]"


        set i [expr {$i+1}]
}
close $tmp2_file

#------------------------------------------------------------------------------##
#-------------------create output delay and load constraints--------------------##
#------------------------------------------------------------------------------##

set output_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  early_rise_delay] 0 ] 0]
set output_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  early_fall_delay] 0 ] 0]
set output_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  late_rise_delay] 0 ] 0]
set output_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  late_fall_delay] 0 ] 0]
set output_load_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  load] 0 ] 0]
set related_clock [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  clocks] 0 ] 0]
set bussed_status [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  bussed] 0 ] 0]

set i [expr {$output_ports_start+1}]
set end_of_ports [expr {$number_of_rows}]
puts "\nInfo-SDC: Working on IO constraints....."
puts "\nInfo-SDC: Categorizing output ports as bits and bussed"

while { $i < $end_of_ports } {
#--------------------------optional script----differentiating input ports as bussed and bits------#
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open ./temp/1 w]
foreach f $netlist {
        set fd [open $f]
        while {[gets $fd line] != -1} {
                set pattern1 " [constraints get cell 0 $i];"
                if {[regexp -all -- $pattern1 $line]} {
                        set pattern2 [lindex [split $line ";"] 0]
                        if {[regexp -all {output} [lindex [split $pattern2 "\S+"] 0]]} {
                        set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
                        puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
                        }
                }
        }
close $fd
}
close $tmp_file
set tmp_file [open ./temp/1 r]
set tmp2_file [open ./temp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open ./temp/2 r]
set count [split [llength [read $tmp2_file]]]

if {$count > 2} {
        set op_ports [concat [constraints get cell 0 $i]*]
} else {
        set op_ports [constraints get cell 0 $i]
}
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $related_clock $i] -min -rise  [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $related_clock $i] -min -fall  [constraints get cell $output_early_fall_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $related_clock $i] -max -rise  [constraints get cell $output_late_rise_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $related_clock $i] -max -fall  [constraints get cell $output_late_fall_delay_start $i] \[get_ports $op_ports\]"
	puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i] \[get_ports $op_ports\]"
	set i [expr {$i+1}]
}
close $tmp2_file
close $sdc_file

puts "\nInfo: SDC created. Please use constraints in path  $OutputDirectory/$DesignName.sdc"


#-----------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------Hierarchy---------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------#

puts "\nInfo: Creating hierarchy check file for yosys tool"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.hier.ys"
set fileID [open $OutputDirectory/$filename "w"]
puts -nonewline $fileID $data

set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
	set data $f
	puts -nonewline $fileID "\nread_verilog $f"
}
puts -nonewline $fileID "\nhierarchy -check"
close $fileID

puts "\nChecking heirarchy..."
set my_err [catch {exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]
puts "\nerr flag is $my_err"

if {$my_err} {
	set filename "$OutputDirectory/$DesignName.hierarchy_check.log"
	set pattern {referenced in module}
	set count 0
	set fid [open $filename r]
	while {[gets $fid line] != -1} {
		incr count [regexp -all -- $pattern $line]
		if {[regexp -all -- $pattern $line]} {
			puts "\nError: module [lindex $line 2] is not part of design $DesignName. Pleae correct RTL in path '$NetlistDirectory'"
			puts "\nInfo: Hierarchy check FAIL"
		}
	}
	close $fid
} else {
	puts "\nInfo: Hierarchy check pass"
}
puts "\nIndo: Please find hierarchy check details in [file normalize $OutputDirectory/$DesignName.heirarchy_check.log] for more help"

#------------------------------------------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------- Main Synthesis Script---------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------------------------------------#


puts "\nInfo: Creating main synthesis for Yosys.."
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.ys"
set fileID [open $OutputDirectory/$filename "w"]
puts -nonewline $fileID $data

set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
	set data $f
	puts -nonewline $fileID "\nread_verilog $f"
}

puts -nonewline $fileID "\nhierarchy -top $DesignName"
puts -nonewline $fileID "\nsynth -top $DesignName"
puts -nonewline $fileID "\nsplitnets -ports"
puts -nonewline $fileID "\nsplitnets -format ___"
puts -nonewline $fileID "\ndfflibmap -liberty ${LateLibraryPath}"
puts -nonewline $fileID "\nopt"
puts -nonewline $fileID "\nabc -liberty ${LateLibraryPath}"
puts -nonewline $fileID "\nflatten"
puts -nonewline $fileID "\nclean -purge\niopadmap -outpad BUFX2 A:Y -bits\nopt\nclean"
puts -nonewline $fileID "\nwrite_verilog $OutputDirectory/$DesignName.synth.v"
close $fileID
puts "\nInfo: Synthesis script created and can be accessed from the path $OutputDirectory/$DesignName.ys"


#-----------------------------------------------------------------------------------------------------#
#--------------------------Run synthesis script on Yosys----------------------------------------------#
#-----------------------------------------------------------------------------------------------------#

if {[catch { exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg] } {
	puts "\nError:Synthesis failed due to errors. Refer to log $OutputDirectory/$DesignName.synthesis.log for errors"
	exit
} else {
	puts "\nInfo: Synthesis finished successfully"
}
puts "\nInfo: Please refer to log $OutputDirectory/$DesignName.synthesis.log"


#-----------------------------------------------------------------------------------------------------------#
#-------------------------Edit synth.v to be used by Opentimer----------------------------------------------#
#-----------------------------------------------------------------------------------------------------------#

set fileID [open temp/1 "w"]
puts -nonewline $fileID [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
close $fileID

set output [open $OutputDirectory/$DesignName.final.synth.v "w"]

set filename "temp/1"
set fid [open $filename r]
	while {[gets $fid line] != -1} {
		puts -nonewline $output [string map {"\\" ""} $line]
		puts -nonewline $output "\n"
	}
close $fid
close $output

puts "\nInfo: PLease find the synthesized netlist for $DesignName at below path. You can use this netlist for STA"
puts "\n$OutputDirectory/$DesignName.final.synth.v"



#-----------------------------------------------------------------------------------------------------------#
#-------------------------------------STA USING OPENTIMER---------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------#

puts "\nInfo: Timing Analysis Started..."
puts "\nInfo: Initializing number of threads, libraries, sdc, verilog netlist path..."
source /home/vsduser/vsdsynth/procs/reopenStdout.proc
source /home/vsduser/vsdsynth/procs/set_num_threads.proc

reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 4

source /home/vsduser/vsdsynth/procs/read_lib.proc
read_lib -early /home/vsduser/vsdsynth/osu018_stdcells.lib

read_lib -late /home/vsduser/vsdsynth/osu018_stdcells.lib


source /home/vsduser/vsdsynth/procs/read_verilog.proc
read_verilog $OutputDirectory/$DesignName.final.synth.v

source /home/vsduser/vsdsynth/procs/read_sdc.proc
read_sdc $OutputDirectory/$DesignName.sdc
reopenStdout /dev/tty

if {$enable_prelayout_timing == 1} {
	puts "\nInfo: enable prelayout timing is $enable_prelayout_timing. Enabling zero-wire load parasitics"
	set spef_file [open $OutputDirectory/$DesignName.spef w]

puts $spef_file "*SPEF \"IEEE 1481-1998\" "

puts $spef_file "*DESIGN \"$DesignName\" "

puts $spef_file "*DATE \"Tue June 20 19:05:00 2023\" "

puts $spef_file "*VENDOR \"TAU 2015 Contest\" "

puts $spef_file "*PROGRAM \"Benchmark Parasitic Generator\" "

puts $spef_file "*VERSION \"0.6\" "

puts $spef_file "*DESIGN FLOW \"NETLIST TYPE VERILOG\" "

puts $spef_file "*DIVIDER / "

puts $spef_file "*DELIMITER : "
puts $spef_file "*BUS_DELIMITER [ ] "

puts $spef_file "*T_UNIT 1 PS "

puts $spef_file "*C_UNIT 1 FF "

puts $spef_file "*R_UNIT 1 KOHM "

puts $spef_file "*L_UNIT 1 UH "

}

close $spef_file


set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer "
puts $conf_file "report_timer "
puts $conf_file "report_wns "
puts $conf_file "report_worst_paths -numPaths 10000 "
close $conf_file


set tcl_precision 3
set time_elapsed_in_us [time {exec /home/vsduser/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results} 1]
puts "time_elapsed_in_us is $time_elapsed_in_us"
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/100000}]sec"
puts "time_elapsed_in_sec is $time_elapsed_in_sec"
puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"

puts "\nInfo: Refer to $OutputDirectory/$DesignName.results for warnings and errors"

#set tcl_precision 3 

puts "tcl precision is $tcl_precision"


#-----find worst output violation---#

set worst_RAT_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
puts "report_file is $OutputDirectory/$DesignName.results"
set pattern {RAT}
puts "pattern is $pattern"
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
	puts "pattern \"$pattern\" found in \"$line\""
	puts "old worst RAT slack is $worst_RAT_slack"
	set worst_RAT_slack "[expr {[lindex $line 3]/1880}]ns"
	puts "partl is [lindex $line 3]"
	puts "new worst_RAT_slack is $worst_RAT_slack"
	puts "breaking"
	break
	} else {
	continue
	}
}
close $report_file


#--------------------find number of output violation-------------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count ©
puts "inital count is $count"
puts "being count"
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}

set Number_output_violations $count
puts "Number_output_violations is $Number_output_violations"
close $report_file


#------------- find worst setup violation--------------- #
set worst_negative_setup_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Setup}
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
	set worst_negative_setup_slack "[expr {[lindex $line 3]/1000}]ns"
	break
	} else {
	continue
	}

}

close $report_file

#-------------------find number of setup violation-------------- #
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line) != -1} {
	incr count [regexp -all -- $pattern $line)
}

set Number_of_setup_violations $count
close $report_file


#----- find worst hold violation------ #
set worst negative hold slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Hold}
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
	set worst_negative_hold_slack "[expr {[lindex $line 3]/1000}]ns"
	break
	} else {
	continue
	}
}

close $report_file

#-------------------find number of hold violation-------------- #
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line) != -1} {
        incr count [regexp -all -- $pattern $line)
}

set Number_of_hold_violations $count
close $report_file


#----------------- find number of instance---------- #
set pattern {Num of gates}
set report_file [open $OutputDirectory/$DesignName.results r]
while {[gets $report_file line] != -1} {
	if {[regexp -all -- $pattern $line]} {
	set Instance_count [lindex [join $line " "] 4 ]
	puts "pattern \"$pattern\" found at line \“$line\""
	break
	} else {
	continue
	}
}
close $report_file

puts "DesignName is \{$DesignName\}"
puts "time_elapsed is \{$time_elapsed_in_sec\}"
puts "Instance_count is \{$Instance_count\}"
puts "worst_negative_setup_slack is \{$worst_negative_setup_slack\}"
puts "Number_of_setup_violations is \{$Number_of_setup_violations\}"
puts "worst_negative_hold_slack is \{$worst_negative_hold_slack\}"
puts "Number_of_hold_violations is \{$Number_of_hold_violations\}"
puts "worst_RAT_slack is \{$worst_RAT_slack\}"
puts "Number_output_violations is \{$Number_output_violations\}"


puts "\n"
puts "						****PRELAYOUT TIMING RESULTS****				"
set fomatStr {%15s%15s%15s%15s%15s%15s%15s%15s%15s}

puts [format $formatStr "-----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts [format $formatStr "Design Name" "Runtime" "Instance count" "WNS setup" "FEP Setup" "WNS Hold" "FEP Hold" "WNS RAT" "FEP RAT"]
puts [format $formatStr "-----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]

foreach design_name $DesignName runtine $time_elapsed_in_sec instance_count $Instance_count wns_Setup $worst_negative_setup_slack fep_setup $Number_of_setup_violations wns_hold $worst_negative_hold_slack fep_hold $Number_of_hold_violations wns_rat $worst_RAT_slack fep_rat $Number_output_violations {
	puts [format $formatStr $design_name $runtime $instance_count $wns_setup $fep_setup $wns_hold $fep_hold $wns_rat $fep_rat]
}

puts [format $formatStr "-----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts "\n"

return
