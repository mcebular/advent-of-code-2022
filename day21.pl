use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;


open(my $file, "<", "input/day21.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;


sub parseMonkeys {
    my %monkeyDeps = ();
    my %monkeyNums = ();
    foreach my $line (@lines) {
        if ($line =~ /(\w+): (\w+) ([\+\-\*\/]{1}) (\w+)/) {
            $monkeyDeps{$1} = [$2, $4, $3];
        } elsif ($line =~ /(\w+): (\d+)/) {
            $monkeyNums{$1} = $2;
        } else {
            die 'parse failed';
        }
    }

    return (\%monkeyDeps, \%monkeyNums);
}

sub part1 {
    my ($md, $mn) = parseMonkeys;
    my %monkeyDeps = %{$md};
    my %monkeyNums = %{$mn};

    my @frontier = ();
    push(@frontier, 'root');
    while (scalar @frontier > 0) {
        my $curr = pop @frontier;
        # say $curr;

        if (defined $monkeyDeps{$curr}) {
            my @m = @{$monkeyDeps{$curr}};
            my $dm1 = $m[0];
            my $dm2 = $m[1];
            if (defined $monkeyNums{$dm1} && defined $monkeyNums{$dm2}) {
                my $n1 = $monkeyNums{$dm1};
                my $n2 = $monkeyNums{$dm2};
                my $op = $m[2];
                $monkeyNums{$curr} = eval "$n1 $op $n2";
            } else {
                push(@frontier, $curr);
                push(@frontier, $dm1);
                push(@frontier, $dm2);
            }
        } elsif (defined $monkeyNums{$curr}) {
            my $num = $monkeyNums{$curr};
            next;
        } else {
            die 'undefined monkey';
        }
    }

    say $monkeyNums{'root'};
}

sub part2 {
    my ($md, $mn) = parseMonkeys;
    my %monkeyDeps = %{$md};
    my %monkeyNums = %{$mn};

    my @frontier = ();
    push(@frontier, 'root');

    delete $monkeyNums{'humn'};
    my %monkeyForm = ();
    $monkeyForm{'humn'} = '?';
    @{$monkeyDeps{'root'}}[2] = "=";

    while (scalar @frontier > 0) {
        my $curr = pop @frontier;
        # say $curr;

        if (defined $monkeyDeps{$curr}) {
            my @m = @{$monkeyDeps{$curr}};
            my $dm1 = $m[0];
            my $dm2 = $m[1];
            my $op = $m[2];

            my $left;
            my $leftIsNum = 0;
            my $right;
            my $rightIsNum = 0;

            if (defined $monkeyNums{$dm1}) {
                $left = $monkeyNums{$dm1};
                $leftIsNum = 1;
            } elsif (defined $monkeyForm{$dm1}) {
                $left = $monkeyForm{$dm1};
            } else {
                push(@frontier, $curr);
                push(@frontier, $dm1);
                next;
            }

            if (defined $monkeyNums{$dm2}) {
                $right = $monkeyNums{$dm2};
                $rightIsNum = 1;
            } elsif (defined $monkeyForm{$dm2}) {
                $right = $monkeyForm{$dm2};
            } else {
                push(@frontier, $curr);
                push(@frontier, $dm2);
                next;
            }

            if ($leftIsNum && $rightIsNum && $op ne '=') {
                $monkeyNums{$curr} = eval "$left $op $right";
            } else {
                $monkeyForm{$curr} = "($left $op $right)";
            }
        }
    }

    my $f = $monkeyForm{'root'};
    my $other;

    if ($f =~ /^\((.*) = (\d+)\)$/) {
        $other = $2;
        $f = $1;
    } else {
        die 'invalid equation';
    }

    sub inverseOp {
        my $op = shift @_;
        if ($op eq '+') { return '-' }
        elsif ($op eq '-') { return '+' }
        elsif ($op eq '*') { return '/' }
        elsif ($op eq '/') { return '*' }
        else { die 'invalid op' };
    }

    while (1) {
        if ($f =~ /^\((.*) ([\+\-\*\/]) (\d+)\)$/) {
            my $op = inverseOp($2);
            $other = eval "$other $op $3";
            $f = $1;
        } elsif ($f =~ /^\((\d+) ([\+\-\*\/]) (.*)\)$/) {
            if ($2 eq '-') {
                $other = eval "-($other - $1)";
            } else {
                my $op = inverseOp($2);
                $other = eval "$other $op $1";
            }
            $f = $3;
        } else {
            last;
        }
    }

    say $other;
}


# Part 1
part1;

# Part 2
part2;