package DBIx::POS::Template;
use strict;
use warnings;
use base qw{Pod::Parser};

# Set our version
our $VERSION = '0.00005';

# Hold data for our pending statement
my $info = {};

# Hold our SQL
my %sql;

# What command we're looking at
my $state;

# Text::Template->new(%TT, %{$arg{tt}})
our %TT = (
    DELIMITERS => ['{%', '%}'],
    #~ BROKEN => sub { die @_;},
);

# separate object
sub new {
    my ($class, $file, %arg) = @_;
    my %back = %sql;
    %sql = ();
    $class->_process( $file, %arg );
    my $new = { %sql, $arg{tt} ? (_tt => $arg{tt}) : (), };
    %sql = %back;
    bless $new, $class;
}

# Taken directly from Class::Singleton
sub instance {
    my $class = shift;
    # get a reference to the _instance variable in the $class package 
    no strict 'refs';
    my $instance = \${ "$class\::_instance" };

    defined $$instance
        ? $$instance
        : ($$instance = $class->_instance(@_));
}

sub _instance {
    my ($class, $file, %arg) = @_;
    $class->_process( $file, %arg );
    # merge prev tt opts
    @{$sql{_tt}}{ keys %{$arg{tt}} } = values %{$arg{tt}}
        if $arg{tt};
    bless \%sql, $class;
    
}

sub _process {# pos file
    my ($class, $file, %arg) = @_;
    return unless $file;
    $file .='.pm'
        if $file =~ s/::/\//g;
    if ( $arg{enc} ) {
        open my $in, "<:encoding($arg{enc})", $file
            or die "Cant open [$file]: $!";#
        $class->SUPER::new->parse_from_filehandle($in);
        close $in;
    } else {
        $class->SUPER::new->parse_from_file($file);
    }
    
}

sub template {
    my ($self, $key, %arg) = @_;
    die "No such item by key [$key] on this POS, please check processed file(s)"
        unless $self->{$key};
    $self->{$key}->template(%arg);
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
            $sql{$info->{name}} = DBIx::POS::Statement->new ($sql{_tt}, $info);
            $sql{$info->{name}}->_eval_param() if $sql{$info->{name}}->param;
            # Start with a new empty hashref
            $info = {};
        } else {# Something's missing
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
use Text::Template;

use overload '""' => sub { shift->{sql} };

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
    my $tt = shift || {};
    my $self = shift;
    $self->{_tt} = $tt;
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

sub param {# ->param() |  ->param('foo') | ->param('foo'=>'bar')
    my $self = shift;
    return unless $self->{param};
    return $self->{param} unless @_;
    return $self->{param}{shift()} if @_ == 1;
    $self->{param}{ shift() } = shift;
}

sub _eval_param {
    my $self = shift;
    #~ warn "\n---------------\n$self->{param}\n===========\n";
    my $param = eval $self->{param};
    die "Malformed perl code param [$self->{param}]: $@" if $@;
    $self->{param} = $param;
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

sub template {
    my ($self, %arg) = @_;
    return $self->sql
        unless scalar %arg;
    $self->{_template} ||= Text::Template->new(
        TYPE => 'STRING',
        SOURCE => $self->sql,
        %TT,
        %{$self->{_tt}},
    );
    $self->{_template}->fill_in(HASH=>\%arg,);#BROKEN_ARG=>\'error!', BROKEN => sub { die @_;},
}

1;


=pod

=encoding utf8

Доброго всем

=head1 DBIx::POS::Template

¡ ¡ ¡ ALL GLORY TO GLORIA ! ! !

=head1 VERSION

0.00005

=head1 NAME

DBIx::POS::Template - is a fork of L<DBIx::POS>. Define a dictionary of SQL statements in a POD dialect (POS) plus expand template sql with embedded Perl using L<Text::Template>.

=head1 SYNOPSIS

  use DBIx::POS::Template;

  # separate object
  my $pos = DBIx::POS::Template->new(__FILE__, enc=>'utf8');
  # or singleton DBIx::POS::Template->instance($file, ...);
  
  my $sql = $pos->{test1}->template(where => "bar = ?");
  # or $pos->template('test1', where => "bar = ?")
  
  =pod

  =name test1

  =desc test the DBIx::POS::Template module

  =param
  
  # Some arbitrary parameters as perl code (eval)
  {
    cache=>1,
  }

  =sql

    select * from foo
    {% $where %}
    ;

  =cut



=head1 DESCRIPTION

DBIx::POS::Template is subclass Pod::Parser to define a POD dialect for writing a SQL dictionary(s) with templating.

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

This class whould work as separate objects per pod-file or as singleton for all processed files with one dictionary of them.

=head1 METHODS

=head2 new($file, <options>)

Create separate object and process $file POS with options:

=over 4

=item * B<enc> (STRING)

Encoding of POD content file. ()

=item * B<tt> (HASHREF)

Some options will passing to Text::Template->new() for each parsed statement. By default only defined option 

    DELIMITERS => ['{%', '%}'],

=back

=head2 instance($file, <options>)

Return singleton dictionary object, parsed $file keys will collapse/override with previous files. Same options as C<new>, I<tt> option merge with previous options of instance invokes.

=head2 template($key, var1 => ..., var2 => ...)

Fill in dictionary sql with variables by L<Text::Template#HASH>. Other syntax:

    $pos->{$key}->template(var1 => ..., var2 => ...)

=head1 SEE ALSO

L<Pod::Parser>

L<DBIx::POS>

L<Text::Template>

=head1 AUTHOR

Михаил Че (Mikhail Che), C<< <mche[-at-]cpan.org> >>

=head1 BUGS / CONTRIBUTING

Please report any bugs or feature requests at L<https://github.com/mche/DBIx-POS-Template/issues>. Pull requests also welcome.

=head1 COPYRIGHT

Copyright 2016 Mikhail Che.

This module is free software; you can redistribute it and/or modify it under the term of the Perl itself.

=cut
