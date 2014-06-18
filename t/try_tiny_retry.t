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

use Try::Tiny::Retry ':all';

use lib::abs qw(
    ../lib
    ./lib
);
use Fail;
use Success;
use TempErrorAndFail;
use TwoErrorsAndSuccess;
use Utils;

sub run_try_tiny_retry {
    my ($class) = @_;

    my $t0 = [gettimeofday];

    my $output = capture_merged {

        my $count = 0;

        my $obj = $class->new();

        retry {
            $obj->do_work();
            die "ick" if ++$count < 3;
        }
        delay {
            sleep $Utils::SLEEP_TIME_SECONDS;
        }
        retry_if {
            ref($_) eq 'TemporaryError'
        };

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
        run_try_tiny_retry('Success'),
        $etalon_success_data,
        'Try::Tiny::Retry - Success',
    );

    compare(
        run_try_tiny_retry('Fail'),
        $etalon_fail_data,
        'Try::Tiny::Retry - Fail',
    );

    compare(
        run_try_tiny_retry('TwoErrorsAndSuccess'),
        $etalon_two_error_sand_success_data,
        'Try::Tiny::Retry - TwoErrorsAndSuccess',
    );

    compare(
        run_try_tiny_retry('TempErrorAndFail'),
        $etalon_temp_error_and_fail_data,
        'Try::Tiny::Retry - TempErrorAndFail',
    );

    done_testing();
}
main();
__END__
