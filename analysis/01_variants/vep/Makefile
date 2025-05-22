#workspace
WDIR=

#apptainer 
VEP_SIF=


split.vcf.by.chr:
	$(eval in_pre=$(WDIR)/merged.snv)
	$(eval out_pre=$(WDIR)/chr/merged.snv)
	mkdir -p $(WDIR)/chr
	for i in `seq 1 22`; do \
		echo $${i} ;\
		bcftools view  -r "chr$${i}" -Oz -o $(out_pre).$${i}.vcf.gz $(in_pre).vcf.gz ;\
		tabix $(out_pre).$${i}.vcf.gz ;\
	done;

test.run: #in_vcf=, out_vcf
	apptainer exec $(VEP_SIF) vep \
		-i $(in_vcf) \
		-o $(out_vcf) \
		--cache \
		--dir vep_data/ \
		--everything \
		--vcf 

run.with.fields:
	apptainer exec $(VEP_SIF) vep \
		-i $(in_vcf) \
		-o $(out_vcf) \
		--cache \
		--dir vep_data/ \
		--vcf \
		--fields "Uploaded_variation,Gene,SYMBOL,Consequence,Feature_type,Feature,IMPACT,VARIANT_CLASS,SIFT,PolyPhen,SV,AF,EUR_AF,gnomADe_AF,gnomADg_AF,MAX_AF,MAX_AF_POPS,CLIN_SIG,BIOTYPE,APPRIS,TSL,PUBMED,PHENO,GENE_PHENO"

