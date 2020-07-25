use strict; # applies to all packages defined in the file

package Moo::Class::SubjectMeta::Role::BackEnd::SqlAbstract::Set;
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
		SETS: {
			has set_def => (
				is      => 'rw',
				lazy    => 1,
				default => 'set_def'
			);
			has set_def_name => (
				is      => 'rw',
				lazy    => 1,
				default => 'name'
			);
			has set_def_id => (
				is      => 'rw',
				lazy    => 1,
				default => 'id'
			);
			has set_def_subjects => (
				is      => 'rw',
				lazy    => 1,
				default => 'subjects'
			);
			has set_def_recalc => (
				is      => 'rw',
				lazy    => 1,
				default => 'recalc'
			);
			has set_def_search_cols => (
				is      => 'rw',
				lazy    => 1,
				default => sub {
					return [
						qw/
						  id
						  name
						  /
					];
				}
			);
		}
		CLOUD: {
			has set_cloud => (
				is      => 'rw',
				lazy    => 1,
				default => 'set_cloud'
			);

			has set_cloud_id => (
				is      => 'rw',
				lazy    => 1,
				default => 'id'
			);

			has set_cloud_set_id => (
				is      => 'rw',
				lazy    => 1,
				default => 'set_id'
			);
			has set_cloud_subject_id => (
				is      => 'rw',
				lazy    => 1,
				default => 'subject_id'
			);
			has set_cloud_stamp => (
				is      => 'rw',
				lazy    => 1,
				default => 'stamp'
			);
			has set_cloud_position => (
				is      => 'rw',
				lazy    => 1,
				default => 'position'
			);
			has set_cloud_position_spacer => (
				is      => 'rw',
				lazy    => 1,
				default => 10
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

our $VERSION = '0.7';
##~ DIGEST : 5cafdcc838c5563add430041714310a9

=head1 SYNOPSIS
	TODO
=head2 TODO
	General planned work
=head1 EXPORT
=head1 SUBROUTINES/METHODS
=head2 PRIMARY
=head2 Set Manipulation
=cut

sub add_set_subject_stack {
	my ( $self, $set, $subject_stack ) = @_;

	my $set_def = $self->_shared_set_def( $set );

	#get max id in existing set
	my $set_status = $self->get_set_status( $set_def->{$self->set_def_id} );
	my $position   = $set_status->{$self->set_cloud_position};
	for my $subject_id ( @{$subject_stack} ) {
		$position += $self->set_cloud_position_spacer();

		# 		warn "added position for $subject_id is $position";
		$self->insert(
			$self->set_cloud,
			{
				$self->set_cloud_set_id     => $set_def->{$self->set_def_id},
				$self->set_cloud_position   => $position,
				$self->set_cloud_subject_id => $subject_id
			}
		);
		$self->commitmaybe();
	}
	$self->commithard();
}

sub add_set_subject_href {
	my ( $self, $set, $subject_href ) = @_;
	my $set_def    = $self->_shared_set_def( $set );
	my $bound_low  = $subject_href->{position} * $self->set_cloud_position_spacer();
	my $bound_high = $bound_low + $self->set_cloud_position_spacer() - 1;
	my $max_string = 'max(' . $self->set_cloud_position . ')';
	warn "bound low $bound_low ; bound high : $bound_high";

	#check existing;
	my $max = $self->select(
		$self->set_cloud,
		[ \$max_string ],
		{
			$self->set_cloud_set_id => $set_def->{$self->set_def_id},
			-and                    => [
				{$self->set_cloud_position => {'>=' => $bound_low}},

				#force break
				{$self->set_cloud_position => {'<=' => $bound_high}}
			]
		}
	)->fetchrow_arrayref->[0]
	  || 0;
	if ( $max == $bound_high ) {
		die "redo after set recalc";
	} else {

		$self->delete(
			$self->set_cloud,
			{
				$self->set_cloud_set_id     => $set_def->{$self->set_def_id},
				$self->set_cloud_subject_id => $subject_href->{id},
			}
		);
		$max ||= $bound_low;
		warn "new position for $subject_href->{id}, is $max +1";
		$self->insert(
			$self->set_cloud,
			{
				$self->set_cloud_set_id     => $set_def->{$self->set_def_id},
				$self->set_cloud_subject_id => $subject_href->{id},
				$self->set_cloud_position   => $max + 1
			}
		);
	}
	$self->flag_recalc_set( \$set_def->{$self->set_def_id} );
	$self->commithard();
}

sub recalc_set_positions {
	my ( $self, $set_def, $p ) = @_;
	$p ||= {};

	my $sth = $self->select(
		$self->set_cloud,
		['*'],
		{
			$self->set_cloud_set_id => $set_def->{$self->set_def_id},
		},
		{
			-asc => $self->set_cloud_position
		}
	);
	my $counter = 0;
	while ( my $set_entry_row = $sth->fetchrow_hashref() ) {
		$counter++;
		$self->update(
			$self->set_cloud,
			{
				$self->set_cloud_position => ( $counter * $self->set_cloud_position_spacer() )
			},
			{
				$self->set_cloud_id() => $set_entry_row->{$self->set_cloud_id()},
			}
		);
		$self->commitmaybe();
	}
	$self->commithard();

}

sub flag_recalc_set {
	my ( $self, $set ) = @_;
	my $set_def = $self->_shared_set_def( $set );
	$self->update(
		$self->set_def,
		{
			$self->set_def_recalc => 1,
		},
		{
			$self->set_def_id => $set_def->{$self->set_def_id}
		}
	);
}

sub recalc_all_sets {
	my ( $self, $p ) = @_;
	$p ||= {};

	my $sth = $self->select(
		$self->set_def(),
		['*'],
		{
			$self->set_def_recalc => 1,
		},
	);
	while ( my $set_def = $sth->fetchrow_hashref() ) {
		$self->recalc_set_positions( $set_def );

	}

}

sub _shared_set_def {
	my ( $self, $set ) = @_;
	my $set_def;
	if ( ref( $set ) eq 'SCALAR' ) {
		$set_def = $self->find_set_def(
			{
				$self->set_def_id => $$set
			}
		);
		unless ( $set_def ) {
			Carp::confess( "set id $$set not found" );
		}
	} else {

		$set_def = $self->find_set_def(
			{
				$self->set_def_name => $set
			}
		);
		unless ( $set_def ) {
			Carp::confess( "set string $set not found" );
		}
	}
	return $set_def;
}

sub add_set_def {

	my ( $self, $def ) = @_;

	#find existing first
	my $found = $self->find_set_def( $def );
	if ( $found ) {
		return {id => $found->{$self->set_def_id}};
	} else {
		$self->insert( $self->set_def, $def );
		return {
			new => 1,
			id  => $self->new_set_def_id()
		};
	}

}

sub find_set_def {

	my ( $self, $set_def ) = @_;
	return $self->generic_get( $self->set_def, $set_def );

}

sub get_set_status {
	my ( $self, $set_id, $p ) = @_;
	$p ||= {};
	my $return;

	unless ( $p->{skip_max} ) {
		my $max_string = 'max(' . $self->set_cloud_position . ')';
		$return->{max} = $self->select(
			$self->set_cloud(),
			[ \$max_string ],
			{
				$self->set_cloud_set_id => $set_id
			}
		)->fetchrow_arrayref()->[0];
	}

	return $return; #return!
}

# in some way, detect and return the id of the newest subject
sub new_set_def_id {

	my ( $self ) = @_;
	$self->last_insert_id();

}

=head3 
=cut

after 'big_maintenance' => sub {
	my ( $self ) = @_;
	$self->recalc_all_sets();

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
