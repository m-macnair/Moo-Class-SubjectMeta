#!/usr/bin/perl
use strict;
use warnings;
use Toolbox::CombinedCLI;
use Moo::Class::SubjectMeta;
use DBI;
main();

sub main {

	my $clv = Toolbox::CombinedCLI::get_config();
	my $sm  = Moo::Class::SubjectMeta->new( {dbh => DBI->connect( "dbi:mysql:subject_metadata", 'root', 'rootpassword' )} );
	#
	# 	my $numbers = $sm->get_subject_tag_id_stack(1);
	# 	print "$/numbers: " . join(',',@{$numbers});
	my $strings = $sm->get_subject_tag_string_stack( 1 );
	print "$/strings: " . join( ',', @{$strings} );

}
