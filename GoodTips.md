### 1. 解压.gz文件到指定文件夹
* `.tar.gz`结尾的文件
```shell
tar -xzvf file.tar.gz -C /path/to/destination/
```
`-x` 解压文件。<br>
`-z` 使用 gzip 解压。<br>
`-v` 显示解压过程。<br>
`-f` 指定文件。<br>
`-C` 指定目标文件夹。<br>

* `.gz`结尾的文件
```shell
gunzip -c file.gz > /path/to/destination/file
```
`-c` 使 `gunzip` 解压后的内容输出到标准输出，不直接替换原文件。（这个非常好评）<br>

`>` 用于将输出重定向到指定的文件或文件夹。

### 2. 在R中，尤其是在函数中画完图生成pdf的时候，打开图片，爆出文件损坏的错误

```R
 pdf("gene_correlation_pearson.pdf",width = 4,height = 3)
 print(p) #不要只是输`p`，要添加`print()`
 dev.off()
```

### 3. 在R中，如何查看加载包的版本。
有时候经常会爆出“版本不一致”的错误，这个时候，我们需要查看目前加载的包的版本。
```R
packageVersion("tidyr") #packageVersion("")括号里面是包名
```

### 4. 分组进行累加计数
```R
subfamily <- aggregate(. ~ Geneid, data = df_filtered, sum) #类别，数据框，函数
```

### 5. 列的拼接和拆分
* 用paste拼接
```R
row.names<-paste(paste(reducedDat$Geneid,reducedDat$Length,sep=":"),1:dim(reducedDat)[1],sep=":")
```
* 用separate拆分
```
ExtensionDat<- data %>% separate(gene.TE, c("transcript","gene","family","class"),sep = ":") #根据“:”，将数据框data中的gene.TE列拆分为4列，列名分别为"transcript","gene","family","class"。

```

### 6. 使用grep如何进行精确匹配

```R
selectedMean[grep("^L1PA8$",selectedMean$TE),"subfamily2"]<-"L1PA8" #有用
```
方法归纳：
* 使用`fixed = TRUE`
```R
grep("L1PA8", strings, fixed = TRUE)
```
* 使用首尾通配符
```R
grep("^L1PA8$", strings)
```
`^`表示的是首，`$`表示的是尾。


### 7. 提取fasta文件/blast建库

```shell
cat exon.gtf |awk -v OFS="\t" '{print $1,$4,$5,$10,$6,$7}' >exon.bed
sed -i 's/\"//g' exon.bed
sed -i 's/\;//g' exon.bed
awk '!seen[$0]++' exon.bed > exon_no_dup.bed
bedtools getfasta -fi "/home/xxzhang/data/Genome_reference/Genome/homo_sapiens/hg38/GRCh38.primary_assembly.genome.fa" -bed exon_no_dup.bed -s -name -fo exon.fasta
awk 'NR % 2 == 1 {print substr($0, 1, 50); next} {print}' exon.fasta >exon_cut50.fasta 
makeblastdb -in exon_cut50.fasta -dbtype nucl -out exon -parse_seqids
```




















