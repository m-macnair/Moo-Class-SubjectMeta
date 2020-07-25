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
			has tag_def_subjects => (
				is      => 'rw',
				lazy    => 1,
				default => 'subjects'
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
			has tag_cloud_stamp => (
				is      => 'rw',
				lazy    => 1,
				default => 'stamp'
			);
		}
		IMPLIES: {
			has tag_implies => (
				is      => 'rw',
				lazy    => 1,
				default => 'tag_implies'
			);
			has tag_implies_source_tag_id => (
				is      => 'rw',
				lazy    => 1,
				default => 'source_tag_id'
			);
			has tag_implies_target_tag_id => (
				is      => 'rw',
				lazy    => 1,
				default => 'target_tag_id'
			);
		}
		ALIAS: {
			has tag_alias => (
				is      => 'rw',
				lazy    => 1,
				default => 'tag_alias'
			);
			has tag_alias_source_tag_id => (
				is      => 'rw',
				lazy    => 1,
				default => 'source_tag_id'
			);
			has tag_alias_target_tag_id => (
				is      => 'rw',
				lazy    => 1,
				default => 'target_tag_id'
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

our $VERSION = '0.5';
##~ DIGEST : ed5ae9fc043296041fcd00e0bee8331c

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

sub add_subject_tags {

	my ( $self, $subject_def, $tag_string ) = @_;
	my $subject_id    = $self->find_subject_or_die( $subject_def );
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
		$self->commitmaybe();
	}
	$self->commithard();
}

#add tag definitions
sub tag_subject {
	my $self = shift;
	Carp::cluck( "obsolete method" );
	$self->add_subject_tag( @_ );

}

sub del_subject_tags {

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
	$self->commithard();
}

sub untag_subject {
	my $self = shift;
	Carp::cluck( "obsolete method" );
	$self->del_subject_tags( @_ );

}

# TODO super daft crazy optimisation
# sub search_tags_to_subject {
# 	die "Not yet implemented at generic level";
# # 	my ( $self, $search_string, $opt ) = @_;
# # 	my ( %yes, %no );
#
#
# # 	my $first_yes;
# # 	for my $tag ( @{$self->_get_tag_array( $search_string )} ) {
# #
# # 		#add negator?
# # 		if ( index( $tag, '!' ) == 0 ) {
# # 			$tag = substr( $tag, 1 );
# # 			my $res = $self->find_tag_def( {$self->tag_def_name() => $tag} );
# # 			Carp::confess( "Unknown tag $tag" ) unless $res->{id};
# # 			$no{$res->{id}} = $tag;
# # 		} else {
# # 			my $res = $self->find_tag_def( {$self->tag_def_name() => $tag} );
# # 			Carp::confess( "Unknown tag $tag" ) unless $res->{id};
# # 			if ( $first_yes ) {
# # 				$yes{$res->{id}} = $tag;
# # 			} else {
# # 				$first_yes = $res->{id};
# # 			}
# # 		}
# # 	}
# # 	my $intersect = [];
# # 	for my $key ( keys( %yes ) ) {
# # 		$self->build_nested( [ {column => $self->tag_cloud_tag_id, value => $key} ], $intersect );
# # 	}
# #
# # 	#  die Dumper($intersect);
# # 	# 	warn $self->tag_cloud;
# # 	my $sth = $self->mselect(
# # 		[
# # 			-from    => $self->tag_cloud,
# # 			-columns => $self->tag_cloud_subject_id,
# # 			-where, {$self->tag_cloud_tag_id() => 3},
# #
# # 			# 		-intersect => [
# # 			# 			-where , { tagdef_id => 1},
# # 			# 			-intersect , [
# # 			# 				-where , {tagdef_id => 2}
# # 			# 			]
# # 			# 		]
# # 			-intersect => $intersect,
# # 		]
# # 	);
# # 	print Dumper( $sth->fetchall_arrayref() );
# }

=head3 get_subject_tag_id_stack

=cut

sub get_subject_tag_id_stack {

	my ( $self, $subject, $p ) = @_;

	#shared
	$p ||= {};
	my $method = $self->_method_name();

	#unique
	my $sth = $self->select( $self->tag_cloud(), [ $self->tag_cloud_tag_id ], {$self->tag_cloud_subject_id => $subject} );
	if ( $method ) {
		return $self->$method( $sth );
	}
	return $self->get_column_array( $sth );

}

# TODO correct the join here
sub get_subject_tag_string_stack {

	my ( $self, $subject, $p ) = @_;

	#shared
	$p ||= {};
	my $method = $self->_method_name();

	#unique
	my $tag_ids = $self->get_subject_tag_id_stack( $subject );
	my $sth     = $self->select( $self->tag_def(), [ $self->tag_def_name ], {$self->tag_def_id => $tag_ids} );
	if ( $method ) {
		return $self->$method( $sth );
	}
	return $self->get_column_array( $sth );

}

# TODO figure out why I wanted this
sub get_subject_tag_hash_stack {

	my ( $self, $subject, $p ) = @_;

	#shared
	$p ||= {};
	my $method = $self->_method_name();

}

=head3 search_tags_to_subject
	mariadb doesn't do intersect and i've broken my head on doing this in dbix::class::schema, so lets try moving it into a pure perl problem instead of 2^n inner joins. might actually work better with query caching
=cut

# TODO paging
sub search_tags_to_subject_id_stack {

	my ( $self, $search_string, $opt ) = @_;
	my $weighted = $self->_get_weighted_tag_id_array( $search_string );
	my $ids;
	my $orderetc = {-asc => $self->tag_cloud_subject_id};
	while ( my $this_tag_id = shift( @{$weighted} ) ) {
		my $search = {$self->tag_cloud_tag_id => $this_tag_id,};
		if ( $ids ) {
			$search->{$self->tag_cloud_subject_id} = {-in => $ids};
		}
		my $qstack = [ $self->tag_cloud(), [ $self->tag_cloud_subject_id ], $search ];

		#add order & paging clauses if this is the last tag being searched
		unless ( ${$weighted}[0] ) {
			push( @{$qstack}, $orderetc );
		}
		my $this_sth = $self->select( @{$qstack} );
		$ids = [];
		while ( my $row = $this_sth->fetchrow_arrayref() ) {
			push( @{$ids}, $row->[0] );
		}
	}
	return $ids;

}

# in some way, detect and return the id of the newest subject
sub new_tag_def_id {

	my ( $self ) = @_;
	$self->last_insert_id();

}

=head2 Tag Retrieval
=cut

sub _get_tag_array {

	my ( $self, $tag_string, $p ) = @_;
	$p ||= {};
	my $return = [];
	if ( $p->{method} ) {
		unless ( $self->can( $p->{method} ) ) {
			Carp::confess( "unsupported tag_string_to_array method ; $p->{method}" );
		}
		my $m = $p->{method};
		for my $tag ( split( $self->tag_separator(), $tag_string ) ) {
			my ( $res, $status ) = $self->$m( $tag );
			if ( $res ) {
				push( @{$return}, $res );
			}
		}
	} else {
		for ( split( $self->tag_separator(), $tag_string ) ) {
			push( @{$return}, $_ );
		}
	}
	return $return; #return!

}

=head3 _get_weighted_tag_array
	get rarest tags first
=cut

sub _get_weighted_tag_id_array {

	my ( $self, $tag_string, $p ) = @_;
	$p ||= {};
	my $return = [];
	my $sth    = $self->select(
		$self->tag_def(),
		[ $self->tag_def_id ],
		{
			$self->tag_def_name => {-in => [ split( $self->tag_separator, $tag_string ) ]},
		},
		{-asc => [ $self->tag_def_subjects ]}
	);
	return $self->get_column_array( $sth );

}

sub _tag_string_to_map {

	my ( $self, $tag_string ) = @_;
	my $id_to_tag_map;
	for my $tag ( @{$self->_get_tag_array( $tag_string )} ) {
		my $tag_res = $self->add_tag_def( {$self->tag_def_name => $tag} );
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

sub find_tag_def {

	my ( $self, $tag_def ) = @_;
	return $self->generic_get( $self->tag_def, $tag_def );

}

#TODO caching
sub get_tag_name_id {

	my ( $self, $tag_name ) = @_;
	my $row = $self->generic_get( $self->tag_def, {name => $tag_name} );
	return $row->{id};

}

#TODO caching

=head3 get_tag_string_ids
	For when we don't care much about the details, we just want the ids
=cut

sub get_tag_string_ids {

	my ( $self, $tag_string, $p ) = @_;
	my $sth = $self->select(
		$self->tag_def(),
		[ $self->tag_def_id ],
		{
			$self->tag_def_name => {-in => [ split( $self->tag_separator, $tag_string ) ]},
		},
	);
	return $self->get_column_array( $sth );

}

=head2 Tag Manipulation
=cut

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

sub add_alias {

	my ( $self, $source_name, $target_name ) = @_;
	my $source_id = $self->get_tag_name_id( $source_name );
	Carp::confess( "source name $source_name does not map to an id" ) unless $source_id;
	my $target_id = $self->get_tag_name_id( $target_name );
	Carp::confess( "target name $target_name does not map to an id" ) unless $target_id;
	$self->insert(
		$self->tag_alias,
		{
			$self->tag_alias_source_tag_id() => $source_id,
			$self->tag_alias_target_tag_id() => $target_id,
		}
	);
	$self->commithard();

}

sub add_implies {

	my ( $self, $source_name, $target_string ) = @_;
	my $source_id = $self->get_tag_name_id( $source_name );
	Carp::confess( "source name $source_name does not map to an id" ) unless $source_id;
	my $alias_tag_ids = $self->get_tag_string_ids( $target_string );
	Carp::confess( "target string [$target_string] did not produce any tag ids" ) unless @{$alias_tag_ids};
	for my $target_id ( @{$alias_tag_ids} ) {
		$self->insert(
			$self->tag_implies,
			{
				$self->tag_alias_source_tag_id() => $source_id,
				$self->tag_alias_target_tag_id() => $target_id,
			}
		);
		$self->commitmaybe();
	}
	$self->commithard();

}

# TODO make less awful
sub update_alias {

	my ( $self, $p ) = @_;
	my $alias_set_sth = $self->select( $self->tag_alias, [ $self->tag_alias_source_tag_id, $self->tag_alias_target_tag_id, ], );
	while ( my $alias_row = $alias_set_sth->fetchrow_hashref() ) {
		$self->update(
			$self->tag_cloud,
			{
				$self->tag_cloud_tag_id => $alias_row->{$self->tag_alias_target_tag_id},
			},
			{
				$self->tag_cloud_tag_id => $alias_row->{$self->tag_alias_source_tag_id},
			}
		);
		$self->commitmaybe();
	}
	$self->commithard();

}

# TODO make much less awful
sub update_implies {

	my ( $self, $p ) = @_;
	my $implies_set_sth = $self->select( $self->tag_implies, [ $self->tag_implies_source_tag_id, $self->tag_implies_target_tag_id, ], );
	while ( my $implies_row = $implies_set_sth->fetchrow_arrayref() ) {
		my $implies_subject_sth = $self->select( $self->tag_cloud, [ $self->tag_cloud_subject_id ], {$self->tag_cloud_tag_id => $implies_row->[0]} );
		while ( my $implied_tag_row = $implies_subject_sth->fetchrow_arrayref() ) {
			$self->insert(
				$self->tag_cloud,
				{
					$self->tag_cloud_subject_id => $implied_tag_row->[0],
					$self->tag_cloud_tag_id     => $implies_row->{$self->tag_cloud_subject_id}
				}
			);
			$self->commitmaybe();
		}
	}
	$self->commithard();

}

=head2 Misc
=cut

sub _method_name {

	my ( $self, $p ) = @_;
	if ( $p->{method} ) {
		if ( $self->can( $p->{method} ) ) {
			return $p->{method};
		} else {
			Carp::confess( "unsupported method ; $p->{method}" );
		}
	}
	return;

}

sub debug {

	return 1;

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
