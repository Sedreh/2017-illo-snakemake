all: outputs/calls/all.csv

inputs/reference.fna:
	mkdir -p inputs
	curl ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/Escherichia_coli/reference/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz -o inputs/reference.fna.gz
	gzip -d -f inputs/reference.fna.gz

inputs/sample1_R1.fastq.gz:
	mkdir -p inputs
	curl ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR131/005/SRR1314595/SRR1314595_1.fastq.gz -o inputs/sample1_R1.fastq.gz

inputs/sample1_R2.fastq.gz:
	mkdir -p inputs
	curl ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR131/005/SRR1314595/SRR1314595_2.fastq.gz -o inputs/sample1_R2.fastq.gz

inputs/TruSeq2-PE.fa:
	mkdir -p inputs
	curl -L http://dib-training.ucdavis.edu.s3.amazonaws.com/mRNAseq-semi-2015-03-04/TruSeq2-PE.fa -o inputs/TruSeq2-PE.fa

outputs/sample1_trim.pe.fq: inputs/sample1_R1.fastq.gz inputs/sample1_R2.fastq.gz inputs/TruSeq2-PE.fa
	mkdir -p outputs
	TrimmomaticPE inputs/sample1_R1.fastq.gz inputs/sample1_R2.fastq.gz \
     outputs/sample1_R1.qc.fq.gz outputs/s1_se outputs/sample1_R2.qc.fq.gz outputs/s2_se \
     ILLUMINACLIP:inputs/TruSeq2-PE.fa:2:40:15 \
     LEADING:2 TRAILING:2 \
     SLIDINGWINDOW:4:2 \
     MINLEN:25
	cat outputs/s1_se outputs/s2_se > outputs/sample1_trim.se.fq
	interleave-reads.py outputs/sample1_R1.qc.fq.gz outputs/sample1_R2.qc.fq.gz \
        -o outputs/sample1_trim.pe.fq

outputs/alignments/sample1.bam: outputs/sample1_trim.pe.fq
	mkdir -p outputs/alignments
	bwa mem -p outputs/sample1_trim.pe.fq | samtools view -Sb - > outputs/alignments/sample1.bam

outputs/sorted_reads/sample1.bai: outputs/alignments/sample1.bam
	mkdir -p outputs/sorted_reads
	samtools sort -T outputs/sorted_reads/sample1 -O bam outputs/alignments/sample1.bam > outputs/sorted_reads/sample1.bam
	samtools index outputs/sorted_reads/sample1.bam

outputs/calls/all.csv: inputs/reference.fna outputs/sorted_reads/sample1.bai
	mkdir -p outputs/calls
	samtools mpileup -g -f inputs/reference.fna outputs/sorted_reads/sample1.bam | \
    bcftools call -mv - > outputs/calls/all.vcf
