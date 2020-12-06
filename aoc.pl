#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use feature qw(say signatures);

no warnings 'experimental::signatures';

use List::Util qw(any first max sum0 product);

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

    my @slopes = map { { right => $_->[0], down => $_->[1] } }
      ( [ 3, 1 ], [ 1, 1 ], [ 5, 1 ], [ 7, 1 ], [ 1, 2 ] );

    my $trees_encountered = traverse_tree_map( $slopes[0], 0, @tree_map );
    say "encountered $trees_encountered trees with the first slope";

    my $all_slopes_multiplied =
      product( map { traverse_tree_map( $_, 0, @tree_map ) } @slopes );

    say "the product of all trees on all slopes is $all_slopes_multiplied";

    say "day 4";
    my @raw_passport_entries = get_input( 4, "\n\n" );
    my $valid_count =
      grep { $_ } map { scan_passport($_) } @raw_passport_entries;
    say "there are $valid_count passports in the batch run!";

    say "day 5";
    my @boarding_passes = get_input(5);
    my @seat_postions   = map { process_boarding_pass($_) } @boarding_passes;
    my @seat_ids        = map { calculate_seat_id($_) } @seat_postions;
    my $highest_seat_id = max(@seat_ids);
    say "Highest Seat ID: " . $highest_seat_id;
    say "My Seat ID: " . find_missing_seat_id( \@seat_postions, \@seat_ids );

    say "day 6";
    my @declaration_form_answers = map {
        my @lines = split( /\n/, $_ );
        my %answers;
        map { $answers{$_}++ } split( '', join( '', @lines ) );

        {
            group_size => scalar @lines,
            answers    => \%answers,
        }
    } get_input( 6, "\n\n" );

    my $total_answers =
      sum0( map { scalar keys %{ $_->{answers} } } @declaration_form_answers );
    say "Total Answers: $total_answers";

    my $all_answered = sum0(
        map {
            my %group = %$_;
            scalar grep { $group{answers}{$_} == $group{group_size} }
              keys %{ $group{answers} };
        } @declaration_form_answers
    );
    say "All Answered: $all_answered";
}

sub find_missing_seat_id ( $seat_positions, $seat_ids ) {
    my %seat_ids = map { $_ => 1 } @{$seat_ids};

    my %position_lookup;
    for my $pos ( @{$seat_positions} ) {
        $position_lookup{ $pos->[0] }{ $pos->[1] } = 1;
    }

    for my $row ( 1 .. 126 ) {
        for my $seat ( 0 .. 7 ) {
            next if $position_lookup{$row}{$seat};
            my $id = calculate_seat_id( [ $row, $seat ] );
            next if !( $seat_ids{ $id + 1 } && $seat_ids{ $id - 1 } );
            return $id;
        }
    }

}

sub calculate_seat_id($pass) {
    return $pass->[0] * 8 + $pass->[1];
}

sub process_boarding_pass($pass) {
    my @partitions = split( '', $pass );
    my @row_ops    = @partitions[ 0 .. 6 ];
    my @seat_ops   = @partitions[ 7 .. 9 ];

    my $row  = ( partition( \@row_ops,  0 .. 127 ) )[0];
    my $seat = ( partition( \@seat_ops, 0 .. 7 ) )[0];

    return [ $row, $seat ];
}

sub partition ( $ops, @list ) {
    for my $op (@$ops) {
        my $mid = @list / 2;
        if ( $op eq 'F' || $op eq 'L' ) {
            @list = @list[ 0 ... ( $mid - 1 ) ];
        }
        if ( $op eq 'B' || $op eq 'R' ) {
            @list = @list[ $mid .. $#list ];
        }
    }

    return @list;
}

sub scan_passport($entry) {
    my @parts = split( /\s+/, $entry );
    my @passport = grep { $_ } map {
        my ( $key, $value ) = split( /\:/, $_, 2 );
        if ( validate_passport_rules( $key, $value ) ) { $key => $value }
    } @parts;
    my %passport = @passport;

    return
      unless keys %passport == 8
      || ( keys %passport == 7 && !exists $passport{cid} );

    return \%passport;
}

sub between ( $val, $min, $max ) {

    $val >= $min && $val <= $max;
}

sub validate_passport_rules ( $key, $value ) {
    my %rules = (
        byr => sub($val) {
            return $val =~ /^\d{4}$/ && $val >= 1920 && $val <= 2002;
        },
        iyr => sub($val) {
            return $val =~ /^\d{4}$/ && $val >= 2010 && $val <= 2020;
        },
        eyr => sub($val) {
            return $val =~ /^\d{4}$/ && $val >= 2020 && $val <= 2030;
        },
        hgt => sub($val) {
            if ( $val =~ /^(\d+)(cm|in)$/ ) {
                my $numval = $1;
                my $unit   = $2;
                return ( $unit eq 'cm' && between( $numval, 150, 193 ) )
                  || ( $unit eq 'in' && between( $numval, 59, 76 ) );
            }
            return;
        },
        hcl => sub($val) {
            return $val =~ m/^#[0-9a-f]{6}$/;
        },
        ecl => sub ($val) {
            return any { $val eq $_ } qw(amb blu brn gry grn hzl oth);
        },
        pid => sub ($val) {
            return $val =~ m/^\d{9}$/;
        },
        cid => sub($val) {
            return 1;
        },
    );

    my $valid = $rules{$key}->($value);
    return $valid;
}

sub traverse_tree_map ( $slope, $pos, @map ) {
    no warnings 'recursion';
    return 0 if !@map;
    my $cur  = $map[0];
    my @rest = @map[ $slope->{down} ... $#map ];

    return $cur->[$pos] +
      traverse_tree_map( $slope, ( $pos + $slope->{right} ) % @$cur, @rest );
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

sub get_input ( $day, $splitchar = "\n" ) {
    local $/ = undef;
    open( my $fh, '<',
        File::Spec->catfile( $FindBin::RealBin, qw(input day), $day ) );
    my $out = <$fh>;
    my @out = split( $splitchar, $out );
    close $fh;
    return @out;
}

