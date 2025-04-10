import argparse
from Bio import SeqIO
from Bio.Seq import Seq  # 用于生成反向互补序列
from collections import Counter
from concurrent.futures import ThreadPoolExecutor, as_completed

def slide_window(sequence, window_size):
    """使用生成器实现滑窗切割，逐步返回序列。"""
    for i in range(len(sequence) - window_size + 1):
        yield str(sequence[i:i + window_size])

def calculate_gc_content(sequence):
    """计算序列的GC含量。"""
    gc_count = sequence.upper().count("G") + sequence.upper().count("C")  # 确保计算时忽略大小写
    return round(gc_count / len(sequence), 2) if len(sequence) > 0 else 0  # 返回保留两位小数的GC含量

def get_reverse_complement(sequence):
    """生成序列的反向互补序列。"""
    seq = Seq(sequence)  # 使用Bio.Seq模块将字符串转换为Seq对象
    return str(seq.reverse_complement())  # 返回反向互补序列的字符串形式

def process_single_sequence(sequence, window_size=30):
    """处理单条序列，滑窗切割并统计子序列的反向互补序列频率。"""
    subsequence_counter = Counter()
    for subseq in slide_window(sequence, window_size):
        reverse_complement_seq = get_reverse_complement(subseq)  # 获取30bp序列的反向互补序列
        subsequence_counter[reverse_complement_seq] += 1
    return subsequence_counter

def read_fasta_and_process_in_parallel(input_fasta, window_size=30, max_workers=4):
    """并行读取FASTA文件中的每条序列并统计反向互补序列频率。"""
    overall_counter = Counter()
    
    # 使用线程池进行并行处理
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = []
        for record in SeqIO.parse(input_fasta, "fasta"):
            sequence = str(record.seq)
            futures.append(executor.submit(process_single_sequence, sequence, window_size))
        
        # 汇总所有线程的结果
        for future in as_completed(futures):
            subsequence_counter = future.result()
            overall_counter.update(subsequence_counter)
    
    return overall_counter

def write_to_file(output_file, subsequence_counts):
    """将子序列的计数结果和GC含量写入文件。"""
    with open(output_file, 'w') as f:
        f.write("Reverse_Complement_Sequence\tCount\tGC_Content\n")  # 写入文件头
        for subseq, count in subsequence_counts.most_common():  # 按照频率从高到低排序
            gc_content = calculate_gc_content(subseq)
            f.write(f"{subseq}\t{count}\t{gc_content:.2f}\n")  # 输出反向互补序列、出现次数和GC含量

def main():
    # 设置命令行参数解析
    parser = argparse.ArgumentParser(description="Extract reverse complement of 30bp sequences from FASTA and count occurrences with GC content.")
    parser.add_argument("-i", "--input", required=True, help="Input FASTA file path.")
    parser.add_argument("-o", "--output", required=True, help="Output file path to save the results.")
    parser.add_argument("-w", "--window", type=int, default=30, help="Sliding window size (default: 30).")
    parser.add_argument("-t", "--threads", type=int, default=4, help="Number of threads for parallel processing (default: 4).")

    # 解析命令行参数
    args = parser.parse_args()

    # 处理FASTA文件，切割序列并统计出现次数
    subsequence_counts = read_fasta_and_process_in_parallel(args.input, window_size=args.window, max_workers=args.threads)

    # 将统计结果和GC含量写入文件
    write_to_file(args.output, subsequence_counts)
    print(f"统计完成，结果已保存到 {args.output} 中。")

if __name__ == "__main__":
    main()
