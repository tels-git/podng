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
use utf8;

require 5.010;

use Pod::PodNG::Common;
use Pod::PodNG::Node;
use Pod::PodNG::File;

use vars qw/@ISA/;

@ISA = qw/Pod::PodNG::Common/;

sub _init
  {
  my ($self, $attr) = @_;

  # The codes we accept:
  $self->{codes} = {
	 A	=> 'cross-reference to an anchor declared with Z<>',
	 B	=> 'bold',
	 C	=> 'monospaced',
	 E	=> 'escape',
	 F	=> 'filename',
	 I	=> 'italic',
	 M	=> 'meaning (explain with mouseover)',
	 N	=> 'footnote',
	 R	=> 'replaceable thing',
	 T	=> 'citation or text with a class',
	 U	=> 'URL',
	 V	=> 'variable',
	 X	=> 'index entry',
	 Z	=> 'cross-reference endpoint',
	 _	=> 'subscript',
	'^'	=> 'superscript',
	};

  # the directives we accept:
  $self->{directives} = map { $_ => undef } ( qw/
	head1 head2 head3 head4 head5 head6
	encoding
	colorscheme
	comment
	include includeonce ifincluded notincluded
	table
	graph
	chart
	text asciiart
	boxart
	code sourcecode listing
	blockquote
	author
	over item back
	var
	todo
	hr br
	/ );

  $self;
  }

#############################################################################
# Handling of document trees

sub _add_node_child
  {
  # add a node as child the current node, making it the new current node
  my ($self, $node) = @_;

  $self->{nodes} = { $node->{id} = $node };	# register the new node

  $self->{curnode}->add_child( $node );		# add as child
  $self->{curnode} = $node;			# make current

  $node;
  }

sub _unwind_tree
  {
  # The node was closed (=end or implicit paragraph after =for seen), so
  # close it and return to the parent. Returns the new currrent node.
  my ($self) = @_;

  $self->{curnode} = $self->{curnode}->{parent};

  $self->_warn( "Seen root of the document." ) unless $self->{curnode};

  $self->{curnode};
  }

#############################################################################
# Public methods

sub parse
  {
  # parse input
  my ($self, $input) = @_;

  $self->{debug} = 1;

  # construct the tree and add the document to it as root
  $self->{tree} = Pod::PodNG::Node->new( type => 'document', id => '' );
  $self->{curnode} = $self->{tree};
  $self->{nodes} = { $self->{tree}->{id} => $self->{tree} };

  $self->{seen_includes} = {};
  $self->{include_stack} = {};

  $self->{linestack} = [];	# accumulate here the content of one section until the end
  $self->{cur_section} = undef;	# not yet in any section

  if (-f $input)
    {
    $self->parse_file( $input );
    }
  else
    {
    $self->_error( "Input looks like a file, but cannot be read: $!" ) if $input =~ /\.pod$/;
    $self->parse_string_document( $input );
    }

  # signal the caller everything is ok
  0;
  }

sub parse_file
  {
  my ($self, $filename) = @_;

  # TODO: if given a GLOB; just read from it

  $self->{file_stack} = ();
  $self->_open_file( $filename );

  while ($self->_parse_line())
    {
    # _parse_line() does all the work
    }

  $self->_clean_up();
  }


sub parse_string_document
  {
  my ($self, $content) = @_;

  $self->{file_stack} = ( Pod::PodNG::File->new( '' ) );

  my @lines = split /\n/, $content;

  for my $line (@lines)
    {
    $self->_analyze_line($line);
    }

  $self->_clean_up();
  }

#############################################################################
# Warning and erroring out

sub _warn
  {
  my ($self, @msg) = @_;

  my $msg = join ("",@msg);
  my $cf = $self->{curfile};

  $msg .= " in $cf->{filename}, line $cf->{linenr}" if $cf;

  $self->log_warn($msg);
  }

