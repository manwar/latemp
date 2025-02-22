#!/usr/bin/env perl

use strict;
use warnings;
use autodie;

sub do_system
{
    my ($args) = @_;

    my $cmd = $args->{cmd};
    print "Running [@$cmd]";
    if ( system(@$cmd) )
    {
        die "Running [@$cmd] failed!";
    }
}

my $IS_WIN = ( $^O eq "MSWin32" );
my $SEP    = $IS_WIN ? "\\" : '/';
my $MAKE   = $IS_WIN ? 'gmake' : 'make';

my $cmake_gen;
if ($IS_WIN)
{
    $cmake_gen = 'MSYS Makefiles';
}
my $cmd = shift @ARGV;

# do_system({cmd => ["cd black-hole-solitaire/ && mkdir B && cd B && ../c-solver/Tatzer && make && $^X ../c-solver/run-tests.pl"]});

# do_system({cmd => ["cd black-hole-solitaire/Games-Solitaire-BlackHole-Solver/ && dzil test --all"]});

my @dzil_dirs = (
    'Perl/modules/HTML-Latemp-GenMakeHelpers',
    'Perl/modules/HTML-Latemp-NavLinks-GenHtml',
    'Perl/modules/HTML-Latemp-News',
    'Perl/modules/Task-Latemp',
    'Perl/modules/Template-Preprocessor-TTML',
);

# my $CPAN = sprintf('%scpanm', ($IS_WIN ? '' : 'sudo '));
my $CPAN = 'cpanm';
if ( $cmd eq 'install_deps' )
{
    foreach my $d (@dzil_dirs)
    {
        do_system(
            {
                cmd => [
"cd $d && (dzil authordeps --missing | $CPAN) && (dzil listdeps --author --missing | $CPAN)"
                ]
            }
        );
    }
}
elsif ( $cmd eq 'test' )
{
    foreach my $d (@dzil_dirs)
    {
        do_system( { cmd => ["cd $d && (dzil smoke --release --author)"] } );
    }
    do_system(
        {
            cmd => [
                      "cd installer/ && mkdir B && cd B && $^X ..${SEP}Tatzer "
                    . ( defined($cmake_gen) ? qq#--gen="$cmake_gen"# : "" )
                    . " .. && $MAKE"
            ]
        }
    );
}
else
{
    die "Unknown command '$cmd'!";
}
