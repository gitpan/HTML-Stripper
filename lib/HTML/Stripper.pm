package HTML::Stripper;

use strict;
use HTML::Parser;

use vars qw($VERSION);
$VERSION = '0.01';

sub new {
    my ($class, %opts) = @_;

    my $parser = HTML::Parser->new(
        start_document_h => [ \&_parser_start, 'self' ],
        text_h => [ \&_parser_text, 'self, dtext, is_cdata' ]
    );

    $parser->unbroken_text();
    $parser->{_skip_cdata} = 1
        if ( exists($opts{skip_cdata}) and $opts{skip_cdata} );
    $parser->{_strip_ws} = 1
        if ( exists($opts{strip_ws}) and $opts{strip_ws});
    
    return bless([$parser], $class);
}

sub strip_html {
    my ($self, $html_text) = @_;

    $self->[0]->parse($html_text);
    return join(' ', @{$self->[0]{_textblocks}});
}

sub _parser_start { $_[0]->{_textblocks} = [] }

sub _parser_text {
    my ($self, $dtext, $is_cdata) = @_;

    return if $is_cdata and $self->{_skip_cdata};

    # \240 = chr(160) = non-breaking space
    $dtext =~ y!\240! !;

    if ($self->{_strip_ws}) {
        $dtext =~ s!\s{2,}! !g;
        $dtext =~ s!\A\s+!!;
        $dtext =~ s!\s+\z!!;
    }
    push(@{$self->{_textblocks}}, $dtext) if ( length($dtext) );
}
        
1;

=head1 NAME

HTML::Stripper - Strip HTML from a body of text.

=head1 SYNOPSIS

  use HTML::Stripper;

  my $stripper = HTML::Stripper->new(
      skip_cdata => 1, # don't include CDATA (javascript, etc)
      strip_ws   => 1  # strip surrounding whitespace
  );

  my $stripped = $stripper->strip_html($html);

=head1 DESCRIPTION

This module takes a body of text and strips the HTML tags from it, leaving only
the text that is considered content. The heavy duty work is handled by
L<HTML::Parser>, a module which has proved itself very worthy in the world of
HTML parsing.

=head1 USAGE

Usage of this module is really quite simple. First, we create a new stripper
object (wow, this is getting steamy already!):

  my $stripper = HTML::Stripper->new(
      skip_cdata => 1,
      strip_ws   => 1
  );

There are two (optional) named parameters you can pass to new(). The first is
'strip_ws' which, if set, will strip all unnecessary whitespace from the HTML.
This makes for much cleaner output, though you lose any and all formatting that
was contained within the orginal HTML. The second optional parameter is
'skip_cdata' which, if set, will not include CDATA segments in the resulting
source. CDATA in HTML is essentially not really HTML - it is something else
embedded in an HTML document's source. JavaScript, VBScript, and Cascading
Style Sheets are examples of CDATA.

Now that we have our stripper object (wow!), we use it on one or more chunks
of HTML using the strip_html() method:

  my $result = $stripper->strip_html($html);

The single parameter to strip_html() is a scalar containing the HTML source to
work on. For example, $html could be the text retrieved via LWP::Simple's get()
method. . The return value of strip_html() is a single scalar containing the
final product, which is the content text, free of all HTML markup.

=head1 EXAMPLES

In this example, we grab the source of google.com and strip its HTML markup.
We remove the javascript text via the 'skip_cdata' parameter, and keep a small
amount of the HTML formatting by disabling the 'strip_ws' parameter.

  use strict;
  use HTML::Stripper;
  use LWP::Simple qw( get );

  my $stripper = HTML::Stripper->new(
      skip_cdata => 1, strip_ws => 0
  );

  my $google_html = get('http://www.google.com');
  print $stripper->strip_html($google_html);

=head1 AUTHOR/COPYRIGHT

Copyright 2004, Nathan Bessette. All rights reserved.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

Bug reports and comments may be sent to <coruscate@cpan.org>.

=cut

