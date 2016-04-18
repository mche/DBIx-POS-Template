package DBIx::POS;
use strict;
use warnings;
use base qw{Pod::Parser};

# Set our version
our $VERSION = '0.00001';

# Hold data for our pending statement
my $info = {};

# Hold our SQL
my %sql;

# What command we're looking at
my $state;

sub new {
    my ($class, $file, %arg) = @_;
    $class->_process( $file, %arg );
    my $new = { %sql };
    %sql = ();
    bless $new, $class;
}

# Taken directly from Class::Singleton---we were already overriding
# _new_instance, and it seemed silly to have an additional dependency
# for four statements.
sub instance {
    my $class = shift;
    # get a reference to the _instance variable in the $class package 
    no strict 'refs';
    my $instance = \${ "$class\::_instance" };

    defined $$instance
        ? $$instance
        : ($$instance = $class->_new_instance(@_));
}

# Does the work of creating a new instance
sub _new_instance {
    my $class = shift;
    $class->_process(@_);
    bless \%sql, $class;
}

sub _process {
    my ($class, $file, %arg) = @_;
    if ( $arg{enc} ) {
        open my $in, "<:encoding($arg{enc})", $file;#
        $class->SUPER::new->parse_from_filehandle($in);
        close $in;
    } else {
        $class->SUPER::new->parse_from_file($file);
    }
    
}

sub template {
    my ($self, $key, %arg) = @_;
    return %arg;
    
}

########### Parser ################

# Handle =whatever commands
sub command {
    my ($self, $command, $paragraph, $line) = @_;

    # Get rid of all trailing whitespace
    $paragraph =~ s/\s+$//ms;

    # There may be a short description right after the command
    if ($command eq 'desc') {
        $info->{desc} = $paragraph || "";
    }

    # The name comes right after the command
    if ($command eq 'name') {
        $self->end_input;
        $info->{name} = $paragraph;
    }

    # The noreturn comes right after the command
    if ($command eq 'noreturn') {
        $info->{noreturn} = 1;
    }

    # Remember what command we're in
    $state = $command;
}

sub end_input {
    my ($self) = @_;
    # If there's stuff to try and construct from
    if (%{$info}) {
        # If we have the necessary bits
        #~ if (scalar (grep {m/^(?:name|short|desc|sql)$/} keys %{$info}) == 3) {
        if (defined($info->{name}) && defined($info->{sql})) {
            # Grab the entire content for the %sql hash
             $sql{$info->{name}} = DBIx::POS::Statement->new ($info);
            # Start with a new empty hashref
            $info = {};
        } else {# Something's missing
            # A nice format for dumping
            #~ use YAML qw{Dump};
            warn "Malformed entry: ", %$info;# . Dump (\%sql, $info);
        }
    }
}


# Handle the blocks of text between commands
sub textblock {
    my ($parser, $paragraph, $line) = @_;

    # Collapse trailing whitespace to a \n
    $paragraph =~ s/\s+$/\n/ms;

    if ($state eq 'desc') {
        $info->{desc} .= $paragraph;
    }

    elsif ($state eq 'param') {
        $info->{param} .= $paragraph;
    }

    elsif ($state eq 'sql') {
        $info->{sql} .= $paragraph;
    }
}

# We handle verbatim sections the same way
sub verbatim {
    my ($parser, $paragraph, $line) = @_;

    # Collapse trailing whitespace to a \n
    $paragraph =~ s/\s+$/\n/ms;

    if ($state eq 'desc') {
        $info->{desc} .= $paragraph;
    }

    elsif ($state eq 'param') {
        $info->{param} .= $paragraph;
    }

    elsif ($state eq 'sql') {
        $info->{sql} .= $paragraph;
    }
}

1;

package DBIx::POS::Statement;

use overload '""' => sub { shift->{sql} };

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
    my $self = shift;
    bless ($self, $class);
    return $self;
}

sub desc {
    my $self = shift;
    $self->{desc} = shift if (@_);
    return $self->{desc};
}

sub name {
    my $self = shift;
    $self->{name} = shift if (@_);
    return $self->{name};
}

sub noreturn {
    my $self = shift;
    $self->{noreturn} = shift if (@_);
    return $self->{noreturn};
}

sub param {
    my $self = shift;
    $self->{param} = shift if (@_);
    return $self->{param};
}

sub short {
    my $self = shift;
    $self->{short} = shift if (@_);
    return $self->{short};
}

sub sql {
    my $self = shift;
    $self->{sql} = shift if (@_);
    return $self->{sql};
}

1;


=encoding utf8

Доброго всем

=head1 DBIx::POS::Template

¡ ¡ ¡ ALL GLORY TO GLORIA ! ! !

=head1 NAME

DBIx::POS::Template - is a fork of L<DBIx::POS>. Define a dictionary of SQL statements in a POD dialect (POS) plus expand template sql with embedded Perl by L<Text::Template>.

=head1 SYNOPSIS

  use DBIx::POS::Template;

  my $sql = DBIx::POS::Template->new(__FILE__, enc=>'utf8');
  # or singleton DBIx::POS::Template->instance($file, ...);
  
  $dbh->selectrow_hashref( $sql->{test1}->template( where => "bar = ?"), undef, ('bla') );
  # or $sql->template('test1',  where => "bar = ?")
  
  =pod

  =name test1

  =desc test the DBIx::POS::Template module

  =param

  Some arbitrary parameter

  =sql

    select * from foo
    where {% $where %}
    ;

  =cut



=head1 DESCRIPTION

DBIx::POS::Template is subclass Pod::Parser to define a POD dialect for writing a
SQL dictionary with templating.

By encouraging the centralization of SQL code, it guards against SQL
statement duplication (and the update problems that can generate).

By separating the SQL code from its normal context of execution, it
encourages you to do other things with it---for instance, it is easy
to create a script that can do performance testing of certain SQL
statements in isolation, or to create generic command-line wrapper
around your SQL statements.

By giving a framework for documenting the SQL, it encourages
documentation of the intent and/or implementation of the SQL code.  It
also provides all of that information in a format from which other
documentation could be generated---say, a chunk of DocBook for
incorporation into a guide to programming the application.

=head2 EXPORT

Nothing is exported. 

=head1 SEE ALSO

L<DBI>

L<Pod::Parser>

L<DBIx::POS>

L<Text::Template>

=head1 AUTHOR

Михаил Че (Mikhail Che), C<< <mche [on] cpan.org> >>

=head1 BUGS / CONTRIBUTING

Please report any bugs or feature requests at L<https://github.com/mche/DBIx-POS-Template/issues>. Pull requests also welcome.

=head1 COPYRIGHT

Copyright 2016 Mikhail Che.

This module is free software; you can redistribute it and/or modify it under 
the term of the Perl itself.

=cut
