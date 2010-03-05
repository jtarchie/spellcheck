#!/opt/local/bin/perl

use strict;
use lib '.';
use Trie::Letter;
use Storable;

my $dir = "./sources";

my $trie = Trie::Letter->new();

unless (-e "letters.dat") {
	#build trie of words
	my @filenames = files($dir);
	foreach my $filename (@filenames) {
		print "filename: $filename\n";
		open(my $fh, "$dir/$filename") || die "cannot open $filename: $!";
		while(my $line = <$fh>) {
			chomp($line);
			$trie->insert($_) foreach (split(/\s+/, $line));
		}
	}
	store($trie, 'letters.dat');
} else{
	$trie = retrieve('letters.dat');
}

print join("\n", $trie->edits('access'));

sub files {
	my $dir = shift;
	
	opendir(my $dh, $dir) || die "cannot opendir $dir: $!";
	my @files = grep {-f "$dir/$_"} readdir($dh);
	closedir($dh);
	
	return @files;
}