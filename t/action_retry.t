use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Differences;

use boolean;
use Capture::Tiny 'capture_merged';
use Time::HiRes qw(
    gettimeofday
    tv_interval
);

use Action::Retry;

use lib::abs qw(
    ../lib
);
use Fail;
use Success;
use TempErrorAndFail;
use TwoErrorsAndSuccess;
use Utils;

sub run_action_retry {
    my ($class) = @_;

    my $t0 = [gettimeofday];

    my $output = capture_merged {

        my $obj = $class->new();

        my $action = Action::Retry->new(
            attempt_code => sub {
                $obj->do_work();
            },
            strategy => {
                Linear => {
                    initial_sleep_time => $Utils::SLEEP_TIME_SECONDS * 1000,
                    multiplicator => 1,
                }
            },
            retry_if_code => sub {
                my ($error) = @_;

                if (ref($error) eq 'TemporaryError') {
                    return true;
                } else {
                    return false;
                }
            },
        );
        $action->run();

    };

    my $elapsed = tv_interval( $t0, [gettimeofday] );

    return {
        output => $output,
        elapsed => $elapsed,
    };

}

sub main {

    $Utils::SLEEP_TIME_SECONDS = 5;

    my $etalon_success_data = run_etalon_success();
    my $etalon_fail_data = run_etalon_fail();
    my $etalon_two_error_sand_success_data = run_etalon_two_errors_and_success();
    my $etalon_temp_error_and_fail_data = run_etalon_temp_error_and_fail();

    compare(
        run_action_retry('Success'),
        $etalon_success_data,
        'Action::Retry - Success',
    );

    compare(
        run_action_retry('Fail'),
        $etalon_fail_data,
        'Action::Retry - Fail',
    );

    compare(
        run_action_retry('TwoErrorsAndSuccess'),
        $etalon_two_error_sand_success_data,
        'Action::Retry - TwoErrorsAndSuccess',
    );

    compare(
        run_action_retry('TempErrorAndFail'),
        $etalon_temp_error_and_fail_data,
        'Action::Retry - TempErrorAndFail',
    );

    done_testing();
}
main();
__END__
