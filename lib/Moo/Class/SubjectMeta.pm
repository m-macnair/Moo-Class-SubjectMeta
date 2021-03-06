use strict; # applies to all packages defined in the file

package Moo::Class::SubjectMeta;
use 5.006;
use warnings;
use Moo;
with qw/
  Moo::Class::SubjectMeta::Role::BackEnd::SqlAbstract::Subject
  Moo::Class::SubjectMeta::Role::BackEnd::SqlAbstract::Set
  Moo::Class::SubjectMeta::Role::BackEnd::SqlAbstract::Tag
  Moo::Class::SubjectMeta::Role::BackEnd::SqlAbstract
  Moo::Class::SubjectMeta::Role::Core
  /;

=head1 NAME
	~
=head1 VERSION & HISTORY
	<feature>.<patch>
	0.01 - <date>
		<actions>
	0.00 - <date unless same as above>
		<actions>
=cut

our $VERSION = '0.07';
##~ DIGEST : b2ea07d1d575848e788f1036424be328

=head1 SYNOPSIS
	TODO
=head2 TODO
	Generall planned work
=head1 EXPORT
=head1 SUBROUTINES/METHODS
=head2 SETUP
=head3 new
=cut

=head3 _init
	Separate class instantiation and configuration for when that's a good idea (i.e. it's overwritten in child classes)
=cut

sub _init {

	my ( $self, $conf ) = @_;
	return {pass => 1};

}

=head2 PRIMARY SUBS
	"The $thing the module is used for", usually implemented as wrappers around private functions
=head3 new
	create, config, return
=cut

sub do_something {

	my ( $self, $p ) = @_;
	$self->validate_some_value( $p, 'the_thing' );
	$self->_do_something( $p );

}

=head2 SECONDARY SUBS
	Actions used by one or more PRIMARY SUBS that aren't wrappers or accessors
=cut

sub validate_some_value {

	my ( $self, $p, $value ) = @_;
	die unless ( $p->{$value} );

}

=head2 ACCESSORS
=head3 getsomething
=cut

sub getsomething {

}

=head2 WRAPPERS
=head3 external_function
=cut

=head1 AUTHOR
	mmacnair, C<< <mmacnair at cpan.org> >>
=head1 BUGS
	TODO Bugs
=head1 SUPPORT
	TODO Support
=head1 ACKNOWLEDGEMENTS
	TODO
=head1 COPYRIGHT
	Copyright 2019 mmacnair.
=head1 LICENSE
	TODO
=cut

1;
