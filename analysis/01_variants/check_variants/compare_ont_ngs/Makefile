SAMPLES=

test:
	for s in $(SAMPLES) ; do \
		echo "sample: $$s" ; \
		make gen.tsv.by.dcm.gene sample=$$s type=snps trial=NCBI_Refseq target=dcm_exon ;\
		make gen.tsv.by.dcm.gene sample=$$s type=snps trial=gencode43 target=dcm_gene ;\
	done

extract.format.txt: #sample=
	$(eval in=ont/$(sample)_merge_output.vcf.gz)
	$(eval out=ont/$(sample)_FORMAT)
	bcftools view -v snps -f 'PASS' -H $(in) | \
	       	awk '{print $$1":"$$2":"$$6":"$$10}' | \
	       	awk -F":" '{print $$1,$$2,$$3,$$4,$$5,$$6,$$7}' > $(out)_snp.txt 
	bcftools view -v indels -f 'PASS' -H $(in) | \
		awk '{print $$1":"$$2":"$$6":"$$10}' | \
		awk -F":" '{print $$1,$$2,$$3,$$4,$$5,$$6,$$7}' > $(out)_indel.txt 

qc.ont:
	$(eval in=ont/$(sample)_merge_output.vcf.gz)
	$(eval out=ont/$(sample)_pass_output.vcf.gz)
	bcftools view -Oz -f 'PASS' -o $(out) $(in) 
	tabix -p vcf $(in)
	tabix -p vcf $(out)

qc.ngs:
	$(eval in=ngs/$(sample).hc.vcf.gz)
	$(eval out=ngs/$(sample)_DP10_GQ20.vcf.gz)
	bcftools view -i'GQ>=20 & FORMAT/DP>=10' -O z -o $(out) $(in)
	tabix -p vcf $(in)
	tabix -p vcf $(out)

merge:
	$(eval ont_raw=ont/$(sample)_merge_output.vcf.gz)
	$(eval ont_pass=ont/$(sample)_pass_output.vcf.gz)
	$(eval ngs_qc=ngs/$(sample)_DP10_GQ20.vcf.gz)
	$(eval out_raw=merged_vcf/$(sample)_merge_raw.vcf.gz)
	$(eval out_qc=merged_vcf/$(sample)_merge_both_qc.vcf.gz)
	mkdir -p merged_vcf
	bcftools merge -m both -O z -o $(out_raw) $(ngs_qc) $(ont_raw) 
	bcftools merge -m both -O z -o $(out_qc) $(ngs_qc) $(ont_pass) 

check.merge: #sample, chr, type
	$(eval ont_raw=ont/$(sample)_merge_output.vcf.gz)
	$(eval ont_pass=ont/$(sample)_pass_output.vcf.gz)
	$(eval ngs_qc=ngs/$(sample)_DP10_GQ20.vcf.gz)
	$(eval out_raw=merged_vcf/$(sample)_merge_raw.vcf.gz)
	$(eval out_qc=merged_vcf/$(sample)_merge_both_qc.vcf.gz)
	@echo "NGS after QC: `bcftools view -H -v $(type) -t $(chr) $(ngs_qc) | wc -l`"
	@echo "NGS after merge ONT_raw: `bcftools view -H -v $(type) -t $(chr) $(out_raw) | awk 'substr($$10,1,3)!="./."{print substr($$10,1,3)}' | wc -l`"
	@echo "NGS after merge ONT_qc: `bcftools view -H -v $(type) -t $(chr) $(out_qc) | awk 'substr($$10,1,3)!="./."{print substr($$10,1,3)}' | wc -l`"
	@echo "ONT before QC: `bcftools view -H -v $(type) -t $(chr) $(ont_raw) | wc -l`"
	@echo "ONT only pass: `bcftools view -H -v $(type) -t $(chr) $(ont_pass) | wc -l`"
	@echo "ONT after merge ONT_raw: `bcftools view -H -v $(type) -t $(chr) $(out_raw) | awk 'substr($$11,1,3)!="./."{print substr($$11,1,3)}' | wc -l`"
	@echo "ONT after merge ONT_qc: `bcftools view -H -v $(type) -t $(chr) $(out_qc) | awk 'substr($$11,1,3)!="./."{print substr($$11,1,3)}' | wc -l`"
	

