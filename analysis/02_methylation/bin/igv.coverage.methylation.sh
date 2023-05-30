#!/use/bin/perl
### Author: yenyen.wang

use strict;
use warnings;

my $gene_list = $ARGV[0];
my $output_dir = $ARGV[1];

open(GENE_LIST,$gene_list) || die "can not open $gene_list\n";


while(<GENE_LIST>){
	chomp;
	@ans = split(/\t/,$_);
	$gene = $ans[0];
	$location = $ans[1];

print<<"END";

new
snapshotDirectory ${output_dir}
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM035-301_methylation_${gene}.bam 
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM035-401_methylation_${gene}.bam 
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM040-301_methylation_${gene}.bam 
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM048-301_methylation_${gene}.bam 
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM048-401_methylation_${gene}.bam 
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM056-301_methylation_${gene}.bam 
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM069-301_methylation_${gene}.bam 
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM094-301_methylation_${gene}.bam 
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM119-301_methylation_${gene}.bam 
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM144-201_methylation_${gene}.bam 
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM144-301_methylation_${gene}.bam 
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM144-302_methylation_${gene}.bam 
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM148-301_methylation_${gene}.bam 
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/${gene}/GDCM167-301_methylation_${gene}.bam 
load /home/yenyenw/data/CpG_island/cpgIslandExt.bed

goto ${location}
snapshot ${gene}_methyl_coverge_zoomin.png

END

}

print<<"END";

exit

END




