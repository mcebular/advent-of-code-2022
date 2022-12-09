use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

open(my $file, "<", "input/day09.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;

sub newPos {
    my ($x, $y) = @_;
    return bless {
        x => $x,
        y => $y,
    }, "Pos";
}

sub Pos::toString {
    my ($self) = @_;
    return sprintf "[$self->{x}, $self->{y}]";
}

sub Pos::isAdjacent {
    my ($self, $other) = @_;
    return abs($self->{x} - $other->{x}) <= 1 && abs($self->{y} - $other->{y}) <= 1;
}

assertTrue newPos(5, 5)->isAdjacent(newPos(5, 5));
assertTrue newPos(5, 5)->isAdjacent(newPos(4, 5));
assertTrue newPos(5, 5)->isAdjacent(newPos(4, 4));
assertTrue newPos(5, 5)->isAdjacent(newPos(5, 4));
assertTrue newPos(5, 5)->isAdjacent(newPos(6, 4));
assertFalse newPos(5, 5)->isAdjacent(newPos(5, 3));
assertFalse newPos(5, 5)->isAdjacent(newPos(3, 5));
assertFalse newPos(5, 5)->isAdjacent(newPos(7, 4));
assertFalse newPos(5, 5)->isAdjacent(newPos(6, 3));
assertFalse newPos(2, 0)->isAdjacent(newPos(0, 0));

sub simulateRope {
    my ($ropeSize) = @_;
    my @rope = ();

    for (my $i = 0; $i < $ropeSize; $i++) {
        push(@rope, newPos(0, 0));
    }

    my %tailVisitedPos = ();
    foreach my $line (@lines) {
        $line =~ /([ULDR]) (\d+)/;
        my ($dir, $amt) = ($1, $2);

        for(my $i = 0; $i < $amt; $i++) {
            for(my $w = 0; $w < $#rope; $w++) {
                my $head = $rope[$w];
                my $tail = $rope[$w + 1];

                if ($w == 0) {
                    # if rope's first knot, move as instructed. The rest of the
                    # rope is just following preceding knot.
                    if ($dir eq 'U') {
                        $head->{y}++;
                    } elsif ($dir eq 'D') {
                        $head->{y}--;
                    } elsif ($dir eq 'L') {
                        $head->{x}--;
                    } elsif ($dir eq 'R') {
                        $head->{x}++;
                    } else {
                        die 'Invalid direction.';
                    }
                }

                if (!$tail->isAdjacent($head)) {
                    if ($head->{x} == $tail->{x}) {
                        if ($head->{y} > $tail->{y}) {
                            $tail->{y}++;
                        } else {
                            $tail->{y}--;
                        }
                    } elsif ($head->{y} == $tail->{y}) {
                        if ($head->{x} > $tail->{x}) {
                            $tail->{x}++;
                        } else {
                            $tail->{x}--;
                        }
                    } else {
                        # head/tail are diagonally not adjacent anymore
                        # move tail diagonally
                        if ($head->{x} > $tail->{x} && $head->{y} > $tail->{y}) {
                            $tail->{x}++;
                            $tail->{y}++;
                        } elsif ($head->{x} > $tail->{x} && $head->{y} < $tail->{y}) {
                            $tail->{x}++;
                            $tail->{y}--;
                        } elsif ($head->{x} < $tail->{x} && $head->{y} > $tail->{y}) {
                            $tail->{x}--;
                            $tail->{y}++;
                        } elsif ($head->{x} < $tail->{x} && $head->{y} < $tail->{y}) {
                            $tail->{x}--;
                            $tail->{y}--;
                        }
                    }
                }

                # printf "(moving $amt steps in $dir)  head: (%d) % 9s tail: (%d) % 9s\n", $w, $head->toString, $w + 1, $tail->toString;
            }

            # rope position after one instruction simulated
            $tailVisitedPos{$rope[$ropeSize - 1]->toString} = 1;
        }
    }

    my $count = keys %tailVisitedPos;
    return $count;

}

# Part 1
say simulateRope 2;

# Part 2
say simulateRope 10;
