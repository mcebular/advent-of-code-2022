use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

use List::Priority;
use List::Util 'max';


open(my $file, "<", "input/day24.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;


sub newPos {
    return bless {
        x => shift @_,
        y => shift @_,
    }, "Pos";
}

sub parsePos {
    my ($str) = @_;
    $str =~ /\[(-?\d+), (-?\d+)\]/;
    return bless {
        x => $1,
        y => $2,
    }, "Pos";
}

sub Pos::str {
    my ($self) = @_;
    return sprintf "[$self->{x}, $self->{y}]";
}

sub Pos::dist {
    my ($self, $other) = @_;
    return abs($self->{x} - $other->{x}) + abs($self->{y} - $other->{y});
}

sub parseMap {
    my %map = ();
    my $max = newPos(0, 0);

    for (my $j = 0; $j <= $#lines; $j++) {
        my @line = split //, $lines[$j];
        for (my $i = 0; $i <= $#line; $i++) {
            my $c = $line[$i];
            if ($c eq '.') {
                next;
            }
            my $pos = newPos($i, $j);
            $max = newPos(max($max->{x}, $i), max($max->{y}, $j));
            $map{$pos->str} = $c;
        }
    }

    return (\%map, $max);
}

my ($map, $max) = parseMap;
my $width = $max->{x} - 1;
my $height = $max->{y} - 1;

sub newState {
    my $pos = shift @_;
    my $steps = shift @_;

    return bless {
        pos => $pos,
        steps => $steps,
    }, "State";
}

sub State::key {
    my $self = shift @_;
    return sprintf "%s %s %s", $self->{pos}->str, $self->{steps} % $width, $self->{steps} % $height;
}

# Below for loops: pecalculate all possible blizzard positions
my %blizzHorizAtPosAtStep = ();
my %blizzVertiAtPosAtStep = ();

for (my $j = 1; $j < $max->{y}; $j++) {
    my $row = '';
    for (my $i = 1; $i < $max->{x}; $i++) {
        my $c = $map->{newPos($i, $j)->str};
        if (defined $c && $c eq '<') {
            $row .= $c;
        } else {
            $row .= '.';
        }
    }

    for (my $s = 0; $s < $width; $s++) {
        my @splRow = split //, $row;
        for (my $i = 1; $i < $max->{x}; $i++) {
            my $c = $splRow[$i - 1];
            if ($c eq '<') {
                $blizzHorizAtPosAtStep{"$i $j $s"} = 1;
            } else {
                $blizzHorizAtPosAtStep{"$i $j $s"} = 0;
            }
        }

        my $head = shift @splRow;
        push(@splRow, $head);
        $row = join '', @splRow;
    }
}
for (my $j = 1; $j < $max->{y}; $j++) {
    my $row = '';
    for (my $i = 1; $i < $max->{x}; $i++) {
        my $c = $map->{newPos($i, $j)->str};
        if (defined $c && $c eq '>') {
            $row .= $c;
        } else {
            $row .= '.';
        }
    }

    for (my $s = 0; $s < $width; $s++) {
        my @splRow = split //, $row;
        for (my $i = 1; $i < $max->{x}; $i++) {
            my $c = $splRow[$i - 1];
            if ($c eq '>') {
                $blizzHorizAtPosAtStep{"$i $j $s"} = 2;
            } elsif (!defined $blizzHorizAtPosAtStep{"$i $j $s"}) {
                $blizzHorizAtPosAtStep{"$i $j $s"} = 0;
            }
        }

        my $head = pop @splRow;
        unshift(@splRow, $head);
        $row = join '', @splRow;
    }
}
for (my $i = 1; $i < $max->{x}; $i++) {
    my $col = '';
    for (my $j = 1; $j < $max->{y}; $j++) {
        my $c = $map->{newPos($i, $j)->str};
        if (defined $c && $c eq '^') {
            $col .= $c;
        } else {
            $col .= '.';
        }
    }

    for (my $s = 0; $s < $height; $s++) {
        my @splCol = split //, $col;
        for (my $j = 1; $j < $max->{y}; $j++) {
            my $c = $splCol[$j - 1];
            if ($c eq '^') {
                $blizzVertiAtPosAtStep{"$i $j $s"} = 3;
            } else {
                $blizzVertiAtPosAtStep{"$i $j $s"} = 0;
            }
        }

        my $head = shift @splCol;
        push(@splCol, $head);
        $col = join '', @splCol;
    }
}
for (my $i = 1; $i < $max->{x}; $i++) {
    my $col = '';
    for (my $j = 1; $j < $max->{y}; $j++) {
        my $c = $map->{newPos($i, $j)->str};
        if (defined $c && $c eq 'v') {
            $col .= $c;
        } else {
            $col .= '.';
        }
    }

    for (my $s = 0; $s < $height; $s++) {
        my @splCol = split //, $col;
        for (my $j = 1; $j < $max->{y}; $j++) {
            my $c = $splCol[$j - 1];
            if ($c eq 'v') {
                $blizzVertiAtPosAtStep{"$i $j $s"} = 4;
            } elsif (!defined $blizzVertiAtPosAtStep{"$i $j $s"}) {
                $blizzVertiAtPosAtStep{"$i $j $s"} = 0;
            }
        }

        my $head = pop @splCol;
        unshift(@splCol, $head);
        $col = join '', @splCol;
    }
}

for (my $i = 0; $i <= $max->{x}; $i++) {
    for (my $s = 0; $s < $width; $s++) {
        $blizzHorizAtPosAtStep{"$i 0 $s"} = 5;
        $blizzVertiAtPosAtStep{"$i 0 $s"} = 6;
        $blizzHorizAtPosAtStep{"$i " . $max->{y} ." $s"} = 5;
        $blizzVertiAtPosAtStep{"$i " . $max->{y} ." $s"} = 6;
    }
}
for (my $j = 0; $j <= $max->{y}; $j++) {
    for (my $s = 0; $s < $width; $s++) {
        $blizzHorizAtPosAtStep{"0 $j $s"} = 5;
        $blizzVertiAtPosAtStep{"0 $j $s"} = 6;
        $blizzHorizAtPosAtStep{$max->{x} . " $j $s"} = 5;
        $blizzVertiAtPosAtStep{$max->{x} . " $j $s"} = 6;
    }
}

sub printMap {
    my $step = shift @_;
    my $mark = shift @_;
    my $start = shift @_;
    my $end = shift @_;

    for (my $j = 0; $j <= $max->{y}; $j++) {
        for (my $i = 0; $i <= $max->{x}; $i++) {
            if ($mark->{x} == $i && $mark->{y} == $j) {
                print 'X';
            } elsif ($start->{x} == $i && $start->{y} == $j) {
                print 'S';
            } elsif ($end->{x} == $i && $end->{y} == $j) {
                print 'E';
            } else {
                my $smh = $step % $width;
                my $smv = $step % $height;
                my $ch = $blizzHorizAtPosAtStep{"$i $j $smh"};
                my $cv = $blizzVertiAtPosAtStep{"$i $j $smv"};

                if (!defined $ch || !defined $cv) {
                    say "$i $j $smv";
                    say "$i $j $smh";
                    die;
                }

                if ($ch == 5 || $cv == 6) {
                    print '#';
                } elsif ($ch != 0 || $cv != 0) {
                    print '-';
                } else {
                    print ' ';
                }
            }
        }
        print "\n";
    }
    print "\n";
}

sub findBestPath {
    my $startPos = shift @_;
    my $endPos = shift @_;
    my $initialSteps = shift @_;

    my $frontier = new List::Priority;
    my $startState = newState($startPos, $initialSteps);
    $frontier->insert(0, $startState);
    my %reached = ();
    # $reached{$startState->key} = 0;
    my $minRequiredSteps = -1;
    while ($frontier->size > 0) {
        my $currState = $frontier->shift;
        my $currPos = $currState->{pos};
        my $currSteps = $currState->{steps};

        # If I was in this exact state before, but with less steps, skip state.
        my $currStateBestSteps = $reached{$currState->key};
        if (defined $currStateBestSteps && $currStateBestSteps <= $currSteps) {
            next;
        }
        $reached{$currState->key} = $currSteps;

        # If I reached end at least once (i.e. having current best) and
        # current state + remaining path would take more time than current best,
        # skip.
        if ($minRequiredSteps != -1 && $currSteps + $currPos->dist($endPos) >= $minRequiredSteps) {
            next;
        }

        if ($currPos->str eq $endPos->str) {
            $minRequiredSteps = $currSteps;
            # We need not to move anywhere else after we're reached the end.
            next;
        }

        my $nx = undef;
        my $ny = undef;
        my $ns = $currSteps + 1;
        my $nsmh = ($currSteps + 1) % $width;
        my $nsmv = ($currSteps + 1) % $height;

        # Move right
        $nx = $currPos->{x} + 1;
        $ny = $currPos->{y};
        if ($nx < $max->{x} && $ny > 0 && $blizzHorizAtPosAtStep{"$nx $ny $nsmh"} == 0 && $blizzVertiAtPosAtStep{"$nx $ny $nsmv"} == 0) {
            $frontier->insert($endPos->dist(newPos($nx, $ny)), newState(newPos($nx, $ny), $ns));
        }
        # Move down
        $nx = $currPos->{x};
        $ny = $currPos->{y} + 1;
        if ($nx == $endPos->{x} && $ny == $endPos->{y}
        || $nx == $startPos->{x} && $ny == $startPos->{y}
        || $ny < $max->{y} && $blizzHorizAtPosAtStep{"$nx $ny $nsmh"} == 0 && $blizzVertiAtPosAtStep{"$nx $ny $nsmv"} == 0) {
            $frontier->insert($endPos->dist(newPos($nx, $ny)), newState(newPos($nx, $ny), $ns));
        }
        # Move left
        $nx = $currPos->{x} - 1;
        $ny = $currPos->{y};
        if (!defined $blizzHorizAtPosAtStep{"$nx $ny $nsmh"}) {
            say $blizzHorizAtPosAtStep{"$nx $ny 0"};
            say $blizzHorizAtPosAtStep{"$nx $ny 1"};
            say $blizzHorizAtPosAtStep{"$nx $ny 2"};
            say $blizzHorizAtPosAtStep{"$nx $ny 3"};
            say $blizzHorizAtPosAtStep{"$nx $ny 4"};
            say $blizzHorizAtPosAtStep{"$nx $ny 5"};
            say $height;
            say "$nx $ny $nsmh $ns";
            die;
        }
        if ($nx > 0 && $blizzHorizAtPosAtStep{"$nx $ny $nsmh"} == 0 && $blizzVertiAtPosAtStep{"$nx $ny $nsmv"} == 0) {
            $frontier->insert($endPos->dist(newPos($nx, $ny)), newState(newPos($nx, $ny), $ns));
        }
        # Move up
        $nx = $currPos->{x};
        $ny = $currPos->{y} - 1;
        if ($nx == $endPos->{x} && $ny == $endPos->{y}
        || $nx == $startPos->{x} && $ny == $startPos->{y}
        || $ny > 0 && $blizzHorizAtPosAtStep{"$nx $ny $nsmh"} == 0 && $blizzVertiAtPosAtStep{"$nx $ny $nsmv"} == 0) {
            $frontier->insert($endPos->dist(newPos($nx, $ny)), newState(newPos($nx, $ny), $ns));
        }
        # Stay at position
        $nx = $currPos->{x};
        $ny = $currPos->{y};
        if ($nx == $endPos->{x} && $ny == $endPos->{y}
        || $nx == $startPos->{x} && $ny == $startPos->{y}
        || $blizzHorizAtPosAtStep{"$nx $ny $nsmh"} == 0 && $blizzVertiAtPosAtStep{"$nx $ny $nsmv"} == 0) {
            $frontier->insert($endPos->dist(newPos($nx, $ny)), newState(newPos($nx, $ny), $ns));
        }
    }

    return $minRequiredSteps;
}

my $startPos = newPos(1, 0);
my $endPos = newPos($max->{x} - 1, $max->{y});

# Part 1
my $trip1 = findBestPath $startPos, $endPos, 0;
say $trip1;

# Part 2
my $trip2 = findBestPath $endPos, $startPos, $trip1;
# say $trip2;

my $trip3 = findBestPath $startPos, $endPos, $trip2;
say $trip3;

