### WORKSPACE
WDIR=
CG_ISLAND=$(WDIR)/download/ann/cpgIslandExt.bed

### SAMPLES DATA DIRECTORY
DATA_DIR=
BAM_DIR=$(DATA_DIR)/BAM
OUTPUT_DIR=$(DATA_DIR)/OUTPUT
VAR_DIR=$(DATA_DIR)/VARIANT_CALL

### REFERENCES (NEED_TO_DOWNLOAD)
REF_DIR=
GRCH38_UC=$(REF_DIR)/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fasta

### SIF NEED TO GENERATE
WHATSHAP_SIF=
OPENJDK11_SIF=

### TOOLS NEED TO COMPILE
MBTOOLS=./mbtools/mbtools

### IGV (NEED TO DOWNLOAD)
IGV_BIN=
IGV=$(IGV_BIN)/igv.sh
METHYL_HAPLOTAG_CONF=$(WDIR)/config/igv.haplotag.methylation.pref 
METHYL_COVERAGE_CONF=$(WDIR)/config/igv.coverage.methylation.pref 

### VAR
PROJECT=
SAMPLES=
GENES=

calc.methyl.freq.from.calls.tsv: #module load python/3.11.2 
	$(eval in=$(OUTPUT_DIR)/$(PROJECT)/$(sample)_methylation_$(gene)_calls.tsv)
	$(eval out=$(OUTPUT_DIR)/$(PROJECT)/$(sample)_methylation_$(gene)_freq.tsv)
	python bin/calculate_methylation_frequency.py \
		$(in) > $(out)

run.all.for.methyl: #gene=
	$(eval indir=$(OUTPUT_DIR)/$(PROJECT)/$(gene))
	for s in $(SAMPLES) ; do \
		echo "$${s} $(gene)" ;\
		make calc.methyl.from.bam sample=$${s} gene=$(gene) ;\
	done
	make gen.heatmap gene=$(gene) 

calc.methyl.from.bam:  # sample gene , module load rust python
	$(eval inbam=$(OUTPUT_DIR)/$(PROJECT)/$(gene)/$(sample)_methylation_$(gene).bam)
	$(eval out_call=$(OUTPUT_DIR)/$(PROJECT)/$(gene)/tsv/$(sample)_methylation_$(gene)_calls.tsv)
	$(eval out_freq=$(OUTPUT_DIR)/$(PROJECT)/$(gene)/tsv/$(sample)_methylation_$(gene)_freq.tsv)
	mkdir -p $(OUTPUT_DIR)/$(PROJECT)/$(gene)/tsv
	samtools index $(inbam)
	$(MBTOOLS) reference-frequency $(inbam) > $(out_call)
	python bin/combine_strand.py $(out_call) $(out_freq)

compare.methyl: #sample1, sample2, gene
	$(eval freq1=$(OUTPUT_DIR)/$(PROJECT)/$(gene)/tsv/$(sample1)_methylation_$(gene)_freq.tsv)
	$(eval freq2=$(OUTPUT_DIR)/$(PROJECT)/$(gene)/tsv/$(sample2)_methylation_$(gene)_freq.tsv)
	$(eval out=$(OUTPUT_DIR)/$(PROJECT)/$(gene)/tsv/compare/$(gene)_$(sample1)_vs_$(sample2).tsv)
	mkdir -p $(OUTPUT_DIR)/$(PROJECT)/$(gene)/tsv/compare
	python3 bin/merged_two_methyl_freq_files_for_compare.py \
		$(freq1) $(freq2) $(out)

