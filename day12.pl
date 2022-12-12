use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;
use List::Priority;

open(my $file, "<", "input/day12.txt") or die "Can't open input file";

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

sub Pos::neighbours {
    my ($self, $w, $h) = @_;
    my @ngh = ();
    if ($self->{x} - 1 >= 0) {
        push(@ngh, newPos($self->{x} - 1, $self->{y}));
    }
    if ($self->{x} + 1 < $w) {
        push(@ngh, newPos($self->{x} + 1, $self->{y}));
    }
    if ($self->{y} - 1 >= 0) {
        push(@ngh, newPos($self->{x}, $self->{y} - 1));
    }
    if ($self->{y} + 1 < $h) {
        push(@ngh, newPos($self->{x}, $self->{y} + 1));
    }
    return \@ngh;
}

sub Pos::distanceTo {
    my ($self, $other) = @_;
    return abs($self->{x} - $other->{x}) + abs($self->{y} - $other->{y});
}

assert @{newPos(1, 1)->neighbours(5, 5)}[0]->toString, "[0,1]";
assert @{newPos(1, 1)->neighbours(5, 5)}[1]->toString, "[2,1]";
assert @{newPos(1, 1)->neighbours(5, 5)}[2]->toString, "[1,0]";
assert @{newPos(1, 1)->neighbours(5, 5)}[3]->toString, "[1,2]";

my %map = ();
my $startPos;
my $endPos;

my $y = 0;
my $x = 0;
foreach my $line (@lines) {
    $x = 0;
    foreach my $char (split(//, $line)) {
        if ($char eq 'S') {
            $startPos = newPos($x, $y);
        } elsif ($char eq 'E') {
            $endPos = newPos($x, $y);
        }
        $map{newPos($x, $y)->toString} = $char;
        $x++;
    }
    $y++;
}
$map{$startPos->toString} = 'a';
$map{$endPos->toString} = 'z';

my $w = $x;
my $h = $y;

# printf "Map size is $w, $h, start is at %s and exit is at %s\n", $startPos->toString, $endPos->toString;

sub part1 {
    # A* search from 'S' to 'E'
    my $frontier = new List::Priority;
    $frontier->insert(0, $startPos);
    my %cameFrom = ($startPos->toString => "");
    my %costSoFar = ($startPos->toString => 0);

    while ($frontier->size > 0) {
        my $currentPos = $frontier->shift;
        if ($currentPos->toString eq $endPos->toString) {
            last;
        }

        foreach my $nextPos (@{$currentPos->neighbours($w, $h)}) {
            my $nextCost = $costSoFar{$currentPos->toString} + 1;

            if (!exists($cameFrom{$nextPos->toString}) || $nextCost < $costSoFar{$nextPos->toString}) {
                my $currentElevation = $map{$currentPos->toString};
                my $nextElevation = $map{$nextPos->toString};
                if (ord($currentElevation) - ord($nextElevation) >= -1) {
                    $costSoFar{$nextPos->toString} = $nextCost;
                    my $priority = $nextCost + $nextPos->distanceTo($endPos);
                    $frontier->insert($priority, $nextPos);
                    $cameFrom{$nextPos->toString} = $currentPos;
                }
            }
        }
    }

    # foreach my $j (0..$h-1) {
    #     foreach my $i (0..$w-1) {
    #         if (exists($cameFrom{newPos($i, $j)->toString})) {
    #             print ".";
    #         } elsif (newPos($i, $j)->toString eq $endPos->toString) {
    #             print "E";
    #         } else {
    #             print "?";
    #         }
    #     }
    #     print "\n";
    # }

    say $costSoFar{$endPos->toString};
}

sub part2 {
    # breadth-first search from 'E' until first 'a' is encountered.
    my $frontier = new List::Priority;
    $frontier->insert(0, $endPos);
    my %cameFrom = ($endPos->toString => "");
    my %costSoFar = ($endPos->toString => 0);

    while ($frontier->size > 0) {
        my $currentPos = $frontier->shift;
        if ($map{$currentPos->toString} eq 'a') {
            say $costSoFar{$currentPos->toString};
            last;
        }

        foreach my $nextPos (@{$currentPos->neighbours($w, $h)}) {
            my $nextCost = $costSoFar{$currentPos->toString} + 1;
            if (!exists($cameFrom{$nextPos->toString}) || $nextCost < $costSoFar{$nextPos->toString}) {
                my $currentElevation = $map{$currentPos->toString};
                my $nextElevation = $map{$nextPos->toString};
                if (ord($nextElevation) - ord($currentElevation) >= -1) {
                    $frontier->insert(0, $nextPos);
                    $cameFrom{$nextPos->toString} = $currentPos;
                    $costSoFar{ $nextPos->toString } = $nextCost;
                }
            }
        }

        # say $frontier->size;
    }
}

# Part 1
part1;

# Part 2
part2;
