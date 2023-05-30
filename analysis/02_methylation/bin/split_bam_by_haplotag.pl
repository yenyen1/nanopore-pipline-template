#!/usr/bin/perl
### Usage: perl split_bam_by_haplotag.pl ${inbam} ${h1.bam} ${h2.bam} ${un.bam}

use strict;
use warnings;

my $inbam = $ARGV[0];
my $h1bam = $ARGV[1];
my $h2bam = $ARGV[2];
my $unbam = $ARGV[3];

open(INBAM, "samtools view -h $inbam |") or die "can not open $inbam $!"; 
open(H1, '>', $h1bam) or die "can not write $h1bam $!";
open(H2, '>', $h2bam) or die "can not write $h2bam $!";
open(UN, '>', $unbam) or die "can not write $unbam $!";

while(<INBAM>){
	if($_ =~/^(\@)/) {
		print H1 $_;
		print H2 $_;
		print UN $_;
	}elsif($_ =~/HP:i:1/){ 
		print H1 $_; 
	}elsif($_ =~/HP:i:2/) { 
		print H2 $_; 
	}else { 
		print UN $_; 
	}	
}
close(H1);
close(H2);
close(UN);
close(INBAM);
