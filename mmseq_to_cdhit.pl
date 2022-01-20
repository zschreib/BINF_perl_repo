#!/usr/bin/perl

use strict;
use warnings;

my $cdhit = $ARGV[0];
my %ids = ();
my $count = 0;
my @arr = [];


open (FILE, $cdhit) or die "Can not find file\n";
	
	while(<FILE>){
		chomp $_;
		@arr = split('\t', $_);
		push( @{ $ids{$arr[0]}}, $arr[1]);		
	}	  
close FILE;

foreach my $orf (keys %ids){
	print ">Cluster $count\n";
	foreach (@{$ids{$orf}}){
	print "$_\n";
	}	
	$count++;
}			
