use strict;
use warnings;

use feature 'say';

use String::Util 'trim';

use lib './';
use assertions;

open(my $file, "<", "input/day05.txt") or die "Can't open input file";

sub sayArray {
    my (@array) = @_;
    say join(';', @array)
}

my @stateLines = ();
my @movesLines = ();

my $hadEmptyLine = 0;
while (my $line = <$file>) {
    chomp($line);

    if (length($line) == 0) {
        $hadEmptyLine = 1;
        next;
    }

    if ($hadEmptyLine) {
        push(@movesLines, $line);
    } else {
        push(@stateLines, $line);
    }
}

close $file;

my @stackIndices = split(/\s*/, $stateLines[-1]);
my $stacksCount = $stackIndices[-1];

sub initStacks {
    my @stacks = ();

    my $row = 0;
    foreach my $stateLine (reverse(@stateLines[0..$#stateLines-1])) {
        # say $stateLine;
        for (my $si = 0; $si <= $stacksCount; $si++) {
            my @tmp = split(//, $stateLine);
            my $idx = 1 + 4 * $si;
            if ($idx <= $#tmp) {
                my $c = $tmp[1 + 4 * $si];
                if (length(trim($c)) > 0) {
                    # say $c;
                    $stacks[$si] .= $c;
                }
            }
        }
        $row++;
    }
    # sayArray @stacks;
    return @stacks;
}

sub rearrangeStacks {
    my ($retainSliceOrder, @stacks) = @_;

    foreach my $move (@movesLines) {
        $move =~ /move (\d+) from (\d+) to (\d+)/;
        my ($count, $from, $to) = ($1, $2 - 1, $3 - 1);
        my $sliceToMove = substr(reverse($stacks[$from]), 0, $count);
        if ($retainSliceOrder) {
            # re-reverse back
            $sliceToMove = reverse($sliceToMove);
        }
        $stacks[$from] = substr($stacks[$from], 0, length($stacks[$from]) - $count);
        $stacks[$to] .= $sliceToMove;
        # say $move;
        # sayArray @stacks;
    }

    return @stacks;
}

sub printTopCrates {
    my (@stacks) = @_;
    foreach my $stack (@stacks) {
        print substr($stack, -1);
    }
    say "";
}

# Part 1
printTopCrates rearrangeStacks 0, initStacks;

# Part 2
printTopCrates rearrangeStacks 1, initStacks;
