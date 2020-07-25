use strict; # applies to all packages defined in the file

package Moo::Class::SubjectMeta::Role::BackEnd::SqlAbstract::Subject;
use 5.006;
use warnings;
use Moo::Role;
use Carp qw/confess/;
use Data::Dumper;
with qw/
  Moo::Class::SubjectMeta::Role::BackEnd::SqlAbstract
  /;
ACCESSORS: {
	TABLEDEFS: {
		SUBJECT: {
			has subject_table => (
				is      => 'rw',
				lazy    => 1,
				default => 'subject_table'
			);

			has subject_table_search_cols => (
				is      => 'rw',
				lazy    => 1,
				default => sub {
					return [
						qw/
						  name
						  /
					];
				}
			);
			has subject_table_id => (
				is      => 'rw',
				lazy    => 1,
				default => 'id'
			);
		}
	}
}

=head1 NAME
	Moo::Class::SubjectM
=head1 VERSION & HISTORY
	<feature>.<patch>
	0.00 - 2020-06-28
		The mk1
=cut

our $VERSION = '0.6';
##~ DIGEST : bdde7372b1dc8bd713422899d5581081

=head1 SYNOPSIS
	TODO
=head2 TODO
	Generall planned work
=head1 EXPORT
=head1 SUBROUTINES/METHODS
=head2 PRIMARY
=head2 Subject Manipulation
=head3 tag_subject
	add a subject definition, returning the id
=cut

# in some way, detect and return the id of the newest subject
sub new_subject_id {

	my ( $self ) = @_;
	$self->last_insert_id(),;

}

sub find_subject {

	my ( $self, $def ) = @_;
	return $self->generic_get( $self->subject_table, $def );

}

sub find_subject_or_die {

	my ( $self, $def ) = @_;
	my $subject_res = $self->find_subject( $def );
	unless ( $subject_res->{id} ) {
		Carp::confess( "Could not find a subject with subject def " . Dumper( $def ) );
	}
	return $subject_res->{id};

}

sub add_subject {

	my ( $self, $def ) = @_;

	#find existing first
	my $found = $self->find_subject( $def );
	if ( $found ) {
		return {id => $found->{$self->subject_table_id}};
	} else {
		$self->insert( $self->subject_table, $def );
		return {
			new => 1,
			id  => $self->new_subject_id()
		};
	}

}

after 'big_maintenance' => sub {
	my ( $self ) = @_;
	$self->update_alias();
	$self->update_implies();
};

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
