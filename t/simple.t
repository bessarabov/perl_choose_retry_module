use strict;
use warnings FATAL => 'all';

use Capture::Tiny 'capture_merged';
use Time::HiRes qw(
    gettimeofday
    tv_interval
);

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

sub main {

    use DDP;

    my $etalon_success_data = run_etalon_success();
    p $etalon_success_data;

    my $etalon_fail_data = run_etalon_fail();
    p $etalon_fail_data;

    my $etalon_two_error_sand_success_data = run_etalon_two_errors_and_success();
    p $etalon_two_error_sand_success_data;

    my $etalon_temp_error_and_fail_data = run_temp_error_and_fail();
    p $etalon_temp_error_and_fail_data;

}
main();
