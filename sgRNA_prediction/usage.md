### 1.gRNA_screenTE_mismatch.pl

> 使用blast，考虑sgRNA序列在index中的匹配的情况。

```shell
cd /home/xxzhang/workplace/project/CRISPRa/gRNA/allTE/
perl "/home/xxzhang/workplace/project/CRISPRa/gRNA/allTE/gRNA_screenTE_mismatch.pl" -h

usage:
-sgRNA     : A text file containing sgRNA sequences, with each line representing a candidate sequence; the default file name is gRNA.txt;
-length     : Length of the sgRNA,default:23;
-mismatch     : Mismatch number when searching,default:0;
-fastaindex      : Fasta file name used to build the BLAST index;default:hg38_bedtools_L1.chr1-Y.fasta;
-h         : usage of this scripts

#mainly input format
perl "/home/xxzhang/workplace/project/CRISPRa/gRNA/allTE/gRNA_screenTE_mismatch.pl" -sgRNA "/home/xxzhang/workplace/project/CRISPRa/gRNA/allTE/gRNA30all.txt" -length 30 -mismatch 0 -fastaindex hg38_bedtools_L1.chr1-Y.fasta
#hg38_bedtools_L1.chr1-Y.fasta是之前已经建立完成的index
```

其中，gRNA30all.txt的文件内容是：
> TGGGAGATATACCTAATGCTAGATGACACA
CCGGCTTAAGAAACGGCGCACCACGAGACT
ATCTGAAATTGTGGCAATAATCAATAGCTT
TATCCGCTGTTCTGCAGCCACCGCTGCTGA
GAAACTTCCAGAGGAACGATCAGGCAGCAA
TGCGGTTCACCAATATCCGCTGTTCTGCAG
ATCAGGCAGCAGCATTTGCGGTTCACCAAT

得到的总结的结果文件是Output0.txt。
结果文件的内容长这样：
> L1:L1HS:<=2k	8	AGAAACGGCGCACCACGAGACTATATCCCA
L1:L1HS:2k-4k	4	AGAAACGGCGCACCACGAGACTATATCCCA
L1:L1HS:4k-6k	7	AGAAACGGCGCACCACGAGACTATATCCCA
L1:L1HS:>6k	217	AGAAACGGCGCACCACGAGACTATATCCCA
L1:L1PA2:4k-6k	1	AGAAACGGCGCACCACGAGACTATATCCCA
L1:L1PA2:>6k	10	AGAAACGGCGCACCACGAGACTATATCCCA
L1:L1PA3:>6k	2	AGAAACGGCGCACCACGAGACTATATCCCA
L1:L1PA7:>6k	1	AGAAACGGCGCACCACGAGACTATATCCCA
L1:L1HS:<=2k	22	AGATCTGAGAACGGGCAGACT
L1:L1HS:2k-4k	21	AGATCTGAGAACGGGCAGACT
> ……

最后，可以对结果文件进行处理，绘制图，来计算比例或其它。

### 2. gRNA_screenTE_mismatch_combine.pl

> 这个文件，合并了多个sgRNA的情况，看组合多个不同的sgRNA，对结果会有怎样的影响或提升。

```shell
perl "/home/xxzhang/workplace/project/CRISPRa/gRNA/allTE/gRNA_screenTE_mismatch_combine.pl" -h

usage:
-sgRNA     : A text file containing sgRNA sequences, with each line representing a candidate sequence; the default file name is gRNA.txt;
-length     : Length of the sgRNA,default:23;
-mismatch     : Mismatch number when searching,default:0;
-fastaindex      : Fasta file name used to build the BLAST index;default:hg38_bedtools_L1.chr1-Y.fasta;
-h         : usage of this scripts

#和前面的用法，基本上是一样的，不同点在于`-sgRNA`，是你想要合并的sgRNA，看看联合使用会对结果有怎样的影响。
```

得到的结果文件是：gRNA-L1PA2-4combine.count3.result
其内容为：

>L1:L1HS:4k-6k	3
L1:L1HS:>6k	4
L1:L1MA1:4k-6k	1
L1:L1MA4A:>6k	1
L1:L1MA8:2k-4k	1
L1:L1P1:<=2k	91
L1:L1P1:2k-4k	95
L1:L1P1:4k-6k	60
L1:L1P2:<=2k	27

最后画图的时候，分别使用的是：sgRNA-plot.ipynb和sgRNA-combine.ipynb这两个文件。





