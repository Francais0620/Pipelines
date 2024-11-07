setwd("F://11-07")
data<-read.table("fimo.txt")
#我不仅要知道出现的次数，我还要知道，出现的都是什么？
#6个全部出现是比较好定义的，定义为conserved
#剩下的情况就比较复杂了，如何对这种复杂的情况进行权衡呢？
##有啥就写上啥，比如为L1PA5-1所有，那就写上1,2,3,4,5
##接下来再根据1,2,3,4,5,6的情况，将其进行更进一步的分类
library(dplyr) #dplyr有必要集中学习一下
# 使用dplyr进行数据处理
df_summary <- data %>%
  group_by(V1) %>%
  mutate(
    # 提取L1PA编号
    L1_type = case_when(
      grepl("L1PA1", V2) ~ 1,
      grepl("L1PA2", V2) ~ 2,
      grepl("L1PA3", V2) ~ 3,
      grepl("L1PA4", V2) ~ 4,
      grepl("L1PA5", V2) ~ 5,
      grepl("L1PA6", V2) ~ 6,
      TRUE ~ NA_real_
    )
  ) %>%
  filter(!is.na(L1_type)) %>% # 过滤掉没有匹配L1类型的行
  summarise(
    V3 = paste(sort(unique(L1_type)), collapse = ",") # 对L1_type排序并组合
  ) %>%
  ungroup()

# 将汇总数据框与原始数据框合并
data <- left_join(data, df_summary, by = "V1")
table(data$V3.y)
