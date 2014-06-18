use strict;
use warnings FATAL => 'all';

use Test::More skip_all => 'Perl module Retry does not work in my situation';
use Test::Differences;

use boolean;
use Capture::Tiny 'capture_merged';
use Time::HiRes qw(
    gettimeofday
    tv_interval
);

use Retry;

use lib::abs qw(
    ../lib
);
use Fail;
use Success;
use TempErrorAndFail;
use TwoErrorsAndSuccess;
use Utils;

sub run_retry {
    my ($class) = @_;

    my $t0 = [gettimeofday];

    my $output = capture_merged {

        my $obj = $class->new();

        my $agent = Retry->new(
            retry_delay => $Utils::SLEEP_TIME_SECONDS,
            max_retry_attempts => 2,
        );

        $agent->retry(
            sub {
                eval {
                    $obj->do_work();
                };
            }
        );

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
        run_retry('Success'),
        $etalon_success_data,
        'Retry - Success',
    );

    compare(
        run_retry('Fail'),
        $etalon_fail_data,
        'Retry - Fail',
    );

    compare(
        run_retry('TwoErrorsAndSuccess'),
        $etalon_two_error_sand_success_data,
        'Retry - TwoErrorsAndSuccess',
    );

    compare(
        run_retry('TempErrorAndFail'),
        $etalon_temp_error_and_fail_data,
        'Retry - TempErrorAndFail',
    );

    done_testing();
}
main();
__END__
