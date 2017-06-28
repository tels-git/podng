#############################################################################
#############################################################################
#
# Pod::PodNG::File - defines a POD or PODNG file entry
#
# Each file can include other files, so we represent the chain of currently
# encountered files with a stack of Pod::PodNG::File objects.
#
#############################################################################
#############################################################################

package Pod::PodNG::File;

use strict;
use warnings;

require 5.010;

use base 'Pod::PodNG::Common';

sub _init
  {
  # initialize ourself
  my ($self, $attr) = @_;

  $self->{filename} = $attr->{name} // 'STDIN';
  $self->{level_shift} = $attr->{level_shift} // 0;

  # limit to -5 .. 5 (headlines goe from 1 .. 6, so a shift > |5| makes no difference)
  $self->{level_shift} = -5 if $self->{level_shift} < -5;
  $self->{level_shift} =  5 if $self->{level_shift} > 5;

  $self->{linenr} = 0;
  $self->{in_pod} = 0;		# not yet
  $self->{in_comment} = 0;	# not yet
  $self->{in_include} = 0;	# not yet

  # support this way to write "STDIN":
  $self->{filename} = 'STDIN' if $self->{filename} eq '-';

  if ($self->{filename} eq 'STDIN')
    {
    $self->{stdin} = *STDIN;			# save the old STDIN
    open ( $self->{handle}, '<&STDIN' ) or	# re-open it
	return $self->_error("Cannot open STDIN: $!");
    }
  else
    {
    # filename = '' => reading from a scalar in memory
    if ($self->{filename} ne '')
      {
      open ( $self->{handle}, '<', $self->{filename} ) or
	return $self->_error("Cannot open $self->{filename}: $!");
      }
    }

  $self->{open} = 1;

  $self;
  }

sub close
  {
  # close the file again
  my $self = shift;

  close($self->{handle}) or return $self->_error("Cannot open $self->{filename}: $!");

  $self->{open} = 0;

  $self;
  }

sub read_line
  {
  my ($self) = @_;

  $self->{linenr} ++;
  my $handle = $self->{handle};
  $self->{curline} = <$handle>;
  }

# everything is fine
1;

=pod

=encoding utf-8

=head1 NAME

Pod::PodNG::File - Represents a currently open input file

=head1 SYNOPSIS

	use Pod::PodNG::File;

	my $file = Pod::PodNG::File( { name => 'somepod.txt' } );

	$file->close();

=head1 DESCRIPTION

TODO

=head1 METHODS

=head2 new()

Create a new Pod::PodNG::File object.

=head2 close()

Close the file and cleanup.

=head1 EXPORT

This module exports nothing.

=cut
