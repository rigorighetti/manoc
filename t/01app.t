#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Manoc' }

ok( request('/auth/login')->is_success, 'Test initial login page' );

done_testing();