gen.tsv: #sample= type=
	$(eval in_raw=merged_vcf/$(sample)_merge_raw.vcf.gz)
	$(eval in_qc=merged_vcf/$(sample)_merge_both_qc.vcf.gz)
	$(eval out_raw=merged_tsv/$(sample)_merge_raw_$(type).tsv)
	$(eval out_qc=merged_tsv/$(sample)_merge_qc_$(type).tsv)
	mkdir -p merged_tsv
	bcftools view -v $(type) -H $(in_raw) | \
		grep -v "\./\."  | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[4],c[1],c[3],c[4]}' > $(out_raw)
	bcftools view -v $(type) -H $(in_raw) | awk 'substr($$10,1,3)=="./."{print $$0}' | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[2],c[1],c[3],c[2]}' >> $(out_raw)
	bcftools view -v $(type) -H $(in_raw) | awk 'substr($$11,1,3)=="./."{print $$0}' | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[4],c[1],c[3],c[4]}' >> $(out_raw)
	bcftools view -v $(type) -H $(in_qc) | \
		grep -v "\./\."  | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[4],c[1],c[3],c[4]}' > $(out_qc)
	bcftools view -v $(type) -H $(in_qc) | awk 'substr($$10,1,3)=="./."{print $$0}' | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[2],c[1],c[3],c[2]}' >> $(out_qc)
	bcftools view -v $(type) -H $(in_qc) | awk 'substr($$11,1,3)=="./."{print $$0}' | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[4],c[1],c[3],c[4]}' >> $(out_qc)

check.tsv:
	$(eval ont_raw=ont/$(sample)_merge_output.vcf.gz)
	$(eval ont_pass=ont/$(sample)_pass_output.vcf.gz)
	$(eval ngs_qc=ngs/$(sample)_DP10_GQ20.vcf.gz)
	$(eval out_raw=merged_vcf/$(sample)_merge_raw.vcf.gz)
	$(eval out_qc=merged_vcf/$(sample)_merge_both_qc.vcf.gz)
	$(eval raw_tsv=merged_tsv/$(sample)_merge_raw_$(type).tsv)
	$(eval qc_tsv=merged_tsv/$(sample)_merge_qc_$(type).tsv)
	@echo "NGS after QC: `bcftools view -H -v $(type) -t $(chr) $(ngs_qc) | wc -l`"
	@echo "NGS after merge ONT_raw: `bcftools view -H -v $(type) -t $(chr) $(out_raw) | awk 'substr($$10,1,3)!="./."{print substr($$10,1,3)}' | wc -l`"
	@echo "NGS after merge ONT_qc: `bcftools view -H -v $(type) -t $(chr) $(out_qc) | awk 'substr($$10,1,3)!="./."{print substr($$10,1,3)}' | wc -l`"
	@echo "NGS in ONT_raw tsv: `cat $(raw_tsv) | awk '$$1=="$(chr)"{print $$5}' | grep -v "\./\." | wc -l`"
	@echo "NGS in ONT_qc tsv: `cat $(qc_tsv) | awk '$$1=="$(chr)"{print $$5}' | grep -v "\./\." | wc -l`"
	@echo "ONT before QC: `bcftools view -H -v $(type) -t $(chr) $(ont_raw) | wc -l`"
	@echo "ONT after merge ONT_raw: `bcftools view -H -v $(type) -t $(chr) $(out_raw) | awk 'substr($$11,1,3)!="./."{print substr($$11,1,3)}' | wc -l`"
	@echo "ONT in ONT_raw tsv: `cat $(raw_tsv) | awk '$$1=="$(chr)"{print $$8}' | grep -v "\./\." | wc -l`"
	@echo "ONT only pass: `bcftools view -H -v $(type) -t $(chr) $(ont_pass) | wc -l`"
	@echo "ONT after merge ONT_qc: `bcftools view -H -v $(type) -t $(chr) $(out_qc) | awk 'substr($$11,1,3)!="./."{print substr($$11,1,3)}' | wc -l`"
	@echo "ONT in ONT_qc tsv: `cat $(qc_tsv) | awk '$$1=="$(chr)"{print $$8}' | grep -v "\./\." | wc -l`"

extract.whole.gene.exon.vcf: #sample, trial
	$(eval in_raw=merged_vcf/$(sample)_merge_raw.vcf.gz)
	$(eval in_qc=merged_vcf/$(sample)_merge_both_qc.vcf.gz)
	$(eval out_raw_gene=merged_vcf/$(sample)_merge_raw_$(trial)_gene.vcf.gz)
	$(eval out_raw_exon=merged_vcf/$(sample)_merge_raw_$(trial)_exon.vcf.gz)
	$(eval out_qc_gene=merged_vcf/$(sample)_merge_both_qc_$(trial)_gene.vcf.gz)
	$(eval out_qc_exon=merged_vcf/$(sample)_merge_both_qc_$(trial)_exon.vcf.gz)
	$(eval gene_bed=gtf_data/gene.$(trial).chr.bed)
	$(eval exon_bed=gtf_data/exon.$(trial).uniq.chr.bed)
	bcftools view -R $(gene_bed) -Oz -o $(out_raw_gene) $(in_raw) 
	bcftools view -R $(exon_bed) -Oz -o $(out_raw_exon) $(in_raw) 
	bcftools view -R $(gene_bed) -Oz -o $(out_qc_gene) $(in_qc) 
	bcftools view -R $(exon_bed) -Oz -o $(out_qc_exon) $(in_qc) 


