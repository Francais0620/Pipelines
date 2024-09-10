
### 1. combine cntTable 

```shell
ls *.DFC.cntTable | while read id; do   echo "less -S ${id} | cut -f 2 >${id}.counts.txt"; done > subset.sh
sh subset.sh 1>subset.log 2>&1 &
cut -f 1 "/home/xxzhang/workplace/project/CRISPRa/expression/brain-dev/TEcount/HSB113.DFC.cntTable" >rownames.txt
paste *.counts.txt>merge.txt
paste rownames.txt merge.txt >merge2.txt
```

### 2. exploratory analysis

#### （1）PCA



#### （2）correlation
