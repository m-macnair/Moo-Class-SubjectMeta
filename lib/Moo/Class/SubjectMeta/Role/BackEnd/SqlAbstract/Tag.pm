
use strict; # applies to all packages defined in the file

package Moo::Class::SubjectMeta::Role::BackEnd::SqlAbstract::Tag;
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
		TAGDEF: {
			has tag_def => (
				is      => 'rw',
				lazy    => 1,
				default => 'tag_def'
			);
			has tag_def_name => (
				is      => 'rw',
				lazy    => 1,
				default => 'name'
			);
			has tag_def_id => (
				is      => 'rw',
				lazy    => 1,
				default => 'id'
			);

			has tag_def_search_cols => (
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
		}
		CLOUD: {
			has tag_cloud => (
				is      => 'rw',
				lazy    => 1,
				default => 'tag_cloud'
			);
			has tag_cloud_tag_id => (
				is      => 'rw',
				lazy    => 1,
				default => 'tag_id'
			);

			has tag_cloud_subject_id => (
				is      => 'rw',
				lazy    => 1,
				default => 'subject_id'
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

our $VERSION = '0.0';

##~ DIGEST : 516777ae87b5a961e3a5cacec775c399

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

#add tag definitions
sub tag_subject {
	my ( $self, $subject_def, $tag_string ) = @_;

	my $subject_id = $self->find_subject_or_die( $subject_def );

	my $id_to_tag_map = $self->_tag_string_to_map( $tag_string );

	$self->filter_existing_tags( $subject_id, $id_to_tag_map, {in_place => 1} );

	for my $tag_id ( keys( %{$id_to_tag_map} ) ) {
		$self->insert(
			$self->tag_cloud,
			{
				$self->tag_cloud_subject_id() => $subject_id,
				$self->tag_cloud_tag_id       => $tag_id,
			}
		);
	}
}

sub untag_subject {
	my ( $self, $subject_def, $tag_string ) = @_;
	my $subject_id    = $self->find_subject_or_die( $subject_def );
	my $id_to_tag_map = $self->_tag_string_to_map( $tag_string );
	$self->delete(
		$self->tag_cloud,
		{
			$self->tag_cloud_subject_id => $subject_id,
			$self->tag_cloud_tag_id     => [ keys( %{$id_to_tag_map} ) ]
		}
	);

}

# TODO super daft crazy optimisation
sub search_tags_to_subject {
	my ( $self, $search_string, $opt ) = @_;
	my ( %yes, %no );

	my $first_yes;
	for my $tag ( @{$self->_get_tag_array( $search_string )} ) {

		#add negator?
		if ( index( $tag, '!' ) == 0 ) {
			$tag = substr( $tag, 1 );
			my $res = $self->find_tag_def( {$self->tag_def_name() => $tag} );
			Carp::confess( "Unknown tag $tag" ) unless $res->{id};
			$no{$res->{id}} = $tag;
		} else {
			my $res = $self->find_tag_def( {$self->tag_def_name() => $tag} );
			Carp::confess( "Unknown tag $tag" ) unless $res->{id};
			if ( $first_yes ) {
				$yes{$res->{id}} = $tag;
			} else {
				$first_yes = $res->{id};
			}
		}
	}
	my $intersect = [];
	for my $key ( keys( %yes ) ) {
		$self->build_nested( [ {column => $self->tag_cloud_tag_id, value => $key} ], $intersect );
	}

	#  die Dumper($intersect);
	# 	warn $self->tag_cloud;
	my $sth = $self->mselect(
		[
			-from    => $self->tag_cloud,
			-columns => $self->tag_cloud_subject_id,
			-where, {$self->tag_cloud_tag_id() => 3},

			# 		-intersect => [
			# 			-where , { tagdef_id => 1},
			# 			-intersect , [
			# 				-where , {tagdef_id => 2}
			# 			]
			# 		]
			-intersect => $intersect,
		]
	);
	print Dumper( $sth->fetchall_arrayref() );
}

sub _get_tag_array {
	my ( $self, $tag_string ) = @_;
	my @tag_strings;
	if ( index( $tag_string, $self->tag_separator() ) != -1 ) {
		@tag_strings = split( $self->tag_separator(), $tag_string );
	} else {
		@tag_strings = ( $tag_string );
	}
	return \@tag_strings;
}

sub _tag_string_to_map {
	my ( $self, $tag_string ) = @_;

	my $id_to_tag_map;
	for my $tag ( @{$self->_get_tag_array( $tag_string )} ) {

		my $tag_res = $self->add_tag_def(
			{
				$self->tag_def_name => $tag
			}
		);
		if ( $tag_res->{id} ) {
			$id_to_tag_map->{$tag_res->{id}} = $tag;
		} else {
			Carp::confess( "Failed to generate or retrieve a tag id using $tag as " . $self->tag_def_name() );
		}
	}
	return $id_to_tag_map;
}

sub filter_existing_tags {
	my ( $self, $subject_id, $id_to_tag_map, $opt ) = @_;
	$opt ||= {};

	#may be wise to deep copy here

	my $new_map;
	if ( $opt->{in_place} ) {
		$new_map = $id_to_tag_map;
	} else {
		$new_map = {%{$id_to_tag_map}};
	}

	my $res = $self->select(
		$self->tag_cloud(),
		[qw/id/],
		{
			$self->tag_cloud_subject_id => $subject_id,
			$self->tag_def_id           => [ keys( %{$id_to_tag_map} ) ],
		}
	);

	while ( my $row = $res->fetchrow_arrayref() ) {

		delete( $new_map->{$row->[0]} );
	}

	return $new_map;
}

# in some way, detect and return the id of the newest subject
sub new_tag_def_id {
	my ( $self ) = @_;
	$self->last_insert_id();
}

sub find_tag_def {
	my ( $self, $tag_def ) = @_;
	return $self->generic_get( 'tag_def', $tag_def );
}

sub add_tag_def {
	my ( $self, $def ) = @_;

	#find existing first
	my $found = $self->find_tag_def( $def );
	if ( $found ) {
		return {id => $found->{$self->tag_def_id}};
	} else {
		$self->insert( $self->tag_def, $def );

		return {
			new => 1,
			id  => $self->new_tag_def_id()
		};
	}
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