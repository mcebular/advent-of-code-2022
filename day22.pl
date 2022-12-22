use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;


open(my $file, "<", "input/day22.txt") or die "Can't open input file";

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
    my @adjs = ();
    push(@adjs, newPos($self->x - 1, $self->y    ));
    push(@adjs, newPos($self->x + 1, $self->y    ));
    push(@adjs, newPos($self->x    , $self->y - 1));
    push(@adjs, newPos($self->x    , $self->y + 1));
    return \@adjs;
}


sub parseInput {
    my $path = undef;
    my %map = ();
    my $mapMaxY = 0;
    my $mapMaxX = 0;
    for (my $j = 0; $j <= $#lines; $j++) {
        if ($lines[$j] eq '') {
            $path = $lines[$j + 1];
            last;
        }

        $mapMaxY = $j;

        my @line = split //, $lines[$j];
        for (my $i = 0; $i <= $#line; $i++) {
            if ($i > $mapMaxX) {
                $mapMaxX = $i;
            }

            my $c = $line[$i];
            if ($c ne ' ') {
                $map{newPos($i, $j)->str} = $c;
            }
        }
    }

    my @parsedPath = ();
    while($path ne '') {
        if ($path =~ /^(\d+)(.*)/) {
            push(@parsedPath, $1);
        } elsif ($path =~ /^(L|R)(.*)/) {
            push(@parsedPath, $1)
        } else {
            die;
        }
        $path = $2;
    }

    return (\%map, $mapMaxX, $mapMaxY, \@parsedPath);
}

sub printMap {
    my %map = %{shift @_};
    my $maxX = shift @_;
    my $maxY = shift @_;
    print "\n";
    for (my $j = 0; $j <= $maxY; $j++) {
        for (my $i = 0; $i <= $maxX; $i++) {
            my $c = $map{newPos($i, $j)->str};
            if (defined $c) {
                print $c;
            } else {
                print ' ';
            }
        }
        print "\n";
    }
}

sub mapRowMinX {
    my %map = %{shift @_};
    my $maxX = shift @_;
    my $y = shift @_;
    for (my $i = 0; $i <= $maxX; $i++) {
        my $c = $map{newPos($i, $y)->str};
        if (defined $c) {
            return $i;
        }
    }
}

sub mapRowMaxX {
    my %map = %{shift @_};
    my $maxX = shift @_;
    my $y = shift @_;
    my $begin = 0;
    for (my $i = 0; $i <= $maxX + 1; $i++) {
        my $c = $map{newPos($i, $y)->str};
        if (!$begin && defined $c) {
           $begin = 1;
        }
        if ($begin && !defined $c) {
            return $i - 1;
        }
    }
    die;
}

sub mapColMinY {
    my %map = %{shift @_};
    my $maxY = shift @_;
    my $x = shift @_;
    for (my $j = 0; $j <= $maxY; $j++) {
        my $c = $map{newPos($x, $j)->str};
        if (defined $c) {
            return $j;
        }
    }
}

sub mapColMaxY {
    my %map = %{shift @_};
    my $maxY = shift @_;
    my $x = shift @_;
    my $begin = 0;
    for (my $j = 0; $j <= $maxY + 1; $j++) {
        my $c = $map{newPos($x, $j)->str};
        if (!$begin && defined $c) {
           $begin = 1;
        }
        if ($begin && !defined $c) {
            return $j - 1;
        }
    }
    die;
}

# This cubeWarp is specific for my input!
#  1: x =  50 ..  99 (y =   0)
#  2: x = 100 .. 149 (y =   0)
#  3: y =   0 ..  49 (x =  50)
#  4: y =   0 ..  49 (x = 150)
#  5: x = 100 .. 149 (y =  50)
#  6: y =  50 ..  99 (x =  50)
#  7: y =  50 ..  99 (x = 100)
#  8: x =   0 ..  49 (y = 100)
#  9: y = 100 .. 149 (x =   0)
# 10: y = 100 .. 149 (x = 100)
# 11: x =  50 ..  99 (y = 150)
# 12: y = 150 .. 199 (x =   0)
# 13: y = 150 .. 199 (x =  50)
# 14: x =   0 ..  49 (y = 200)

