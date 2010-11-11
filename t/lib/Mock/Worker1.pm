package Mock::Worker1;
use strict;
use warnings;

sub work {
    my ($class, $arg) = @_;
    print STDOUT $arg->{name};
}

1;
