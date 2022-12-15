use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

use List::Util 'max', 'min', 'sum';


open(my $file, "<", "input/day15.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;

sub newPos {
    my ($x, $y, $r) = @_;
    return bless {
        x => $x,
        y => $y,
        r => $r
    }, "Pos";
}

sub parsePos {
    my ($str) = @_;
    $str =~ /\[(-?\d+), (-?\d+), (-?\d+)\]/;
    return bless {
        x => $1,
        y => $2,
        r => $3
    }, "Pos";
}

sub Pos::str {
    my ($self) = @_;
    return sprintf "[$self->{x}, $self->{y}, $self->{r}]";
}

sub Pos::key {
    my ($self) = @_;
    return sprintf "[$self->{x}, $self->{y}]";
}

sub Pos::dist {
    my ($self, $other) = @_;
    return abs($self->{x} - $other->{x}) + abs($self->{y} - $other->{y});
}

sub newRange {
    my ($f, $t) = @_;
    if ($t < $f) {
        die "invalid range ($f -> $t)";
    }
    return bless {
        f => $f,
        t => $t,
    }, "Range";
}

sub Range::len {
    my ($self) = @_;
    return $self->{t} - $self->{f};
}

sub Range::str {
    my ($self) = @_;
    return sprintf "[$self->{f}, $self->{t}]";
}

assert newRange(5, 10)->len, 5;
assert newRange(-4, -3)->len, 1;
assert newRange(3, 3)->len, 0;
assert newRange( -1095773, 1649961 )->len, 2745734;

my %map = ();
my @sensors = ();
my %beacons = ();
foreach my $line (@lines) {
    $line =~ /Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/;
    my ($sx, $sy, $bx, $by) = ($1, $2, $3, $4);
    my $b = newPos($bx, $by, 0);
    my $s = newPos($sx, $sy, -1);
    $s->{r} = $s->dist($b);

    $map{$s->key} = 'S';
    push(@sensors, $s);
    $map{$b->key} = 'B';
    $beacons{$b->key} = $b;
}

@sensors = sort({$a->{x} <=> $b->{x}} @sensors);
my @beacons = sort({$a->{x} <=> $b->{x}} values %beacons);

sub Pos::reachesY {
    # returns range (from, to) where this position can reach given Y.
    my ($self, $y) = @_;
    my $distToY = $self->dist(newPos($self->{x}, $y));
    if ($distToY > $self->{r}) {
        return newRange(0, 0);
    }

    my $minx = $self->{x} - ($self->{r} - $distToY);
    my $maxx = $self->{x} + ($self->{r} - $distToY);
    return newRange($minx, $maxx);
}

my $r = newPos(0, 11, 3)->reachesY(10);
assert $r->{f}, -2;
assert $r->{t}, 2;

sub mergeRanges {
    my @ranges = @_;
    @ranges = sort { $a->{f} <=> $b->{f} } @ranges;

    my @newRanges = ();
    my $currentRange = shift @ranges;
    foreach my $range (@ranges) {
        if ($currentRange->{t} >= $range->{f}) {
            if ($range->{t} > $currentRange->{t}) {
                $currentRange->{t} = $range->{t};
            }
        } else {
            push(@newRanges, $currentRange);
            $currentRange = $range;
        }
    }
    push(@newRanges, $currentRange);
    return @newRanges;
}

sub reachableRangesForY {
    my ($y) = @_;
    my @ranges = ();
    foreach my $sensor (@sensors) {
        my $range = $sensor->reachesY($y);
        if ($range->len > 0) {
            # printf "Sensor %s can reach %d (range: %s)\n", $sensor->str, $y, $range->str;
            push(@ranges, $range);
        }
    }

    return mergeRanges(@ranges);
}


# Part 1
my $y = 2000000;

my $yc = sum map {$_->len + 1} reachableRangesForY $y;
foreach my $beacon (@beacons) {
    if ($beacon->{y} == $y) {
        $yc--;
    }
}
say $yc;

# Part 2
my $maxy = 4000000;
for (my $y = 0; $y <= $maxy; $y+=1) {
    if ($y % 10000 == 0) {
        # This one takes a few minutes. For printing progress:
        # printf "% 3.2f %%\n", ($y / $maxy) * 100;
    }

    my @ranges = reachableRangesForY $y;
    my $rs = scalar @ranges;
    if ($rs > 2) {
        die "got more than two ranges: " . (scalar @ranges);
    } elsif ($rs == 1) {
        next;
    } else {
        my $left = $ranges[0];
        my $right = $ranges[1];
        if ($right->{f} - $left->{t} > 0) {
            my $p = newPos($left->{t} + 1, $y, 0);
            say $p->{x} * $maxy + $p->{y};
            last;
        }
    }
}