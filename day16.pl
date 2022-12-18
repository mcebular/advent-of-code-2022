use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

use Algorithm::Combinatorics "subsets";
use List::Util 'max';


open(my $file, "<", "input/day16.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;

sub parseValve {
    my ($line) = @_;
    $line =~ /^Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z ,]+)$/;
    my ($name, $flow, $links) = ($1, $2, $3);
    return bless {
        name => $name,
        flow => $flow,
        links => [split(/, /, $links)],
    }, "Valve";
}

sub Valve::name {
    my $self = shift @_;
    return $self->{name};
}

sub Valve::flow {
    my $self = shift @_;
    return $self->{flow};
}

sub Valve::links {
    my $self = shift @_;
    return $self->{links};
}

sub Valve::str {
    my $self = shift @_;
    return sprintf "Valve %s has flow rate=%d; tunnels lead to valves %s", $self->name, $self->flow, join(', ', @{$self->links});
}


my %valves = ();
foreach my $line (@lines) {
    my $v = parseValve($line);
    $valves{$v->name} = $v;
    # say $v->str;
}

sub shortestPathBetweenValves {
    my ($v1, $v2) = @_;
    my @frontier = ();
    push(@frontier, $v1->name);
    my %reached = ();
    $reached{$v1->name} = 0;
    while (scalar @frontier > 0) {
        my $current = $valves{shift @frontier};
        foreach my $next (@{$current->links}) {
            if (!exists $reached{$next}) {
                push(@frontier, $next);
                $reached{$next} = $reached{$current->name} + 1;
            }
        }
    }

    return $reached{$v2->name};
}

# Calculate shortest paths between each valve pairs.
my %valveTimes = ();
foreach my $v1 (values %valves) {
    foreach my $v2 (values %valves) {
        $valveTimes{$v1->name . " to " . $v2->name} = shortestPathBetweenValves($v1, $v2);
    }
}

my %workingValves = ();
foreach my $valve (values %valves) {
    if ($valve->flow > 0) {
        $workingValves{$valve->name} = $valve;
    }
}

sub newState {
    my ($time, $valve, $openValves) = @_;
    return bless {
        time => $time,
        valve => $valve,
        openValves => $openValves,
    }, "State";
}

sub State::time {
    return (shift @_)->{time};
}

sub State::valve {
    return (shift @_)->{valve};
}

sub State::openValves {
    return (shift @_)->{openValves};
}

sub State::isOpenValve {
    my $self = shift @_;
    my $valve = shift @_;
    foreach my $v (@{$self->openValves}) {
        if ($v eq $valve) {
            return 1;
        }
    }
    return "";
}

sub State::additionalPressure {
    my $self = shift @_;
    my $additionalPressure = 0;
    foreach my $v (@{$self->openValves}) {
        $additionalPressure += $valves{$v}->flow;
    }
    return $additionalPressure;
}

sub State::key {
    my $self = shift @_;
    return sprintf "[%s, %s, (%s)]", $self->time, $self->valve, join(', ', sort @{$self->openValves});
}

sub State::nexts {
    my $self = shift @_;
    my @valves = @{shift @_};

    my @openValves = @{$self->openValves};

    my @nexts = ();
    foreach my $valve (@valves) {
        if ($valve eq $self->valve || $self->isOpenValve($valve)) {
            next;
        }

        my $timeToValve = $valveTimes{$self->valve . " to " . $valve};
        $timeToValve++; # to open the valve

        my $timeSoFar = $self->time;

        my $next = newState(
            $timeSoFar + $timeToValve,
            $valve,
            [@{$self->openValves}, $valve],
        );

        push(@nexts, $next);
    }
    return @nexts;
}

my %valveToBitPosition = ();
for (my $i=0; $i < scalar keys %workingValves; $i++) {
    my @vs = sort keys %workingValves;
    my $v = $vs[$i];
    $valveToBitPosition{$v} = 1 << $i;
}

