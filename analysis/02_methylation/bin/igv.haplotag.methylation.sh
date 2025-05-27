#!/use/bin/perl
### Author: yenyen.wang

use strict;
use warnings;

my $gene_list = $ARGV[0];
my $input_dir = $ARGV[1];
my $output_dir = $ARGV[2];

open(GENE_LIST,$gene_list) || die "can not open $gene_list\n";


while(<GENE_LIST>){
	chomp;
	@ans = split(/\t/,$_);
	$gene = $ans[0];
	$location = $ans[1];

print<<"END";

new
snapshotDirectory ${output_dir}
load ${input_dir}/${gene}/family1-1_methylation_${gene}_phased.bam
load ${input_dir}/${gene}/family1-2_methylation_${gene}_phased.bam
load ${input_dir}/CpG_island/cpgIslandExt.bed
goto ${location}
snapshot ${gene}_methyl_haplotag_family1.png

new
snapshotDirectory ${output_dir}
load ${input_dir}/${gene}/family2-1_methylation_${gene}_phased.bam
load ${input_dir}/${gene}/family2-2_methylation_${gene}_phased.bam
load ${input_dir}/CpG_island/cpgIslandExt.bed
goto ${location}
snapshot ${gene}_methyl_haplotag_family2.png

new
snapshotDirectory ${output_dir}
load ${input_dir}/${gene}/family3-1_methylation_${gene}_phased.bam
load ${input_dir}/${gene}/family3-2_methylation_${gene}_phased.bam
load ${input_dir}/${gene}/family3-3_methylation_${gene}_phased.bam
load ${input_dir}/CpG_island/cpgIslandExt.bed
goto ${location}
snapshot ${gene}_methyl_haplotag_family3.png

END

}

print<<"END";
exit

END
