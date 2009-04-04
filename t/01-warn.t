#!perl -T

use Test::More tests => 25;

#capture warnings
my $warn;
BEGIN { 
	$SIG{__WARN__} = sub {
		$warn = join '', @_;
	};
}

use strict;
use warnin's; #' fix syntax highlighting in Vim

for my $i (1 .. 6) {
	warn "";
	ok(
		(
			$warn =~ /Warning: WHAT the HECK/ or
			$warn =~ /Warning: somethin' ain't right/
		),
		"Warning: something’s wrong $i"
	);
}

for my $i (1 .. 6) {
	eval "'' == 0";
	ok(
		(
			$warn =~ /Suffering succatash! Ya used da strin' "" in numeric eq \(==\)/ or
			$warn =~ /Even I know that "" ain't a number in numeric eq \(==\)/
		),
		"non-number in numeric context $i"
	);
}

my $x; $x = $x + 4;
ok($warn =~ /Yer usin' a variable that ain't got a value/, "Use of uninitialized value");

no strict 'subs';
eval "if (BUTT) { 0 }";
use strict;
ok($warn =~ /Might wanna put your clothes on. Maybe./, "Bareword found in conditional");

for my $i (1 .. 6) {
	recurse();
	ok(
		(
			$warn =~ /Whoa there "main::recurse"! Don't be running aroun' like chickin with its head cut off./ or
			$warn =~ /Man, I'm gettin' a headache in subroutine "main::recurse"/
		),
        	"Deep recursion on subroutine $1"
	);
}

no strict 'subs';
eval '$x = case';
use strict;
ok(
	$warn =~ /I got dibs on "case". Pick yer own name/,
	'Unquoted string "%s" may clash with future reserved word'
);

no strict 'subs';
eval 'FOO::';
use strict;
ok(
	$warn =~ /I got no idear what this "FOO::" sposta be/,
	'Bareword "%1" refers to nonexistent package'
);


use IO::File;
my $fh = IO::File->new;
$fh->close;
ok(
	$warn =~ /Yer tryna close\(\) GEN0 what ain't been opened yet/,
	'close() on unopened filehandle %s'
);

#FIXME: this isn't working, so I am going to fake it
my $s = "foo";
$s =~ s/(foo)/\1\1/;
warn "\\1 better written as \$1 in blah.pl at line 1\n";
ok(
	$warn =~ /do it the Perl way, son: \$1, not \\1/,
	'\1 better written as $1'
);

warn "this is a test";
ok(
	$warn =~ /this is a test/,
	'normal warn usage'
);

#FIXME: add more tests

sub recurse {
	my $n = shift || 0;
	return if $n == 1_000;
	recurse($n+1);
}

