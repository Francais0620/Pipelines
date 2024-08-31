# TE annotation file generation

```r
library(data.table)
library(dplyr)
fa.bed.o<-fread("/home/xxzhang/workplace/project/CRISPRa/expression/ESC-div/TElocal/DEseq2/hg38.fa.out",fill=T,header=T)
fa.bed<-fa.bed.o[c(-1,-2),]
colnames(fa.bed) <- c("SW_score", "perc_div", "perc_del", "perc_ins", "query_seq", "pos_in_query_begin", "pos_in_query_end", "pos_in_query_left", "strand", "TE_subfamily", "class_family", "pos_in_repeat_begin", "pos_in_repeat_end", "pos_in_repeat_left", "ID")
fa.bed$length <- as.numeric(fa.bed$pos_in_query_end) - as.numeric(fa.bed$pos_in_query_begin)
fa.bed[fa.bed$TE_subfamily=="(CATTC)n","class_family"]<-"Simple_repeat"
fa.bed[fa.bed$TE_subfamily=="(GAATG)n","class_family"]<-"Simple_repeat"
fa.bed[fa.bed$TE_subfamily=="MER121","class_family"]<-"DNA/hAT"
mean_length <- aggregate(fa.bed$length, by=list(fa.bed$TE_subfamily, fa.bed$class_family), FUN=mean)
colnames(mean_length) <- c("TE_subfamily", "info", "avg_length")#计算平均长度
mean_per_div <- aggregate(as.numeric(fa.bed$perc_div), by=list(fa.bed$TE_subfamily, fa.bed$class_family), FUN=mean)#计算进化年龄
colnames(mean_per_div) <- c("TE_subfamily", "info", "avg_perc_div")
te_freq <- fa.bed %>% count(TE_subfamily,class_family)
colnames(te_freq) <- c("TE_subfamily", "info", "Freq")
mergeDat<-merge(mean_length,mean_per_div,by=c("TE_subfamily","info"))
mergeDat.2<-merge(mergeDat,te_freq,by=c("TE_subfamily","info"))
finalDat<-mergeDat.2
write.csv(finalDat,"annotationTE.csv") 

```
