package assertions;

use Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(assert assertTrue assertFalse assertEq);

sub assert {
    my ($actual, $expected) = @_;
    if ($actual != $expected) {
        die "assertion failed: actual value '$actual', expected '$expected'";
    }
}

sub assertTrue {
    my ($value) = @_;
    if (!$value) {
        die "assertion failed: value is not true, was '$value'";
    }
}

sub assertFalse {
    my ($value) = @_;
    if ($value) {
        die "assertion failed: value is true, was '$value'";
    }
}

sub assertEq {
    my ($actual, $expected) = @_;
    if ($actual ne $expected) {
        die "assertion failed: actual value '$actual', expected '$expected'";
    }
}

return 1;