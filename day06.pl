use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

open(my $file, "<", "input/day06.txt") or die "Can't open input file";

my @lines = ();

while ( my $line = <$file> ) {
    chomp($line);
    push(@lines, $line);
}

close $file;

sub is_marker {
    my ($marker) = @_;
    for (my $p = 0; $p < length($marker); $p++) {
        for (my $q = $p + 1; $q < length($marker); $q++) {
            my $c1 = substr($marker, $p, 1);
            my $c2 = substr($marker, $q, 1);
            if ($c1 eq $c2) {
                return 0;
            }
        }
    }
    return 1;
}

sub find_marker {
    my ($buffer, $markerSize) = @_;
    for (my $i = 0; $i < length($buffer) - 3; $i++) {
        my $marker = substr($buffer, $i, $markerSize);
        if (is_marker $marker) {
            # say "Marker '$marker' is at index $i";
            return $i + $markerSize;
        }
    }
    return -1;
}

assert 7, find_marker("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 4);
assert 5, find_marker("bvwbjplbgvbhsrlpgdmjqwftvncz", 4);
assert 6, find_marker("nppdvjthqldpwncqszvftbrmjlhg", 4);
assert 10, find_marker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 4);
assert 11, find_marker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 4);
assert 19, find_marker("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 14);
assert 23, find_marker("bvwbjplbgvbhsrlpgdmjqwftvncz", 14);
assert 23, find_marker("nppdvjthqldpwncqszvftbrmjlhg", 14);
assert 29, find_marker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 14);
assert 26, find_marker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 14);

# Part 1
say find_marker($lines[0], 4);

# Part 2
say find_marker($lines[0], 14);
