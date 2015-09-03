use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Manoc';
use Manoc::Controller::Host;

ok( request('/host')->is_success, 'Request should succeed' );
done_testing();
