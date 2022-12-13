use strict;
use warnings;

use feature 'say';

use lib './';
use assertions;

open(my $file, "<", "input/day13.txt") or die "Can't open input file";

my @lines = ();

while (my $line = <$file>) {
    chomp($line);
    push(@lines, $line);
}

close $file;

sub newPacket {
    my (@values) = @_;
    my $packet = bless {
        values => [],
    }, "Packet";
    my $values = $packet->{values};
    foreach my $v (@values) {
        push(@$values, $v);
    }
    return $packet;
}

sub parsePacket {
    my ($input) = @_;
    my @chars = split(//, $input);

    my $packet = bless {
        values => [],
    }, "Packet";
    my $values = $packet->{values};

    my $nestingLevel = 0;
    my $nestedPacketBegin = -1;
    my $number = "";
    for (my $i = 0; $i <= $#chars; $i++) {
        my $c = $chars[$i];

        if ($c =~ /\D/ && $number ne "") {
            push(@$values, $number);
            $number = "";
        }

        if ($i == 0 || $i == $#chars) {
            # skip starting and ending bracket
            next;
        }

        if ($c eq '[') {
            if ($nestingLevel == 0) {
                $nestedPacketBegin = $i;
            }
            $nestingLevel++;
            next;
        }

        if ($c eq ']') {
            $nestingLevel--;
            if ($nestingLevel < 0) {
                die "invalid nesting level (overclosed)";
            }
            if ($nestingLevel == 0) {
                my $nestedPacketEnd = $i;
                push(@$values, parsePacket(substr($input, $nestedPacketBegin, $nestedPacketEnd - $nestedPacketBegin + 1)));
                $nestedPacketBegin = -1;
            }
            next;
        }

        if ($nestedPacketBegin >= 0) {
            # run until end of nested packet
            next;
        }

        if ($c =~ /\d/) {
            $number .= $c;
            next;
        }

        if ($c eq ',') {
            next;
        }

        die "invalid character: '$c'";
    }

    if ($nestingLevel > 0) {
        die "invalid nesting level (remained open)";
    }

    return $packet;
}

assert parsePacket("[]")->length, 0;
assert parsePacket("[1,2]")->length, 2;
assert parsePacket("[15]")->get(0), 15;
assert parsePacket("[4,5,6]")->get(2), 6;
assert parsePacket("[[]]")->get(0)->length, 0;
assert parsePacket("[1,[2,[3],4]]")->get(0), 1;
assert parsePacket("[1,[2,[3],4]]")->get(1)->length, 3;
assert parsePacket("[1,[2,[3],4]]")->get(1)->get(2), 4;
assert parsePacket("[1,[2,[3],4]]")->get(1)->get(1)->length, 1;

assert newPacket(12)->length, 1;

sub Packet::length {
    my ($packet) = @_;
    return scalar @{$packet->{values}};
}

sub Packet::get {
    my ($packet, $index) = @_;
    return ${$packet->{values}}[$index];
}

sub Packet::toString {
    my ($packet) = @_;
    sprintf "[%s]", join(', ', map { $_->isa("Packet") ? $_->toString : $_ } @{$packet->{values}});
}

my @packets = ();
foreach my $line (@lines) {
    if ($line eq '') {
        next;
    }
    push(@packets, parsePacket($line));
}

# Part 1
sub comparePackets {
    # returns 1 if packets are OK
    # returns -1 if packets are not OK
    # returns 0 if inconclusive?

    my ($left, $right, $wrapped) = @_;
    # printf "%s vs. %s\n", $left->toString, $right->toString;

    my $cmpLength = $left->length;
    if ($right->length > $left->length) {
        $cmpLength = $right->length;
    }

    for (my $i = 0; $i < $cmpLength; $i++) {
        my $vl = $left->get($i);
        my $vr = $right->get($i);

        if (!(defined $vl)) {
            return 1;
        } elsif (!(defined $vr)) {
            return -1;
        }

        if (!$vl->isa("Packet") && !$vr->isa("Packet")) {
            # values are numbers
            if ($vl > $vr) {
                return -1;
            } elsif ($vl < $vr) {
                return 1;
            }
            next;
        }

        # either of the values is a packet, convert other to a packet
        if (!$vl->isa("Packet")) {
            $vl = newPacket($vl);
        }
        if (!$vr->isa("Packet")) {
            $vr = newPacket($vr);
        }

        my $w = comparePackets($vl, $vr);
        if ($w != 0) {
            return $w;
        }
    }

    return 0;
}

assert comparePackets(parsePacket("[1,1,3,1,1]"), parsePacket("[1,1,5,1,1]")), 1;
assert comparePackets(parsePacket("[1,1]"), parsePacket("[1,1,1]")), 1;
assert comparePackets(parsePacket("[1,1,1]"), parsePacket("[1,1]")), -1;
assert comparePackets(parsePacket("[[4,4],4,4]"), parsePacket("[[4,4],4,4,4]")), 1;
assert comparePackets(parsePacket("[7,7,7,7]"), parsePacket("[7,7,7]")), -1;
assert comparePackets(parsePacket("[]"), parsePacket("[3]")), 1;
assert comparePackets(parsePacket("[2,3]"), parsePacket("[4]")), 1;
assert comparePackets(parsePacket("[4,3]"), parsePacket("[4]")), -1;
assert comparePackets(parsePacket("[[[]]]"), parsePacket("[[]]")), -1;
assert comparePackets(parsePacket("[[1],[2,3,4]]"), parsePacket("[[1],4]")), 1;
assert comparePackets(parsePacket("[9]"), parsePacket("[[8,7,6]]")), -1;
assert comparePackets(parsePacket("[1,[2,[3,[4,[5,6,7]]]],8,9]"), parsePacket("[1,[2,[3,[4,[5,6,0]]]],8,9]")), -1;
assert comparePackets(parsePacket("[5]"), parsePacket("[]")), -1;
assert comparePackets(parsePacket("[1,2]"), parsePacket("[1,1,1]")), -1;
assert comparePackets(parsePacket("[1,1]"), parsePacket("[1,2,1]")), 1;
assert comparePackets(
    parsePacket("[[8,4,7,[2,8]],[1,[[8],[3,6,8,2,4]],[],5,[3,0,3,[4,3,0]]],[[7]],[7,[],6,[[8,10,8,8,4],9,8,[6,6,9]]],[1,[[5,0,8,7],6]]]"),
    parsePacket("[[[2,[6,4,7,1],0],[1,[6]],[[4],9,[6,0,8,2],[1,2,2,2]],4,[[7,6,8,6],2,[3,5,10],[]]]]")
), -1;

my $idxSum = 0;
for (my $i = 0; $i < $#packets / 2; $i++) {
    my $p1 = $packets[$i * 2];
    my $p2 = $packets[$i * 2 + 1];
    if (comparePackets($p1, $p2) == 1) {
        $idxSum += $i + 1;
    }
}
say $idxSum;

# Part 2
my $dp1 = "[[2]]";
my $dp2 = "[[6]]";
push(@packets, parsePacket($dp1));
push(@packets, parsePacket($dp2));

@packets = sort { -comparePackets $a, $b } @packets;
my $dpidx1 = -1;
my $dpidx2 = -1;
for my $i (0 .. $#packets) {
    my $packet = $packets[$i];

    if ($packet->toString eq $dp1) {
        $dpidx1 = $i + 1;
    } elsif ($packet->toString eq $dp2) {
        $dpidx2 = $i + 1;
    }
}

say $dpidx1 * $dpidx2;
