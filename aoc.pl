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
    my @pw_file_entries = map { parse_password_entry($_) } @raw_entries;
    my $valid_count_sled_shop_rules =
      grep { validate_password_sled_shop_rules($_) } @pw_file_entries;
    say
"there are $valid_count_sled_shop_rules valid password after the sled shop policy.";
    my $valid_count_toboggan_corporate_policy =
      grep { validate_password_toboggan_corporate_policy($_) } @pw_file_entries;
    say
"there are $valid_count_toboggan_corporate_policy valid password after the toboggan corporate policy.";

    say "day 3";

    my @raw_tree_map = get_input(3);
    my @tree_map     = map {
        [ map { $_ eq '#' ? 1 : 0 } split( //, $_ ) ]
    } @raw_tree_map;

    my $trees_encountered = traverse_tree_map( 0, @tree_map );
    say "encountered $trees_encountered trees";
}

sub traverse_tree_map ( $pos, @map ) {
    no warnings 'recursion';
    return 0 if !@map;
    my ( $cur, @rest ) = @map;
    return $cur->[$pos] + traverse_tree_map( ( $pos + 3 ) % @$cur, @rest );
}

sub validate_password_toboggan_corporate_policy($entry) {
    my $count = grep {
        substr( $entry->{password}, $_ - 1, 1 ) eq $entry->{policy}{letter}
    } ( @{ $entry->{policy} }{qw(min max)} );
    return $count == 1;
}

sub validate_password_sled_shop_rules($entry) {
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

