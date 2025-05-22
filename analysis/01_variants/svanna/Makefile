#workspace
WDIR=

#apptainer
SVANNA_SIF=

#
SAMPLES=

run.only.majorHP:
	for s in $(SAMPLES) ; do \
		echo $$s ; \
		make go.svanna sample=$$s caller=svim hpo="HP:0001644" ; \
		make go.svanna sample=$$s caller=sniffles2 hpo="HP:0001644" ; \
		make go.svanna sample=$$s caller=pbsv hpo="HP:0001644" ; \
	done

go.svanna: # sample= , hpo= , caller=
	$(eval out=$(WDIR)/output/$(sample))
	$(eval in_vcf=$(WDIR)/vcf/$(caller)/$(sample).$(caller).pass.gt.vcf)
	apptainer exec \
		-B $(WDIR) \
		$(SVANNA_SIF) \
		java -jar /opt/svanna-cli-1.0.3/svanna-cli-1.0.3.jar \
			prioritize \
			-t $(hpo) \
			-d $(WDIR)/svanna/2304_hg38.svanna \
			--vcf $(in_vcf) \
			--out-dir $(out) \
			--output-format=tsv


# -d /opt/svanna-data 


merge: #caller=
	$(eval out=$(WDIR)/output/merge.$(caller).tsv)
	echo "contig\tstart\tend\tid\tvtype\tfailed_filters\tpsv" > $(out)
	for s in $(SAMPLES) ; do \
		echo $$s ;\
		zcat output_2304_DCM_only/$${s}/$${s}.$(caller).SVANNA.tsv.gz | \
		awk -F"\t" '$$6==""&&$$7>1.2&&$$1!="X"{print $$0}' | grep -v "E-" | \
		awk -v t=$${s} '{print t"\t"$$0}' >> $(out) ;\
	done

