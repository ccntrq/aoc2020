#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use feature qw(say signatures);

no warnings 'experimental::signatures';

use List::Util qw(sum0 product first);

use FindBin;
use lib File::Spec->catfile( $FindBin::RealBin, 'lib' );

use Combinations qw(combinations);

{
    my @expense_report = get_input(1);
    find_tuple_challenge( 2, @expense_report );
    find_tuple_challenge( 3, @expense_report );
}

sub find_tuple_challenge ( $count, @expenses ) {
    my $target = find_target_values( $count, @expenses );
    say target_value_output($target);
}

sub target_value_output($target_values) {
    my $out =
        join( ' + ', @$target_values )
      . ' = 2020 their product is '
      . product(@$target_values);
    return $out;
}

sub find_target_values ( $count, @expenses ) {
    my $target_sum = 2020;
    first { sum0(@$_) == $target_sum } combinations( $count, @expenses );
}

sub get_input($day) {
    open( my $fh, '<',
        File::Spec->catfile( $FindBin::RealBin, qw(input day), $day ) );
    my @out = <$fh>;
    chomp(@out);
    close $fh;
    return @out;
}