my %intervals = (
     1 => [ 50,  99],
     2 => [100, 149],
     3 => [  0,  49],
     4 => [  0,  49],
     5 => [100, 149],
     6 => [ 50,  99],
     7 => [ 50,  99],
     8 => [  0,  49],
     9 => [100, 149],
    10 => [100, 149],
    11 => [ 50,  99],
    12 => [150, 199],
    13 => [150, 199],
    14 => [  0,  49],
);

my %fixCrd = (
     1 =>   0,
     2 =>   0,
     3 =>  50,
     4 => 149,
     5 =>  49,
     6 =>  50,
     7 =>  99,
     8 => 100,
     9 =>   0,
    10 =>  99,
    11 => 149,
    12 =>   0,
    13 =>  49,
    14 => 199,
);

sub cubeWarp {
    my $pos = shift @_;
    my $dir = shift @_;

    sub flipIntervalSide {
        my $num = shift @_;
        my $md = $num % 50;
        return $num + 50 - 2 * $md - 1;
    }

    sub isInInterval {
        my $num = shift @_;
        my $side = shift @_;
        my ($start, $end) = @{$intervals{$side}};
        return $num >= $start && $num <= $end;
    }

    # 1U -> 12R
    if ($pos->y == -1 && isInInterval($pos->x, 1) && $dir == 3) {
        return (newPos($fixCrd{12}, $pos->x - $intervals{1}[0] + $intervals{12}[0]), 0);
    }
    # 13R -> 11U
    if ($pos->x == 50 && isInInterval($pos->y, 13) && $dir == 0) {
        return (newPos($pos->y - $intervals{13}[0] + $intervals{11}[0], $fixCrd{11}), 3);
    }
    # 9L -> 3D
    if ($pos->x == -1 && isInInterval($pos->y, 9) && $dir == 2) {
        return (newPos($fixCrd{3}, flipIntervalSide($pos->y - $intervals{9}[0] + $intervals{3}[0])), 0);
    }
    # 3L -> 9R
    if ($pos->x == 49 && isInInterval($pos->y, 3) && $dir == 2) {
       return (newPos($fixCrd{9}, flipIntervalSide($pos->y - $intervals{3}[0] + $intervals{9}[0])), 0);
    }
    # 8U -> 6R
    if ($pos->y == 99 && isInInterval($pos->x, 8) && $dir == 3) {
        return (newPos($fixCrd{6}, $pos->x - $intervals{8}[0] + $intervals{6}[0]), 0);
    }
    # 6L -> 8D
    if ($pos->x == 49 && isInInterval($pos->y, 6) && $dir == 2) {
        return (newPos($pos->y - $intervals{6}[0] + $intervals{8}[0], $fixCrd{8}), 1);
    }
    # 12L -> 1D
    if ($pos->x == -1 && isInInterval($pos->y, 12) && $dir == 2) {
        return (newPos($pos->y - $intervals{12}[0] + $intervals{1}[0], $fixCrd{1}), 1);
    }
    # 14D -> 2D
    if ($pos->y == 200 && isInInterval($pos->x, 14) && $dir == 1) {
        return (newPos($pos->x - $intervals{14}[0] + $intervals{2}[0], $fixCrd{2}), 1);
    }
    # 2U -> 14U
    if ($pos->y == -1 && isInInterval($pos->x, 2) && $dir == 3) {
        return (newPos($pos->x - $intervals{2}[0] + $intervals{14}[0], $fixCrd{14}), 3);
    }
    # 4R -> 10L
    if ($pos->x == 150 && isInInterval($pos->y, 4) && $dir == 0) {
        return (newPos($fixCrd{10}, flipIntervalSide($pos->y - $intervals{4}[0] + $intervals{10}[0])), 2);
    }
    # 11D -> 13L
    if ($pos->y == 150 && isInInterval($pos->x, 11) && $dir == 1) {
        return (newPos($fixCrd{13}, $pos->x - $intervals{11}[0] + $intervals{13}[0]), 2);
    }
    # 10R -> 4L
    if ($pos->x == 100 && isInInterval($pos->y, 10) && $dir == 0) {
        return (newPos($fixCrd{4}, flipIntervalSide($pos->y - $intervals{10}[0] + $intervals{4}[0])), 2);
    }
    # 5D -> 7L
    if ($pos->y == 50 && isInInterval($pos->x, 5) && $dir == 1) {
        return (newPos($fixCrd{7}, $pos->x - $intervals{5}[0] + $intervals{7}[0]), 2);
    }
    # 7R -> 5U
    if ($pos->x == 100 && isInInterval($pos->y, 7) && $dir == 0) {
        return (newPos($pos->y - $intervals{7}[0] + $intervals{5}[0], $fixCrd{5}), 3);
    }

    die 'invalid warp';
}

