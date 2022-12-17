use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

use List::Util 'max', 'min', 'sum';


open(my $file, "<", "input/day17.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;

my @rocks = (
    [
        '0,0', '1,0', '2,0', '3,0',
    ],
    [
               '1,2',
        '0,1', '1,1', '2,1',
               '1,0',
    ],
    [
                      '2,2',
                      '2,1',
        '0,0', '1,0', '2,0',
    ],
    [
        '0,3',
        '0,2',
        '0,1',
        '0,0',
    ],
    [
        '0,1', '1,1',
        '0,0', '1,0',
    ]
);

my @jetstream = split //, $lines[0];

my %cave = ();
for (my $i = 0; $i < 7; $i++) {
    $cave{"$i,0"} = '-';
}

my $memoCaveMaxY = 0;

sub printCave {
    for (my $j = $memoCaveMaxY + 8; $j >= 0; $j--) {
        for (my $i = 0; $i < 7; $i++) {
            my $p = $cave{"$i,$j"};
            if (defined $p) {
                print $p;
            } else {
                print '.';
            }
        }
        print "\n";
    }
}

sub createNewRock {
    my $rock = shift @_;
    my $sx = 2;
    my $sy = 4 + $memoCaveMaxY;
    my @rockPositions = ();
    for my $pos (@{$rock}) {
        my @xy = split /,/, $pos;
        my $x = $xy[0] + $sx;
        my $y = $xy[1] + $sy;
        my $rpos = $x . "," . $y;
        push(@rockPositions, $rpos);
        $cave{$rpos} = '@';
    }
    return \@rockPositions;
}

sub moveRock {
    # returns true if move was successful
    my @rock = @{shift @_};
    my $mx = shift @_;
    my $my = shift @_;

    my @newRock = ();
    for my $rp (@rock) {
        my @xy = split /,/, $rp;
        my $nrp = ($xy[0] + $mx) . "," . ($xy[1] - $my);
        push (@newRock, $nrp);
    }

    my $canMove = 1;
    for my $rp (@newRock) {
        my @xy = split /,/, $rp;
        my $x = $xy[0];
        my $y = $xy[1];
        if ($x < 0 || $x >= 7) {
            $canMove = '';
            last;
        }
        if ($y <= 0) {
            $canMove = '';
            last;
        }

        my $c = $cave{$rp};
        if (defined $c && !($c eq '.' || $c eq '@')) {
            $canMove = '';
            last;
        }
    }

    if ($canMove) {
        for my $prev (@rock) {
            delete $cave{$prev};
        }
        for my $curr (@newRock) {
            $cave{$curr} = '@';
        }
    }

    return ($canMove, $canMove ? \@newRock : \@rock);
}

sub settleRock {
    my @rock = @{shift @_};
    for my $rp (@rock) {
        my @xy = split /,/, $rp;
        $memoCaveMaxY = max $memoCaveMaxY, $xy[1];
        $cave{$rp} = '#';
    }
}

sub getCaveLine {
    my $y = shift @_;
    my $line = "";
    for (my $x = 0; $x < 7; $x++) {
        my $c = $cave{$x . "," . $y};
        if (!defined $c || $c eq '@') {
            $line .= '.';
        } elsif ($c eq '#') {
            $line .= '#';
        } else {
            die "invalid char: '$c'";
        }
    }
    return $line;
}

sub getCaveLineValue {
    my $lineStr = shift @_;
    my @line = split //, $lineStr;
    my $val = 0;
    for (my $x = 0; $x < 7; $x++) {
        my $c = $line[$x];
        if ($c eq '#') {
            $val += 2 ** $x;
        }
    }
    return $val;
}

my $chunkSize = 1000;
sub encodeCaveChunk {
    my $atY = shift @_;
    my $caveLineValues = '';
    for (my $y = $atY; $y > $atY - $chunkSize; $y--) {
        $caveLineValues .= " " . (getCaveLineValue getCaveLine $y);
    }
    return $caveLineValues;
}


my $currentRock = createNewRock $rocks[0];
my $rockCount = 1;
my $rockIndex = 1;
my $jetstreamIndex = 0;

my $max1 = 2023;
my $max2 = 1000000000000;

my %memoCaveChunk = ();

my $virtualRockCount = 0;
my $virtualHeight = 0;

my $emitPart1 = 0;
my $emitPart2 = 0;

while (1) {
    if ($emitPart1 && $emitPart2) {
        last;
    }

    my $prevMemoCaveMaxY = $memoCaveMaxY;

    # jetstream push
    my $push = $jetstream[$jetstreamIndex];
    $jetstreamIndex = ($jetstreamIndex + 1) % ($#jetstream + 1);
    if (!($push eq '>' || $push eq '<')) {
        die "invalid jetstream: '$push'";
    }
    my ($ok, $newRock) = moveRock $currentRock, $push eq '<' ? -1 : +1, 0;
    $currentRock = $newRock;

    # fall down
    ($ok, $newRock) = moveRock $currentRock, 0, 1;
    $currentRock = $newRock;

    # if fall down failed, settle
    if (!$ok) {
        if ($rockCount == $max1) {
            # Part 1
            say $memoCaveMaxY;
            $emitPart1 = 1;
        }
        if ($virtualRockCount == $max2 + 1) {
            # Part 2
            say $virtualHeight;
            $emitPart2 = 1;
        }

        if ($memoCaveMaxY > $chunkSize) {
            my $ec = encodeCaveChunk $memoCaveMaxY;
            if (!defined $memoCaveChunk{$ec}) {
                $memoCaveChunk{$ec} = [$rockCount, $memoCaveMaxY];
            } else {
                if ($virtualRockCount == 0) {
                    my @eec = @{$memoCaveChunk{$ec}};
                    my $rockDiff = $rockCount - $eec[0];
                    my $heightDiff = $memoCaveMaxY - $eec[1];
                    # say "Got a repeated chunk at $rockCount rocks and $memoCaveMaxY height.";
                    # say "Previously seen at $eec[0] rocks and $eec[1] height.";
                    # say "Difference is $rockDiff in rock count and $heightDiff in height.";

                    my $existingChunkCount = (sprintf "%d", ($rockCount / $rockDiff));
                    my $skipChunkCount = (sprintf "%d", ($max2 / $rockDiff)) - $existingChunkCount - 1;

                    $virtualRockCount = $rockCount + $skipChunkCount * $rockDiff;
                    $virtualHeight = $prevMemoCaveMaxY + $skipChunkCount * $heightDiff;
                    # say "Skipping $skipChunkCount repeats, we are now at rock count $virtualRockCount and height $virtualHeight.";
                }
            }
        }

        settleRock $currentRock;
        $currentRock = createNewRock $rocks[$rockIndex];
        $rockCount++;
        $rockIndex = ($rockIndex + 1) % ($#rocks + 1);

        if ($virtualRockCount > 0) {
            $virtualRockCount++;
            $virtualHeight += ($memoCaveMaxY - $prevMemoCaveMaxY);
        }
    }

    # printCave;
}
# printCave;
