# How to quantify TEs properly for bulk RNA-seq in our research?

## 0.Propressing

[Literature ](https://pubmed.ncbi.nlm.nih.gov/38849613/)

### (1) QC

FastQC version 0.11.9 was used to evaluate quality scores of raw sequencing reads. 

### (2)trimming

Adaptor and low-quality bases were then trimmed using Trim Galore version 0.6.6 with parameters “-q 20 –phred33 –trim-n –paired”.

## 1.Only consider the unique mapped reads

[Literature 1](https://www.nature.com/articles/s41594-020-0487-4#Sec10)

> The RNA-seq pipeline for comprehensive quantification of TE copies.
<img width="477" alt="截屏2024-08-27 18 49 39" src="https://github.com/user-attachments/assets/87cee135-7d78-457c-98c2-3747b568afe7">

### (1) prepare the ‘best match’ TE annotation set
TE copies that overlapped with exonic regions of a gene annotation set or had low SW scores (≤500 for SINE and DNA transposons and ≤1,000 for other transposons) were removed using the BEDTools64 (version 2.26.0) intersect function and custom Python scripts.

### (2) mapping
Raw single-end RNA-seq reads in each spermatogenic stage were aligned to the indexed mouse genome (GRCm38/mm10) using STAR aligner version 2.5.3a with **--outFilterMultimapNmax 1** and --sjdbGTFfile./best_match_mm10_TE_annotaion_set.gtf options for unique alignments. 
Short reads of repetitive element RNAs could potentially be mapped to multiple loci bearing homologous elements; to ensure interpretability of our results at the individual locus level, we **counted only uniquely mapping** RNA-seq reads.

```shell
--twopassMode Basic；--outSAMtype BAM SortedByCoordinate; --outFilterType BySJout; --outFilterMultimapNmax 1; --winAnchorMultimapNmax 50; --chimSegmentMin 12; --chimJunctionOverhangMin 8; --alignSJoverhangMin 8; --alignSJDBoverhangMin 10; --outFilterMismatchNmax 999; --outFilterMismatchNoverReadLmax 0.04; --alignSJstitchMismatchNmax 5 --1 5; --outSAMattrRGline
```

### (3) quantification
To quantify uniquely aligned reads on the respective TE loci, we used the htseq-count/featureCounts function, part of the HTSeq package with best_match_mm10_TE_annotaion_set.gtf annotation.

### (4) filtering&normalization
After quantification, unexpressed TE copies through spermatogenesis (< Raw read count: 2) were removed, and values of counts per million (CPM) were calculated by dividing raw aligned reads by total uniquely aligned reads. 

<img width="664" alt="截屏2024-08-27 21 31 21" src="https://github.com/user-attachments/assets/8af3c9ed-7154-42d3-afe0-74a2756fe5b5">

> Yet, notably, the majority of detected TEs were differentially expressed during each transition of spermatogenesis (Fig. 1d and Supplementary Data 1); in particular, 89.0% (18,552/20,853) of expressed TEs were differentially expressed at the KIT+ spermatogonia-to-PS transition (the mitosis-to-meiosis transition). [也即说明TE凡表达，变化的比例都很大]((https://www.nature.com/articles/s41594-020-0487-4 fig 1d))

<img width="893" alt="截屏2024-08-27 23 24 13" src="https://github.com/user-attachments/assets/97569fed-e51c-453a-8300-6772fbcb91fe">

> b,c, Violin plots showing the log2-transformed reads per kilobase of exon per million reads mapped (log2RPKM) values of MERVL-int (b) and its LTR promoter, MT2_Mm (c) during preimplantation development. Each plot encompasses box plot; central bars represent medians, box edges indicate 50% of data points and the whiskers show 90% of data points.(https://www.nature.com/articles/s41588-023-01324-y/figures/1 fig.bc)


### (5) detection of DE TEs
To detect a differentially expressed TE copy between **two biological samples**, **a read count output file** was input to the DESeq2 package (version 1.16.1), then the program functions DESeqDataSetFromMatrix and DESeq were used to compare each TE copy’s expression level between two biological samples. Differentially expressed TE copies were identified through two criteria: (1) ≥2-fold change and (2) ≥baseMean 2 in two stages, which are compared. 


## 2.Consider multiple mapped reads

[Literature](https://pubmed.ncbi.nlm.nih.gov/37910626/)
### (1) mapping

For the quantification of TE subfamilies, the reads were mapped using STAR aligner with an hg38 index and
GENCODE version 36 as the guide GTF (--sjdbGTFfile), allowing for a maximum of 100 multimapping loci (--outFilterMultimapNmax 100) and 200 anchors (--winAnchorMultimapNmax). The rest of the parameters affecting the mapping was left in default as for version 2.6.0c.

```shell
--outFilterMultimapNmax 100 --winAnchorMultimapNmax 200
```

### (2) TE subfamily quantification

The TE subfamily quantification was performed using **TEcount** from the TEToolkit (version 2.0.3; RRID:SCR_023208) in mode **multi (--mode)**.GENCODE annotation v36 was used as the input gene GTF (--GTF), and the provided hg38 GTF file from the author’s web server was used as the TE GTF (--TE).

### (3) DE-TEs

We performed differential expression analysis using DESeq2 with the read count matrix from TEcount using only the TE subfamilies entries. Fold changes were shrunk using DESeq2:: lfcShrink.
Using the gene DESeq2 object (see section above), we normalized the TE subfamily counts by **dividing the read count matrix by the sample distances (sizeFactor) as calculated by DESeq2 with the quantification of genes** without multimapping reads (see the “Bulk
RNA-seq analysis: Gene quantification” section). For heatmap visualization, a pseudo-count of 0.5 was added and log2-transformed.

## 3. Different in counting 
[Literature ](https://pubmed.ncbi.nlm.nih.gov/38849613/)

### (1) TE annotation set
To avoid confounding between gene and repeat elements expression, we **excluded all the repeats locus that overlap with GENCODE v31/vM23 exons** using bedtools intersect. 

### (2) allow multiple mapping alignment
Cleaned reads were aligned to the unmasked hg38 or mm10 reference genome with HISAT211 version 2.1.0 (–no-mixed –no-discordant –rna-strandness RF **-k 5** --binSize 10 –normalizeUsing CPM  ).

>  -k <int>           It searches for at most <int> distinct, primary alignments for each read. Primary alignments mean
                     alignments whose alignment score is equal to or higher than any other alignments. The search terminates
                     when it cannot find more distinct valid alignments, or when it finds <int>, whichever happens first.
                     The alignment score for a paired-end alignment equals the sum of the alignment scores of
                     the individual mates. Each reported read or pair alignment beyond the first has the SAM ‘secondary’ bit
                     (which equals 256) set in its FLAGS field. For reads that have more than <int> distinct,
                     valid alignments, hisat2 does not guarantee that the <int> alignments reported are the best possible
                     in terms of alignment score. Default: 5 (linear index) or 10 (graph index).
                     Note: HISAT2 is not designed with large values for -k in mind, and when aligning reads to long,
                     repetitive genomes, large -k could make alignment much slower.

### (3) quantification:consider repetitive reads or not

Known (GENCODE v31 for human, GENCODE vM23 for mouse) and repeat (from UCSC RepeatMasker) transcript coverages were quantified with featureCount version.Reads mapping to the same repeat family were then tabulated together to obtain retrotransposon subfamily-level expression.

```shell
featureCount -Q 0 -M --fraction #consider repetitive reads
featureCount  -Q 10 #not consider repetitive reads
```

### (4) normalization

The read counts were normalized to counts per million (CPM), and fold change was calculated by dividing knockout samples by their corresponding controls.


### (5) Figures

#### a) Multi-mapped reads were included

> b, Volcano plots showing expression changes of indicated repeats upon L1 CRISPRa (left) and CRISPRi (right), compared with those from NC NCCIT. Padjusted (Padj), DESeq2 analysis based on negative binomial generalized linear model with Benjamini–Hochberg adjustments for multiple comparisons.

![批注 2024-08-29 173846](https://github.com/user-attachments/assets/b70f6516-36d3-4658-8054-a00b4451ca6a)

https://www.nature.com/articles/s41588-024-01789-5

figure 3b

#### b) Only considering uniquely mapped reads

>  e, Box plot showing that CTBP1 KO derepresses the CTBP1-bound L1s. n = 4 biological replicates. P value, two-tailed Mann–Whitney–Wilcoxon test. Plots show median and interquartile range (IQR), and whiskers are 1.5-fold IQR.

![image](https://github.com/user-attachments/assets/041b25e4-1152-4d1d-bdbe-6eeba06b649e)

https://www.nature.com/articles/s41588-024-01789-5

figure 2e


> e, Line plots showing expression of SIX2 (red, left y axis) and its two cognate L1PA2 (blue, right y axis) in early human embryos with ZGA occurring at the eight-cell stage. 

![批注 2024-08-29 174402](https://github.com/user-attachments/assets/091a1ed8-8408-474c-b8de-e000b77f385d)

https://www.nature.com/articles/s41588-024-01789-5

figure 4e

> f, Box plots showing expression of L1PA1–L1PA5 (top), their regulated ZGA genes (blue, bottom) and the orthologous genes in rhesus macaque (yellow, bottom), in single cells of early human and rhesus macaque embryos. Plots show median and IQR, and whiskers are 1.5-fold IQR. *P < 0.05; **P < 0.01; ***P < 0.001; two-tailed Mann–Whitney–Wilcoxon test. 

![批注 2024-08-29 174433](https://github.com/user-attachments/assets/c2bfa437-294d-4bb6-b217-3fd1f3d670e2)

https://www.nature.com/articles/s41588-024-01789-5

figure 4f

> a, Full-length L1 expression in single cells of mouse embryos at indicated stages. Solid line indicates mean. **P < 0.01; ****P < 0.0001; two-tailed Mann–Whitney–Wilcoxon test. Exact P values are in the source data.

![批注 2024-08-29 174503](https://github.com/user-attachments/assets/26b54f8b-5b50-446f-b10d-2e67a3342e17)

https://www.nature.com/articles/s41588-024-01789-5

figure 5a












---

(上次整理的时候，没有把文献链接一起放上来，此处先写个草稿)

TE的标准化方法（文献调研及总结）
文献一：LINE-1在大脑中的表达
1.mapping：STAR --outFilterMultimapNmax 100 --winAnchorMultimaoNmax 200,other default
2.quantification:TEcount 
3.differential TE subfamily expression: 
 (1) Fold change,DESeq2::lfcShrink;
 (2) sizeFactor calculate by DESeq2 with the quantification of genes  without multipping reads;
 (3) a pseudo-count of 0.5 was added and log2-transformed
 
重新读的话，发现这篇文章其实在L1的转录层面做过一些比较细致的分类和探索；
在读的时候，注意学习一下他们结果的呈现的方式，是一些定量的结果，还是一些定性的结果（我发现我在结果的呈现层面上，只会一些很粗浅的定量的展示）；

文献二：TE和KZFP一起驱动大脑的新颖性
 For gene and TE integrant analysis:只考虑了单一匹配的reads
   featureCounts -t exon -g gene_id -Q 10
   samples with < 10 million unique mapped reads on genes were discarded from the analysis;
   TEs did not have at least one sample with 50 reads or overlapped an exon was discard;
 
 For estimating TE subfamilies expression level:
   multi-mapping reads were summarized using the command:
   featureCounts -M --fraction -t exon -g gene_id -Q 0; for each subfamily, counts on all TE members were added up;
 
 Normalization:
 	TMM method as implemented in the limma package;
 	using the counts on genes as library size;
 
 今天我们先靶向于学习这些，后面再考虑学习其他的；如果课题遇到困难，一定是文献读的不够；
 我现在准备把这个方法归纳起来，然后写一个文档；我觉得输出型的学习总是好的；
 
 文献三：一篇关于LTR的研究
 标准化的方法：
  DESeq2的rlog的方法；然后使用标准化后的数据，进行PCA和heatmap；
 PCA：DESeq2 plotPCA；用ggplot进行可视化
 热图：取前1000个，高表达（higher average）的基因，用pheatmap绘制；
 DESeq2 dist函数 获得样本与样本之间的距离；
 
 文献四：肺部细胞
 
 SQuIRE：gene和TE的比对和定量；
 TE family和TE locus都看了；
 REdiscoverTE：定量TE的表达；也可以按照基因组区域进行分类；
 没有交代他们用了啥样的标准化的方法；
 
 文献五：细胞分化
 标准化方法：
 RPM for each TE subfamily
 Z-score of the RPM 
 top200 with the largest variance for the normalization counts
 
 文献六：
 比对：STAR，
 -readFilesCommand -outFilterMultimapNmax 100 -winAnchorMultimapNmax 100 -outMultimapperOrder Random -outSAMmultNmax 1 -outSAMtype BAM -outFilterTypeBySJou -alignSJDBoverhangMin 1 -outFilterMismatchNmax
 定量：TEtranscript
 --mode multi
 标准化:normalize with genes
 
目前，对标准化的方法有了基本的概念，我现在想要学习如何写文档，把这些内容梳理出来；

 
 
 
 
 
 
 
  
 
 
