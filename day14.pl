use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

use List::Util;


open(my $file, "<", "input/day14.txt") or die "Can't open input file";

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

sub parsePos {
    my ($str) = @_;
    $str =~ /\[(\d+), (\d+)\]/;
    return bless {
        x => $1,
        y => $2,
    }, "Pos";
}

sub Pos::toString {
    my ($self) = @_;
    return sprintf "[$self->{x}, $self->{y}]";
}

sub Pos::below {
    my ($self) = @_;
    return newPos($self->{x}, $self->{y} + 1);
}

sub Pos::belowLeft {
    my ($self) = @_;
    return newPos($self->{x} - 1, $self->{y} + 1);
}

sub Pos::belowRight {
    my ($self) = @_;
    return newPos($self->{x} + 1, $self->{y} + 1);
}

sub Pos::pathTo {
    my ($self, $other) = @_;
    if ($self->{x} == $other->{x}) {
        my @range = ();
        if ($self->{y} <= $other->{y}) {
            @range = ($self->{y} .. $other->{y});
        } else {
            @range = reverse ($other->{y} .. $self->{y});
        }
        my @x = map { newPos($self->{x}, $_) } @range;
        return \@x;

    } elsif ($self->{y} == $other->{y}) {
        my @range = ();
        if ($self->{x} <= $other->{x}) {
            @range = ($self->{x} .. $other->{x});
        } else {
            @range = reverse ($other->{x} .. $self->{x});
        }
        my @y = map { newPos($_, $self->{y}) } @range;
        return \@y;

    } else {
        die "pathTo is not a straight line";
    }
}

assert scalar @{newPos(0, 3)->pathTo(newPos(3, 3))}, 4;
assert scalar @{newPos(3, 0)->pathTo(newPos(3, 3))}, 4;
assert scalar @{newPos(3, 3)->pathTo(newPos(0, 3))}, 4;
assert scalar @{newPos(3, 3)->pathTo(newPos(3, 0))}, 4;

my %cave = ();
foreach my $line (@lines) {
    my @pts = split(/ -> /, $line);
    my $start;
    my $end;
    for my $point (@pts) {
        $end = newPos(split(/,/, $point));
        if (!defined $start) {
            $start = $end;
            next;
        }

        foreach my $p (@{$start->pathTo($end)}) {
            $cave{$p->toString} = "#";
        }

        $start = $end;
    }
}

my $minX = List::Util::min map { parsePos($_)->{x} } keys %cave;
my $maxX = List::Util::max map { parsePos($_)->{x} } keys %cave;
my $minY = List::Util::min map { parsePos($_)->{y} } keys %cave;
my $maxY = List::Util::max map { parsePos($_)->{y} } keys %cave;
# say $minX; say $maxX; say $minY; say $maxY;

sub printCave {
    for (my $y = 0; $y <= $maxY; $y++) {
        for (my $x = $minX; $x <= $maxX; $x++) {
            my $p = $cave{newPos($x, $y)->toString};
            if (defined $p) {
                print $p;
            } else {
                print '.';
            }
        }
        print "\n";
    }
    print "\n";
}

my $sandStartPoint = newPos(500, 0);
$cave{$sandStartPoint->toString} = '+';

# printCave;

sub sandFall {
    my $sandPos = $sandStartPoint;

    if ($cave{$sandStartPoint->toString} eq 'O') {
        # cave is full
        return "";
    }

    while (1) {
        # flows out the bottom, falling into the endless void
        # -or-
        # floor is an infinite horizontal line with a y coordinate equal to two plus the highest y coordinate
        if ($sandPos->{y} > $maxY + 2) {
            # return false to signal a cave full of sand
            return "";
        }

        # down one step if possible
        if (!defined $cave{$sandPos->below->toString}) {
            $sandPos = $sandPos->below;
        }
        # diagonally one step down and to the left
        elsif (!defined $cave{$sandPos->belowLeft->toString}) {
            $sandPos = $sandPos->belowLeft;
        }
        # diagonally one step down and to the right
        elsif (!defined $cave{$sandPos->belowRight->toString}) {
            $sandPos = $sandPos->belowRight;
        }
        # comes to rest
        else {
            $cave{$sandPos->toString} = 'O';
            last;
        }
    }

    return 1;
}

# Part 1
while (sandFall) {};
# printCave;
say scalar grep { $_ eq 'O' } values %cave;

# Part 2
foreach my $p (@{newPos(-10000, $maxY + 2)->pathTo(newPos(10000, $maxY + 2))}) {
    $cave{$p->toString} = "#";
}

while (sandFall) {};
# printCave;
say scalar grep { $_ eq 'O' } values %cave;
