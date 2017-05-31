#!/usr/bin/perl

# Test that the main module can be loaded and used

use Test::More tests => 2;

use lib 'lib';
require_ok( 'Pod::PodNG' );

# Various ways to say "ok"
#ok($got eq $expected, $test_name);
#
#is  ($got, $expected, $test_name);
#isnt($got, $expected, $test_name);

#      # Rather than print STDERR "# here's what went wrong\n"
#      diag("here's what went wrong");

#      like  ($got, qr/expected/, $test_name);
#      unlike($got, qr/expected/, $test_name);

#      cmp_ok($got, '==', $expected, $test_name);

#      is_deeply($got_complex_structure, $expected_complex_structure, $test_name);

#      SKIP: {
#          skip $why, $how_many unless $have_some_feature;
#
#          ok( foo(),       $test_name );
#          is( foo(42), 23, $test_name );
#      };
#
#      TODO: {
#          local $TODO = $why;
#
#          ok( foo(),       $test_name );
#          is( foo(42), 23, $test_name );
#      };
#
#      can_ok($module, @methods);

my $podng = Pod::PodNG->new();

isa_ok($podng, 'Pod::PodNG');

1;
