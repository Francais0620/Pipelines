> 这一步的目的是想看看这些突变是否会引起转录因子结合的改变，通过转录因子结合的改变来推断它的功能改变。当然，我们不要一开始的时候就关注那些突变的地方，可以先总体上看一看，哪些转录因子可以结合，然后再关注改变。

```shell
fimo --oc ./batch_fimo_vertebrates/ ./motif_databases/JASPAR/JASPAR2022_CORE_vertebrates_non-redundant_v2.meme extracted_sequences.nogap.fasta
```

其中.meme文件下载自https://meme-suite.org/meme/meme-software/Databases/motifs/motif_databases.12.25.tgz
extracted_sequences.nogap.fasta文件为提取的指定区间范围内的序列信息。
