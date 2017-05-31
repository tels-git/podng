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

require 5.010;

use Pod::Simple;

#use Exporter;
#use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
#@ISA		= qw(Exporter);
#@EXPORT		= ();
#@EXPORT_OK	= ();
##%EXPORT_TAGS = ( DEFAULT => [qw(&func1)],
#                 Both    => [qw(&func1 &func2)]);

#############################################################################
# Initialize a new Pod::PodNG object

=pod

=head2 new()

Create a new Pod::PodNG object.

=cut

sub new
  {
  my $self = bless {}, shift;

  $self->_init( @_ );
  }

sub _init
  {
  my ($self, $args) = @_;

  $self;
  }

#############################################################################
# Parse input

=pod

=head2 parse()

This function parses the input and stores the result in memory.

=cut

sub parse
  {
  my ($self, $input) = @_;

  }

# everything is fine
1;
