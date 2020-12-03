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
    say "day 1";
    find_tuple_challenge( 2, @expense_report );
    find_tuple_challenge( 3, @expense_report );
    say "day 2";
    my @raw_entries = get_input(2);
    my $valid_count =
      grep { validate_password($_) }
      map  { parse_password_entry($_) } @raw_entries;
    say "there are $valid_count valid passwords";

}

sub validate_password($entry) {
    my $letters_used = () =
      $entry->{password} =~ m/\Q$entry->{policy}{letter}\E/gi;
    return $letters_used >= $entry->{policy}{min}
      && $letters_used <= $entry->{policy}{max};
}

sub parse_password_entry($entry) {
    my ( $policy, $password ) = split( /\:\s+/, $entry,  2 );
    my ( $counts, $letter )   = split( /\s+/,   $policy, 2 );
    my ( $min,    $max )      = split( /-/,     $counts );

    return {
        password => $password,
        policy   => {
            letter => $letter,
            min    => $min,
            max    => $max,
          }

    };
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

