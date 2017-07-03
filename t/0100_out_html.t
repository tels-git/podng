#!/usr/bin/perl

# Test that the HTML output works

use Test::More tests => 6 + 10;

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

# by default we have no CSS
unlike ($html, qr/<link/);

my $rc = $podng->parse( 't/samples/encoding.pod' );
is($rc // 0, '0');

#############################################################################
# CSS tests

my $rc = $podng->add_css_link( 'basic.css' );
is ($rc, 1, 'CSS link to basic.css got added' );

$html = $podng->as_html();
like ($html, qr/<link.*stylesheet.*basic.css/);

$rc = $podng->add_css_link( 'basic.css', 'print' );
is ($rc, 0, 'CSS link to basic.css got not added (duplicate)' );

$rc = $podng->add_css_link( 'print.css', 'aural' );
is ($rc, 1, 'CSS link to print.css got added' );

$html = $podng->as_html();
like ($html, qr/<link.*stylesheet.*basic.css/);
like ($html, qr/<link.*stylesheet.*print.css.*aural/);

1;
