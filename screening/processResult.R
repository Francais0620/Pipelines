setwd("F://04-06")
library(dplyr)
library(tidyr)
wid=8 #设置输出图片宽
high=8 #设置输出图片长
mismatch=3 #修改此处
#inputfile<-paste("/home/xxzhang/workplace/project/CRISPRa/basic/allTE/gRNA1001/L1PA1_4_top3000_output3.txt")
inputfile<-paste("L1HS_top4026_output3.txt")
#inputfile<-paste("L1PA1_4_top1946_output3.txt")
metadata<-read.table("TE.total.num.txt") #修改此处
data<-read.table(inputfile)
mergeDat<-merge(data,metadata,by="V1")
library(dplyr)
library(tidyr)
data_ext<-mergeDat %>% separate(V1, c("family","subfamily","length"),sep = "[:]")
head(data_ext)
colnames(data_ext)[4]<-"count"
colnames(data_ext)[5]<-"gRNA"
colnames(data_ext)[6]<-"label"
colnames(data_ext)[7]<-"total"
data_ext$count<-as.numeric(data_ext$count)
data_ext$total<-as.numeric(data_ext$total)
data_ext$per<-data_ext$count/data_ext$total
data_ext$length<-factor(data_ext$length,levels=rev(c("<=2k","2k-4k","4k-6k",">6k")))
mergeDat3<-data_ext
#####save the percentage result
mergeDat4<-mergeDat3[,-c(4,7)]
library(stringr)
mergeDat4$G_per<-str_count(mergeDat4$gRNA, "G")
mergeDat4$C_per<-str_count(mergeDat4$gRNA, "C")
mergeDat4$GC_per<-(mergeDat4$G_per+mergeDat4$C_per)/30
head(mergeDat4)
library(dplyr)
mergeDat4 <- mergeDat4 %>%
  mutate(TTTT = ifelse(grepl("TTTT", gRNA), TRUE, FALSE))
mergeDat4$class<-paste(paste(mergeDat4$family,mergeDat4$subfamily,sep=":"),mergeDat4$length,sep=":")
mergeDat5<-mergeDat4[,c(11,4,6,9,10)]
data_save <- mergeDat5 %>%
  pivot_wider(names_from = class, values_from = per)
data_save[is.na(data_save)] <- 0
data_sf<-data_save[,c(1,2,3,grep("L1",colnames(data_save)))]
head(data_sf)
order<-grep(">6k",colnames(data_sf))
order2<-append(1:3,order)
other<-setdiff(4:dim(data_sf)[2],order2)
final<-append(order2,other)
data_sf2<-data_sf[,final]
head(data_sf2)
#write.csv(data_sf2,"L1HS_top4026.csv",row.names=F)
#write.csv(data_sf2,"L1PA1_4_top1946.csv",row.names=F)
############################
candidate<-read.table("candidate.txt")
#i<-54
for (i in 1:52) {
  filterDat<-mergeDat4[mergeDat4$gRNA%in%c(candidate[i,1]),]
  
  #####draw plot
  background_colors <- c("#f0f0f0", "#ffffff")
  unique_categories <- unique(filterDat$subfamily)
  category_positions <- as.numeric(factor(unique_categories))
  background_data <- data.frame(
    xmin = category_positions - 0.5,
    xmax = category_positions + 0.5,
    ymin = -Inf,
    ymax = Inf,
    fill = rep(background_colors, length.out = length(unique_categories))
  )
  library(ggplot2)
  options(repr.plot.width =4, repr.plot.height =3)
  title<-paste("mismatch:<=",mismatch,sep="")
  p2<-ggplot(data=filterDat) + 
    geom_rect(data = background_data, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = fill), alpha = 0.2) +
    geom_bar(aes(fill=length, y=per, x=subfamily),position='dodge', stat='identity')+
    #scale_fill_brewer(palette = "Paired")+
    # scale_fill_manual(values = c("#17becf","#9467bd","#ff7f0e","#bcbd22"))+
    scale_fill_manual(name = "length",values = c("#98d09d","#fbf398","#f7a895","#9b8191","#f0f0f0","#dadada"))+
    #scale_fill_manual(name = "length",values = c("#98d09d","#fbf398","#f7a895","#9b8191"))+
    theme_classic()+
    facet_grid(. ~ gRNA) +
    scale_y_continuous(limits = c(0, 1))+
    coord_flip()+
    labs(title=title,y="Percentage(%)")+
    theme(plot.title=element_text(face="bold", #字体
                                  color="steelblue", #颜色
                                  size=20,  #大小
                                  hjust=0.5, #位置
                                  vjust=0.5,
                                  angle=360))
  print(p2)
  outputfile<-paste(i,"-",candidate[i,1],".pdf",sep="")
  pdf(outputfile,width = 6,height = 8)
  print(p2)
  dev.off()
}

# p21 <- p2 + guides(fill = guide_legend(override.aes = list(alpha = 1)))
# p21

