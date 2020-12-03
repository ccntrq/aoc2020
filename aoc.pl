#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use feature qw(say signatures);

no warnings 'experimental::signatures';

use List::Util qw(sum0 product first);

use FindBin;
use lib File::Spec->catfile( $FindBin::RealBin, 'lib' );

use Combinations qw(unique_pairs);

{
    my $expense_report = get_input(1);
    my @expenses       = split( "\n", $expense_report );
    my $target_pair    = first { sum0(@$_) == 2020 } unique_pairs(@expenses);
    say sprintf( "%d and %d sum up to 2020 their product is %d",
        @$target_pair, product(@$target_pair) );
}

sub get_input($day) {
    local $/ = undef;
    open(
        my $fh,
        '<',
        File::Spec->catfile( $FindBin::RealBin, qw(input day), $day, 'input' )
    );
    my $out = <$fh>;
    close $fh;
    return $out;
}

