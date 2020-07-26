use strict; # applies to all packages defined in the file

package Moo::Class::SubjectMeta::Role::BackEnd::SqlAbstract;
our $VERSION = '0.5';
##~ DIGEST : 5edf662314dd9c2c089fd8798d7f0235
use 5.006;
use warnings;
use Moo::Role;
use Carp qw/confess/;
with qw/
  Moo::GenericRole::DB
  Moo::GenericRole::DB::MariaMysql
  Moo::GenericRole::DB::Abstract
  /;

=head1 NAME
	Moo::Class::SubjectM
=head1 VERSION & HISTORY
	<feature>.<patch>
	0.00 - 2020-06-28
		The mk1
=cut

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

use Data::Dumper;

sub generic_get {

	my ( $self, $accessor_root, $def ) = @_;
	my $search_accessor = "$accessor_root\_search_cols";
	my $search_def      = {};
	for my $col ( @{$self->$search_accessor} ) {
		if ( exists( $def->{$col} ) ) {
			$search_def->{$col} = $def->{$col};
		}
	}
	warn Dumper( $search_def );
	Carp::Confess( "empty search definition" ) unless %{$search_def};
	return $self->get( $self->$accessor_root, $search_def );

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
