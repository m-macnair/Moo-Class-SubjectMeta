#!/usr/bin/perl
use strict;
use warnings;
use Toolbox::CombinedCLI;
use Moo::Class::SubjectMeta;
use DBI;
use Data::Dumper;
main();

sub main {

	my $clv = Toolbox::CombinedCLI::get_config();
	my $sm  = Moo::Class::SubjectMeta->new( { dbh => DBI->connect( "dbi:mysql:subject_metadata", 'root', 'rootpassword' ) } );
	print Dumper( $sm->search_tags_to_subject_id_stack('test1 test2 !test3 test4') );

}
