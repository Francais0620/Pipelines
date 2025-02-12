## chip-seq分析流程

### 0. 设置工作目录

#### 0.1 创建项目目录

```shell
mkdir chipseq #项目的名称为chipseq
```
我的：
```shell
mkdir GSE78099_KZFP_2017Nature 
```

#### 0.2 创建分析目录

```shell
mkdir raw_data reference_data scripts logs meta #创建文件夹
mkdir -p results/fastqc results/bowtie2 results/macs2 #创建结果子文件夹
```

* **logs：** 跟踪运行的命令和使用的具体参数，同时还记录运行命令时生成的任何标准输出【脚本输出】。
* **meta：** 用于描述您正在使用的样本的任何信息，我们将其称为元数据【样本的详细信息】。
* **raw_data：** 用于计算分析之前获得的任何未修改的（原始）数据，例如来自测序中心的 FASTQ 文件。我们强烈建议在分析过程中不要修改此目录【原始数据】。
* reference_data：用于分析的参考基因组相关的已知信息，例cd如基因组序列（FASTA）、与基因组相关的基因注释文件（GTF）【索引文件】。
* results：用于您在工作流程中实施的不同工具的输出。在此文件夹中创建特定于工作流程的每个工具/步骤的子文件夹【每一个子流程的结果文件】。
* **scripts：** 用于您编写并用于运行分析/工作流程的脚本【分析脚本】。

> 想法很好，但是具体是如何实现的呢？

看了一下后面，好像没怎么讲怎么将过程信息，保存到log文件夹中的。

```shell
mkdir raw_data scripts logs meta
mkdir -p results/bowtie2 results/macs2
```

#### 0.3 查看目录结构

```shell
tree

.
|-- logs
|-- meta
|-- raw_data
|-- reference_data
|-- results
|   |-- bowtie2
|   |-- fastqc
|-- scripts
```

#### 0.4 安装未安装的软件

##### 0.4.1 parallel

```shell
parallel -h #系统中已经有parallel了，只是我之前都不怎么会用

Usage:

parallel [options] [command [arguments]] < list_of_arguments
parallel [options] [command [arguments]] (::: arguments|:::: argfile(s))...
cat ... | parallel --pipe [options] [command [arguments]]

-j n            Run n jobs in parallel
-k              Keep same order
-X              Multiple arguments with context replace
--colsep regexp Split input on regexp for positional replacements
{} {.} {/} {/.} {#} {%} {= perl code =} Replacement strings
{3} {3.} {3/} {3/.} {=3 perl code =}    Positional replacement strings
With --plus:    {} = {+/}/{/} = {.}.{+.} = {+/}/{/.}.{+.} = {..}.{+..} =
                {+/}/{/..}.{+..} = {...}.{+...} = {+/}/{/...}.{+...}

-S sshlogin     Example: foo@server.example.com
--slf ..        Use ~/.parallel/sshloginfile as the list of sshlogins
--trc {}.bar    Shorthand for --transfer --return {}.bar --cleanup
--onall         Run the given command with argument on all sshlogins
--nonall        Run the given command with no arguments on all sshlogins

--pipe          Split stdin (standard input) to multiple jobs.
--recend str    Record end separator for --pipe.
--recstart str  Record start separator for --pipe.

GNU Parallel can do much more. See 'man parallel' for details

Academic tradition requires you to cite works you base your article on.
If you use programs that use GNU Parallel to process data for an article in a
scientific publication, please cite:

  Tange, O. (2021, August 22). GNU Parallel 20210822 ('Kabul').
  Zenodo. https://doi.org/10.5281/zenodo.5233953

This helps funding further development; AND IT WON'T COST YOU A CENT.
If you pay 10000 EUR you should feel free to use GNU Parallel without citing.
```

##### 0.4.2 seqkit

```shell
conda install bioconda::seqkit
```

### 1. 下载原始数据

#### 1.1 准备存放数据fastq格式的下载链接文件（url.txt）

```shell
# rep1
https://www.encodeproject.org/files/ENCFF000OQA/@@download/ENCFF000OQA.fastq.gz
# rep2
https://www.encodeproject.org/files/ENCFF000OQM/@@download/ENCFF000OQM.fastq.gz
```

#### 1.2 批量下载

```shell
cat down_fq.sh
```

