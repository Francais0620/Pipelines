import pandas as pd
import numpy as np
from Bio import pairwise2
from itertools import combinations
from tqdm import tqdm
import argparse
from concurrent.futures import ProcessPoolExecutor
import multiprocessing

def read_sequences_from_file(filename):
    """从文件读取并标准化序列"""
    with open(filename, 'r') as f:
        return list({s.strip().upper() for s in f if s.strip()})

def calc_identity(args):
    """多进程任务函数：计算序列相似度"""
    i, j, seq1, seq2, threshold = args
    len1, len2 = len(seq1), len(seq2)
    max_len = max(len1, len2)
    
    # 快速长度过滤
    if min(len1, len2) < 0.75 * max_len:
        return (i, j, False)
    
    # 精确比对
    align = pairwise2.align.globalxx(seq1, seq2, one_alignment_only=True)[0]
    matches = align.score
    similarity = matches / max_len * 100
    return (i, j, similarity >= threshold)

def cluster_sequences(sequences, threshold=75, workers=None):
    """多进程聚类主函数"""
    n = len(sequences)
    manager = multiprocessing.Manager()
    adjacency = manager.dict({(i,j): False for i, j in combinations(range(n), 2)})
    
    # 生成任务列表
    tasks = [(i, j, sequences[i], sequences[j], threshold) 
            for i, j in combinations(range(n), 2)]
    
    # 多进程处理
    with ProcessPoolExecutor(max_workers=workers) as executor:
        results = list(tqdm(executor.map(calc_identity, tasks), 
                      total=len(tasks), 
                      desc="Processing pairs"))
    
    # 构建邻接矩阵
    adj_matrix = np.eye(n, dtype=bool)
    for i, j, match in results:
        if match:
            adj_matrix[i][j] = True
            adj_matrix[j][i] = True
    
    # 查找连通分量
    visited = set()
    groups = []
    for i in range(n):
        if i not in visited:
            component = set(np.where(adj_matrix[i])[0])
            visited.update(component)
            groups.append(sorted(component, key=lambda x: -len(sequences[x])))
    
    return [[sequences[i] for i in group] for group in groups]

def create_report(groups):
    """生成报告数据（同前）"""
    report = []
    for group_id, group in enumerate(groups, 1):
        group_size = len(group)
        for seq in group:
            report.append({
                "GroupID": f"Group_{group_id:03d}",
                "Sequence": seq,
                "Length": len(seq),
                "GC%": round((seq.count("G") + seq.count("C"))/len(seq)*100, 2),
                "GroupSize": group_size,
                "IsSingleton": group_size == 1
            })
    return pd.DataFrame(report)

def main():
    parser = argparse.ArgumentParser(description="crRNA序列聚类工具")
    parser.add_argument("-i", "--input", required=True, help="输入文件路径（crRNA_list.txt）")
    parser.add_argument("-o", "--output", default="crRNA_groups.xlsx", help="输出Excel文件路径")
    parser.add_argument("-t", "--threshold", type=float, default=75, 
                       help="相似度阈值（百分比）")
    parser.add_argument("-w", "--workers", type=int, 
                       default=multiprocessing.cpu_count()-1,
                       help="并行进程数（默认CPU核心数-1）")
    args = parser.parse_args()

    # 读取和处理数据
    print(f"正在读取序列文件：{args.input}")
    sequences = read_sequences_from_file(args.input)
    print(f"发现 {len(sequences)} 条唯一序列")
    
    print(f"开始聚类（阈值={args.threshold}%，进程数={args.workers}）")
    groups = cluster_sequences(sequences, args.threshold, args.workers)
    
    # 生成报告
    print("生成分析报告...")
    df = create_report(groups)
    
    # 输出Excel
    with pd.ExcelWriter(args.output) as writer:
        df.to_excel(writer, sheet_name="Full_Report", index=False)
        summary = df.groupby("GroupID").agg(
            Sequences=("Sequence", lambda x: "\n".join(x)),
            Count=("GroupID", "count"),
            Avg_Length=("Length", "mean"),
            Avg_GC=("GC%", "mean")
        ).reset_index()
        summary.to_excel(writer, sheet_name="Group_Summary", index=False)
        df[df["IsSingleton"]].to_excel(writer, sheet_name="Singletons", index=False)
    
    print(f"处理完成！结果已保存至 {args.output}")

if __name__ == "__main__":
    main()
