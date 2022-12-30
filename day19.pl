use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

use List::Util 'max';


open(my $file, "<", "input/day19.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;


sub type2index {
    my $type = shift @_;
    if ($type eq 'ore') {
        return 0;
    } elsif ($type eq 'clay') {
        return 1;
    } elsif ($type eq 'obsidian') {
        return 2;
    } elsif ($type eq 'geode') {
        return 3;
    } else {
        die "Invalid type: '$type'";
    }
}

sub RobotSpec::new {
    my $class = shift @_;
    my $type = shift @_;
    my @cost = @{shift @_};

    if (scalar @cost != 4) {
        die 'invalid cost array';
    }

    return bless {
        type => $type,
        cost => \@cost,
    }, $class;
}

sub RobotSpec::str {
    my $self = shift @_;
    return sprintf "RobotSpec[type=%s, cost=(%d %d %d %d)]",
        $self->{type},
        $self->{cost}->[0],
        $self->{cost}->[1],
        $self->{cost}->[2],
        $self->{cost}->[3];
}

sub Blueprint::new {
    my $class = shift @_;
    my $id = shift @_;
    my @specs = @{shift @_};

    if (scalar @specs != 4) {
        die 'invalid specs array'
    }

    return bless {
        id => $id,
        specs => \@specs,
        maxResource => [
            max(map { $_->{cost}->[0] } @specs),
            max(map { $_->{cost}->[1] } @specs),
            max(map { $_->{cost}->[2] } @specs),
            max(map { $_->{cost}->[3] } @specs),
        ]
    }, $class;
}

sub Blueprint::str {
    my $self = shift @_;
    return sprintf "Blueprint[id=%d, specs=(%s, %s, %s, %s)]",
        $self->{id},
        $self->{specs}->[0]->str,
        $self->{specs}->[1]->str,
        $self->{specs}->[2]->str,
        $self->{specs}->[3]->str;
}

sub parseBlueprints {
    my %blueprints = ();
    foreach my $line (@lines) {
        if($line =~ /Blueprint (\d+): (.*)/) {
            my $blueprintId = $1;
            my @robots = (undef, undef, undef, undef);
            foreach my $robot (split /\. /, $2) {
                if($robot =~ /Each (\w+) robot costs (\d+) ore( and (\d+) (\w+))?/) {
                    my @cost = (0, 0, 0, 0);
                    $cost[0] = $2;
                    if (defined $3) {
                        $cost[type2index($5)] = $4;
                    }
                    my $spec = RobotSpec->new(type2index($1), \@cost);
                    $robots[type2index($1)] = $spec;
                } else {
                    die $robot;
                }
            }
            $blueprints{$blueprintId} = Blueprint->new($blueprintId, \@robots);
        } else {
            die;
        }
    }
    return %blueprints;
}

sub findBestBuildOrder {

    sub State::new {
        my $class = shift @_;
        my $time = shift @_;
        my @resources = @{shift @_};
        my @robots = @{shift @_};
        my $builtRobot = shift @_;

        if (scalar @resources != 4) {
            die 'invalid resources array'
        }

        if (scalar @robots != 4) {
            die 'invalid robots array'
        }

        return bless {
            time => $time,
            resources => \@resources,
            robots => \@robots,
            builtRobot => $builtRobot
        }, $class;
    }

    sub State::str {
        my $self = shift @_;
        return sprintf "[t=%2d, res=(%2d, %2d, %2d, %2d), rob=(%2d, %2d, %2d, %2d), br=%s]",
        $self->{time},
        $self->{resources}->[0],
        $self->{resources}->[1],
        $self->{resources}->[2],
        $self->{resources}->[3],
        $self->{robots}->[0],
        $self->{robots}->[1],
        $self->{robots}->[2],
        $self->{robots}->[3],
        $self->{builtRobot};
    }

    sub State::encode {
        my $self = shift @_;
        return sprintf "%d %d %d %d %d %d %d %d %d %d",
        $self->{time},
        $self->{resources}->[0],
        $self->{resources}->[1],
        $self->{resources}->[2],
        $self->{resources}->[3],
        $self->{robots}->[0],
        $self->{robots}->[1],
        $self->{robots}->[2],
        $self->{robots}->[3],
        $self->{builtRobot};
    }

    sub State::clone {
        my $self = shift @_;
        return State->new(
            $self->{time},
            \@{$self->{resources}},
            \@{$self->{robots}},
            $self->{builtRobot}
        );
    }

    {
        my $testState = State->new(44, [3, 0, 15, 7], [1, 6, 4, 0], 0);
        my $clonedState = $testState->clone;
        $clonedState->{robots}->[4] = 2;
        $clonedState->step;
        assert $testState->{time}, 44;
        assert $testState->{robots}->[4], 0;
        assert $clonedState->{time}, 45;
        assert $clonedState->{robots}->[4], 2;
    }

    sub State::step {
        my $self = shift @_;
        $self->{time}++;
        for (my $i = 0; $i < 4; $i++) {
            $self->{resources}->[$i] += $self->{robots}->[$i];
        }
        $self->{builtRobot} = 0;
    }

    {
        my $testState = State->new(0, [3, 0, 15, 7], [1, 6, 4, 0], 0);
        $testState->step;
        assert $testState->{resources}->[0], 4;
        assert $testState->{resources}->[1], 6;
        assert $testState->{resources}->[2], 19;
        assert $testState->{resources}->[3], 7;
    }

    sub State::hasEnoughResourcesForRobot {
        my $self = shift @_;
        my $robotSpec = shift @_;

        for (my $i = 0; $i < 4; $i++) {
            my $cost = $robotSpec->{cost}->[$i];
            my $available = $self->{resources}->[$i];
            if ($cost > $available) {
                return '';
            }
        }

        return 1;
    }

    {
        my $spec1 = RobotSpec->new('ore', [2, 0, 0, 0]);
        my $spec2 = RobotSpec->new('geode', [2, 0, 6, 0]);
        my $state = State->new(0, [2, 0, 5, 0], [1, 0, 7, 0], 0);
        assertTrue $state->hasEnoughResourcesForRobot($spec1);
        assertFalse $state->hasEnoughResourcesForRobot($spec2);
    }

    sub State::buildRobot {
        my $self = shift @_;
        my $robotSpec = shift @_;

        if (!$self->hasEnoughResourcesForRobot($robotSpec) || $self->{builtRobot}) {
            die 'invalid call to buildRobot: ' . $self->str;
        }

        for (my $i = 0; $i < 4; $i++) {
            my $cost = $robotSpec->{cost}->[$i];
            $self->{resources}->[$i] -= $cost;
        }

        $self->{robots}->[$robotSpec->{type}] += 1;
        $self->{builtRobot} = 1;
    }

    {
        my $spec1 = RobotSpec->new(0, [3, 0, 0, 0]);
        my $state = State->new(0, [4, 0, 0, 0], [2, 0, 0, 0], 0);
        $state->buildRobot($spec1);
        assert $state->{resources}->[0], 1;
        assert $state->{robots}->[0], 3;
        assert $state->{builtRobot}, 1;
    }

    sub nextStates {
        my $blueprint = shift @_;
        my $curr = shift @_;
        my $prev = shift @_;
        my @nexts = ();

        for (my $i = 3; $i >= 0; $i--) {
            my $spec = $blueprint->{specs}->[$i];
            if ($curr->{builtRobot} == 0 && $prev->hasEnoughResourcesForRobot($spec)) {
                # If we could built a robot in the previous round but we didn't,
                # don't build it now either.
                next;
            }

            if ($i != type2index('geode') && $curr->{robots}->[$i] >= $blueprint->{maxResource}->[$i]) {
                # We don't need more robots than maximum resource required for building any of the robots.
                # (unless it's a geode robot - we want as many of those as possible)
                next;
            }

            if ($curr->hasEnoughResourcesForRobot($spec)) {
                my $next = $curr->clone;
                $next->step;
                $next->buildRobot($spec);
                push(@nexts, $next);

                if ($i == type2index('geode')) {
                    # We don't care about other branches if we can build a geode robot.
                    return [$next];
                }
            }
        }


        my $next = $curr->clone;
        $next->step;
        push (@nexts, $next);

        return \@nexts;
    }

    my $blueprint = shift @_;
    my $maxTime = shift @_;

    my $start = State->new(0, [0, 0, 0, 0], [1, 0, 0, 0], 0);

    my @frontier = ();
    push(@frontier, $start);
    my %cameFrom = ();
    $cameFrom{$start->encode} = State->new(0, [0, 0, 0, 0], [0, 0, 0, 0], 0);

    my $bestState = $start;
    while (scalar @frontier > 0) {
        my $curr = pop @frontier;
        my $prev = $cameFrom{$curr->encode};
        # say $curr->str;

        if ($curr->{resources}->[3] > $bestState->{resources}->[3]) {
            $bestState = $curr;
        }

        if ($curr->{time} >= $maxTime) {
            next;
        }

        foreach my $next (@{nextStates $blueprint, $curr, $prev}) {
            if (!defined $cameFrom{$next->encode}) {
                push(@frontier, $next);
                $cameFrom{$next->encode} = $curr;
            }
        }
    }

    return $bestState;
}

my %blueprints = parseBlueprints;
# say $blueprints{"1"}->str;

sub part1 {
    my $qlSum = 0;
    for my $blueprintId (sort {$a <=> $b} keys %blueprints) {
        my $blueprint = $blueprints{$blueprintId};
        my $s = findBestBuildOrder($blueprint, 24);
        my $qualityLevel = $blueprint->{id} * $s->{resources}->[3];
        # say $blueprint->{id} . ": " . $qualityLevel;
        $qlSum += $qualityLevel;
    }
    say $qlSum;
}

sub part2 {
    my $r1 = findBestBuildOrder($blueprints{1}, 32);
    # say $r1->str;
    my $r2 = findBestBuildOrder($blueprints{2}, 32);
    # say $r2->str;
    my $r3 = findBestBuildOrder($blueprints{3}, 32);
    # say $r3->str;
    say $r1->{resources}->[3] * $r2->{resources}->[3] * $r3->{resources}->[3];
}

# Part 1
part1;

# Part 2
part2;