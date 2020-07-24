use strict; # applies to all packages defined in the file

package Moo::Class::SubjectMeta::Role::Core;
use 5.006;
use warnings;
use Moo::Role;
use Carp qw/confess/;
ACCESSORS: {
	has tag_separator => (
		is      => 'rw',
		lazy    => 1,
		default => ' '
	);
}

sub small_maintenance {

	return 1;

}

sub big_maintenance {

	return 1;

}
1;
