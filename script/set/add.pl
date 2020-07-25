#!/usr/bin/perl
use strict;
use warnings;
use Toolbox::CombinedCLI;
use Moo::Class::SubjectMeta;
use DBI;
main();

sub main {

	my $clv  = Toolbox::CombinedCLI::get_config();
	my $sm   = Moo::Class::SubjectMeta->new( {dbh => DBI->connect( "dbi:mysql:subject_metadata", 'root', 'rootpassword' )} );
	my $time = time;
	my $ids;
	for my $counter ( 1 ... 10 ) {
		my $res = $sm->add_subject(
			{
				name => "test_subject_$time\_$counter"
			}
		);
		push( @{$ids}, $res->{id} );
	}
	my $set_res = $sm->add_set_def(
		{
			name => "test_set_$time"
		}
	);

	$sm->add_set_subject_stack( \$set_res->{id}, $ids );
	my $back_counter = 0;
	while ( my $back_id = pop( @{$ids} ) ) {
		$back_counter++;
		warn "back id : $back_id ; back counter : $back_counter ";

		$sm->add_set_subject_href(
			\$set_res->{id},
			{
				position => $back_counter,
				id       => $back_id,

			}
		);
	}
	$sm->recalc_all_sets();
}
