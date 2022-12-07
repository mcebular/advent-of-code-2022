use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

open(my $file, "<", "input/day07.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;

my @currentPath = ("");
my %filesystem = ();
my %filesystemDirs = ();

foreach my $line (@lines) {
    my $path = join("/", @currentPath);
    if ($line =~ /\$ cd (.*)/) {
        # say "Moving to directory '$1'";
        if ($1 eq "/") {
            @currentPath = ("");
        } elsif ($1 eq "..") {
            if ($#currentPath > 0) {
                pop(@currentPath);
            }
        } else {
            push(@currentPath, $1);
        }
    } elsif ($line =~ /\$ ls/) {
        # say "Listing directory '$path'";
    } elsif ($line =~ /dir (.*)/) {
        # say "Directory called '$path/$1'";
        $filesystem{"$path/$1/"} = -1;
        $filesystemDirs{"$path/$1/"} = 1;
    } elsif ($line =~ /([\d]+) (.*)/) {
        # say "File called '$path/$2' of size $1";
        $filesystem{"$path/$2"} = $1;
    } else {
        die "Failed to parse input: $line";
    }
}

sub calc_size {
    my ($path) = @_;
    if ($filesystem{$path} == -1) {
        # is a dir, size is sum of all children
        my $totalSize = 0;
        for my $fsk (keys %filesystem) {
            if ($fsk =~ /^$path(.+)/) {
                if ($1 =~ /.+\/.+/) {
                    # skip sub-dirs, will sum them recursively
                    next;
                }
                $totalSize += calc_size("$fsk");
            }
        }
        $filesystem{$path} = $totalSize;
        return $totalSize;
    } else {
        return $filesystem{$path};
    }
}

$filesystem{"/"} = -1;
$filesystemDirs{"/"} = 1;
calc_size '/';

sub print_filesystem {
    for my $path (sort keys %filesystem) {
        my $size = $filesystem{$path};
        my $isDir = exists($filesystemDirs{$path});
        printf("% 1s% 10d %s\n", $isDir ? 'd' : '', $size, $path);
    }
}
# print_filesystem

# Part 1
my $part1 = 0;
for my $dir (sort keys %filesystemDirs) {
    my $size = $filesystem{$dir};
    if ($size <= 100000) {
        $part1 += $size;
    }
}
say $part1;

# Part 2
my $totalSpace = 70000000;
my $requiredSpace = 30000000;
my $freeSpace = $totalSpace - $filesystem{"/"};

my $minSize = $filesystem{"/"};
for my $dir (sort keys %filesystemDirs) {
    my $size = $filesystem{$dir};
    my $spaceAfterDelete = $freeSpace + $size;
    if ($spaceAfterDelete > $requiredSpace && $size < $minSize) {
        $minSize = $size;
    }
}
say $minSize;
