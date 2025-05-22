#workspace
WDIR=

#apptainer=
ANNOTSV_SIF=

split.vcf.by.chr: #mtool=
	$(eval in_vcf=$(WDIR)/$(mtool).sv.vcf.gz)
	mkdir -p $(WDIR)/chr
	for i in `seq 1 22`; do \
		echo "$${i}" ;\
		bcftools view -h $(in_vcf) > $(WDIR)/chr/$(mtool).sv.chr$${i}.vcf ;\
		bcftools view -H $(in_vcf) | awk -v c=chr$${i} '$$1==c {print $$0}' >> $(WDIR)/chr/$(mtool).sv.chr$${i}.vcf ;\
	done;

run.annotsv: #mtool= chr=
	$(eval in_vcf=$(WDIR)/chr/$(mtool).sv.chr$(chr).vcf)
	$(eval out=$(WDIR)/output/chr/$(mtool).sv.annotsv.chr$(chr))
	echo "$(in_vcf)"
	apptainer exec $(ANNOTSV_SIF) /opt/AnnotSV/bin/AnnotSV \
		-SVinputFile $(in_vcf) \
		-outputFile $(out) \
		-REreport 1

run:
	mkdir -p $(WDIR)/output/chr
	for i in `seq 1 22`; do \
		echo "[[  $${i}  ]] =======================================" ;\
		make run.annotsv mtool=survivor chr=$${i} ;\
		make run.annotsv mtool=jasmine chr=$${i} ;\
	done;

merge.full45: # mtool=
	$(eval out=output/$(mtool).sv.annotsv.full45.tsv)
	head -n 1 output/chr/$(mtool).sv.annotsv.chr1.tsv | cut -f1-6,8,11- > $(out)
	for i in `seq 1 22`; do \
		echo "$$i" ;\
		cat output/chr/$(mtool).sv.annotsv.chr$${i}.tsv | awk '{if($$5>-5000000&&$$5<5000000){print $$0}}' | \
			awk -F"\t" '$$75=="full"{print $$0}' | \
			awk -F"\t" '{if($$177=="4"||$$177=="5"){print $$0}}' | \
			cut -f1-6,8,11-  >> $(out) ;\
	done ;

merge.full3NA: # mtool=
	$(eval out=output/$(mtool).sv.annotsv.full3NA.tsv)
	head -n 1 output/chr/$(mtool).sv.annotsv.chr1.tsv | cut -f1-6,8,11- > $(out)
	for i in `seq 1 22`; do \
		echo "$$i" ;\
		cat output/chr/$(mtool).sv.annotsv.chr$${i}.tsv | awk '{if($$5>-5000000&&$$5<5000000){print $$0}}' | \
			awk -F"\t" '$$75=="full"{print $$0}' | \
			awk -F"\t" '{if($$177=="3"||$$177=="NA"){print $$0}}' | \
			cut -f1-6,8,11-  >> $(out) ;\
	done ;

draw:
	apptainer exec vcf2circos.sif vcf2circos





