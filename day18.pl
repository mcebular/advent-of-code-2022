use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;


open(my $file, "<", "input/day18.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;


my %scan = ();
foreach my $line (@lines) {
    # say $line;
    $scan{$line} = 1;
}

sub adjacentPositions {
    my ($x, $y, $z) = split /,/, (shift @_);
    my @adjs = ();
    push(@adjs, sprintf("%d,%d,%d", $x-1, $y  , $z  ));
    push(@adjs, sprintf("%d,%d,%d", $x+1, $y  , $z  ));
    push(@adjs, sprintf("%d,%d,%d", $x  , $y-1, $z  ));
    push(@adjs, sprintf("%d,%d,%d", $x  , $y+1, $z  ));
    push(@adjs, sprintf("%d,%d,%d", $x  , $y  , $z-1));
    push(@adjs, sprintf("%d,%d,%d", $x  , $y  , $z+1));
    return @adjs;
}

sub adjacentPositions2 {
    my ($x, $y, $z) = split /,/, (shift @_);
    my @adjs = ();

    if ($x >= 0) {
        push(@adjs, sprintf("%d,%d,%d", $x-1, $y  , $z  ));
    }
    if ($x <= 20) {
        push(@adjs, sprintf("%d,%d,%d", $x+1, $y  , $z  ));
    }
    if ($y >= 0) {
        push(@adjs, sprintf("%d,%d,%d", $x  , $y-1, $z  ));
    }
    if ($y <= 20) {
        push(@adjs, sprintf("%d,%d,%d", $x  , $y+1, $z  ));
    }
    if ($z >= 0) {
        push(@adjs, sprintf("%d,%d,%d", $x  , $y  , $z-1));
    }
    if ($z <= 20) {
        push(@adjs, sprintf("%d,%d,%d", $x  , $y  , $z+1));
    }

    return @adjs;
}

no warnings 'recursion';
sub floodFill {
    my $pos = shift @_;
    if (defined $scan{$pos}) {
        return;
    }

    $scan{$pos} = 2;
    foreach my $adj (adjacentPositions2 $pos) {
        floodFill($adj);
    }
}

floodFill("0,0,0");

my $totalSides1 = 0;
my $totalSides2 = 0;
for (my $x = 0; $x < 20; $x++) {
    for (my $y = 0; $y < 20; $y++) {
        for (my $z = 0; $z < 20; $z++) {
            my $pos = "$x,$y,$z";
            my $sides1 = 0;
            my $sides2 = 0;
            if (defined $scan{$pos} && $scan{$pos} == 1) {
                # say "$x, $y, $z";
                $sides1 = 6;
                $sides2 = 6;

                foreach my $adj (adjacentPositions $pos) {
                    if ($adj eq "2,2,5") {
                        #say $scan{$adj};
                        #die;
                    }
                    if (defined $scan{$adj} && $scan{$adj} == 1) {
                        $sides1--;
                        $sides2--;
                    } elsif (!defined $scan{$adj}) {
                        $sides2--;
                    }
                }
            }
            $totalSides1 += $sides1;
            $totalSides2 += $sides2;
        }
    }
}

# Part 1
say $totalSides1;

# Part 2
say $totalSides2;
