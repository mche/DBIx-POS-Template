package POS;
use lib 'lib';
use DBIx::POS::Template;

sub new {DBIx::POS::Template->new(__FILE__, @_);}

=pod

=encoding utf8

=name тест

=desc test the DBIx::POS::Template module

=sql

  select * from {% $tables{foo} %};


=cut

1;