sub assertCubeWarp {
    my ($actual, $expected) = @_;
    my @actual = @{$actual};
    my @expected = @{$expected};

    assertEq $actual[0]->str, $expected[0]->str;
    assert $actual[1], $expected[1];
}

# I ended up writing tests for each warp edge so I could find the error. :)
my @t;
# 1 -> 12
@t = cubeWarp(newPos(50, -1), 3); assertCubeWarp \@t, [newPos(0, 150), 0];
@t = cubeWarp(newPos(99, -1), 3); assertCubeWarp \@t, [newPos(0, 199), 0];

# 2 -> 14
@t = cubeWarp(newPos(100, -1), 3); assertCubeWarp \@t, [newPos(0, 199), 3];
@t = cubeWarp(newPos(149, -1), 3); assertCubeWarp \@t, [newPos(49, 199), 3];

# 3 -> 9
@t = cubeWarp(newPos(49, 0), 2); assertCubeWarp \@t, [newPos(0, 149), 0];
@t = cubeWarp(newPos(49, 49), 2); assertCubeWarp \@t, [newPos(0, 100), 0];

# 4 -> 10
@t = cubeWarp(newPos(150, 0), 0); assertCubeWarp \@t, [newPos(99, 149), 2];
@t = cubeWarp(newPos(150, 49), 0); assertCubeWarp \@t, [newPos(99, 100), 2];

# 5 -> 7
@t = cubeWarp(newPos(100, 50), 1); assertCubeWarp \@t, [newPos(99, 50), 2];
@t = cubeWarp(newPos(149, 50), 1); assertCubeWarp \@t, [newPos(99, 99), 2];

# 6 -> 8
@t = cubeWarp(newPos(49, 50), 2); assertCubeWarp \@t, [newPos(0, 100), 1];
@t = cubeWarp(newPos(49, 99), 2); assertCubeWarp \@t, [newPos(49, 100), 1];

# 7 -> 5
@t = cubeWarp(newPos(100, 50), 0); assertCubeWarp \@t, [newPos(100, 49), 3];
@t = cubeWarp(newPos(100, 99), 0); assertCubeWarp \@t, [newPos(149, 49), 3];

# 8 -> 6
@t = cubeWarp(newPos(0, 99), 3); assertCubeWarp \@t, [newPos(50, 50), 0];
@t = cubeWarp(newPos(49, 99), 3); assertCubeWarp \@t, [newPos(50, 99), 0];

# 9 -> 3
@t = cubeWarp(newPos(-1, 149), 2); assertCubeWarp \@t, [newPos(50, 0), 0];
@t = cubeWarp(newPos(-1, 100), 2); assertCubeWarp \@t, [newPos(50, 49), 0];

# 10 -> 4
@t = cubeWarp(newPos(100, 149), 0); assertCubeWarp \@t, [newPos(149, 0), 2];
@t = cubeWarp(newPos(100, 100), 0); assertCubeWarp \@t, [newPos(149, 49), 2];

# 11 -> 13
@t = cubeWarp(newPos(50, 150), 1); assertCubeWarp \@t, [newPos(49, 150), 2];
@t = cubeWarp(newPos(99, 150), 1); assertCubeWarp \@t, [newPos(49, 199), 2];

# 12 -> 1
@t = cubeWarp(newPos(-1, 150), 2); assertCubeWarp \@t, [newPos(50, 0), 1];
@t = cubeWarp(newPos(-1, 199), 2); assertCubeWarp \@t, [newPos(99, 0), 1];

# 13 -> 11
@t = cubeWarp(newPos(50, 150), 0); assertCubeWarp \@t, [newPos(50, 149), 3];
@t = cubeWarp(newPos(50, 199), 0); assertCubeWarp \@t, [newPos(99, 149), 3];