gen.tsv.by.whole.gene: #sample= type= trial= target=
	$(eval in_raw=merged_vcf/$(sample)_merge_raw_$(trial)_$(target).vcf.gz)
	$(eval in_qc=merged_vcf/$(sample)_merge_both_qc_$(trial)_$(target).vcf.gz)
	$(eval out_raw=merged_tsv/by_gene/$(sample)_merge_raw_$(trial)_$(target)_$(type).tsv)
	$(eval out_qc=merged_tsv/by_gene/$(sample)_merge_qc_$(trial)_$(target)_$(type).tsv)
	mkdir -p merged_tsv/by_gene
	bcftools view -v $(type) -H $(in_raw) | \
		grep -v "\./\."  | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[4],c[1],c[3],c[4]}' > $(out_raw)
	bcftools view -v $(type) -H $(in_raw) | awk 'substr($$10,1,3)=="./."{print $$0}' | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[2],c[1],c[3],c[2]}' >> $(out_raw)
	bcftools view -v $(type) -H $(in_raw) | awk 'substr($$11,1,3)=="./."{print $$0}' | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[4],c[1],c[3],c[4]}' >> $(out_raw)
	bcftools view -v $(type) -H $(in_qc) | \
		grep -v "\./\."  | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[4],c[1],c[3],c[4]}' > $(out_qc)
	bcftools view -v $(type) -H $(in_qc) | awk 'substr($$10,1,3)=="./."{print $$0}' | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[2],c[1],c[3],c[2]}' >> $(out_qc)
	bcftools view -v $(type) -H $(in_qc) | awk 'substr($$11,1,3)=="./."{print $$0}' | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[4],c[1],c[3],c[4]}' >> $(out_qc)

extract.gene.exon.list.vcf: #sample, trial=NCBI_Refseq, gencode43
	$(eval in_raw=merged_vcf/$(sample)_merge_raw.vcf.gz)
	$(eval in_qc=merged_vcf/$(sample)_merge_both_qc.vcf.gz)
	$(eval out_raw_gene=merged_vcf/$(sample)_merge_raw_$(trial)_gene.vcf.gz)
	$(eval out_raw_exon=merged_vcf/$(sample)_merge_raw_$(trial)_exon.vcf.gz)
	$(eval out_qc_gene=merged_vcf/$(sample)_merge_both_qc_$(trial)_gene.vcf.gz)
	$(eval out_qc_exon=merged_vcf/$(sample)_merge_both_qc_$(trial)_exon.vcf.gz)
	$(eval gene_bed=gtf_data/DCM_genes_$(trial).bed)
	$(eval exon_bed=gtf_data/DCM_exons_$(trial).bed)
	bcftools view -R $(gene_bed) -Oz -o $(out_raw_gene) $(in_raw) 
	bcftools view -R $(exon_bed) -Oz -o $(out_raw_exon) $(in_raw) 
	bcftools view -R $(gene_bed) -Oz -o $(out_qc_gene) $(in_qc) 
	bcftools view -R $(exon_bed) -Oz -o $(out_qc_exon) $(in_qc) 


gen.tsv.by.gene.list: #sample= type= trial= target=gene exon
	$(eval in_raw=merged_vcf/$(sample)_merge_raw_$(trial)_$(target).vcf.gz)
	$(eval in_qc=merged_vcf/$(sample)_merge_both_qc_$(trial)_$(target).vcf.gz)
	$(eval out_raw=merged_tsv/by_gene/$(sample)_merge_raw_$(trial)_$(target)_$(type).tsv)
	$(eval out_qc=merged_tsv/by_gene/$(sample)_merge_qc_$(trial)_$(target)_$(type).tsv)
	bcftools view -v $(type) -H $(in_raw) | \
		grep -v "\./\."  | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[4],c[1],c[3],c[4]}' > $(out_raw)
	bcftools view -v $(type) -H $(in_raw) | awk 'substr($$10,1,3)=="./."{print $$0}' | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[2],c[1],c[3],c[2]}' >> $(out_raw)
	bcftools view -v $(type) -H $(in_raw) | awk 'substr($$11,1,3)=="./."{print $$0}' | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[4],c[1],c[3],c[4]}' >> $(out_raw)
	bcftools view -v $(type) -H $(in_qc) | \
		grep -v "\./\."  | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[4],c[1],c[3],c[4]}' > $(out_qc)
	bcftools view -v $(type) -H $(in_qc) | awk 'substr($$10,1,3)=="./."{print $$0}' | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[2],c[1],c[3],c[2]}' >> $(out_qc)
	bcftools view -v $(type) -H $(in_qc) | awk 'substr($$11,1,3)=="./."{print $$0}' | \
		awk 'BEGIN{OFS="\t"}{split($$10,b,":"); split($$11,c,":"); print $$1,$$2,$$4,$$5,b[1],b[3],b[4],c[1],c[3],c[4]}' >> $(out_qc)