sub encodeValves {
    my $valves = shift @_;
    my $enc = 0;
    foreach my $v (split / /, $valves) {
        $enc |= $valveToBitPosition{$v};
    }
    return $enc;
}

my %memoBestPressureForSequence = ();

sub findBestValveSequence {
    my $maxTime = shift @_;
    my @valves = @{shift @_};

    if ($maxTime == 26) {
        my $testMemoKey = encodeValves join ' ', sort @valves;
        foreach my $existingMemoKey (keys %memoBestPressureForSequence) {
            if (($existingMemoKey & $testMemoKey) == $existingMemoKey) {
                return $memoBestPressureForSequence{$existingMemoKey};
            }
        }
    }

    my $start = newState(0, "AA", []);
    # say $start->key;

    my @frontier = ();
    push(@frontier, $start);
    my %reached = ();
    my %endings = ();
    $reached{$start->key} = 0;

    while (scalar @frontier > 0) {
        my $curr = pop @frontier;

        my $hasNexts = 0;
        foreach my $next ($curr->nexts(\@valves)) {
            if ($next->time >= $maxTime) {
                next;
            }
            $hasNexts = 1;

            my $pressureSoFar = $reached{$curr->key};

            my $timeDiff = $next->time - $curr->time;
            my $additionalPressure = $curr->additionalPressure * $timeDiff;

            my $exiReached = $reached{$next->key};
            my $newReached = $pressureSoFar + $additionalPressure;
            if (!defined $exiReached || $exiReached <= $newReached) {
                push(@frontier, $next);
                $reached{$next->key} = $pressureSoFar + $additionalPressure;
            }
        }

        if (!$hasNexts) {
            $endings{$curr->key} = $curr;
        }
    }

    my $bestState = undef;
    my $bestPressure = 0;
    foreach my $s (values %endings) {
        if (!defined $s || $s eq '') {
            next;
        }

        my $timeDiff = $maxTime - $s->time;
        my $additionalPressure = $s->additionalPressure * $timeDiff;

        my $totalPressure = $reached{$s->key} + $additionalPressure;
        if ($totalPressure > $bestPressure) {
            $bestPressure = $totalPressure;
            $bestState = $s;
        }
    }

    if ($maxTime == 26) {
        my $memoKey = encodeValves join ' ', sort @{$bestState->openValves};
        $memoBestPressureForSequence{$memoKey} = [$bestPressure, $bestState];
    }

    return ($bestPressure, $bestState);
}

sub part1 {
    my @valves = keys %workingValves;
    my ($pressure, $state) = findBestValveSequence(30, \@valves);
    say $pressure;
}

sub part2 {
    my @allValves = sort keys %workingValves;
    my $iter = subsets(\@allValves);
    my $steps = 0;
    while (my $valveSubset = $iter->next) {
        if (scalar @$valveSubset == 0) {
            next;
        }
        # This can take a minute or two... to print progress:
        # printf "% 3.3f %%\n", (($steps++ / (2 ** scalar @allValves)) * 100);

        my ($pressure, $state) = findBestValveSequence(26, $valveSubset);
    }

    my @possibles = sort keys %memoBestPressureForSequence;
    my $bestPressure = 0;
    for (my $i = 0; $i < scalar @possibles; $i++) {
        for (my $j = $i; $j < scalar @possibles; $j++) {
            # Had to add "+ 0" just so we're sure we're bitwising numbers and
            # not strings ... i.e. (29 & 54) != ("29" & "54")
            my $a = $possibles[$i] + 0;
            my $b = $possibles[$j] + 0;
            if (($a & $b) != 0) {
                next;
            }

            my ($pressureA) = @{$memoBestPressureForSequence{$a}};
            my ($pressureB) = @{$memoBestPressureForSequence{$b}};
            $bestPressure = max $bestPressure, $pressureA + $pressureB;
        }
    }
    say $bestPressure;
}

# Part 1
# takes about 15 seconds
part1;

# Part 2
# takes a minute or two
part2;
