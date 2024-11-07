# 示例数据
setwd("F://11-04//new")
data<-read.csv("results.txt",header=F)
numbers <- data$V1
# 为每个数字生成左右各扩展 25 的区间
intervals <- data.frame(
  start = numbers - 25,
  end = numbers + 25
)

# 合并重叠区间的函数
merge_intervals <- function(intervals) {
  # 按开始值排序
  intervals <- intervals[order(intervals$start), ]
  merged_intervals <- data.frame(start = integer(), end = integer())
  
  current_start <- intervals$start[1]
  current_end <- intervals$end[1]
  
  for (i in 2:nrow(intervals)) {
    if (intervals$start[i] <= current_end) {
      # 如果当前区间与前一个区间重叠或相接，扩展当前区间
      current_end <- max(current_end, intervals$end[i])
    } else {
      # 如果不重叠，将前一个区间存入结果，并更新为新的区间
      merged_intervals <- rbind(merged_intervals, data.frame(start = current_start, end = current_end))
      current_start <- intervals$start[i]
      current_end <- intervals$end[i]
    }
  }
  # 添加最后一个区间
  merged_intervals <- rbind(merged_intervals, data.frame(start = current_start, end = current_end))
  
  return(merged_intervals)
}

# 合并区间
result <- merge_intervals(intervals)
print(result)
write.csv(result,"result.interals.csv")
