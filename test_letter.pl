#!/opt/local/bin/perl

use strict;
use Test::More ;
use lib '.';

BEGIN {
	use_ok('Trie::Letter');
}

my $trie = Trie::Letter->new();

#check the API is working correctly
isa_ok($trie, 'Trie::Letter');
can_ok($trie, 'insert');
can_ok($trie, 'count');
can_ok($trie, 'lookup');
can_ok($trie, 'cleanup_word');
can_ok($trie, 'split_word');
can_ok($trie, 'remove');
can_ok($trie, 'length_word');

#are the words cleaning up correctly
is($trie->cleanup_word('HELLO  '), 'HELLO', 'check if words cleanup correctly');
is($trie->cleanup_word(' HELlO '), 'HELlO', 'check if words cleanup correctly');
is($trie->length_word('hello'), 5, 'check if word length "hello" is 5');

#do some inserts in the trie
foreach my $i (1..5) {
	is($trie->insert('hello'), $trie, 'insert "hello" and receive self');
}
#check the counts are returned correctly
is($trie->count('hello'), 5, 'check "hello" count is 5');
is($trie->count('world'), 0, 'check "world" count is 0');

#remove a word from the trie
is($trie->insert('hella'), $trie, 'insert "hella" and receive self');
is($trie->count('hella'), 1, 'check "hella" count is 1');

is($trie->remove('hello'), $trie, 'check "hello" remove and receive self');
is($trie->count('hello'), 0, 'Removing "hello" should have count at 0');
is($trie->count('hella'), 1, 'check "hella" count is still 1');

is_deeply($trie->edits('hela'), 'hella', "testing if 'hela' is respelled to 'hella'");

done_testing();