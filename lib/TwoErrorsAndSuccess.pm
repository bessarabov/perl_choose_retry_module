package TwoErrorsAndSuccess;

use strict;
use warnings FATAL => 'all';
use feature 'say';

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

    if ($self->{_number} < 3) {

        say 'TwoErrorsAndSuccess: Attempt '
            . $self->{_number}
            . ' - TemporaryError'
            ;

        TemporaryError->throw();

    } else {
        say 'TwoErrorsAndSuccess: Attempt '
            . $self->{_number}
            . ' - ok'
            ;
    }

}

1;
