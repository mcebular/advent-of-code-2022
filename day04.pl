use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

sub doRangesOverlapFull {
    my ($r1s, $r1e, $r2s, $r2e) = @_;
    return $r1s >= $r2s && $r1e <= $r2e || $r2s >= $r1s && $r2e <= $r1e;
}

sub doRangesOverlap {
    my ($r1s, $r1e, $r2s, $r2e) = @_;
    return $r1s <= $r2s && $r1e >= $r2s || $r2s <= $r1s && $r2e >= $r1s;
}

assertTrue doRangesOverlapFull(3, 6, 4, 5);
assertTrue doRangesOverlapFull(4, 5, 3, 6);
assertTrue doRangesOverlapFull(1, 10, 1, 10);
assertTrue !doRangesOverlapFull(1, 5, 4, 6);
assertTrue !doRangesOverlapFull(4, 6, 1, 5);

assertTrue doRangesOverlap(1, 5, 4, 6);
assertTrue doRangesOverlap(4, 6, 1, 5);
assertTrue doRangesOverlap(1, 10, 1, 10);
assertTrue !doRangesOverlap(1, 5, 6, 7);
assertTrue !doRangesOverlap(6, 7, 1, 5);

open(my $file, "<", "input/day04.txt") or die "Can't open input file";

my @pairs = ();

while (my $line = <$file>) {
    chomp($line);
    push(@pairs, $line);
}

close $file;

my $fullOverlaps = 0;
my $overlaps = 0;

foreach my $pair (@pairs) {
    $pair =~ /(\d+)-(\d+),(\d+)-(\d+)/;
    $fullOverlaps += doRangesOverlapFull($1, $2, $3, $4);
    $overlaps += doRangesOverlap($1, $2, $3, $4);
}

# Part 1
say $fullOverlaps;

# Part 2
say $overlaps;
