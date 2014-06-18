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

my $sleep_time_seconds = 5;

sub run_etalon_success {

    my $t0 = [gettimeofday];

    my $output = capture_merged {

        my $obj = Success->new();
        $obj->do_work();

    };

    my $elapsed = tv_interval( $t0, [gettimeofday] );

    return {
        output => $output,
        elapsed => $elapsed,
    };

}

sub run_etalon_fail {

    my $t0 = [gettimeofday];

    my $output = capture_merged {

        my $obj = Fail->new();

        eval {
            $obj->do_work();
        };

    };

    my $elapsed = tv_interval( $t0, [gettimeofday] );

    return {
        output => $output,
        elapsed => $elapsed,
    };

}

sub run_etalon_two_errors_and_success {

    my $t0 = [gettimeofday];

    my $output = capture_merged {

        my $obj = TwoErrorsAndSuccess->new();

        eval {
            $obj->do_work();
        };

        sleep $sleep_time_seconds;

        eval {
            $obj->do_work();
        };

        sleep $sleep_time_seconds;

        $obj->do_work();

    };

    my $elapsed = tv_interval( $t0, [gettimeofday] );

    return {
        output => $output,
        elapsed => $elapsed,
    };

}

sub run_temp_error_and_fail {

    my $t0 = [gettimeofday];

    my $output = capture_merged {

        my $obj = TempErrorAndFail->new();

        eval {
            $obj->do_work();
        };

        sleep $sleep_time_seconds;

        eval {
            $obj->do_work();
        };

    };

    my $elapsed = tv_interval( $t0, [gettimeofday] );

    return {
        output => $output,
        elapsed => $elapsed,
    };

}

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
                    initial_sleep_time => $sleep_time_seconds * 1000,
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

sub compare {
    my ($got, $expected, $message) = @_;

    eq_or_diff(
        $got->{output},
        $expected->{output},
        "$message - output is expected",
    );

    ok(
        abs($got->{elapsed} - $expected->{elapsed}) < 1,
        "$message - elapsed time is expected",
    );

}

sub main {

    my $etalon_success_data = run_etalon_success();
    my $etalon_fail_data = run_etalon_fail();
    my $etalon_two_error_sand_success_data = run_etalon_two_errors_and_success();
    my $etalon_temp_error_and_fail_data = run_temp_error_and_fail();

    # Action::Retry
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
