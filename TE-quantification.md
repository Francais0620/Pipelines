# How to quantify TEs properly for bulk RNA-seq in our research?

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

> Yet, notably, the majority of detected TEs were differentially expressed during each transition of spermatogenesis (Fig. 1d and Supplementary Data 1); in particular, 89.0% (18,552/20,853) of expressed TEs were differentially expressed at the KIT+ spermatogonia-to-PS transition (the mitosis-to-meiosis transition). [也即说明TE凡表达，变化的比例都很大]


### (5) detection of DE TEs
To detect a differentially expressed TE copy between **two biological samples**, **a read count output file** was input to the DESeq2 package (version 1.16.1), then the program functions DESeqDataSetFromMatrix and DESeq were used to compare each TE copy’s expression level between two biological samples. Differentially expressed TE copies were identified through two criteria: (1) ≥2-fold change and (2) ≥baseMean 2 in two stages, which are compared. 





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

 
 
 
 
 
 
 
  
 
 