sub _die
  {
  my ($self, @msg) = @_;

  my $msg = join ("",@msg);
  my $cf = $self->{curfile};

  $msg .= " in $cf->{filename}, line $cf->{linenr}" if $cf;

  $self->log_error($msg);
  die ("$msg\n");
  }

#############################################################################
# Managing the file stack (for including)

sub _unwind_file_stack
  {
  my ($self) = @_;

  $self->{curfile}->close();

  delete $self->{include_stack}->{ $self->{curfile}->get('filename') };

  pop @{ $self->{filestack} };

  # set the last entry in the stack as the current file
  $self->{curfile} = @{ $self->{filestack} } ? $self->{filestack}->[-1] : undef;

  # for the current file, we are no longer in include mode
  $self->{curfile}->{in_include} = 0;

  $self;
  }

sub _include_file
  {
  my ($self, $filename, $once, $level_shift) = @_;

  # if this file should be included only once, but already was, just ignore it
  if ($once && exists $self->{seen_includes}->{$filename})
    {
    $self->log_debug( 2, "Already included $filename, skipping include." );
    return undef;
    }

  if (exists $self->{include_stack}->{ $filename })
    {
    # do not include files in a circular manner
    $self->_die( "File $filename included from itself!" );
    }

  $self->_open_file( $filename, $level_shift);
  }

