use strict;
use warnings;
use utf8;

use Test::More;
 
use_ok('DBIx::POS::Template');

my $pos = DBIx::POS::Template->instance(__FILE__, template=>{tables=>{foo=>'"Bar1"'}});

isnt($pos, undef, 'undefined');
isa_ok($pos, 'DBIx::POS::Template');
can_ok($pos, qw(new instance template));
isnt($pos->{'тест'}.'', '', 'empty');
isa_ok($pos->{'тест'}, 'DBIx::POS::Statement');
ok($pos->{'тест'}->name eq 'тест', 'attribute');
like($pos->{'тест'}->template(tables=>{foo=>'"Bar2"'}), qr/Bar2/, 'over default 1');
like($pos->{'тест'}.'', qr/Bar1/, 'stringify 1');
like($pos->{'тест'}->template, qr/Bar1/, 'default 1');
ok(ref($pos->{'тест'}->param()) eq 'HASH', 'param');
ok($pos->{'тест'}->param('cached') eq 1, 'param get');
$pos->{'тест'}->param('bla'=>1, 'blah'=>2,);
ok($pos->{'тест'}->param('blah') eq 2, 'param set');
like($pos->{'тест'}->template(where=>'where f.id = ?'), qr/f\.id/, 'template hashref');
like($pos->template('тест', join=>'select * from "Baz1"'), qr/Baz1/, 'template object');

my $pos2 = DBIx::POS::Template->new(__FILE__.'.pod', template=>{tables=>{foo=>'"Foo1"'}});

isnt($pos2, undef, 'undefined 2');
isa_ok($pos2->{'тест'}, 'DBIx::POS::Statement');
can_ok($pos2->{'тест'}, qw(new template name desc sql));
like($pos2->{'тест'}.'', qr/Foo1/, 'stringify 2');
like($pos2->{'тест'}->template(tables=>{foo=>'"Foo2"'}), qr/Foo2/, 'over default 2');
my $st = $pos->template('тест', join => $pos2->{'тест'}->template, );
like($st, qr/Foo1/, 'template 1 on template 2 defaults');
like($st, qr/Bar1/, 'template 1 on template 2 defaults');
ok(scalar keys %$pos eq 1, 'count __FILE__');
ok(scalar keys %$pos2 eq 1, 'count __FILE__.pod');
ok(ref($pos2->{'тест'}->param()) eq undef, 'undef param');

my $pos3 = POS->new();

done_testing;

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
    from {% $tables{foo} %} f
      join ({% $join %}) j on f.id=j.id
  {% $where %}
  order by 1
  ;


=cut

