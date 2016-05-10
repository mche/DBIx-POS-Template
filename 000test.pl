use strict;
use utf8;
package SomePodFormatter;
use base qw(Pod::Simple::Methody);#
use Data::Dumper;
binmode(STDOUT, ":encoding(UTF-8)");

my @elem = qw(sql);

#~ sub _handle_element_start {
  #~ my($parser, $element_name, $attr_hash_r) = @_;
  #~ print "$element_name\n-----------\n",;
  #~ $parser->{element} = $element_name
    #~ if grep($_ eq $element_name, @elem);
#~ }

#~ sub _handle_element_end {
  #~ my($parser, $element_name, $attr_hash_r) = @_;
  # NOTE: $attr_hash_r is only present when $element_name is "over" or "begin"
  # The remaining code excerpts will mostly ignore this $attr_hash_r, as it is
  # mostly useless. It is documented where "over-*" and "begin" events are
  # documented.
  #~ $parser->{element} = undef;
#~ }

#~ sub _handle_text {
  #~ my($parser, $text) = @_;
  #~ print "$parser->{element}\n-----------\n", Dumper($text), "\n===============\n"
    #~ if $parser->{element};
#~ }

#~ sub _handle_element_start {
  #~ $_[1] =~ tr/-:./__/;
  #~ print $_[1]."\n----------\n";
  #~ ( $_[0]->can( 'start_' . $_[1] )
    #~ || return
  #~ )->(
    #~ $_[0], $_[2]
  #~ );
  
#~ }

#~ sub _handle_text {
  #~ ( $_[0]->can( 'handle_text' )
    #~ || return
  #~ )->(
    #~ @_
  #~ );
#~ }

#~ sub _handle_element_end {
  #~ $_[1] =~ tr/-:./__/;
  #~ ( $_[0]->can( 'end_' . $_[1] )
    #~ || return
  #~ )->(
    #~ $_[0], $_[2]
  #~ );
#~ }

my $tocken;

sub handle_text {
 my($self, $text) = @_;
 print $text, "\n=============\n"
  #~ if $tocken
  ;
}

sub start_sql {
 my($self, $attrs) = @_;
 print '-----------sql', "\n";
 
}
sub end_sql {
 my($self) = @_;
 $tocken = undef;
}

my $parser=__PACKAGE__->new();
$parser->no_whining(1);
$parser->complain_stderr(1);
$parser->parse_file("$ENV{HOME}/Mojolicious-Plugin-RoutesAuthDBI/lib/Mojolicious/Plugin/RoutesAuthDBI/Install.pm");