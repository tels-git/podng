#############################################################################
#############################################################################
#
# Pod::PodNG - a module to parse PODNG (a superset of POD) and POD
#
# While the input is any valid POD document, the parser understands many
# extensions like graphs, tables, charts or ASCII art.
#
# The output can be in various formats like PODNG, POD, text or HTML. The
# main focus here lies on well-formed, structurally sound and good looking
# HTML, which can then be printed or converted to PDF ("Print to PDF").
#
#############################################################################
#############################################################################

package Pod::PodNG;

use strict;
use warnings;
use utf8;

require 5.010;

use Pod::PodNG::Common;
use Pod::PodNG::Parser;

use vars qw(@ISA);

@ISA = qw/Pod::PodNG::Common/;

#############################################################################
# Initialize a new Pod::PodNG object

sub _init
  {
  my ($self, $args) = @_;

  $self->{parser} = Pod::PodNG::Parser->new();

  $self;
  }

#############################################################################
# Parse input

sub parse
  {
  my ($self, $input) = @_;

  # parse input and return result
  $self->{parser}->parse($input);
  }

sub parse_file
  {
  my ($self, $input) = @_;

  # parse input and return result
  $self->{parser}->parse_file($input);
  }

# everything is fine
1;

=pod

=encoding utf-8

=head1 NAME

Pod::PodNG - Extend POD with graphs, tables etc. and create nice HTML or PDF from it

=head1 SYNOPSIS

	use Pod::PodNG;

	my $podng = Pod::PodNG->new();

	$podng->parse( 'somefile.pod' );

	my ($html, $css) = $podng->as_html();

	$podng->write_html( 'outputdir', 'basename' );

=head1 DESCRIPTION

This module implements a new improved POD format, which is largely compatible with
the normal POD format.

The main new features are:

=over 2

=item * Re-use content by including other files, multiple times or even only once, even include only some sections

=item * Define variables and use them with V<>

=item * Easily add Hyperlinks with L<>

=item * Add graphs (flowcharts), tables and charts, blockquotes or source code

=item * Generates structurally sound HTML, which can be easily styled with CSS

=item * By default, a nice-looking CSS is included

=item * Make printing (for instance into PDF) easier and better looking

=back

=head1 EXAMPLES

TODO

=head1 METHODS

=head2 new()

Create a new Pod::PodNG object.

=head2 parse()

This function parses the input and stores the result in memory.

=head1 EXPORT

This module exports nothing.

=cut