sub _open_file
  {
  my ($self, $filename, $level_shift) = @_;

  $self->{include_stack}->{ $filename } = undef;

  push @{ $self->{filestack} }, Pod::PodNG::File->new( name => $filename, level_shift => $level_shift // 0 );
  $self->{curfile} = $self->{filestack}->[-1];

  $self;
  }

#############################################################################
# Parsing of content

sub _parse_content_start
  {
  # Parse content like "::class Text" or "name ::class Text" or
  # "::id_name Text" into the three parts name, css_class and the rest,
  # where the first two are optional.
  # In all cases below $input will start after "=begin table ".
  # Examples:
  #  =begin table
  #  =begin table ::cssclass
  #  =begin table ::cssclass [table1]
  #  =begin table ::cssclass [table1] Description
  #  =begin table [table1]
  #  =begin table [table1] Description
  #  =begin table [table1] ::cssclass Description

  #  =for figure [fig1] ::cssclass F<Description|filename.png>
  #  =for figure [fig1] ::cssclass F<filename.png> Description

  #  =for boxart [fig1] ::cssclass Description

  #  =for include ::-1 F<Description|filename.pod>
  #  =for includeonce ::-1 F<Description|filename.pod>
  #  =for includeonce filename.pod

  #  =for todo [todo1] Some to do item text here.
  #  =for todo [todo1] Do this: Description of what to do.

  #  =begin todo [todo1] Do this
  #  Description of what to do.
  #  =end todo

  #  =for comment This gets ignored.
  #  =for author T. He Authore

  my ($self, $input) = @_;

  # no input?
  return (undef, [], '') if !defined $input || $input =~ /^[\s\t]*$/;

  print STDERR "[_parse_content_start]: '$input'\n";

  my $name = undef;
  my $classes = [];
  my $seen = {};

  while ($input =~ s/^(::[a-zA-Z][a-zA-Z0-9_]* |\[[a-zA-Z][a-zA-Z0-9_]*\])//)
    {
    my $what = $1;
    if ($what =~ /^::(.*)$/)
      {
      my $c = $1;
      $self->_die("Seen duplicate class in '$input'") if exists $seen->{$c};
      $seen->{$c} = undef;
      push @$classes, $c;	# remember the input order
      }
    else
      {
      $self->_die("Seen duplicate [name] in '$input'") if defined $name;
      $name = $what;
      $name =~ s/^\[//;
      $name =~ s/\]$//;
      }
    }

  ($name, $classes, $input);
  }

#############################################################################
# Handling of section start and end

sub _handle_start
  {
  my ($self, $type, $input, $isfor) = @_;

  my ($name, $classes, $content) = $self->_parse_content_start( $input );

  # if this is a "=for foobar Content", then "Content" is the entire content
  # if this is a "=begin foobar Description", then "Description" is merely the description

  my $description = $isfor ? undef : $content;
  $content = $isfor ? $content : undef;

  # create a new node and insert it as children in the current node
  my $node = Pod::PodNG::Node->new( type => 'document', id => $name, class => $classes,
				    description => $description, content => $content );

  }

sub _handle_end
  {
  my ($self, $content) = @_;

  }

sub _handle_end_for
  {
  my ($self, $content) = @_;

  }

#############################################################################
# Reading and analyzing a single line

sub _analyse_line
  {
  # the main parse routine, parses one line from the input
  my ($self, $line) = @_;

  return unless defined $line;		# end of parsing

  $line =~ s/[\r\n]+$//;		# remove the line-end

  ###########################################################################
  # Handling of =pod and =cut

  if ($line =~ /^=pod(.*)\z/)
    {
    $self->log_info("Seen =pod");

    $self->_warn( "=pod does not take any arguments" ) if defined $1;
    # TODO: Support "::class" or "::id"?

    # set the current file to be in_pod, and ignore if it already is
    $self->{curfile}->{in_pod} = 1;
    return 1;
    }
  elsif ($line =~ /^=cut(.*)\z/)
    {
    $self->log_info("Seen =cut");

    $self->_warn( "=cut does not take any arguments" ) if defined $1;
    # set the current file to be not in_pod, and ignore if it already is
    $self->{curfile}->{in_pod} = 0;
    return 1;
    }

  # only continue if we are inside POD
  return 1 unless $self->{curfile}->{in_pod};

  # now handle =begin, =end and =for
  if ($line =~ /^=begin ([a-zA-Z]+)( .*)$/)
    {
    return $self->_handle_start( $1, $2 );
    }

  if ($line =~ /^=for ([a-zA-Z]+)( .*)$/)
    {
    return $self->_handle_start( $1, $2, 'for' );
    }

  if ($line =~ /^=end ([a-zA-Z]+)( .*)$/)
    {
    return $self->_handle_end( $1, $2 );
    }

  # if the line is empty, and we are currently in a for-section, end the section
  if ($line =~ /^[\s\t]+$/)
    {
    if ($self->{curnode}->{is_for})
      {
      return $self->_handle_end_for();
      }
    }

  # TODO: handle =headX
  # TODO: handle =over
  # TODO: handle =back
  # TODO: handle =item

  # Since the line is neither =begin, =end nor =for, we are inside a section, so
  # accumulate content until we are outside the section again
  push @{ $self->{linestack} }, $line;

  # TODO: add the actual parsing
  print STDERR "_analyse_line: $line\n";

  # return 1 to signal "ok, continue"
  1;
  }

sub _read_line
  {
  my ($self) = @_;

  # read a single line from the current file
  my $line = $self->{curfile}->read_line();

  while (!defined $line)
    {
    # end of the current file
    $self->_unwind_file_stack() unless defined $line;
    # We encountered the end of the document if the file stack is empty
    last if @{$self->{filestack}} == 0;

    # read the next line from the previous file in case the current was empty
    $line = $self->{curfile}->read_line();
    }

  $line;
  }


sub _clean_up
  {
  # Cleanup data & memory after parsing
  my ($self) = @_;

  # if we have files left on the stack (maybe we died?), unwind the stack first
  while (@{ $self->{filestack} }) { $self->_unwind_file_stack(); }

  delete $self->{filestack};
  delete $self->{curfile};
  delete $self->{seen_includes};
  delete $self->{include_stack};
  delete $self->{linestack};

  $self;
  }


sub _parse_line
  {
  # parse a given line, or read a line from the current file and parse it
  my ($self, $line) = @_;

  $line = $self->_read_line() unless defined $line;

  $self->_analyse_line($line) if $line;
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

=cut
