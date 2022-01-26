#!/usr/bin/perl

use strict;
use warnings;
use HTTP::Tiny;

## Cluster rep ids
my $unirefIDs = $ARGV[0];
my %ids = ();

my ($html,$response, $response1, $response2, $url, $content, $fasta, $gff); 
my %members = (); my %format = (); my @arr = []; 

open (FILE, $unirefIDs) or die "Can not load $unirefIDs\n";

while (<FILE>){
	chomp $_;
	$ids{$_} = 1;	
}
close (FILE);

#grabs rep clusters and members
foreach my $id (keys %ids){
	$url = "https://www.uniprot.org/uniref/?query=$id&format=tab&columns=id,members";
	$response = HTTP::Tiny->new->get($url);
	if ($response->{success}){
		    my $html = $response->{content};	
		    chomp $html; 
					    
			if($html =~ /^$/){
				next;
			}
			else{					
				$members{$id} = $html;
			}	
	} 
	else {
	    print "Failed: $response->{status} $response->{reasons}\n";
	}
}

#format api output 
foreach my $id (keys %members){

	chomp $id;
	$members{$id} =~ s/Cluster ID//;
	$members{$id} =~ s/Cluster members//;
	$members{$id} =~ s/$id//;
	$members{$id} =~ s/;//g;
	@arr = split(" ", $members{$id});
	push @{ $format{$id} }, @arr;

}


#pulls cluster member fasta and gff data
open (FASTA, '>', "id_pull.fasta");
open (GFF, '>', "id_pull.gff");
open (SUMMARY, '>', "id_pull_summary");

foreach my $id (keys %format){

	foreach my $val ( @{$format{$id}}){

        	$fasta = "https://www.uniprot.org/uniref/?query=$val&format=fasta";
        	$gff   = "https://www.uniprot.org/uniref/?query=$val&format=gff";

		$response1 = HTTP::Tiny->new->get($gff);
		$response2 = HTTP::Tiny->new->get($fasta);
         if ($response1->{success} || $response2->{success}){
                    my $html1 = $response1->{content};
		    my $html2 = $response2->{content};

                    chomp $html1;
		    chomp $html2;

                        if($html1 =~ /^$/ || $html2 =~ /^$/ ){
                                next;
                        }

		                #summary of data printed in mmseqs style cluster output	
                        else{   print SUMMARY "$id\t$val\n";
				print GFF   $html1;
				print FASTA $html2;
                        }

        }
        else {
            print "Failed: $response1->{status} $response1->{reasons}\n";
	    print "Failed: $response2->{status} $response2->{reasons}\n"
        }
      }
}

close (SUMMARY);
close (GFF);
close(FASTA);

exit 0;
