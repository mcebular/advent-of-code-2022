use strict;
use warnings;

use feature 'say';

use List::Util 'max', 'sum';
use String::Util 'trim';

open(my $file, "<", "input/day01.txt") or die "Can't open input file";

my @totalCalories = ();
my $elfIndex = 0;

while (my $line = <$file>) {
    my $val = trim($line);
    # say $val;
    if ($val eq "") {
        $elfIndex++;
        $totalCalories[$elfIndex] = 0;
        next;
    }
    $totalCalories[$elfIndex] += $line;
}

close $file;

@totalCalories = sort(@totalCalories);

# Part 1
say $totalCalories[-1];

# Part 2
say sum(@totalCalories[-3..-1]);
