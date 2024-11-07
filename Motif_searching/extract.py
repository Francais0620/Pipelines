from Bio import SeqIO

def extract_sequences(fasta_file, positions_file, output_file):
    # 读取FASTA文件中的序列
    sequences = list(SeqIO.parse(fasta_file, "fasta"))
    
    # 打开结果文件准备写入
    with open(output_file, 'w') as output:
        # 读取位置文件
        with open(positions_file, 'r') as pos_file:
            for line in pos_file:
                # 去掉行尾的换行符并分割起始和终止位置
                start, end = map(int, line.strip().split())
                
                # 遍历每条FASTA序列并提取对应位置的片段
                for i, record in enumerate(sequences):
                    # 提取片段（Biopython中的序列索引是从0开始的，所以需要减1）
                    fragment = record.seq[start-1:end]
                    
                    # 将片段写入输出文件，格式为FASTA格式
                    output.write(f">{record.id}_fragment_{start}_{end}\n")
                    output.write(f"{fragment}\n")

# 设置文件路径
fasta_file = "seq.fasta"
positions_file = "positions.txt"
output_file = "extracted_sequences.fasta"

# 调用函数
extract_sequences(fasta_file, positions_file, output_file)
