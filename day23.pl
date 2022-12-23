use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

use List::Util 'max', 'min';


open(my $file, "<", "input/day23.txt") or die "Can't open input file";

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

sub Pos::x {
    return (shift @_)->{x};
}

sub Pos::y {
    return (shift @_)->{y};
}

sub Pos::adjacent {
    my $self = shift @_;
    my $dir = shift @_;

    if (defined $dir) {
        if ($dir eq 'N') {
            return newPos($self->x    , $self->y - 1);
        } elsif ($dir eq 'E') {
            return newPos($self->x + 1, $self->y    );
        } elsif ($dir eq 'S') {
            return newPos($self->x    , $self->y + 1);
        } elsif ($dir eq 'W') {
            return newPos($self->x - 1, $self->y    );
        } elsif ($dir eq 'NE') {
            return newPos($self->x + 1, $self->y - 1);
        } elsif ($dir eq 'NW') {
            return newPos($self->x - 1, $self->y - 1);
        } elsif ($dir eq 'SE') {
            return newPos($self->x + 1, $self->y + 1);
        } elsif ($dir eq 'SW') {
            return newPos($self->x - 1, $self->y + 1);
        } else {
            die 'invalid direction';
        }
    }
    return (
        newPos($self->x - 1, $self->y - 1),
        newPos($self->x    , $self->y - 1),
        newPos($self->x + 1, $self->y - 1),
        newPos($self->x - 1, $self->y    ),
        # newPos($self->x    , $self->y    ),
        newPos($self->x + 1, $self->y    ),
        newPos($self->x - 1, $self->y + 1),
        newPos($self->x    , $self->y + 1),
        newPos($self->x + 1, $self->y + 1),
    );
}


sub parseMap {
    my %map = ();
    for (my $j = 0; $j <= $#lines; $j++) {
        my @line = split //, $lines[$j];
        for (my $i = 0; $i <= $#line; $i++) {
            my $c = $line[$i];
            if ($c eq '#') {
                $map{newPos($i, $j)->str} = $c;
            }
        }
    }

    return \%map;
}

sub printMap {
    my %map = %{shift @_};
    my $min = newPos(9999, 9999);
    my $max = newPos(0, 0);

    foreach my $posstr (keys %map) {
        my $pos = parsePos $posstr;
        $min = newPos(min($min->x, $pos->x), min($min->y, $pos->y));
        $max = newPos(max($max->x, $pos->x), max($max->y, $pos->y));
    }

    print "\n";
    for (my $j = $min->y; $j <= $max->y; $j++) {
        for (my $i = $min->x; $i <= $max->x; $i++) {
            my $c = $map{newPos($i, $j)->str};
            if (defined $c) {
                print $c;
            } else {
                print '.';
            }
        }
        print "\n";
    }
}

sub countEmptyGround {
    my %map = %{shift @_};
    my $min = newPos(9999, 9999);
    my $max = newPos(0, 0);

    foreach my $posstr (keys %map) {
        my $pos = parsePos $posstr;
        $min = newPos(min($min->x, $pos->x), min($min->y, $pos->y));
        $max = newPos(max($max->x, $pos->x), max($max->y, $pos->y));
    }

    my $count = 0;
    for (my $j = $min->y; $j <= $max->y; $j++) {
        for (my $i = $min->x; $i <= $max->x; $i++) {
            my $c = $map{newPos($i, $j)->str};
            if (!defined $c) {
                $count++;
            }
        }
    }
    return $count;
}

sub isElfAtPos {
    my $map = shift @_;
    my $pos = shift @_;
    my $t = $map->{$pos->str};
    return defined $t && $t eq '#';
}

my $map = parseMap;
# printMap $map;

my $rounds = 0;
while (1) {
    if ($rounds == 10) {
        # Part 1
        say countEmptyGround $map;
    }
    # say "Round $rounds.";

    my %proposedMoves = ();
    foreach my $posstr (keys %$map) {
        my $pos = parsePos $posstr;

        # If no other Elves are in one of those eight positions,
        # the Elf does not do anything during this round.
        my $hasAnyAdj = 0;
        foreach my $adj ($pos->adjacent) {
            if (isElfAtPos $map, $adj) {
                $hasAnyAdj = 1;
                last;
            }
        }

        if (!$hasAnyAdj) {
            next;
        }

        my $startAtRule = ($rounds % 4);
        my $currentRule = $startAtRule;
        while (1) {
            # If there is no Elf in the N, NE, or NW adjacent positions, the Elf proposes moving north one step.
            if ($currentRule == 0
            && !isElfAtPos($map, $pos->adjacent('N'))
            && !isElfAtPos($map, $pos->adjacent('NE'))
            && !isElfAtPos($map, $pos->adjacent('NW'))
            ) {
                my $nextPos = $pos->adjacent('N');
                if (!defined $proposedMoves{$nextPos->str}) {
                    $proposedMoves{$nextPos->str} = $pos->str;
                } else {
                    $proposedMoves{$nextPos->str} = 'clash';
                }
                last;
            }

            # If there is no Elf in the S, SE, or SW adjacent positions, the Elf proposes moving south one step.
            elsif ($currentRule == 1
            && !isElfAtPos($map, $pos->adjacent('S'))
            && !isElfAtPos($map, $pos->adjacent('SE'))
            && !isElfAtPos($map, $pos->adjacent('SW'))
            ) {
                my $nextPos = $pos->adjacent('S');
                if (!defined $proposedMoves{$nextPos->str}) {
                    $proposedMoves{$nextPos->str} = $pos->str;
                } else {
                    $proposedMoves{$nextPos->str} = 'clash';
                }
                last;
            }

            # If there is no Elf in the W, NW, or SW adjacent positions, the Elf proposes moving west one step.
            elsif ($currentRule == 2
            && !isElfAtPos($map, $pos->adjacent('W'))
            && !isElfAtPos($map, $pos->adjacent('NW'))
            && !isElfAtPos($map, $pos->adjacent('SW'))
            ) {
                my $nextPos = $pos->adjacent('W');
                if (!defined $proposedMoves{$nextPos->str}) {
                    $proposedMoves{$nextPos->str} = $pos->str;
                } else {
                    $proposedMoves{$nextPos->str} = 'clash';
                }
                last;
            }

            # If there is no Elf in the E, NE, or SE adjacent positions, the Elf proposes moving east one step.
            elsif ($currentRule == 3
            && !isElfAtPos($map, $pos->adjacent('E'))
            && !isElfAtPos($map, $pos->adjacent('NE'))
            && !isElfAtPos($map, $pos->adjacent('SE'))
            ) {
                my $nextPos = $pos->adjacent('E');
                if (!defined $proposedMoves{$nextPos->str}) {
                    $proposedMoves{$nextPos->str} = $pos->str;
                } else {
                    $proposedMoves{$nextPos->str} = 'clash';
                }
                last;
            }

            $currentRule = ($currentRule + 1) % 4;
            if ($currentRule == $startAtRule) {
                last;
            }
        }
    }

    if (scalar keys %proposedMoves == 0) {
        last;
    }

    foreach my $to (keys %proposedMoves) {
        my $from = $proposedMoves{$to};
        if ($from eq 'clash') {
            next;
        }
        delete $map->{$from};
        $map->{$to} = '#';
    }

    $rounds++;
}

# Part 2
say $rounds + 1;