# 14 -> 2
@t = cubeWarp(newPos(0, 200), 1); assertCubeWarp \@t, [newPos(100, 0), 1];
@t = cubeWarp(newPos(49, 200), 1); assertCubeWarp \@t, [newPos(149, 0), 1];

sub walkPath {
    my $warpType = shift @_;

    my ($map, $maxX, $maxY, $path) = parseInput;
    # printMap($map, $maxX, $maxY);

    my $pos = newPos(mapRowMinX($map, $maxX, 0), 0);
    # 3
    #2 0
    # 1
    my $dir = 0;
    my $insIdx = 0;

    my $prevPos = newPos(-1, -1);
    my $prevDir = -1;
    while ($insIdx < scalar @$path) {
        $prevPos = $pos;
        $prevDir = $dir;

        my $ins = @$path[$insIdx];
        $insIdx++;

        # follow the instruction until we made the count or we stop
        if ($ins =~ /(L|R)/) {
            if ($ins eq 'L') {
                $dir = ($dir - 1) % 4;
            } elsif ($ins eq 'R') {
                $dir = ($dir + 1) % 4;
            } else {
                die 'invalid direction';
            }
        } else {
            # assuming number
            for (my $p = 0; $p < $ins + 0; $p++) {
                my $nextPos;
                my $nextDir = $dir;
                my $mapTile;
                if ($dir == 3) {
                    $nextPos = newPos($pos->x, $pos->y - 1);
                    $mapTile = %$map{$nextPos->str};
                    if (!defined $mapTile) {
                        if ($warpType eq 'classic') {
                            $nextPos = newPos($pos->x, mapColMaxY($map, $maxY, $pos->x));
                        } elsif ($warpType eq 'cube') {
                            ($nextPos, $nextDir) = cubeWarp($nextPos, $nextDir);
                        } else {
                            die 'invalid warp type';
                        }
                        $mapTile = %$map{$nextPos->str};
                    }
                } elsif($dir == 0) {
                    $nextPos = newPos($pos->x + 1, $pos->y);
                    $mapTile = %$map{$nextPos->str};
                    if (!defined $mapTile) {
                        if ($warpType eq 'classic') {
                            $nextPos = newPos(mapRowMinX($map, $maxX, $pos->y), $pos->y);
                        } elsif ($warpType eq 'cube') {
                            ($nextPos, $nextDir) = cubeWarp($nextPos, $nextDir);
                        } else {
                            die 'invalid warp type';
                        }
                        $mapTile = %$map{$nextPos->str};
                    }
                } elsif($dir == 1) {
                    $nextPos = newPos($pos->x, $pos->y + 1);
                    $mapTile = %$map{$nextPos->str};
                    if (!defined $mapTile) {
                        if ($warpType eq 'classic') {
                            $nextPos = newPos($pos->x, mapColMinY($map, $maxY, $pos->x));
                        } elsif ($warpType eq 'cube') {
                            ($nextPos, $nextDir) = cubeWarp($nextPos, $nextDir);
                        } else {
                            die 'invalid warp type';
                        }
                        $mapTile = %$map{$nextPos->str};
                    }
                } elsif($dir == 2) {
                    $nextPos = newPos($pos->x - 1, $pos->y);
                    $mapTile = %$map{$nextPos->str};
                    if (!defined $mapTile) {
                        if ($warpType eq 'classic') {
                            $nextPos = newPos(mapRowMaxX($map, $maxX, $pos->y), $pos->y);
                        } elsif ($warpType eq 'cube') {
                            ($nextPos, $nextDir) = cubeWarp($nextPos, $nextDir);
                        } else {
                            die 'invalid warp type';
                        }
                        $mapTile = %$map{$nextPos->str};
                    }
                } else {
                    die 'invalid dir';
                }

                if (!defined $nextPos) {
                    die 'undefined nextPos';
                }

                if (!defined $mapTile) {
                    die 'invalid mapTile for nextPos (' . $nextPos->str . ')';
                }

                if ($mapTile eq '#') {
                    last;
                } elsif ($mapTile eq '.') {
                    $pos = $nextPos;
                    $dir = $nextDir;
                } else {
                    die 'invalid position';
                }
            }
        }
    }
    return 1000 * ($pos->y + 1) + 4 * ($pos->x + 1) + $dir;
}


# Part 1
say walkPath 'classic';

# Part 2
say walkPath 'cube';
