#!/bin/bash -eu

# Step 1: download raw data
mkdir -p inputs
cd inputs

# Download reference genome
curl ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/Escherichia_coli/reference/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz -o reference.fna.gz
gzip -d -f reference.fna.gz

# Download raw reads (sample 1)

curl ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR131/005/SRR1314595/SRR1314595_1.fastq.gz -o sample1_R1.fastq.gz
curl ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR131/005/SRR1314595/SRR1314595_2.fastq.gz -o sample1_R2.fastq.gz

# Download raw reads (sample 2)

#curl ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR131/004/SRR1314564/SRR1314564_1.fastq.gz -o sample2_R1.fastq.gz
#curl ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR131/004/SRR1314564/SRR1314564_2.fastq.gz -o sample2_R2.fastq.gz

# Download adapters
curl -O -L http://dib-training.ucdavis.edu.s3.amazonaws.com/mRNAseq-semi-2015-03-04/TruSeq2-PE.fa
cd ..

# Step two: let's start processing samples
mkdir -p outputs
cd outputs

# trim
TrimmomaticPE ../inputs/sample1_R1.fastq.gz ../inputs/sample1_R2.fastq.gz \
     sample1_R1.qc.fq.gz s1_se sample1_R2.qc.fq.gz s2_se \
     ILLUMINACLIP:../inputs/TruSeq2-PE.fa:2:40:15 \
     LEADING:2 TRAILING:2 \
     SLIDINGWINDOW:4:2 \
     MINLEN:25

cat s1_se s2_se > sample1_trim.se.fq

interleave-reads.py sample1_R1.qc.fq.gz sample1_R2.qc.fq.gz \
   -o sample1_trim.pe.fq

# Step 3: aligning with bwa mem
mkdir -p alignments
bwa mem -p  sample1_trim.pe.fq | samtools view -Sb - > alignments/sample1.bam

# Step 4: sort and index reads
mkdir -p sorted_reads
samtools sort -T sorted_reads/sample1 -O bam alignments/sample1.bam > sorted_reads/sample1.bam
samtools index sorted_reads/sample1.bam

# Step 5: call variants
mkdir -p calls
samtools mpileup -g -f ../inputs/reference.fna sorted_reads/sample1.bam | \
bcftools call -mv - > calls/all.vcf
