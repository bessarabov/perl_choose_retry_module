package Utils;

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

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    run_etalon_success
    run_etalon_fail
    run_etalon_two_errors_and_success
    run_etalon_temp_error_and_fail
    compare
);
our @EXPORT = @EXPORT_OK;

our $SLEEP_TIME_SECONDS = 5;

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

        sleep $SLEEP_TIME_SECONDS;

        eval {
            $obj->do_work();
        };

        sleep $SLEEP_TIME_SECONDS;

        $obj->do_work();

    };

    my $elapsed = tv_interval( $t0, [gettimeofday] );

    return {
        output => $output,
        elapsed => $elapsed,
    };

}

sub run_etalon_temp_error_and_fail {

    my $t0 = [gettimeofday];

    my $output = capture_merged {

        my $obj = TempErrorAndFail->new();

        eval {
            $obj->do_work();
        };

        sleep $SLEEP_TIME_SECONDS;

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


1;
