setwd("F://11-04//new")
data<-read.csv("results.txt",header=F)
colnames(data)<-c("location","subfamily","type")
data[grep("^1->2",data$subfamily),"subfamily2"]<-"L1PA2->L1HS"
data[grep("^2->3",data$subfamily),"subfamily2"]<-"L1PA3->L1PA2"
data[grep("^3->4",data$subfamily),"subfamily2"]<-"L1PA4->L1PA3"
data[grep("^4->5",data$subfamily),"subfamily2"]<-"L1PA5->L1PA4"
data[grep("^5->6",data$subfamily),"subfamily2"]<-"L1PA6->L1PA5"
data$location<-as.numeric(data$location)
data[grep("^G->",data$type),"type2"]<-"->G"
data[grep("^A->",data$type),"type2"]<-"->A"
data[grep("^T->",data$type),"type2"]<-"->T"
data[grep("^C->",data$type),"type2"]<-"->C"
data[grep("^-->",data$type),"type2"]<-"->-"
library(ggplot2)
library(tidyr)
library(dplyr)
#首先统计位点location的分布
p1<-ggplot(data, aes(x=location)) +
  geom_histogram(binwidth=200,color="white", fill="#3E56A1",linewidth=0.5)+ #设置框线类型，颜色和fill的颜色
  geom_vline(aes(xintercept=907), color="#E98E29", linetype="dashed", linewidth=1)+ 
  geom_vline(aes(xintercept=1923), color="#E98E29", linetype="dashed", linewidth=1)+ 
  geom_vline(aes(xintercept=1987), color="#E98E29", linetype="dashed", linewidth=1)+ 
  geom_vline(aes(xintercept=5814), color="#E98E29", linetype="dashed", linewidth=1)+
  theme_classic() #以上数值是依照L1HS的，尚不算严谨
pdf("distribution_new.pdf", width=6, heigh=2)
p1
dev.off()

#其次对loctaion出现的次数进行分类，看这些频率中，替换次数最多的subfamily是哪些
detailDat <- data %>%
  group_by(location) %>%
  mutate(frequency = n()) %>%
  ungroup()
result <- detailDat %>%
  group_by(frequency, subfamily2) %>%
  summarise(count = n(), .groups = 'drop')
result$frequency<-as.factor(result$frequency)
result$count<-as.numeric(result$count)
p2<-ggplot(data = result,aes(x=frequency,y=count,fill=subfamily2))+
  geom_bar(stat = "identity",position = "dodge")+
  scale_fill_manual(values = c("L1PA2->L1HS"="#EB999C","L1PA3->L1PA2"="#C1C8DD",
                               "L1PA4->L1PA3"="#D3D4D3","L1PA5->L1PA4"="#A190B4",
                               "L1PA6->L1PA5"="#C9E1BD"),
                    limits=c("L1PA2->L1HS","L1PA3->L1PA2","L1PA4->L1PA3",
                             "L1PA5->L1PA4","L1PA6->L1PA5"))+
  labs(x="mutation frequency",y="count",
       title="")+
  theme_classic()
p2
pdf("frequency_new.pdf", width=3, heigh=2)
p2
dev.off()


# result2 <- data %>%
#   group_by(type, subfamily) %>%
#   summarise(count = n(), .groups = 'drop')
# ggplot(data = result2,aes(x=subfamily,y=count,fill=type))+
#   geom_bar(stat = "identity",position = "dodge")


detailDat2<-detailDat[detailDat$frequency=="1",]
result3 <- detailDat2 %>%
  group_by(type2, subfamily2) %>%
  summarise(count = n(), .groups = 'drop')
result3$subfamily2<-factor(result3$subfamily2,levels =rev(c("L1PA2->L1HS","L1PA3->L1PA2","L1PA4->L1PA3",
                                                        "L1PA5->L1PA4","L1PA6->L1PA5")))
p3<-ggplot(data = result3,aes(x=subfamily2,y=count,fill=type2))+
  geom_bar(stat = "identity",position = "stack")+
  scale_fill_manual(values = c("->-"="#E98E29","->A"="#17646D",
                               "->C"="#B3D393","->G"="#7AC7CC",
                               "->T"="#B9C7C6"),
                    limits=c("->-","->A","->C","->G","->T"))+
  labs(x="substitution",y="count",
       title="mutation frequency:1")+
  coord_flip()+ 
  theme_classic()


library(cowplot)
p4<-plot_grid(p2, p3, labels = c("A", "B"), align = "h")
p4
pdf("count2.pdf", width=8, heigh=2)
p4
dev.off()






detailDat<- data %>% separate(type, c("site","mutation"),sep = ":") #separate来源于tidyr函数
head(detailDat)
#如果location行重复，则给新列frequency赋值
detailDat <- detailDat %>%
  group_by(location) %>%
  mutate(frequency = n()) %>%
  ungroup()
result <- detailDat %>%
  group_by(frequency, site) %>%
  summarise(count = n(), .groups = 'drop')

#接下来根据frequency，对site的类型进行计数画图
library(ggplot2)
p1 <- ggplot(detailDat, aes(taxonomy, weight = mean, fill = group)) +
  geom_hline(yintercept = seq(10, 50, 10), color = 'gray') +
  geom_bar(color = "black", width = .7, position = 'dodge') +
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se), width = 0.25, size = 0.3, position = position_dodge(0.7)) +
  labs( y = 'Relative abundance (%)') +
  scale_fill_brewer(palette = "Set3")+
  scale_y_continuous(expand = c(0,0)) +
  theme_classic()
p1