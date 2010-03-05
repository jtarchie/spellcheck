package Trie::Letter;

use strict;
use base 'Class::Base';

sub init {
	my ($self, $config) = @_;
	
	$self->{root} = {};
	
	return $self;
}

sub insert {
	my ($self, $word) = @_;
	
	$word = $self->cleanup_word($word);
	my $node = $self->{root};
	
	foreach my $letter ($self->split_word($word)) {
		$node->{$letter} ||= {};
		$node = $node->{$letter};
	}
	
	$node->{_count}++;
	$node->{_word} = $word;
	
	return $self;
}

sub count {
	my ($self, $word) = @_;
	
	my $node = $self->lookup($word);

	return $node->{_count} || 0;
}

sub lookup {
	my ($self, $word) = @_;
	
	$word = $self->cleanup_word($word);
	my $node = $self->{root};
	
	foreach my $letter ($self->split_word($word)) {
		unless (exists $node->{$letter}) {
			return undef;
		}
		$node = $node->{$letter};
	}
	
	return $node;
}

sub remove {
	my ($self, $word) = @_;
	
	$word = $self->cleanup_word($word);
	my ($head, $tail) = (substr($word, 0, -1), substr($word, -1, 1));
	
	my $node = $self->lookup($head);
	
	delete($node->{$tail}->{_count});
	delete($node->{$tail}->{_word});
	if (scalar(keys %{$node->{$tail}}) == 0) {
		delete $node->{$tail};
	}
	
	return $self;
}

sub cleanup_word {
	my ($self, $word) = @_;

	chomp($word);
	#$word = lc($word);
	$word =~ s/^\s+//g;
	$word =~ s/\s+$//g;
	
	return $word;
}

sub split_word {
	my ($self, $word) = @_;
	
	return split(//, $word);
}

sub length_word {
	my ($self, $word) = @_;
	
	return length($word);
}

sub edits {
	my ($self, $word, $depth, $results, $node) = @_;
	
	$word = $self->cleanup_word($word);
	$results ||= {};
	$depth = 2 unless defined($depth);
	$node ||= $self->{root};
	
	#print "$node $depth '$word'\n";
	
	if ($self->length_word($word) == 0 && $depth >= 0 && $node->{_word} ne '') {
		$results->{$node->{'_word'}} = 1;
	}
	
	if ($depth >= 1) {
		# deletion. [remove the current letter, and try it on the current branch--see what happens]
		if ($self->length_word($word) > 1) {
			$self->edits(substr($word, 1), $depth - 1, $results);
		} else {
			$self->edits("", $depth - 1, $results);
		}

		foreach my $letter (keys %{$node}) {
			next if $letter =~ /^_/;
		
			my $branch = $node->{$letter};
			
			# insertion. [pass the current word, no changes, to each of the branches for processing]
			$self->edits($word, $depth - 1, $results, $branch);
		
			# substitution. [pass the current word, sans first letter, to each of the branches for processing]
			if ($self->length_word($word) > 1) {
				$self->edits(substr($word, 1), $depth - 1, $results, $branch);
			} else {
				$self->edits("", $depth - 1, $results, $branch);
			}
		}
		
		# transposition. [swap the first and second letters]
		if ($self->length_word($word) > 2) {
			$self->edits(substr($word, 1, 1) . substr($word, 0, 1) . substr($word, 2), $depth - 1, $results, $node);
		} elsif ($self->length_word($word) == 2) {
			$self->edits(substr($word, 1, 1) . substr($word, 0, 1), $depth - 1, $results, $node);
		}
	}

	# move on to the next letter. (no edits have happened)

	if ($self->length_word($word) >= 1 && $node->{substr($word, 0, 1)}) {
		my $letter = substr($word, 0, 1);
		if ($self->length_word($word) > 1) {
			$self->edits(substr($word, 1), $depth, $results, $node->{$letter});
		} elsif ($self->length_word($word) == 1) {
			$self->edits("", $depth, $results, $node->{$letter});
		}
	}

	# results are stored in a hash to prevent duplicate words
	return keys %{$results};
}

1;