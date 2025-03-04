#setwd("/home/xxzhang/workplace/project/multiomics/Enrichment_cCRE/giggle_TE_cCRE/") #cCRE
setwd("/home/xxzhang/workplace/project/multiomics/Enrichment_cCRE/giggle_TE_HM_0909/") #HM
#setwd("/home/xxzhang/workplace/project/multiomics/Enrichment_cCRE/giggle_TE_cCRE_0910/")
#setwd("/home/xxzhang/workplace/project/multiomics/Enrichment_cCRE/giggle_AUPs_HM/") 
#setwd("/home/xxzhang/workplace/project/multiomics/Enrichment_cCRE/giggle_Age_cCRE/")
#setwd("/home/xxzhang/workplace/project/multiomics/Enrichment_cCRE/giggle_Age_HM/")
library(vroom)
library(ggplot2)
library(stringr)
library(ggrepel)
filelist <- list.files("./")
n <-length(filelist) 
#有必要整理出来一个自己的知识库，发现很多代码复用的需求很高，每次都要自己翻之前的代码；
resultDat<-as.data.frame(matrix(NA,nrow =0,ncol = 4))

for (i in 1:n)
{
  test<- vroom(filelist[i],id="./",col_names= T,delim="\t")
  P_value<-test[,8]
  ratio<-test[,5]
  label<-strsplit(test$`./`,".HM.giggle.result")[1]
  marker<-strsplit(test$`#file`,".sorted.bed.gz")
  marker2<-as.character(lapply(marker, function(x) x[1]))
  marker3<-strsplit(marker2,"./HistomeMarker_sort_b/")
  marker4<-as.character(lapply(marker3, function(x) x[2]))
  values<-cbind(label,marker4,ratio,P_value)
  colnames(values)<-c("label","tissue","ratio","P_value")
  resultDat<-rbind(resultDat,values)
}


# for (i in 1:n)
#  {
#    test<- vroom(filelist[i],id="./",col_names= T,delim="\t")
#    P_value<-test[,8]
#    ratio<-test[,5]
#    label<-strsplit(test$`./`,".cCRE.giggle.result")[1]
#    marker<-strsplit(test$`#file`,".sorted.bed.gz")
#    marker2<-as.character(lapply(marker, function(x) x[1]))
#    marker3<-strsplit(marker2,"./cCRE_sort_b/")
#    marker4<-as.character(lapply(marker3, function(x) x[2]))
#    values<-cbind(label,marker4,ratio,P_value)
#    colnames(values)<-c("label","tissue","ratio","P_value")
#    resultDat<-rbind(resultDat,values)
#  }

#selectDat<-resultDat[resultDat$P_value<0.05,] 
selectDat<-resultDat[resultDat$P_value<0.01,] #这边其实对P-value进行了筛选了

#write.csv(selectDat,"test.csv")
label_class<-unique(selectDat$label)
LEVELS<-c(grep("Alu$",label_class,value = TRUE),
       grep("MIR$",label_class,value = TRUE),
       grep("L1$",label_class,value = TRUE),
       grep("L2$",label_class,value = TRUE),
       grep("ERVL$",label_class,value = TRUE),
       grep("ERV1$",label_class,value = TRUE),
       grep("ERVL-MaLR$",label_class,value = TRUE),
       grep("ERVK$",label_class,value = TRUE))

selectDat$label<-factor(selectDat$label,levels = LEVELS)


selectDat[grep("V1C",selectDat$label,value = F),"region"]="V1C"
selectDat[grep("M1C",selectDat$label,value = F),"region"]="M1C"
selectDat[grep("ACC",selectDat$label,value = F),"region"]="ACC"
selectDat[grep("dlPFC",selectDat$label,value = F),"region"]="dlPFC"

selectDat[grep("ERVL-MaLR$",selectDat$label,value = F),"family"]="ERVL-MaLR"
selectDat[grep("ERVL$",selectDat$label,value = F),"family"]="ERVL"
selectDat[grep("ERVK$",selectDat$label,value = F),"family"]="ERVK"
selectDat[grep("ERV1$",selectDat$label,value = F),"family"]="ERV1"
selectDat[grep("Alu$",selectDat$label,value = F),"family"]="Alu"
selectDat[grep("MIR$",selectDat$label,value = F),"family"]="MIR"
selectDat[grep("L1$",selectDat$label,value = F),"family"]="L1"
selectDat[grep("L2$",selectDat$label,value = F),"family"]="L2"

selectDat[grep("L2-3-IT",selectDat$label,value = F),"celltype"]="L2-3-IT"
selectDat[grep("L4-IT",selectDat$label,value = F),"celltype"]="L4-IT"
selectDat[grep("L5-IT",selectDat$label,value = F),"celltype"]="L5-IT"
selectDat[grep("L5-ET",selectDat$label,value = F),"celltype"]="L5-ET"
selectDat[grep("L5-6-NP",selectDat$label,value = F),"celltype"]="L5-6-NP"
selectDat[grep("L6-CT",selectDat$label,value = F),"celltype"]="L6-CT"
selectDat[grep("L6-IT",selectDat$label,value = F),"celltype"]="L6-IT"
selectDat[grep("L6-IT-Car3",selectDat$label,value = F),"celltype"]="L6-IT-Car3"
selectDat[grep("PVALB",selectDat$label,value = F),"celltype"]="PVALB"
selectDat[grep("SST",selectDat$label,value = F),"celltype"]="SST"
selectDat[grep("VIP",selectDat$label,value = F),"celltype"]="VIP"
selectDat[grep("LAMP5",selectDat$label,value = F),"celltype"]="LAMP5"
selectDat[grep("PAX6",selectDat$label,value = F),"celltype"]="PAX6"
selectDat[grep("Astro",selectDat$label,value = F),"celltype"]="Astro"
selectDat[grep("Oligo",selectDat$label,value = F),"celltype"]="Oligo"
selectDat[grep("OPC",selectDat$label,value = F),"celltype"]="OPC"
selectDat[grep("L6b",selectDat$label,value = F),"celltype"]="L6b"
selectDat[grep("Microglia",selectDat$label,value = F),"celltype"]="Microglia"

