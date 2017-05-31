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

sub parse
  {
  my ($self, $input) = @_;

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

	# TODO

=head1 DESCRIPTION

TODO

=head1 EXAMPLES

TODO

=head1 METHODS

=head2 new()

Create a new Pod::PodNG object.

=head2 parse()

This function parses the input and stores the result in memory.

=head1 EXPORT

This module exports nothing.

=head1 SEE ALSO

=head1 LIMITATIONS

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

