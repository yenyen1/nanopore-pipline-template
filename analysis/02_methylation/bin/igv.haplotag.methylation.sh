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
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/phased/GDCM035-301_methylation_${gene}_phased.bam
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/phased/GDCM035-401_methylation_${gene}_phased.bam
load /home/yenyenw/data/CpG_island/cpgIslandExt.bed
goto ${location}
snapshot ${gene}_methyl_haplotag_family035.png

new
snapshotDirectory ${output_dir}
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/phased/GDCM048-301_methylation_${gene}_phased.bam
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/phased/GDCM048-401_methylation_${gene}_phased.bam
load /home/yenyenw/data/CpG_island/cpgIslandExt.bed
goto ${location}
snapshot ${gene}_methyl_haplotag_family048.png

new
snapshotDirectory ${output_dir}
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/phased/GDCM144-201_methylation_${gene}_phased.bam
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/phased/GDCM144-301_methylation_${gene}_phased.bam
load /lustre07/scratch/yenyenw/Mathyl/OUTPUT/DCM/phased/GDCM144-302_methylation_${gene}_phased.bam
load /home/yenyenw/data/CpG_island/cpgIslandExt.bed
goto ${location}
snapshot ${gene}_methyl_haplotag_family144.png

END

}

print<<"END";
exit

END
