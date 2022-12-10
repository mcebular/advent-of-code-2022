use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

open(my $file, "<", "input/day10.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;


my $cycle = 1;
my $register = 1;

my $signalSum = 0;

my @crt = ();

sub checkSignalStrength {
    if ($cycle == 20 || ($cycle - 20) % 40 == 0) {
        # say $cycle . " * " . $register . " = " . $cycle * $register;
        $signalSum += $cycle * $register;
    }
}

sub drawOnCrt {
    my $drawPtr = ($cycle - 1) % 40;
    push(@crt, abs($register - $drawPtr) <= 1 ? '#' : '.');
    # printf "Start cycle %3d: begin executing %s\n", $cycle, $lines[$drawPtr];
    # printf "During cycle %2d: CRT draws pixel in position %d\n", $cycle, $drawPtr;
    # printf "Current CRT row: ";
    # say @crt;
    # printf "Sprite position: %d", $register;
    # printf "\n\n";
}

foreach my $line (@lines) {
    my $instr = substr($line, 0, 4);

    if ($instr eq "noop") {
        checkSignalStrength;
        drawOnCrt;
        $cycle++;

    } elsif ($instr eq "addx") {
        $line =~ /\w{4} (-?\d+)/;
        my $instrValue = $1;
        for (my $i = 0; $i < 2; $i++) {
            checkSignalStrength;
            drawOnCrt;
            $cycle++;
        }
        $register += $instrValue;

    } else {
        die "Invalid instruction";
    }
}


# Part 1
say $signalSum;

# Part 2
for (my $i = 0; $i <= $#crt; $i++) {
    if ($i % 40 == 0) {
        print "\n";
    }
    print $crt[$i];
}
print "\n";