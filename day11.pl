use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

open(my $file, "<", "input/day11.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;

sub newMonkey {
    my ($id) = @_;
    return bless {
        id => $id,
        items => [],
        operation => "",
        divisor => "",
        trueThrow => "",
        falseThrow => "",
        inspections => 0
    }, "Monkey";
}

sub Monkey::addItem {
    my ($self, $item) = @_;
    my $items = $self->{items};
    push(@$items, $item);
}

sub Monkey::removeItem {
    my ($self, $itemToRemove) = @_;
    my $items = $self->{items};
    my $i = 0;
    foreach my $item (@$items) {
        if ($item == $itemToRemove) {
            splice(@$items, $i, 1);
            last;
        }
        $i++;
    }
}

sub Monkey::evalItemOp {
    my ($self, $old) = @_;
    return eval $self->{operation};
}

sub Monkey::toString {
    my ($self) = @_;
    return sprintf(
        "Monkey %d [%s], op: '%s', div: % 3d, tt: %d, ft: %d",
        $self->{id},
        join(', ', @{$self->{items}}),
        $self->{operation},
        $self->{divisor},
        $self->{trueThrow},
        $self->{falseThrow}
    );
}

my @monkeys = ();
my $currentMonkey;
my $commonDivisor = 1;
foreach my $line (@lines) {
    if ($line =~ /^Monkey (\d+):$/) {
        $currentMonkey = newMonkey($1);
    } elsif ($line =~ /^\s*Starting items: ([\d, ]+)$/) {
        for my $item (split(/, /, $1)) {
            $currentMonkey->addItem($item);
        }
    } elsif ($line =~ /^\s*Operation: new = (.+)$/) {
        $currentMonkey->{operation} = $1 =~ s/old/\$old/rg;
    } elsif ($line =~ /^\s*Test: divisible by (\d+)$/) {
        $currentMonkey->{divisor} = $1;
        $commonDivisor *= $1;
    } elsif ($line =~ /^\s*If true: throw to monkey (\d+)$/) {
        $currentMonkey->{trueThrow} = $1;
    } elsif ($line =~ /^\s*If false: throw to monkey (\d+)$/) {
        $currentMonkey->{falseThrow} = $1;
    } elsif ($line =~ /^\s*$/) {
        push(@monkeys, $currentMonkey);
    } else {
        die "failed to parse input.";
    }
}
push(@monkeys, $currentMonkey); # 🐒

# foreach my $monkey (@monkeys) {
#     say $monkey->toString;
# }

my $rounds = 10_000;
foreach my $round (1 .. $rounds) {
    foreach my $monkey (@monkeys) {
        while ($#{$monkey->{items}} >= 0) {
            $monkey->{inspections}++;
            my $item = $monkey->{items}[0];
            $monkey->removeItem($item);
            my $newItem = $monkey->evalItemOp($item);

            # for part 1:
            # $newItem = sprintf("%d", $newItem / 3);

            # for part 2:
            $newItem = $newItem % $commonDivisor;

            my $throwTo = $newItem % $monkey->{divisor} == 0 ? $monkey->{trueThrow} : $monkey->{falseThrow};
            $monkeys[$throwTo]->addItem($newItem);
        }
    }

    if ($round == 20) {
        # for part 1:
        # last;
    }

    if ($round % 100 == 0) {
        printf "% 3d%%\n", $round / 100;
    }

    # say "Round $round";
    # foreach my $monkey (@monkeys) {
    #     say $monkey->toString;
    # }
    # say "";
}

# Part 1 / 2
# For switching between part 1 and 2, see comments above.
my @insp = sort({$b <=> $a} map({ $_->{inspections} } @monkeys));
say join(', ', @insp);
say $insp[0] * $insp[1];
