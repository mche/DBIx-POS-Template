package POS;
#~ use lib 'lib';
use DBIx::POS::Template;

sub new {shift; DBIx::POS::Template->new(__FILE__, @_);}

=pod

=encoding utf8

=name тест

=sql

  select * from {% $tables{foo} %};

=name тест2

=sql

  select * from {% $tables{foo2} %};

=cut

1;