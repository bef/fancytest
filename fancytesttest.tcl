source fancytest.tcl

namespace eval ::fancytest::test {
	namespace import ::fancytest::*
	check -name error -body {foo}
	check -name {expected error} -body {foo} -code 1
	check -name continue -body {continue}
	check -name break -body {break}
	check -name {unexpected return} -body {return}
	check -name {return with value} -body {return "foo"} -result {foo}
	check -name fail -body {set _ "a"} -result {b}
	run
}
