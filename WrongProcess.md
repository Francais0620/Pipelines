### 1. stat_compare_means() requires the following missing aesthetics: x and y.
出错代码：
```r
p<-ggplot(data = selectedDat[selectedDat$TE=="L1HS",])+ #我在这一行没有定义x和y
geom_boxplot(aes(x = group, y = log2(count+1)))+
theme_classic()+ #对比上述的两张图，其实发现
ggtitle("L1HS\n(normalization:TPM)")+
theme(axis.text.x = element_text(angle = 30,vjust = 0.85,hjust = 0.75))+
stat_compare_means(method = "t.test", 
                       aes(label = paste0("p = ", after_stat(p.format))), 
                       label.x.npc = "center", label.y = 30,
                       size = 5)
p
```
修正代码：
```r
p<-ggplot(data = selectedDat[selectedDat$TE=="L1HS",],aes(x = group, y = log2(count+1)))+ #原来bug在这里？所以区别是什么？
geom_boxplot()+
theme_classic()+ #对比上述的两张图，其实发现
ggtitle("L1HS\n(normalization:TPM)")+
theme(axis.text.x = element_text(angle = 30,vjust = 0.85,hjust = 0.75))+
stat_compare_means(method = "t.test", 
                       aes(label = paste0("p = ", after_stat(p.format))), 
                       label.x.npc = "center", label.y = 30,
                       size = 5)
p
```

### 2. stop("At least one covariate is confounded with batch! Please remove confounded covariates and rerun ComBat") 

> 原因是向量condition和batch存在共线性的关系。需要仔细检查一下两个向量。

