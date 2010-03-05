#!/opt/local/bin/perl

use strict;
use Test::More;
use lib '.';

BEGIN {
	use_ok('Trie::Word');
}

my $trie = Trie::Word->new();

#check the API is working correctly
isa_ok($trie, 'Trie::Letter');
can_ok($trie, 'insert');
can_ok($trie, 'count');
can_ok($trie, 'lookup');
can_ok($trie, 'cleanup_word');
can_ok($trie, 'split_word');
can_ok($trie, 'remove');
can_ok($trie, 'length_word');

done_testing();