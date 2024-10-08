### 将数据转换为可以直接上传到igv上的文件
```shell
samtools view -b ENCFF924WKD_labeled.sam >ENCFF924WKD_labeled.bam
samtools sort ENCFF924WKD_labeled.bam -o ENCFF924WKD_labeled.sorted.bam
samtools index ENCFF924WKD_labeled.sorted.bam
```

### 查看sam文件中比对到指定位点的reads的序列信息
```shell
cat "/home/xxzhang/workplace/project/CRISPRa/Pacbio/AD_dlPFC/ENCFF924WKD/ENCFF924WKD_labeled.sam" |awk '$3=="chr3" && $4>116360000 && $4<116366026' |wc -l
```
