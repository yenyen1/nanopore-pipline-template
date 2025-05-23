
test:
	for sv in INV ; do \
		bcftools view -H sample.vcf | grep "=$$sv"  | \
	       		perl -ne 'print "$$1\n" if /SVLEN=([^,;]+)/' > test.txt; \
	done

extract.chr:
	$(eval out=sv_count_per_chr.txt)
	for file in `ls *.vcf | tr "\n" " "`; do \
		echo "$${file}" >> $(out) ; \
	done 
	for sv in INS DEL INV ; do \
		echo "$${sv}" >> $(out) ; \
		for file in `ls *.vcf | tr "\n" " "`; do \
			echo "$$file" ;\
			for n in `seq 1 22` X Y M Un; do \
				bcftools view -H $${file} | grep "PASS" | grep -v "IMPRECISE" | \
		       		grep "=$${sv}" | awk '{print $$1"_"}'|  grep "chr$${n}_" | wc -l | sed s/" "//g | \
				tr "\n" " " >> $(out) ; \
			done ; \
			echo "\n" >> $(out) ;\
		done ; \
	done

extract.size:
	for file in `ls *.vcf | tr "\n" " "`; do \
		echo "$${file}" ; \
		for sv in INS DEL INV; do \
			bcftools view -H $${file} | grep "PASS" | grep -v "IMPRECISE" | grep "=$$sv" | \
	       			perl -ne 'print "$$1\n" if /SVLEN=([^,;]+)/' \
				> tmp_$${file}_$${sv}_len.txt ; \
		done ; \
	done



stat.raw:
	for file in `ls *.vcf | tr "\n" " "`; do \
		echo "$$file" ; \
		echo "INS: `bcftools view -H $$file | grep "=INS" | wc -l`" ; \
		echo "DEL: `bcftools view -H $$file | grep "=DEL" | wc -l`" ; \
		echo "DUP: `bcftools view -H $$file | grep "=DUP" | wc -l`" ; \
		echo "DUP:TANDEM: `bcftools view -H $$file | grep "=DUP:TANDEM" | wc -l`" ; \
		echo "DUP:INT: `bcftools view -H $$file | grep "=DUP:INT" | wc -l`" ; \
		echo "INVDUP: `bcftools view -H $$file | grep "=INVDUP" | wc -l`" ; \
		echo "INV: `bcftools view -H $$file | grep "=INV" | wc -l`" ; \
		echo "TRA: `bcftools view -H $$file | grep "=TRA" | wc -l`" ; \
		echo "BND: `bcftools view -H $$file | grep "=BND" | wc -l`" ; \
	done

stat.filter:
	for file in `ls *.vcf | tr "\n" " "`; do \
		echo "$$file" ; \
		echo "INS: `bcftools view -H $$file | grep "PASS" | grep -v "IMPRECISE;" | grep "=INS" | wc -l`" ; \
		echo "DEL: `bcftools view -H $$file | grep "PASS" | grep -v "IMPRECISE;" | grep "=DEL" | wc -l`" ; \
		echo "DUP: `bcftools view -H $$file | grep "PASS" | grep -v "IMPRECISE;" | grep "=DUP" | wc -l`" ; \
		echo "DUP:TANDEM: `bcftools view -H $$file | grep "PASS" | grep -v "IMPRECISE;" | grep "=DUP:TANDEM" | wc -l`" ; \
		echo "DUP:INT: `bcftools view -H $$file | grep "PASS" | grep -v "IMPRECISE;" | grep "=DUP:INT" | wc -l`" ; \
		echo "INVDUP: `bcftools view -H $$file | grep "PASS" | grep -v "IMPRECISE;" | grep "=INVDUP" | wc -l`" ; \
		echo "INV: `bcftools view -H $$file | grep "PASS" | grep -v "IMPRECISE;" | grep "=INV" | wc -l`" ; \
		echo "TRA: `bcftools view -H $$file | grep "PASS" | grep -v "IMPRECISE;" | grep "=TRA" | wc -l`" ; \
		echo "BND: `bcftools view -H $$file | grep "PASS" | grep -v "IMPRECISE;" | grep "=BND" | wc -l`" ; \
	done

