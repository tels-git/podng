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

use base 'Pod::PodNG::Common';
use Pod::PodNG::Node::HTML;

our $CURID = 1;		# to get consecutive IDs

sub _init
  {
  my ($self, $attr) = @_;

  $self->{name} = $attr->{name};		# user-supplied id like "table1"
  $self->{type} = $attr->{type};		# =begin table => 'table'
  $self->{idnr} = $attr->{id} // $CURID++;	# get a new automatic nr for the id

  # either use the user-supplied name or generate something like "figure1"
  $self->{id} = $self->{name} // "$self->{type}$self->{idnr}";

  $self->{description} = $attr->{description} // '';	# if set, use as description of the content
  $self->{content} = $attr->{content} // '';		# if set, use this as content

  $self->{is_for} = $attr->{is_for} ? 1 : 0;		# this node is a =for directive
  $self->{level} = $attr->{level} ? $attr->{level} : 0;	# the head-level depth

  $self->{parent} = $attr->{parent};
  $self->{is_root} = ($attr->{is_root} // (defined $attr->{parent} ? 1 : 0)) ? 1 : 0;

  $self->{children} = [];	# no children yet

  $self->{linestack} = [];	# extra raw content, to be parsed

  my $p = ref $self->{parent} ? $self->{parent}->{id} : 'none';

  $self->log_info( "Creating Node $self->{id} ($self->{description}) (parent $p)" );

  $self->{html} =
	{
		tag => $attr->{tag} // 'span',
		class => $attr->{class} // [],
		css_links => {},
	};
  $self;
  }

#############################################################################
# public methods

sub add_child
  {
  my ($self, $child) = @_;

  push @{ $self->{children} }, $child;
  $child->{parent} = $self;

  $self;
  }

sub set_parent
  {
  my ($self, $parent) = @_;

  $self->{parent} = $parent;
  $self->{is_root} = defined $parent ? 1 : 0;

  $self;
  }

sub add_content
  {
  my ($self, $content) = @_;

  push @{ $self->{linestack} }, @$content;

  $self;
  }

sub cleanup
  {
  my ($self) = @_;

  for my $child (@{$self->{children}})
    {
    $child->cleanup();
    }
  delete $self->{children};

  $self;
  }

#############################################################################
# internal helper routines

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

#############################################################################
# Output routines: POD

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

Pod::PodNG::Node - Represents a part of the POD or PODNG document

=head1 SYNOPSIS

	use Pod::PodNG::Node;

	my $node = Pod::PodNG::Node->new( name => 'head1', content => 'Headline' );

	print $node->as_pod();

=head1 DESCRIPTION

Represents a part of the POD or PODNG document.

=head1 EXAMPLES

TODO

=head1 METHODS

=head2 new()

Create a new Pod::PodNG::Node object.

=head2 as_pod()

Return the node and all its children as POD.

=head2 as_html()

Return the node and all its children as HTML code.

=head1 EXPORT

This module exports nothing.

=cut
