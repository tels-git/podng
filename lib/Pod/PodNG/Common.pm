#############################################################################
#############################################################################
#
# Pod::PodNG::Common - a common base class for Pod::PodNG modules
#
#############################################################################
#############################################################################

package Pod::PodNG::Common;

use strict;
use warnings;

require 5.010;

#############################################################################
# The constructor

sub new
  {
  my $self = bless {}, shift;

  # If given arguments like ( name => 'foo', bar => 'baz' ), convert them to
  # a hash ref, otherwise use the single argument:
  my $args = scalar @_ > 1 && (((scalar @_) % 2) == 0) ? { @_ } : shift;

  # call the class _init() routine
  $self->_init( $args );
  }

sub _init
  {
  my ($self, $args) = @_;

  # the base class does not any initialization on its own
  $self;
  }

sub _error
  {
  my ($self, $error) = @_;

  if (defined $error)
    {
    $self->{error} = $error;
    $self->log_error( $error );
    }

  $self->{error};
  }

sub log_debug
  {
  my $self = shift;
  my $text = "DEBUG: " . (join("", @_, "\n"));

  print STDERR $text if $self->{debug};
  }

sub log_info
  {
  my $self = shift;
  my $text = "INFO: " . (join("", @_, "\n"));

  print STDERR $text;
  }

sub log_error
  {
  my $self = shift;
  my $text = "ERROR: " . (join("", @_, "\n"));

  print STDERR $text;
  }

# everything is fine
1;

=pod

=encoding utf-8

=head1 NAME

Pod::PodNG::Common - A common base class for Pod::PodNG modules

=head1 SYNOPSIS

	use Pod::PodNG::Common;

	use vars qw/@ISA/;

	@ISA = qw/Pod::PodNG::Common/;

	$self->{debug} = 1;

	$self->log_debug( "Some debug info" );
	$self->log_info( "Some info" );
	$self->log_error( "Some error" );

=head1 DESCRIPTION

This is a common base class for all Pod::PodNG modules.

=head1 METHODS

This base class provides the following methods:

=over 2

=item * log_debug( @messages )

=item * log_error( @messages )

=item * log_info @messages )

=back

=head1 EXPORTS

Nothing.

=cut
