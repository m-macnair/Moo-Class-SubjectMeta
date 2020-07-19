use strict; # applies to all packages defined in the file

package Moo::Class::SubjectMeta::Role::BackEnd::SqlAbstract;
use 5.006;
use warnings;
use Moo::Role;
use Carp qw/confess/;

with qw/
  Moo::Role::DB
  Moo::Role::DB::Abstract
  Moo::Role::DB::Abstract::More

  /;

ACCESSORS: {
	TABLEDEFS: {
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

=head1 NAME
	Moo::Class::SubjectM
=head1 VERSION & HISTORY
	<feature>.<patch>
	0.00 - 2020-06-28 
		The mk1
=cut

our $VERSION = '0.1';

##~ DIGEST : 34b74781e67c0d50dcf01e619be62934

=head1 SYNOPSIS
	TODO
=head2 TODO
	Generall planned work
=head1 EXPORT
=head1 SUBROUTINES/METHODS
=head2 PRIMARY
=head3 add_subject
	add a subject definition, returning the id
=cut

# in some way, detect and return the id of the newest subject
sub new_subject_id {
	my ( $self ) = @_;
	$self->last_insert_id(),;
}

sub find_subject {
	my ( $self, $def ) = @_;
	return $self->generic_get( 'subject_table', $def );
}

sub find_subject_or_die {
	my ( $self, $def ) = @_;
	my $subject_res = $self->find_subject( $def );
	unless ( $subject_res->{id} ) {
		Carp::confess( "Could not find a subject with subject def " . Dumper( $def ) );
	}

	return $subject_res->{id};

}

sub generic_get {
	my ( $self, $accessor_root, $def ) = @_;

	my $search_accessor = "$accessor_root\_search_cols";
	my $search_def      = {};
	for my $col ( @{$self->$search_accessor} ) {
		$search_def->{$col} = $def->{$col};
	}
	Carp::Confess( "empty search definition" ) unless %{$search_def};
	return $self->get( $self->$accessor_root, $search_def );

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

=head2 SECONDARY
=head3 tag_to_tag_id
	add a subject definition, returning the id
=cut

sub tag_to_tag_id {
	my ( $self, $search_string, $opt ) = @_;

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
