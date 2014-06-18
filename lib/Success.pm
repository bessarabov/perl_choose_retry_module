package Success;

use strict;
use warnings FATAL => 'all';
use feature 'say';

sub new {
    my ($class) = @_;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub do_work {
    say 'Success: Attempt 1 - ok';
}

1;
