use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;


open(my $file, "<", "input/day20.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;

sub newNumber {
    my ($value, $index, $prev, $next) = @_;
    return bless {
        value => $value,
        index => $index,
        prev => $prev,
        next => $next
    }, "Number";
}

sub Number::str {
    my $self = shift @_;
    return $self->{value};
}

sub Number::next {
    my $self = shift @_;
    my $count = shift @_;

    if ($count < 0) {
        # actually prev
        return $self->prev(-$count);
    }
    my $next = $self;
    for (my $i = 0; $i < $count; $i++) {
        $next = $next->{next};
    }
    return $next;
}

sub Number::prev {
    my $self = shift @_;
    my $count = shift @_;

    my $prev = $self;
    for (my $i = 0; $i <= $count; $i++) {
        $prev = $prev->{prev};
    }
    return $prev;
}

# For part 1, set to 1.
my $multiplier = 811589153;
# For part 1, set to 1.
my $iters = 10;

my $start = undef;
my $zero = undef;
my $prev = undef;
my $count = 0;
foreach my $line (@lines) {
    my $curr = newNumber($line * $multiplier, $count++);
    if (!defined $start) {
        $start = $curr;
    }
    if (defined $prev) {
        $prev->{next} = $curr;
        $curr->{prev} = $prev;
    }
    if ($curr->{value} == 0) {
        $zero = $curr;
    }
    $prev = $curr;
}
$prev->{next} = $start;
$start->{prev} = $prev;

sub printNumbers {
    my $start = shift @_;
    my $curr = $start;
    do {
        printf "%d ", $curr->{value};
        $curr = $curr->{next};
    } while ($curr->{value} != $start->{value});
    printf "\n";
}

sub moveNumbers {
    my $start = shift @_;

    for (my $i = 0; $i < $count; $i++) {
        my $curr = $start;
        while ($curr->{next}->{index} != $i) {
            $curr = $curr->{next};
        }

        my $S1 = $curr;
        my $X = $S1->{next};
        # say "Moving " . $X->{value};
        if ($X->{value} != 0) {
            my $E1 = $X->{next};
            my $S2 = $X->next($X->{value} % ($count - 1));
            my $E2 = $S2->{next};

            $S1->{next} = $E1;
            $E1->{prev} = $S1;

            $S2->{next} = $X;
            $X->{prev} = $S2;
            $X->{next} = $E2;
            $E2->{prev} = $X;
        }

        # printNumbers $zero;
    }
}

for (my $i = 0; $i < $iters; $i++) {
    moveNumbers $zero;
    # say "Iter " . $i;
}

# See $multiplier and $iters for Part 1/2.
say $zero->next(1000)->{value} + $zero->next(2000)->{value} + $zero->next(3000)->{value};
