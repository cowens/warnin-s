use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'warnin::s',
    AUTHOR              => 'Chas. J. Owens IV <chas.owens@gmail.com>',
    VERSION_FROM        => 'lib/warnin/s.pm',
    ABSTRACT            => "warnin's - like warnings, but with more casual language",
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::Pod::Coverage' => 0,
        'Test::More'          => 0,
        'warnings'            => 0,
        'strict'              => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'warnin-s-*' },
);
