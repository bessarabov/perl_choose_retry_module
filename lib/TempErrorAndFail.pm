package TempErrorAndFail;

use strict;
use warnings FATAL => 'all';
use feature 'say';

use Carp;

use Exception::Class (
    'TemporaryError' => {},
);

sub new {
    my ($class) = @_;

    my $self = {};
    bless $self, $class;

    $self->{_number} = 0;

    return $self;
}

sub do_work {
    my ($self) = @_;

    $self->{_number}++;

    if ($self->{_number} < 2) {

        say 'TempErrorAndFail: Attempt '
            . $self->{_number}
            . ' - TemporaryError'
            ;

        TemporaryError->throw();

    } else {
        say 'TempErrorAndFail: Attempt '
            . $self->{_number}
            . ' - fail'
            ;

        croak 'FatalError';
    }

}

1;
