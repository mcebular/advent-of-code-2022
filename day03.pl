use strict;
use warnings;

use feature 'say';

sub assert {
    my ($actual, $expected) = @_;
    if ($actual != $expected) {
        die "assertion failed: actual value '$actual', expected '$expected'";
    }
}

sub assertEq {
    my ($actual, $expected) = @_;
    if ($actual ne $expected) {
        die "assertion failed: actual value '$actual', expected '$expected'";
    }
}

sub char2val {
    my ($char) = @_;
    if (ord($char) >= 97) {
        return ord($char) - 96;
    } else {
        return ord($char) - 64 + 26;
    }
}

sub findCommonItem {
    my ($first, $second, $third) = @_;

    foreach my $c1 (split //, $first) {
        foreach my $c2 (split //, $second) {
            if ($#_ == 2) {
                foreach my $c3 (split //, $third) {
                    if ($c1 eq $c2 && $c2 eq $c3) {
                        return $c1;
                    }
                }
            } else {
                if ($c1 eq $c2) {
                    return $c1;
                }
            }
        }
    }
}

assert char2val("a"), 1;
assert char2val("z"), 26;
assert char2val("A"), 27;
assert char2val("Z"), 52;

assertEq findCommonItem("vJrwpWtwJgWr", "hcsFMMfFFhFp"), "p";
assertEq findCommonItem("aaXaaa", "bbbbXb", "cXcccc"), "X";

open(my $file, "<", "input/day03.txt") or die "Can't open input file";

my @backpacks = ();

while (my $line = <$file>) {
    chomp($line);
    push(@backpacks, $line);
}

close $file;

my $total = 0;
foreach my $bp (@backpacks) {
    my $bpLen = length($bp);
    my $left = substr($bp, 0, $bpLen / 2);
    my $right = substr($bp, $bpLen / 2, $bpLen / 2);

    assertEq "$left$right", $bp;
    assert length($left), length($right);

    $total += char2val(findCommonItem($left, $right));
}

# Part 1
say $total;
$total = 0;

for (my $i = 0; $i < $#backpacks; $i += 3) {
    my $a = $backpacks[$i];
    my $b = $backpacks[$i + 1];
    my $c = $backpacks[$i + 2];

    $total += char2val(findCommonItem($a, $b, $c));
}

# Part 2
say $total;
