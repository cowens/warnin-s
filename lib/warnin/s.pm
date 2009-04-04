package warnin::s;

use warnings;
use strict;

=head1 NAME

warnin's - like warnings, but with more casual language

=head1 VERSION

Version 0.0.4

=cut

our $VERSION = '0.0.4';


=head1 SYNOPSIS

  use strict;
  use warnin's; #turn warnin's on

  my ($x, $y);

  #warnings: Use of uninitialized value in addition (+) at z.pl line 16.
  #warnin's: Yer usin' a variable that ain't got a value in addition (+) at z.pl line 16. 
  $x = $x + 4;

  no warnin's; #turn warnin's off

  $y = $y + 1; #no warning

  use warnin's; #turn warnin's back on

  #warnings: Argument "" isn't numeric in numeric eq (==) at z.pl line 116.
  #warnin's: Suffering succatash! Ya used da strin' "" in numeric eq (==) at z.pl line 116.
  if ("" == 0) {
     $y++
  }

=head1 DESCRIPTION

This pragma works just like the warnings pragma, but replaces the 
normal warnings with "humorous" warnin's.  Currently the following 
warnings have been replaced:

=head2 C<Use of uninitialized value>

=over

=item C<Yer usin' a variable that ain't got a value>

=back

=head2 C<Argument "%s" isn't numeric>

=over

=item C< Suffering succatash! Ya used da strin' "%s">

=item C<Even I know that "%s" ain't a number>

=back

=head2 C<Bareword found in conditional>

=over

=item C<Might wanna put your clothes on. Maybe.>

=back

=head2 C<Deep recursion on subroutine "%s">

=over

=item C<Whoa there "%s"! Don't be running aroun' like chickin with its head cut off.>

=item C<Man, I'm gettin' a headache in subroutine "%s">

=back

=head2 C<Unquoted string "%s" may clash with future reserved word>

=over

=item C<I got dibs on %s. Pick yer own name>

=back

=head2 C<Bareword "%s" refers to nonexistent package>

=over

=item C<I got no idear what this "%s" sposta be>

=back

=head2 C<\1 better written as $1>

=over

=item C<do it the Perl way, son: $1, not \1>

=back

=head2 C<close() on unopened filehandle %s>

=over

=item C<Yer tryna close() %s what ain't been opened yet>

=back

=head2 C<Warning: something's wrong>

=over

=item C<Warning: WHAT the HECK>

=item C<Warning: somethin' ain't right>

=back

=head1 AUTHOR

Chas. J. Owens IV, C<< <chas.owens at gmail.com> >>

=head1 BUGS

Any code that parses warning mesages will likely fail.

It overrides the __WARN__ signal handler, so any code that 
also overrides it will stomp warnin's and vice versa

There are probably problems with how the messages are being changed

It is probably very slow.

saying C<no warnin's;> and then C<use warnings;> doesn't turn off
warnin's (need to unhook the handler in unimport I guess).

=head1 ACKNOWLEDGEMENTS

James Mastros for spelling warnings incorrectly F<http://www.nntp.perl.org/group/perl.perl5.porters/2009/04/msg145454.html>.

Ronald J Kimball for pointing out the mistake.

Others on StackOverflow.com for creating warnin' messages F<http://stackoverflow.com/questions/711117/what-warnings-would-you-like-a-warnins-pragma-to-throw>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Chas. J. Owens IV, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

my %jokes = (
	'^Use of uninitialized value' => 
		"Yer usin' a variable that ain't got a value",

	q/^Argument (".*") isn't numeric/ => [
		q/Suffering succatash! Ya used da strin' $1/,
		q/Even I know that $1 ain't a number/,
	],

	q/^Bareword found in conditional/ => 
		'Might wanna put your clothes on. Maybe.',

	'^Deep recursion on subroutine (".*?")' => [
		q/Whoa there $1! Don't be running aroun' like chickin with its head cut off./,
		q/Man, I'm gettin' a headache in subroutine $1/
	],

	'Unquoted string (".*") may clash with future reserved word' =>
		'I got dibs on $1. Pick yer own name',

	'Bareword (".*") refers to nonexistent package' =>
		'I got no idear what this $1 sposta be',

	'\\\\1 better written as \$1' =>
		'do it the Perl way, son: \$1, not \\\\1',

	'close\(\) on unopened filehandle (\w+)' =>
		q/Yer tryna close() $1 what ain't been opened yet/,

	"Warning: something's wrong" => [
		"Warning: WHAT the HECK",
		"Warning: somethin' ain't right",
	],
);

#wrap the jokes in another set of double quotes to 
#get the double eval replace to work below
#FIXME: we may wind up with a # in an error message,
#this should be smarter about figuring out what 
#character it can use as a delimiter
for my $k (keys %jokes) {
	my $v = $jokes{$k};
	$jokes{$k} = ref $v ?  [ map { "qq#$_#" } @$v ] : "qq#$v#";
}

our $old     = $SIG{__WARN__};
our $handler = sub {
	my $message = join '', @_;

	for my $joke (keys %jokes) {
		next unless $message =~ /$joke/;

		my $replace = $jokes{$joke};
		$replace    = $replace->[rand @$replace] if ref $replace;
		
		$message =~ s/$joke/$replace/ee;

		last;
	}

	#if there was an old signal handler call it
	#otherwise call warn directly
	if (ref $old) {
		$old->($message);
	} else {
		warn $message;
	}
};

#FIXME: should these be goto &func?
sub import {
	our $handler;
	our $old;
	$old = $SIG{__WARN__};
	$SIG{__WARN__} = $handler;
	&warnings::import;
}

sub unimport {
	our $old;
	$SIG{__WARN__} = $old;
	&warnings::unimport;
}

1;
