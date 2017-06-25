#############################################################################
#############################################################################
#
# Pod::PodNG::Node::HTML - inject HTML output routines into Pod::PodNG::Node
#
#############################################################################
#############################################################################

package Pod::PodNG::Node;

use strict;
use warnings;

require 5.010;

#############################################################################
# public methods

sub as_html
  {
  # Return the node and all it's children as HTML
  my ($self) = @_;

  my $html = $self->{is_root} ? $self->_html_header() : '';

  $html .= $self->_as_html_start();

  # add all children
  for my $child (@{$self->{children}})
    {
    $html .= $child->as_html();
    }

  $html .= $self->_as_html_end();

  $html .= $self->{is_root} ? $self->_html_footer() : '';

  # return the result
  $html;
  }

#############################################################################
# Helper routines for hTML output

sub _html_esscape
  {
  my ($self, $text) = @_;

  $text =~ s/&/&amp;/g;
  $text =~ s/</&lt;/g;
  $text =~ s/>/&gt;/g;
  $text =~ s/"/&quot;/g;

  $text;
  }

sub _html_header
  {
  # return the HTML <head> tags etc.
  my ($self) = @_;

my $tpl = <<EOF
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
  <head>
##HEADER##
  </head>
  <body>
EOF
;

  $tpl =~ s/##HEADER##//;

  $tpl;
  }

sub _html_footer
  {
  # return the HTML </head> tags etc.
  my ($self) = @_;

  "  </body>\n</html>\n";
  }

sub _as_html_start
  {
  # Return the node's begin as HTML
  my ($self) = @_;

  my $html = $self->{html};

  my $class = defined $html->{class} ? ' class="' . $html->{class} . '"' : '';

  if ($html->{single_tag})
    {
    return "<$html->{tag} />";
    }

  "<$html->{tag}$class>";
  }

sub _as_html_end
  {
  # Return the node's end as HTML
  my ($self) = @_;

  my $html = $self->{html};

  my $class = defined $html->{class} ? ' class="' . $html->{class} . '" ' : '';

  return '' if $html->{single_tag};

  "</$html->{tag}>\n";
  }


# everything is fine
1;

=pod

=encoding utf-8

=head1 NAME

Pod::PodNG::Node::HTML - Inject HTML output routines into Pod::PodNG::Node

=head1 SYNOPSIS

	use Pod::PodNG::Node;
	use Pod::PodNG::Node::HTML;

	my $node = Pod::PodNG::Node->new( name => 'head1', content => 'Headline' );

	print $node->as_html();

=head1 DESCRIPTION

This module contains routines that convert a Pod::PodNG::Node into HTML. The
routines will be inserted into the package Pod::PodNG::Node, so each node
can then output HTML on its own.

=head1 METHODS

=head2 as_html()

Return the node and all its children as HTML code.

=head1 EXPORT

This module exports nothing.

=cut
