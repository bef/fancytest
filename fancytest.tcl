## very simple and slim yet fancy test framework
## 2013-11-22 - bef@pentaphase.de

package provide fancytest 0.1
package require Tcl 8.4

## color output
package require term::ansi::code
package require term::ansi::code::ctrl

namespace eval ::fancytest {
	::term::ansi::code::ctrl::import

	variable checks {}
	variable cfg
	array set cfg {}
	
	proc c {name} {
		foreach prefix {"ctrl::sda_fg" "ctrl::sda_" "ctrl::"} {
			set cmd "$prefix$name"
			if {[info commands $cmd] ne ""} { return [$cmd] }
		}
		return ""
	}

	proc check {args} {
		variable checks
		array set check {-body {} -name {unnamed}}
		array set check $args
		lappend checks [array get check]
	}

	proc log {level msg} {puts "$msg"}
	proc log_result {result {msg ""}} {
		upvar 1 check check
		switch $result {
			passed -
			pass -
			ok {set resultstr "[c green]OK :)[c default]"}
			fail -
			failed {set resultstr "[c red]FAIL :([c default]"}
			error {set resultstr "[c magenta]ERR :|[c default]"}
			default {set resultstr "[c white]? :\{[c default]"}
		}
		log result "\[$resultstr\] $check(-name)"
		if {$msg ne ""} {
			log result "$msg"
		}
	}
	
	proc run {args} {
		variable cfg
		array set cfg $args
		
		variable checks
		foreach checkdict $checks {
			array unset check
			array set check $checkdict
			
			catch {
				namespace eval [uplevel 1 {namespace current}] $check(-body)
			} result options
			
			if {[info exists check(-code)]} {
				if {[dict get $options -code] ne $check(-code)} {
					log_result failed "got return code [dict get $options -code] but expected $check(-code)"
					continue
				}
				log_result ok
				continue
			} elseif {[dict get $options -code] != 0} {
				log_result error "$result"
				continue
			}
			
			if {[info exists check(-result)]} {
				if {$result ne $check(-result)} {
					log_result failed "result mismatch: got '$result' but expected '$check(-result)'"
					continue
				}
				log_result ok
				continue
			}
			
			log_result unknown
		}
	}
	
	namespace export log run check
}

