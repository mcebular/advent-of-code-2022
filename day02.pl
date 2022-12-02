use strict;
use warnings;

use feature 'say';

open(my $file, "<", "input/day02.txt") or die "Can't open input file";

my $possibles = {
    'A' => {
        'X' => {
            1 => 1 + 3,
            2 => 3 + 0
        },
        'Y' => {
            1 => 2 + 6,
            2 => 1 + 3
        },
        'Z' => {
            1 => 3 + 0,
            2 => 2 + 6
        },
    },
    'B' => {
        'X' => {
            1 => 1 + 0,
            2 => 1 + 0
        },
        'Y' => {
            1 => 2 + 3,
            2 => 2 + 3
        },
        'Z' => {
            1 => 3 + 6,
            2 => 3 + 6
        },
        },
    'C' => {
        'X' => {
            1 => 1 + 6,
            2 => 2 + 0
        },
        'Y' => {
            1 => 2 + 0,
            2 => 3 + 3
        },
        'Z' => {
            1 => 3 + 3,
            2 => 1 + 6
        },
    }
};

sub roundScore {
    my ($round, $pt) = @_;
    my $other = substr($round, 0, 1);
    my $me = substr($round, 2, 1);
    return $possibles->{$other}{$me}{$pt};
}

sub assert {
    my ($actual, $expected) = @_;
    if ($actual != $expected) {
        die "assertion failed: actual value '$actual', expected '$expected'";
    }
}

assert roundScore("A Y", 1) + roundScore("B X", 1) + roundScore("C Z", 1), 15;
assert roundScore("A Y", 2) + roundScore("B X", 2) + roundScore("C Z", 2), 12;

my $score1 = 0;
my $score2 = 0;
while (my $line = <$file>) {
    $score1 += roundScore($line, 1);
    $score2 += roundScore($line, 2);
}

close $file;

# Part 1
say $score1;

# Part 2
say $score2;
