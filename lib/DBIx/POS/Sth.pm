package DBIx::POS::Sth;
use strict;
use utf8;

my %cache= ();

sub new {
  my $class = shift;
  my $dbh = shift;
  my $pos = shift;
  my %opt = @_;
  return bless [$dbh, $pos, \%opt], $class;
}

sub sth {
  my ($dbh, $sql, $opt) = @{ shift() };
  my $name = shift;
  my %arg = @_;
  die "No such name[$name] in SQL dict! @{[ join ':', keys %$sql  ]}" unless $sql->{$name};
  my $s = $sql->{$name}->template(%$opt, %arg);
  my $param = $sql->{$name}->param;
  
  my $sth;
  
  if ($param && $param->{cached}) {
    $sth = $dbh->prepare_cached($s)
  } else {
    $sth = $dbh->prepare($s);
  }
  
  warn "pg_prepared_statements:\n", map "%$_", @{$dbh->selectall_arrayref('select * from pg_prepared_statements;', {Slice=>{}}, )};
  
  return $sth;
  
  #~ warn "Запрос уже подготовлен!", $sth->{pg_prepare_name}
    #~ if $cache{$sth->{pg_prepare_name}};
  #~ $cache{$sth->{pg_prepare_name}}++;

  #~ return $sth;
}

1;

=pod

=encoding utf8

=head1 DBIx::POS::Sth

¡ ¡ ¡ ALL GLORY TO GLORIA ! ! !

=head1 NAME

DBIx::POS::Sth - is a DBI statements hub. Works with L<DBIx::POS::Template> in pair.

=head1 SYNOPSIS

    my $sth = DBIx::POS::Sth->new(
      $dbh,
      $pos, # SQL dict
      foo => 'bar', # any pairs opts
      ...,
    );
    my $r = $dbh->selectrow_hashref($sth->sth('foo name'));

=head1 DESCRIPTION

Dictionary of DBI statements.

=head1 new($dbh, $pos, ...)

=head2 $dbh (first in list)

DBI handle

=head2 $pos (second in list)

An SQL dictionary object/instance of the L<DBIx::POS::Template>.

=head2 <any key=>value pairs>

Used for templates of $pos.


=head1 SEE ALSO

L<DBIx::POS::Template>

=cut
