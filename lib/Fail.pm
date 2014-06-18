package Fail;

use strict;
use warnings FATAL => 'all';
use feature 'say';

use Carp;

sub new {
    my ($class) = @_;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub do_work {
    say 'Fail: Attempt 1 - fail';

    croak 'FatalError';
}

1;
