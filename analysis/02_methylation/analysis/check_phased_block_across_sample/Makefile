WDIR=
BAM_DIR=
VCF_DIR=
REF_DIR=
REF=$(REF_DIR)/GCA_000001405.15_GRCh38_no_alt_analysis_set.fasta
WHATSHAP_SIF=


run:
	make extract.vcf sample=$(sample) chr=$(chr)
	make phase.vcf sample=$(sample) type=ont chr=$(chr)
	make phase.vcf sample=$(sample) type=ngs chr=$(chr)
	make stats sample=$(sample) type=ont chr=$(chr)
	make stats sample=$(sample) type=ngs chr=$(chr)

extract.vcf:
	mkdir -p $(WDIR)/vcf/ngs
	mkdir -p $(WDIR)/vcf/ont
	bcftools view -r $(chr) $(VCF_DIR)/ngs/$(sample).hc.vcf.gz \
	       	> $(WDIR)/vcf/ngs/$(sample).ngs.$(chr).vcf
	bcftools view -r $(chr) $(VCF_DIR)/ont/$(sample)_clair3_pass_GQ20_DP10.vcf.gz \
		> $(WDIR)/vcf/ont/$(sample).ont.$(chr).vcf

index.bam:
	samtools index $(BAM_DIR)/$(sample)_ngs.$(chr).bam
	samtools index $(BAM_DIR)/$(sample)_ont.$(chr).bam

phase.vcf:
	$(eval in_vcf=$(WDIR)/vcf/$(type)/$(sample).$(type).$(chr).vcf)
	$(eval in_bam=$(BAM_DIR)/$(sample)_$(type).$(chr).bam)
	$(eval out_vcf=$(WDIR)/vcf/$(type)/phased/$(sample).$(type).$(chr).phased.vcf)
	mkdir -p $(WDIR)/vcf/$(type)/phased
	apptainer exec \
		-B $(REF_DIR) \
		-B $(WDIR) \
		-B $(BAM_DIR) \
		$(WHATSHAP_SIF) whatshap haplotagphase \
		-o $(out_vcf) \
		--reference=$(REF)  \
		$(in_vcf)  \
		$(in_bam)

stats:
	$(eval in_vcf=$(WDIR)/vcf/$(type)/phased/$(sample).$(type).$(chr).phased.vcf)
	$(eval out=$(WDIR)/result/$(sample).$(type).$(chr).phased)
	mkdir -p $(WDIR)/result
	apptainer exec \
		-B $(WDIR) \
		$(WHATSHAP_SIF) whatshap stats \
		--tsv=$(out).stats.tsv \
		--block-list=$(out).block.tsv \
		$(in_vcf)
	
