#############################################################################
#############################################################################
#
# Pod::PodNG::Node - Represents part of the document.
#
# Nodes are arranged in a tree, where the top-node represents the entire
# document.
#
#############################################################################
#############################################################################

package Pod::PodNG::Node;

use strict;
use warnings;

require 5.010;

use Pod::PodNG::Common;

our @ISA = qw/Pod::PodNG::Common/;

sub _init
  {
  my ($self, $attr) = @_;

  $self->{name} = $attr->{name};
  $self->{parent} = $attr->{parent};

  $self->{children} = [];	# no children yet

  $self;
  }


sub _walk_depth
  {
  # Call the specified method for each child (depth first).
  my ($self, $method, @arguments) = @_;

  for my $child (@{$self->{children}})
    {
    $child->_walk_depth( $method, @arguments );
    }
  # now call the method on ourself
  $self->{$method}( @arguments );

  # return
  $self;
  }

sub _as_pod
  {
  # Return the node as POD
  my ($self) = @_;

  "$self->{name} $self->{content}\n\n";
  }

sub as_pod
  {
  # Return the node and all it's children as POD
  my ($self) = @_;

  $self->{_out_pod} = '';

  # call as_pod() on each child
  $self->_walk_depth( 'as_pod' );

  $self->{_out_pod} = $self->_as_pod();

  # add all children
  for my $child (@{$self->{children}})
    {
    $self->{_out_pod} .= $child->{_out_pod};
    }

  # return the result
  $self->{_out_pod};
  }

# everything is fine
1;

=pod

=encoding utf-8

=head1 NAME

Pod::PodNG::Node - Represent a part of the POD or PODNG document

=head1 SYNOPSIS

	use Pod::PodNG::Node;

	my $node = Pod::PodNG::Node->new( name => 'head1', content => 'Headline' );

=head1 DESCRIPTION

TODO

=head1 EXAMPLES

TODO

=head1 METHODS

=head2 new()

Create a new Pod::PodNG::Node object.

=head2 as_pod()

Return the node and all its children as POD.

=head1 EXPORT

This module exports nothing.

=cut
