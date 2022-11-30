use strict;
use warnings;

use feature 'say';

say "Hello, world!";

if ($#ARGV >= 0) {
    say "Also hello, $ARGV[0]!";
}
