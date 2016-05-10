use strict;
use warnings;
use utf8;

use Test::More tests => 20;
 
use_ok('DBIx::POS::Template');

my $pos = DBIx::POS::Template->instance(__FILE__, enc=>'utf8');

isnt($pos, undef, 'undefined');
isa_ok($pos, 'DBIx::POS::Template');
can_ok($pos, qw(new instance template));
isnt($pos->{'тест'}.'', '', 'empty key');
isa_ok($pos->{'тест'}, 'DBIx::POS::Statement');
ok($pos->{'тест'}->name eq 'тест', 'attribute');
like($pos->{'тест'}, qr/foo/, 'content 1');
ok(ref($pos->{'тест'}->param()) eq 'HASH', 'param');
ok($pos->{'тест'}->param('cached') eq 1, 'param get');
$pos->{'тест'}->param('bla'=>1, 'blah'=>2,);
ok($pos->{'тест'}->param('blah') eq 2, 'param set');
like($pos->{'тест'}->template(where=>'bar = ?'), qr/bar/, 'template hashref');
like($pos->template('тест', where=>'baz = ?'), qr/baz/, 'template object');

my $pos2 = DBIx::POS::Template->new(__FILE__.'.pod', enc=>'utf8');

isnt($pos2, undef, 'undefined 2');
isa_ok($pos2->{'тест'}, 'DBIx::POS::Statement');
can_ok($pos2->{'тест'}, qw(new template name desc sql));
like($pos2->{'тест'}, qr/bar/, 'content 2');
like($pos->template('тест', join => $pos2->{'тест'}->sql, where=>'bla = ?'), qr/bar/, 'template object 2');
ok(scalar keys %$pos eq 1, 'count __FILE__');
ok(scalar keys %$pos2 eq 1, 'count __FILE__.pod');


=pod

=encoding utf8

=name тест

=desc test the DBIx::POS::Template module

=param

##Some arbitrary parameters as perl code (eval)
{ 
  cached=>1,
}

=sql

  select *
    from foo f
      join ({% $join %}) j on f.id=j.id
  where {% $where %}
  order by 1
  ;


=cut