#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'PV' ) || print "Bail out!\n";
}

diag( "Testing PV $PV::VERSION, Perl $], $^X" );
