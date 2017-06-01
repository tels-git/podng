#############################################################################
#############################################################################
#
# Pod::PodNG::Parser - parse POD or PodNG into a memory structure
#
# While the input is any valid POD document, the parser understands many
# extensions like graphs, tables, charts or ASCII art.
#
#############################################################################
#############################################################################

package Pod::PodNG::Parser;

use strict;
use warnings;

require 5.010;

use Pod::Simple;
use Pod::PodNG::Common;

use vars qw/@ISA/;

@ISA = qw/Pod::Simple Pod::PodNG::Common/;

sub parse
  {
  # parse input
  my ($self, $input) = @_;

  $self->{debug} = 1;
  # we do only parsing, no output, but just in case discard the output
  $self->output_string( $self->{_dummy_output} );

  if (-f $input)
    {
    $self->parse_file( $input );
    }
  else
    {
    $self->_error( "Input looks like a file, but cannot be read: $!" );
    $self->parse_string_document( $input );
    }

  # signal the caller everything is ok
  0;
  }

sub _handle_element_start
  {
  my ($self, $ename, $attr) = @_;

  $self->log_debug( "Seen begin $self, $ename, $attr" );
  }

sub _handle_element_end
  {
  my ($self, $ename, $attr) = @_;

  # NOTE: $attr_hash_r is only present when $element_name is "over" or "begin"
  # The remaining code excerpts will mostly ignore this $attr_hash_r, as it is
  # mostly useless. It is documented where "over-*" and "begin" events are
  # documented.

  $self->log_debug( "Seen end $self, $ename, $attr" );
  }

sub _handle_text
  {
  my ($self, $text) = @_;

  $self->log_debug( "Seen text $self, $text" );
  }

# everything is fine
1;

=pod

=encoding utf-8

=head1 NAME

Pod::PodNG::Parser - Parse POD or PODNG into a memory tree structure

=head1 SYNOPSIS

	use Pod::PodNG::Parser;

	my $parser = Pod::PodNG::Parser->new();

	my $pod = $parser->parse( 'somefile.pod' );
	my $pod = $parser->parse( \$scalar_with_pod );
	my $pod = $parser->parse( \@array_with_lines );
	my $pod = $parser->parse_file( 'name.pod' );
	my $pod = $parser->parse_text( \$scalar_with_pod );
	my $pod = $parser->parse_lines( \@array_with_lines );

	# TODO

=head1 DESCRIPTION

TODO

=head1 EXAMPLES

TODO

=head1 METHODS

=head2 new()

Create a new Pod::PodNG::Parser object.

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
