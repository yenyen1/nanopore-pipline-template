### WORKSPACE
WDIR=
TAMDEM_BED=$(WDIR)/download/ann/human_GRCh38_no_alt_analysis_set.trf.bed

### SAMPLES DATA DIRECTORY
DATA_DIR=
F5_DIR=$(DATA_DIR)/F5
FQ_DIR=$(DATA_DIR)/FQ
BAM_DIR=$(DATA_DIR)/BAM
OUTPUT_DIR=$(DATA_DIR)/OUTPUT
VAR_DIR=$(DATA_DIR)/VARIANT_CALL

### REFERENCES (NEED_TO_DOWNLOAD)
REF_DIR=
GRCH38_UC=$(REF_DIR)/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fasta
GRCH38=$(REF_DIR)/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fasta.gz

### SIF NEED TO GENERATE
GUPPY_GPU_SIF=
NANOPLOT_SIF=
MINIMAP2_SIF=
QUALIMAP_SIF=
CLAIR3_SIF=
SVIM_SIF=
CUTESV_SIF=
SNIFFLES_SIF=
PBSV_SIF=
NANOPOLISH_SIF=
WHATSHAP_SIF=

### VAR
PROJECT=


add.log.dir:
	mkdir -p log/01_guppy_basecall_gpu
	mkdir -p log/02_mapping
	mkdir -p log/03_call_var
	mkdir -p log/04_methylation

besecall.with.guppy.gpu: #sample=, run=, flow_cell=, kit=, run_dir=
	$(eval in_dir=$(F5_DIR)/$(PROJECT)/$(sample)/$(run_dir))
	$(eval out_dir=$(FQ_DIR)/$(PROJECT)/$(sample)/$(run))
	mkdir -p $(out_dir)
	singularity exec \
		-B $(out_dir) \
		-B $(in_dir) \
		$(GUPPY_GPU_SIF) guppy_basecaller \
                        --compress_fastq \
                        -i $(in_dir) \
                        -s $(out_dir) \
                        --flowcell $(flow_cell)   \
                        --kit $(kit) \
                        --device 'auto' \
                        --disable_pings

fastq.qc.with.nanoplot.seq.summary: # sample=, run=
	$(eval in_dir=$(FQ_DIR)/$(PROJECT)/$(sample)/$(run))
	$(eval qc_dir=$(FQ_DIR)/$(PROJECT)/$(sample)/qc01_$(run)_by_seq_summary)
	mkdir -p $(qc_dir)
	singularity exec \
		-B $(in_dir) \
		-B $(qc_dir) \
		$(NANOPLOT_SIF) NanoPlot \
		-t 8 \
		--summary $(in_dir)/sequencing_summary.txt \
		--outdir $(qc_dir)

