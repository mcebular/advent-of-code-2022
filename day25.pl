use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

use List::Util 'sum';


open(my $file, "<", "input/day25.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;

sub decimal2quintimal {
    my $decimal = shift @_;
    my $quintimal = '';
    while ($decimal > 0) {
        my $rem = $decimal % 5;
        $decimal = sprintf "%d", $decimal / 5;
        $quintimal .= $rem;
    }
    $quintimal = reverse $quintimal;
    return $quintimal;
}

assertEq decimal2quintimal("1"), "1";
assertEq decimal2quintimal("2"), "2";
assertEq decimal2quintimal("3"), "3";
assertEq decimal2quintimal("4"), "4";
assertEq decimal2quintimal("5"), "10";
assertEq decimal2quintimal("6"), "11";
assertEq decimal2quintimal("7"), "12";
assertEq decimal2quintimal("8"), "13";
assertEq decimal2quintimal("9"), "14";
assertEq decimal2quintimal("10"), "20";
assertEq decimal2quintimal("15"), "30";
assertEq decimal2quintimal("20"), "40";
assertEq decimal2quintimal("2022"), "31042";


sub quintimal2snafu {
    my @quintimal = split //, shift @_;
    my $snafu = '';

    my $carry = '';
    while (scalar @quintimal > 0) {
        my $c = pop @quintimal;

        if ($carry eq '1') {
            if ($c eq '=') {
                $c = '-';
            } elsif ($c eq '-') {
                $c = '0';
            } elsif ($c eq '0') {
                $c = '1';
            } elsif ($c eq '1') {
                $c = '2';
            } elsif ($c eq '2') {
                $c = '3';
            } elsif ($c eq '3') {
                $c = '4';
            } elsif ($c eq '4') {
                $c = '5';
            } else {
                die;
            }
        }

        if ($c eq '0' || $c eq '1' || $c eq '2') {
            $snafu .= $c;
            $carry = '';
        } elsif ($c eq '3') {
            $snafu .= '=';
            $carry = '1';
        } elsif ($c eq '4') {
            $snafu .= '-';
            $carry = '1';
        } elsif ($c eq '5') {
            $snafu .= '0';
            $carry = '1';
        } else {
            die;
        }
    }
    $snafu .= $carry;
    $snafu = reverse $snafu;
    return $snafu;
}

sub decimal2snafu {
    my $decimal = shift @_;
    return quintimal2snafu decimal2quintimal $decimal;
}

assertEq decimal2snafu("1"),         "1";
assertEq decimal2snafu("2"),         "2";
assertEq decimal2snafu("3"),         "1=";
assertEq decimal2snafu("4"),         "1-";
assertEq decimal2snafu("5"),         "10";
assertEq decimal2snafu("6"),         "11";
assertEq decimal2snafu("7"),         "12";
assertEq decimal2snafu("8"),         "2=";
assertEq decimal2snafu("9"),         "2-";
assertEq decimal2snafu("10"),        "20";
assertEq decimal2snafu("15"),        "1=0";
assertEq decimal2snafu("20"),        "1-0";
assertEq decimal2snafu("2022"),      "1=11-2";
assertEq decimal2snafu("12345"),     "1-0---0";
assertEq decimal2snafu("314159265"), "1121-1110-1=0";


sub snafu2decimal {
    my $snafu = shift @_;
    my @digits = split //, $snafu;
    my $decimal = 0;
    my $pow = 0;
    while (scalar @digits > 0) {
        my $digit = pop @digits;
        if ($digit eq '-') {
            $digit = -1;
        } elsif ($digit eq '=') {
            $digit = -2;
        }

        $decimal += (5 ** $pow) * $digit;
        $pow++;
    }
    return $decimal;
}

assertEq snafu2decimal("1"),             "1";
assertEq snafu2decimal("2"),             "2";
assertEq snafu2decimal("1="),            "3";
assertEq snafu2decimal("1-"),            "4";
assertEq snafu2decimal("10"),            "5";
assertEq snafu2decimal("11"),            "6";
assertEq snafu2decimal("12"),            "7";
assertEq snafu2decimal("2="),            "8";
assertEq snafu2decimal("2-"),            "9";
assertEq snafu2decimal("20"),            "10";
assertEq snafu2decimal("1=0"),           "15";
assertEq snafu2decimal("1-0"),           "20";
assertEq snafu2decimal("1=11-2"),        "2022";
assertEq snafu2decimal("1-0---0"),       "12345";
assertEq snafu2decimal("1121-1110-1=0"), "314159265";


# Part 1
say decimal2snafu sum map { snafu2decimal $_ } @lines;
