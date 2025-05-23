

get.genelist.ensembl.bed:
	$(eval gene_list=gene_list.txt)
	$(eval gtf=gencode.v43.basic.annotation.gtf.gz)
	$(eval out=genes_gencode43.bed)
	> $(out)
	for g in `cat $(gene_list) | awk '{print $$1}' | tr "\n" " "` ; do \
		echo "$$g" ;\
		make extract.gene.from.ensembl gene=$$g gtf=$(gtf) out=$(out) ;\
	done

get.geneslist.refseq.bed:
	$(eval gene_list=gene_list.txt)
	$(eval gtf=GCF_000001405.40_GRCh38.p14_genomic.gtf.gz)
	$(eval out=genes_NCBI_Refseq.bed)
	> $(out)
	for g in `cat $(gene_list) | awk '{print $$1}' | tr "\n" " "` ; do \
		echo "$$g" ;\
		make extract.gene.from.Refseq gene=$$g gtf=$(gtf) out=$(out) ;\
	done
	sed -i '' 's#NC_[0]*#chr#g' $(out)

extract.gene.from.ensembl:
	gzcat $(gtf) | grep "\"$(gene)\";" | awk -F"\t" -v g=$(gene) '$$3=="gene"{print substr($$1,1,9),$$4,$$5,g}' >> $(out) 

extract.gene.from.Refseq:
	gzcat $(gtf) | grep "\"$(gene)\";" | awk -F"\t" -v g=$(gene) '$$3=="gene"{print substr($$1,1,9),$$4,$$5,g}' >> $(out) 

extract.exon.from.ensembl:
	gzcat $(gtf) | grep "\"$(gene)\";" | awk -F"\t" -v g=$(gene) '$$3=="exon"{split($$9,a,";"); print substr($$1,1,9),$$4,$$5,g,"exon_"substr(a[7],14,length(a[7])-13)}' >> $(out) 

extract.exon.from.Refseq:
	gzcat $(gtf) | grep "\"$(gene)\";" | awk -F"\t" -v g=$(gene) '$$3=="exon"{split($$9,a,";"); print substr($$1,1,9),$$4,$$5,g,"exon_"substr(a[length(a)-1],15,length(a[length(a)-1])-15)}' >> $(out) 