selectDat$family<-factor(selectDat$family,levels = rev(c("Alu","MIR","L1","L2",
                                                     "ERV1","ERVK",
                                                     "ERVL","ERVL-MaLR")))

selectDat$tissue<-factor(selectDat$tissue,levels = c(unique(grep("fetal",selectDat$tissue,value = TRUE)),
                                                     grep("adult",
                                                          unique(c(grep("H3K4me3",selectDat$tissue,value = TRUE),
                                                                 grep("H3K4me1",selectDat$tissue,value = TRUE),
                                                                 grep("H3K27ac",selectDat$tissue,value = TRUE),
                                                                 grep("H3K36me3",selectDat$tissue,value = TRUE),
                                                                 grep("H3K9me3",selectDat$tissue,value = TRUE),
                                                                 grep("H3K27me3",selectDat$tissue,value = TRUE)),
                                                                 fromLast = TRUE)
                                                          ,value = TRUE
                                                          )

                                                     )
                         )

#selectDat$tissue<-factor(selectDat$tissue,levels = c("PLS","pELS","dELS","DNase-H3K4me3","CTCF-only"))

plotDat<-subset(selectDat,region=="dlPFC"&celltype=="L2-3-IT",)
ggplot(plotDat,aes(x=tissue,y=family))+
  geom_point(aes(
                 size=ratio,
                 color=-log10(P_value)))+
  theme_bw()+
  scale_size_continuous(range=c(1,4))+
  #facet_grid(family ~ region)+
  theme(
        axis.text.x=element_text(angle=90,hjust = 1,vjust=0.5),
        legend.position = "bottom")+
  scale_color_gradient(low="#9581ff",high="#f6c310")+
  labs(x=NULL,y=NULL)+
  labs(title="dlPFC L2-3-IT")+
  theme(plot.title = element_text(hjust = 0.5,color="black", size=12)) 


plotDat<-subset(selectDat,region=="ACC"&celltype=="L5-IT",)
ggplot(plotDat,aes(x=tissue,y=family))+
  geom_point(aes(
    size=ratio,
    color=-log10(P_value)))+
  theme_bw()+
  scale_size_continuous(range=c(1,4))+
  #facet_grid(family ~ region)+
  theme(
    axis.text.x=element_text(angle=90,hjust = 1,vjust=0.5),
    legend.position = "bottom")+
  scale_color_gradient(low="#9581ff",high="#f6c310")+
  labs(x=NULL,y=NULL)+
  labs(title="ACC L5-IT")+
  theme(plot.title = element_text(hjust = 0.5,color="black", size=12)) 

plotDat<-subset(selectDat,region=="V1C"&celltype=="L4-IT",)
ggplot(plotDat,aes(x=tissue,y=family))+
  geom_point(aes(
    size=ratio,
    color=-log10(P_value)))+
  theme_bw()+
  scale_size_continuous(range=c(1,4))+
  #facet_grid(family ~ region)+
  theme(
    axis.text.x=element_text(angle=90,hjust = 1,vjust=0.5),
    legend.position = "bottom")+
  scale_color_gradient(low="#9581ff",high="#f6c310")+
  labs(x=NULL,y=NULL)+
  labs(title="V1C L4-IT")+
  theme(plot.title = element_text(hjust = 0.5,color="black", size=12)) 

plotDat<-subset(selectDat,region=="M1C"&celltype=="L2-3-IT",)
ggplot(plotDat,aes(x=tissue,y=family))+
  geom_point(aes(
    size=ratio,
    color=-log10(P_value)))+
  theme_bw()+
  scale_size_continuous(range=c(1,4))+
  #facet_grid(family ~ region)+
  theme(
    axis.text.x=element_text(angle=90,hjust = 1,vjust=0.5),
    legend.position = "bottom")+
  scale_color_gradient(low="#9581ff",high="#f6c310")+
  labs(x=NULL,y=NULL)+
  labs(title="M1C L2-3-IT")+
  theme(plot.title = element_text(hjust = 0.5,color="black", size=12)) 



ggplot(selectDat,aes(x=celltype,y=tissue))+
  geom_point(aes(size=ratio,
                 color=-log10(P_value)))+
  theme_bw()+
  scale_size_continuous(range=c(1,4))+
  facet_grid(family ~ region)+
  theme(panel.grid = element_blank(),
        axis.text.x=element_text(angle=90,hjust = 1,vjust=0.5))+
  scale_color_gradient(low="lightgrey",high="blue")+
  labs(x=NULL,y=NULL)


ggplot(selectDat,aes(x=region,y=tissue))+
  geom_point(aes(size=ratio,
                 color=-log10(P_value)))+
  theme_bw()+
  scale_size_continuous(range=c(1,4))+
  facet_grid(family ~ celltype)+
  theme(
        axis.text.x=element_text(angle=90,hjust = 1,vjust=0.5))+
  scale_color_gradient(low="lightgrey",high="blue")+
  labs(x=NULL,y=NULL)
