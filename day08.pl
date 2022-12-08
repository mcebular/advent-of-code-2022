use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

open(my $file, "<", "input/day08.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;

my %trees = ();
my $maxi = 0;
my $maxj = 0;
for (my $i = 0; $i <= $#lines; $i++) {
    $maxi = $i;
    my @line = split(//, $lines[$i]);
    for (my $j = 0; $j <= $#line; $j++) {
        $maxj = $j;
        my $height = $line[$j];
        $trees{"$i,$j"} = $height;
    }
}

sub printForest {
    say $maxi;
    say $maxj;
    for (my $i = 0; $i <= $maxi; $i++) {
        for (my $j = 0; $j <= $maxj; $j++) {
            my $height = $trees{"$i,$j"};
            print("$height");
        }
        print("\n");
    }
    print("\n");
}
# printForest;

sub isVisibleFromEdge {
    my ($i, $j) = @_;
    my $tree = $trees{"$i,$j"};
    if ($i == 0 || $j == 0 || $i == $maxi || $j == $maxj) {
        return 1;
    }

    my $visible = 4;
    for (my $ii = 0; $ii < $i; $ii++) {
        if ($trees{"$ii,$j"} >= $tree) {
            $visible--;
            last;
        }
    }
    for (my $ii = $maxi; $ii > $i; $ii--) {
        if ($trees{"$ii,$j"} >= $tree) {
            $visible--;
            last;
        }
    }
    for (my $jj = 0; $jj < $j; $jj++) {
        if ($trees{"$i,$jj"} >= $tree) {
            $visible--;
            last;
        }
    }
    for (my $jj = $maxj; $jj > $j; $jj--) {
        if ($trees{"$i,$jj"} >= $tree) {
            $visible--;
            last;
        }
    }
    return $visible;
}

sub scenicScore {
    my ($j, $i) = @_; # ah yes, mixed up coordinates
    my $tree = $trees{"$i,$j"};

    my @score = (0,0,0,0);
    for (my $ii = $i; $ii <= $maxi; $ii++) {
        if ($i == $ii) {
            next;
        }
        $score[0]++;
        if ($trees{"$ii,$j"} >= $tree) {
            last;
        }
    }
    for (my $ii = $i; $ii >= 0; $ii--) {
        if ($i == $ii) {
            next;
        }
        $score[1]++;
        if ($trees{"$ii,$j"} >= $tree) {
            last;
        }
    }
    for (my $jj = $j; $jj <= $maxj; $jj++) {
        if ($j == $jj) {
            next;
        }
        $score[2]++;
        if ($trees{"$i,$jj"} >= $tree) {
            last;
        }
    }
    for (my $jj = $j; $jj >= 0; $jj--) {
        if ($j == $jj) {
            next;
        }
        $score[3]++;
        if ($trees{"$i,$jj"} >= $tree) {
            last;
        }
    }

    return $score[0] * $score[1] * $score[2] * $score[3];
}

# Part 1
my $visibleCount = 0;
for (my $i = 0; $i <= $maxi; $i++) {
    for (my $j = 0; $j <= $maxj; $j++) {
        if (isVisibleFromEdge $i, $j) {
            $visibleCount++;
        }
    }
}
say $visibleCount;

# Part 2
my $highestScore = 0;
for (my $i = 0; $i <= $maxi; $i++) {
    for (my $j = 0; $j <= $maxj; $j++) {
        my $score = scenicScore($i, $j);
        if ($score > $highestScore) {
            $highestScore = $score;
        }
    }
}
say $highestScore;
