#!/usr/bin/perl
use strict;
use warnings;
use Toolbox::CombinedCLI;
use Moo::Class::SubjectMeta;
use DBI;
main();

sub main {
	my $clv = Toolbox::CombinedCLI::get_config();
	my $sm  = Moo::Class::SubjectMeta->new(
		{
			dbh => DBI->connect( "dbi:mysql:subject_metadata", 'root', 'rootpassword' )
		}
	);
	$sm->search_tags_to_subject( 'test1 test2 !test3 test4' );

}
