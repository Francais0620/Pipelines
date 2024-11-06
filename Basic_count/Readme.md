> 对L1PA6-L1HS的保守序列进行突变的统计，看看突变的是哪些地方，以及由什么变成了什么？

### 1. diff-L1PA.v3.py

文件diff-L1PA.v3.py，鉴定了consensus sequence上的突变位点。输入为seq.fata文件,输出为result.txt文件。

### 2. result.txt
文件result.txt为1的输出文件，用逗号分隔。第一列是位点的名称，第二列为L1PA5向L1PA6突变的过程，第三列为碱基突变的具体信息，由G突变为gap。

1,5->6,G->- \\n
2,5->6,G->-
3,5->6,G->-
4,5->6,G->-
5,5->6,G->-
6,5->6,G->-
7,5->6,A->-
8,5->6,G->-
9,5->6,G->-

### 3.plot.R
对result.txt文件进行整理，画图。distribution_new.pdf，frequency_new.pdf以及count2.pdf为基本的输出的图。

### 4. align.pdf
align.pdf为geneDoc的输出结果。
得到的过程如下：
（1）首先将文件L1PA1-6-unalign.fasta放到clustalw（ https://www.genome.jp/tools-bin/clustalw ）上进行多序列比对，得到结果文件L1PA1-6-align-clustalw.fasta文件。
（2）将L1PA1-6-align-clustalw.fasta文件import到geneDoc中，修改呈现的格式（颜色等），最后打印输出pdf。打印输出的pdf可以放到Ai里面进行编辑修改。