gen.heatmap.table: #gene
	$(eval indir=$(OUTPUT_DIR)/$(PROJECT)/$(gene)/tsv)
	$(eval first_sample=)
	$(eval temp=$(OUTPUT_DIR)/$(PROJECT)/$(gene)/tsv/$(first_sample)_methylation_$(gene)_freq.tsv.temp)
	$(eval out=$(OUTPUT_DIR)/$(PROJECT)/$(gene)/heatmap_$(gene).txt)
	for t in `ls $(indir)/*freq.tsv` ; do \
		echo "$${t} $(gene)" ;\
		cat $${t} | awk 'BEGIN{OFS="\t"}{print $$1"_"$$2,$$6}'  > $${t}.temp ;\
	done
	for t in `ls $(indir)/*freq.tsv.temp | grep -v $(first_sample)` ; do \
		echo "$${t} $(gene)" ;\
		join -t$$'\t' $(temp) $${t} > $(out) ;\
		cat $(out) > $(temp) ;\
	done
	rm $(indir)/*.temp

gen.whole.heatmap:  #GENE IDX SAMPLE ...
	$(eval indir=$(OUTPUT_DIR)/$(PROJECT))
	$(eval out=$(OUTPUT_DIR)/$(PROJECT)/heatmap_merged_49genes.tsv)
	echo  > $(out) 
	for g in $(GENES) ; do \
		echo "$${g}" ;\
		cat $(indir)/$${g}/heatmap_$${g}.txt | awk -v s=$${g} '{print s"\t"$$0}' >> $(out) ;\
	done

run.all.haplotag: #sample=
	$(eval stats=$(OUTPUT_DIR)/$(PROJECT)/phased/$(sample)_phased_stats.txt)
	for g in $(GENES) ; do \
                echo "$${g}" ;\
                make whatshap.haplotag.methylated.bam sample=$(sample) gene=$${g} 2> temp.txt ;\
                printf "$${g} " >> $(stats) ;\
                cat temp.txt | grep lignment | sed 's# ##g' | awk -F":" '{print $$2}' | tr "\n" " " >> $(stats) ;\
                printf "\n" >> $(stats) ;\
	done

whatshap.haplotag.methylated.bam: #sample=, gene=
	$(eval in_bam=$(OUTPUT_DIR)/$(PROJECT)/$(gene)/$(sample)_methylation_$(gene).bam)
	$(eval in_vcf=$(VAR_DIR)/$(PROJECT)/clair3_g5014/$(sample)_clair3_GQ20_DP10_phased.vcf.gz)
	$(eval out_bam=$(OUTPUT_DIR)/$(PROJECT)/phased/$(sample)_methylated.phased.$(gene).bam)
	mkdir -p $(OUTPUT_DIR)/$(PROJECT)/phased
	singularity exec \
                -B $(REF_DIR) \
                -B $(VAR_DIR) \
                -B $(OUTPUT_DIR) \
                $(WHATSHAP_SIF) whatshap haplotag \
                -o $(out_bam) \
                --reference=$(GRCH38_UC) \
                $(in_vcf) \
                $(in_bam)
	samtools index $(out_bam)

take.igv.converge.snapshot: # gene_list=
	$(eval outdir=$(OUTPUT_DIR)/$(PROJECT)/igv_screenshot/methyl_coverage)
	$(eval batch=$(outdir)/batch_script.txt)
	$(eval xvfb="-screen 0 1920x1440x24")
	mkdir -p $(outdir)
	perl bin/igv.coverage.methylation.sh $(gene_list) $(outdir) > $(batch)
	xvfb-run --auto-servernum --server-num=1 \
                --server-args=$(xvfb) \
                singularity exec \
                        -B $(IGV_BIN) \
                        -B $(BAM_DIR) \
                        -B $(OUTPUT_DIR) \
                        -B $(outdir) \
                        $(OPENJDK11_SIF) $(IGV) \
                        --preferences $(METHYL_COVERAGE_CONF) \
                        --genome hg38 \
                        --batch $(batch) 


take.igv.haplotag.snapshot: # gene_list=
	$(eval outdir=$(OUTPUT_DIR)/$(PROJECT)/igv_screenshot/methyl_haplotag/)
	$(eval batch=$(outdir)/batch_script.txt)
	$(eval xvfb="-screen 0 1920x1440x24")
	mkdir -p $(outdir)
	perl bin/igv.haplotag.methylation.sh $(gene_list) $(outdir) > $(batch)
	xvfb-run --auto-servernum --server-num=1 \
                --server-args=$(xvfb) \
                singularity exec \
                        -B $(IGV_BIN) \
                        -B $(OUTPUT_DIR) \
                        $(OPENJDK11_SIF) $(IGV) \
                        --preferences $(METHYL_HAPLOTAG_CONF) \
                        --genome hg38 \
                        --batch $(batch) 


