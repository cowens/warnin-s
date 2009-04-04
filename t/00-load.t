#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'warnin::s' );
}

diag( "Testing warnin::s $warnin::s::VERSION, Perl $], $^X" );
