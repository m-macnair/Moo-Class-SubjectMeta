#!/usr/bin/perl
use strict;
use warnings;
use Toolbox::CombinedCLI;
use Moo::Class::SubjectMeta;
use DBI;
main();

sub main {

	my $clv  = Toolbox::CombinedCLI::get_config();
	my $sm   = Moo::Class::SubjectMeta->new( { dbh => DBI->connect( "dbi:mysql:subject_metadata", 'root', 'rootpassword' ) } );
	my $time = time;
	$sm->add_tag_def( {
			name => "funky",
		}
	);
	$sm->add_tag_def( {
			name => "fnucky$time",
		}
	);
	$sm->add_tag_def( {
			name => "fresh",
		}
	);
	$sm->add_tag_def( {
			name => "beats",
		}
	);
	$sm->add_alias( "fnucky$time", "funky" );
	$sm->add_implies( "funky", "fresh beats" );
	$sm->big_maintenance();

}