merge.pass.fastq.and.fastq.qc: #sample=, run=
	$(eval in_dir=$(FQ_DIR)/$(PROJECT)/$(sample)/$(run))
	$(eval merge_fq=$(FQ_DIR)/$(PROJECT)/$(sample)/$(run).fastq.gz)
	$(eval qc_dir=$(FQ_DIR)/$(PROJECT)/$(sample)/qc02_$(run)_by_merged_seq)
	$(eval stat=stat_$(out))
	cat $(in_dir)/pass/*.fastq* > $(merge_fq)
	mkdir -p $(qc_dir)
	singularity exec \
		-B $(FQ_DIR)/$(PROJECT)/$(sample) \
		$(NANOPLOT_SIF) NanoPlot \
		-t 8 \
		--fastq $(merge_fq) \
		--outdir $(qc_dir)

align.ont.minimap2: #sample=,run=
	$(eval merge_fq=$(FQ_DIR)/$(PROJECT)/$(sample)/$(run).fastq.gz)
	$(eval bam_pre=$(BAM_DIR)/$(PROJECT)/$(sample)/$(run))
	$(eval temp=$(SLURM_TMPDIR))
	mkdir -p $(BAM_DIR)/$(PROJECT)/$(sample)
	singularity exec \
		-B $(merge_fq) \
		-B $(GRCH38) \
		-B $(BAM_DIR)/$(PROJECT)/$(sample) \
		-B $(temp) \
		$(MINIMAP2_SIF) minimap2 \
			-t 24 \
			-ax map-ont \
			-Y --MD \
			-R '@RG\tID:$(run)\tSM:$(sample)\tPL:Nanopore' \
			$(GRCH38) \
			$(merge_fq) > $(bam_pre).sam
	samtools sort \
		-@ 24 -m 4G -O bam -T $(temp) \
		-o $(bam_pre).sorted.bam \
		$(bam_pre).sam
	samtools index -@ 24 $(bam_pre).sorted.bam
	rm $(bam_pre).sam

qualimap.bam:   # sample=,run= 
	$(eval bam=$(BAM_DIR)/$(PROJECT)/$(sample)/$(run).sorted.bam)
	$(eval outdir=$(BAM_DIR)/$(PROJECT)/$(sample)/qc_$(run))
	singularity exec \
		-B $(BAM_DIR)/$(PROJECT)/$(sample) \
		$(QUALIMAP_SIF) qualimap bamqc \
			-bam $(bam) \
			-outdir $(outdir) \
			-gd HUMAN \
			--skip-duplicated \
			--java-mem-size=55G 

merge.fastq.by.sample: #sample= 
	$(eval merged_fq=$(FQ_DIR)/$(PROJECT)/$(sample).fastq.gz)
	cat $(FQ_DIR)/$(PROJECT)/$(sample)/*.fastq.gz > $(merged_fq)

merge.bam.by.sample: #sample=
	$(eval merged_bam=$(BAM_DIR)/$(PROJECT)/$(sample).sorted.bam)
	$(eval bam_files=$(shell ls $(BAM_DIR)/$(PROJECT)/$(sample)/*.bam | tr "\n" " "))
	samtools merge -@ 8 -O bam $(merged_bam) $(bam_files) 
	samtools index -@ 8 $(merged_bam)

call.clair3: # sample
	$(eval fasta=$(GRCH38))
	$(eval bam=$(BAM_DIR)/$(PROJECT)/$(sample).sorted.bam)
	$(eval outdir=$(VAR_DIR)/$(PROJECT)/clair3_g5014/$(sample)_clair3)
	$(eval raw_vcf=$(VAR_DIR)/$(PROJECT)/clair3_g5014/$(sample)_clair3/merge_output.vcf.gz)
	$(eval qc_vcf=$(VAR_DIR)/$(PROJECT)/clair3_g5014/$(sample)_clair3_pass_GQ20_DP10.vcf.gz)
	mkdir -p $(outdir)
	singularity exec \
                -B $(REF_DIR) \
                -B $(BAM_DIR) \
                -B $(outdir) \
                $(CLAIR3_SIF) run_clair3.sh \
                	--bam_fn=$(bam) \
                	--ref_fn=$(fasta) \
                	--output=$(outdir) \
                	--threads=24 \
                	--platform="ont" \
                	--model_path="/opt/models/r941_prom_sup_g5014" 
	bcftools view -Oz -f 'PASS' -i'GQ>=20 & FORMAT/DP>=10' -o $(qc_vcf) $(raw_vcf) 
	tabix -p vcf $(qc_vcf)

call.svim: #sample=
	$(eval fasta=$(GRCH38))
	$(eval bam=$(BAM_DIR)/$(PROJECT)/$(sample).sorted.bam)
	$(eval outdir=$(VAR_DIR)/$(PROJECT)/svim/$(sample)_svim)
	mkdir -p $(outdir)
	singularity exec \
                -B $(BAM_DIR) \
                -B $(REF_DIR) \
                $(SVIM_SIF) svim alignment \
                        --read_names \
                        --insertion_sequences \
                        --sample $(sample) \
                        $(outdir) \
                        $(bam) \
                        $(fasta)
	bcftools sort -Ov -o $(outdir).vcf $(outdir)/variants.vcf
	grep -v "\./\." $(outdir)/variants.vcf | bcftools sort -Ov -o $(outdir)_gt.vcf

call.cuteSV: ##sample  #fasta not zip
	$(eval fasta=$(GRCH38_UC))
	$(eval bam=$(BAM_DIR)/$(PROJECT)/$(sample).sorted.bam)
	$(eval vcf=$(VAR_DIR)/$(PROJECT)/cuteSV/$(sample)/$(sample).cuteSV.mq7ms6.vcf)
	$(eval workdir=$(VAR_DIR)/$(PROJECT)/cuteSV/$(sample)/$(sample).cuteSV.mq7ms6)
	mkdir -p $(workdir)
	singularity exec \
                -B $(BAMDIR) \
                -B $(fasta) \
                $(CUTESV_SIF) cuteSV \
                        $(bam) \
                        $(fasta) \
                        $(vcf) \
                        $(workdir) \
                        -t 24 \
                        -S $(sample) \
                        --min_mapq 7 \
                        --min_support 6 \
                        --report_readid \
                        --genotype \
                        --max_cluster_bias_INS 100 \
                        --diff_ratio_merging_INS 0.3 \
                        --max_cluster_bias_DEL 100 \
                        --diff_ratio_merging_DEL 0.3

call.sniffles: #sample=
	$(eval bam=$(BAM_DIR)/$(PROJECT)/$(sample).sorted.bam)
	$(eval vcf=$(VAR_DIR)/$(PROJECT)/sniffles2/$(sample).sniffles2.vcf)
	$(eval snf=$(VAR_DIR)/$(PROJECT)/sniffles2/$(sample).sniffles2.snf)
	mkdir -p $(VAR_DIR)/$(PROJECT)/sniffles2
	singularity exec \
                -B $(BAM_DIR) \
                -B $(TAMDEM_BED) \
                $(SNIFFLES_SIF) sniffles \
                        --input $(bam) \
                        --vcf $(vcf) \
                        --snf $(snf) \
                        --tandem-repeats $(TAMDEM_BED) \
                        --threads 24 \
                        --sample-id $(sample)

call.pbsv: #sample= #fasta not zip
	$(eval fasta=$(GRCH38_UC))
	$(eval bam=$(BAM_DIR)/$(PROJECT)/$(sample).sorted.bam)
	$(eval svsig=$(VAR_DIR)/$(PROJECT)/pbsv/$(sample).pbsv.svsig.gz)
	$(eval vcf=$(VAR_DIR)/$(PROJECT)/pbsv/$(sample).pbsv.vcf)
	mkdir -p $(WKDIR)/pbsv/$(sample)
	singularity exec \
                -B $(BAM_DIR) \
                -B $(TAMDEM_BED) \
                $(PBSV_SIF) pbsv discover \
                        $(bam) \
                        $(svsig) \
                        --tandem-repeats $(TAMDEM_BED)
	singularity exec \
                -B $(svsig) \
                -B $(fasta) \
                $(PBSV_SIF) pbsv call \
                        $(fasta) \
                        $(svsig) \
                        $(vcf) \
                        -j 24 

index.fast5.by.nanopolish: #sample=
	$(eval fast5=$(F5_DIR)/$(PROJECT)/$(sample))
	$(eval merged_fq=$(FQ_DIR)/$(PROJECT)/$(sample).fastq.gz)
	singularity exec \
		-B $(fast5) \
		-B $(FQ_DIR)/$(PROJECT) \
		$(NANOPOLISH_SIF) \
		$(NANOPOLISH_PATH)/nanopolish index \
			-d $(fast5) $(merged_fq)

index.fast5.by.nanopolish.with.seq.summary: #sample=
	$(eval fast5=$(F5_DIR)/$(PROJECT)/$(sample))
	$(eval fast5_list=$(shell ls $(fast5) | awk -v f="$(fast5)" '{print f"/"$$1"/fast5_pass"}' | sed ':a;N;$$!ba;s/\n/ -d /g'))
	$(eval fastq_list=$(shell ls $(FQ_DIR)/$(PROJECT)/$(sample)/*sequencing_summary.txt |  sed ':a;N;$$!ba;s/\n/ -s /g')) 
	$(eval merged_fq=$(FQ_DIR)/$(PROJECT)/$(sample).fastq.gz)
	singularity exec \
		-B $(fast5) \
		-B $(FQ_DIR)/$(PROJECT) \
		$(NANOPOLISH_SIF) \
		$(NANOPOLISH_PATH)/nanopolish index \
			-d $(fast5_list) \
			-s $(fastq_list) \
			$(merged_fq)

nanopolish: #sample=, gene=, t=, range="chr2:178,425,989-178,907,423" 
	$(eval fast5=$(F5_DIR)/$(PROJECT)/$(sample))
	$(eval merged_fq=$(FQ_DIR)/$(PROJECT)/$(sample).fastq.gz)
	$(eval merged_bam=$(BAM_DIR)/$(PROJECT)/$(sample).sorted.bam)
	$(eval outbam=$(OUTPUT_DIR)/$(PROJECT)/$(gene)/$(sample)_methylation_$(gene).bam)
	mkdir -p $(OUTPUT_DIR)/$(PROJECT)/$(gene)
	singularity exec \
		-B $(fast5) \
		-B $(FQ_DIR)/$(PROJECT) \
		-B $(BAM_DIR)/$(PROJECT) \
		-B $(OUTPUT_DIR)/$(PROJECT) \
		-B $(GRCH38) \
		$(NANOPOLISH_SIF) \
		$(NANOPOLISH_PATH)/nanopolish call-methylation \
			-t $(t) \
			-r $(merged_fq) \
			-b $(merged_bam) \
			-g $(GRCH38) \
			-w $(range) \
			--modbam-output-name=$(outbam) 

whatshap.phase: #sample=
	$(eval in_bam=$(BAM_DIR)/$(PROJECT)/$(sample).sorted.bam)
	$(eval in_vcf=$(VAR_DIR)/$(PROJECT)/clair3_g5014/$(sample)_clair3_pass_GQ20_DP10.vcf.gz)
	$(eval out_vcf=$(VAR_DIR)/$(PROJECT)/clair3_g5014/$(sample)_clair3_GQ20_DP10_phased.vcf.gz)
	singularity exec \
                -B $(REF_DIR) \
                -B $(BAMDIR) \
                -B $(NGSDIR) \
                $(WHATSHAP) whatshap phase \
                        -o $(out_vcf) \
                        --reference=$(GRCH38_UC) \
                        $(in_vcf) \
                        $(in_bam)
	tabix $(out_vcf)

whatshap.haplotag.bam: #sample=
	$(eval in_bam=$(BAM_DIR)/$(PROJECT)/$(sample).sorted.bam)
	$(eval in_vcf=$(VAR_DIR)/$(PROJECT)/clair3_g5014/$(sample)_clair3_GQ20_DP10_phased.vcf.gz)
	$(eval out_bam=$(BAM_DIR)/$(PROJECT)/$(sample).sorted.phased.bam)
	singularity exec \
		-B $(REF_DIR) \
		-B $(VAR_DIR) \
		-B $(BAM_DIR) \
		$(WHATSHAP_SIF) whatshap haplotag \
		-o $(out_bam) \
		--reference=$(GRCH38_UC) \
		$(in_vcf) \
		$(in_bam)
	samtools index $(out_bam)

