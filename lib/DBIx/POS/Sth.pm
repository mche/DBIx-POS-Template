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
  my $s = sprintf("--%s\n", $sql->{$name}->name).$sql->{$name}->template(%$opt, %arg);
  my $param = $sql->{$name}->param;
  
  my $sth;# = $dbh->prepare($s, {pg_server_prepare => 0,});
  #~ my $sth_name = $sth->{pg_prepare_name};
  #~ warn "ST for name: $sth_name\n", $sth->{Statement};
  #~ $sth = undef;
  
  #~ local $dbh->{TraceLevel} = "3|DBD";
  
  warn "pg_prepared_statement:\n", "$_->{name}\t$_->{statement}\n" for @{$dbh->selectall_arrayref(q!select * from pg_prepared_statements where regexp_replace(statement, '\$\d+', '?', 'g')=?;!, {Slice=>{}}, ($s))};
  
  if ($param && $param->{cached}) {
    $sth = $dbh->prepare_cached($s);
    #~ warn "ST cached: ", $sth->{pg_prepare_name};
  } else {
    $sth = $dbh->prepare($s);
  }
  
  
  
=pod

https://www.depesz.com/2012/12/02/what-is-the-point-of-bouncing/

$dbh->do('PREPARE mystat AS SELECT COUNT(*) FROM pg_class WHERE reltuples < ?');
$sth = $dbh->prepare($s, {pg_server_prepare => 0,});
$sth->bind_param(1, 1, SQL_INTEGER);
$sth->{pg_prepare_name} = 'mystat';
$sth->execute(123);

=cut
  
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
