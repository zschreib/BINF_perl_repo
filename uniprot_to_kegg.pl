#!/usr/bin/perl

use strict;
use warnings;
use HTTP::Tiny;

my $unirefIDs = $ARGV[0];
my %ids = ();

my $response;
my $url;
my $content;

open (FILE, $unirefIDs) or die "Can not load $unirefIDs\n";

while (<FILE>){
	chomp $_;
	$ids{$_} = 1;	
}
close (FILE);

foreach my $id (keys %ids){
	$url = "http://rest.kegg.jp/conv/genes/uniprot:$id";
	$response = HTTP::Tiny->new->get($url);
	if ($response->{success}){
		    my $html = $response->{content};
		    chomp $html; 

			if($html =~ /^$/){
				next;
			}
			else{
				print $html . "\n";
			}
		    
	} 
	else {
	    print "Failed: $response->{status} $response->{reasons}\n";
	}
}

exit 0;
