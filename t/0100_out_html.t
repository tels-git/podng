#!/usr/bin/perl

# Test that the HTML output works

use Test::More tests => 6 + 3;

use lib 'lib';
require_ok( 'Pod::PodNG' );

my $podng = Pod::PodNG->new();

isa_ok($podng, 'Pod::PodNG');

# empty input => empty output
my $html = $podng->as_html();

for my $tag (qw/html body head/)
  {
  like ($html, qr/<$tag>/);
  like ($html, qr/<\/$tag>/);
  }

my $rc = $podng->parse( 't/samples/encoding.pod' );
is($rc // 0, '0');

1;
