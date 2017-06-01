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

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the terms of the GPL 3.0 or a later version.

See the LICENSE file for a copy of the GPL.

This product includes color specifications and designs developed by Cynthia
Brewer (http://colorbrewer.org/). See the LICENSE file for the full license
text that applies to these color schemes.

X<gpl>
X<apache-style>
X<cynthia>
X<brewer>
X<colorscheme>
X<license>

=head1 AUTHOR

Copyright (C) 2016 - 2017 by Tels L<http://bloodgate.com>

X<tels>

=cut