```shell
#!/bin/bash
URL=~/project/chipseq/raw_data/url.txt
dir=~/project/chipseq/raw_data #下载到raw_data目录下，这里用的是绝对路径

cat ${URL} | parallel --dry-run aria2c -x 5 -d ${dir} {} #parallel这里我没怎么配置好
cat ${URL} | parallel aria2c -x 5 -d ${dir} {}
```

我的处理方式会有所不同，因为我直接下载的sra文件。

```shell
prefetch --option-file ZNF.txt --output-directory /home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/sra/
fastq-dump --gzip --split-3 -O /home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/fastq/ "/home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/sra/SRR5197033/SRR5197033.sra"
fastq-dump --gzip --split-3 -O /home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/fastq/ "/home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/sra/SRR5197067/SRR5197067.sra"
fastq-dump --gzip --split-3 -O /home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/fastq/ "/home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/sra/SRR5197125/SRR5197125.sra"
fastq-dump --gzip --split-3 -O /home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/fastq/ "/home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/sra/SRR5197126/SRR5197126.sra"
fastq-dump --gzip --split-3 -O /home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/fastq/ "/home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/sra/SRR5197135/SRR5197135.sra"
fastq-dump --gzip --split-3 -O /home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/fastq/ "/home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/sra/SRR5197260/SRR5197260.sra"
fastq-dump --gzip --split-3 -O /home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/fastq/ "/home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/sra/SRR5197268/SRR5197268.sra"
```





#### 1.3 解压及质控

在raw_data目录下：
```shell
gunzip  *.gz #解压
ls *fastq #可以改名字
seqkit stats *fastq #基本信息统计
```

我的：
```shell
cd  /home/xxzhang/workplace/project/CRISPRa/chip_seq/GSE78099_KZFP_2017Nature/raw_data/fastq/
ls  *fastq
seqkit stats *fastq

```

### 2. 批量比对

#### 2.1 生成样本的ID文件(即ID.txt)

包括不做抗体富集的input组和特定抗体富集的组。

```shell
ls *fastq | xargs -n 1 -I {} basename {} .fastq > ID.txt
```
#### 2.2 创建脚本
```shell
#!/bin/bash

genome=~/project/chipseq/reference_data/GCF_000001405.40_GRCh38.p14_genomic #bowtie2的索引目录
ID=~/project/chipseq/raw_data/ID.txt #样本的ID信息
align=~/project/chipseq/results/bowtie2 #bowtie2的位置


# Run bowtie2，进行比对
cat ${ID} | parallel \
        bowtie2 -p 6 -q --local -x ${genome} -U {}.fastq -S ${align}/{}_unsorted.sam

# Create BAM from SAM，进行格式转换
cat ${ID} | parallel \
        samtools view -h -S -b -@ 6 -o ${align}/{}_unsorted.bam ${align}/{}_unsorted.sam

# Sort BAM file by genomic coordinates，将bam文件排序
cat ${ID} | parallel \
        sambamba sort -t 6 -o ${align}/{}_sorted.bam ${align}/{}_unsorted.bam

# Filter out duplicates，过滤多重比对序列，只保留唯一比对序列
cat ${ID} | parallel \
        sambamba view -h -t 6 -f bam -F "[XS] == null and not unmapped " ${align}/{}_sorted.bam > ${align}/{}_aln.bam

# Create indices for all the bam files for visualization and QC，建立bam文件的索引
cat ${ID} | parallel \
        samtools index ${align}/{}_aln.bam
```
#### 2.3 运行脚本

```shell
bash align_filter.sh
```

### 3. peak calling

这里就一行代码，用到了input的文件。
```shell
macs2 callpeak -t bowtie2/H1hesc_Nanog_Rep2_aln.bam -c bowtie2/H1hesc_Input_Rep2_aln.bam -f BAM -g 1.3e+8 --outdir macs2 -n Nanog-rep2 2> macs2/Nanog-rep2-macs2.log
```

### 4. 小结

#### 4.1 完整的代码

#### 4.2 我学到的

> 我从这篇教程中学到的：  
> （1）分析前对于目录的设置非常的详细（包括原始的数据文件，使用到的代码等）。  
> （2）下载、比对的时候，使用shell脚本，批量处理的代码也值得我学习。  






参考资料：  
Website: https://hbctraining.github.io/Intro-to-ChIPseq/  
Github: https://github.com/hbctraining/Intro-to-ChIPseq  
教程：https://mp.weixin.qq.com/s/0KOk_ij29xrqdQzNaeVVvA  

