import argparse
from Bio import AlignIO
from Bio.SeqRecord import SeqRecord
from Bio.Seq import Seq
from collections import Counter

# IUPAC 混合碱基符号（支持 GAP）
IUPAC_CODES = {
    frozenset(['A']): 'A',
    frozenset(['C']): 'C',
    frozenset(['G']): 'G',
    frozenset(['T']): 'T',
    frozenset(['-']): '-',  # GAP
    frozenset(['A', 'G']): 'R',
    frozenset(['C', 'T']): 'Y',
    frozenset(['G', 'C']): 'S',
    frozenset(['A', 'T']): 'W',
    frozenset(['G', 'T']): 'K',
    frozenset(['A', 'C']): 'M',
    frozenset(['C', 'G', 'T']): 'B',
    frozenset(['A', 'G', 'T']): 'D',
    frozenset(['A', 'C', 'T']): 'H',
    frozenset(['A', 'C', 'G']): 'V',
    frozenset(['A', 'C', 'G', 'T']): 'N',
}

# # 从比重生成 IUPAC 符号
# def get_iupac_from_frequencies(freqs):
    # # 按比重降序排列碱基
    # sorted_bases = sorted(freqs.items(), key=lambda x: x[1], reverse=True)
    # max_freq = sorted_bases[0][1]
    # selected_bases = {base for base, freq in sorted_bases if freq == max_freq}

    # # 如果 gap 存在但不是唯一最高频率，排除 gap
    # if '-' in selected_bases and len(selected_bases) > 1:
        # selected_bases.remove('-')

    # # 打印调试信息：查看当前位点的选中碱基和最大比重
    # print(f"DEBUG: Selected bases: {selected_bases}, Frequencies: {freqs}")
    
    # # 返回对应的 IUPAC 符号
    # iupac = IUPAC_CODES.get(frozenset(selected_bases), 'N')  # 默认返回 N 表示不确定
    # print(f"DEBUG: Returning IUPAC: {iupac}")
    # return iupac

# # 计算共识序列和每个位点比重
# def get_frequencies_and_consensus(alignment):
    # frequencies = []
    # consensus_sequence = []
    # for i in range(alignment.get_alignment_length()):
        # column = alignment[:, i]
        # counts = Counter(column)
        # total = sum(counts.values())
        # freqs = {base: round(count / total, 3) for base, count in counts.items()}
        # frequencies.append(freqs)

        # consensus_base = get_iupac_from_frequencies(freqs)
        # consensus_sequence.append(consensus_base)

        # # 调试输出每个位点的共识碱基
        # print(f"DEBUG: Position {i+1}, Frequencies: {freqs}, Consensus Base: {consensus_base}")
    
    # consensus_str = "".join(consensus_sequence)
    # print(f"DEBUG: Final consensus sequence: {consensus_str}")
    # return frequencies, consensus_str

# # 从比重生成 IUPAC 符号
# def get_iupac_from_frequencies(freqs):
    # sorted_bases = sorted(freqs.items(), key=lambda x: x[1], reverse=True)
    # max_freq = sorted_bases[0][1]
    # selected_bases = {base for base, freq in sorted_bases if freq == max_freq}

    # # 如果 GAP 存在但不是唯一最高频率，排除 GAP
    # if '-' in selected_bases and len(selected_bases) > 1:
        # selected_bases.remove('-')

    # # 如果只有一个碱基具有最高频率，直接返回
    # if len(selected_bases) == 1:
        # return next(iter(selected_bases))

    # # 返回对应的 IUPAC 符号
    # iupac = IUPAC_CODES.get(frozenset(selected_bases), 'N')
    # return iupac
# 从比重生成 IUPAC 符号
def get_iupac_from_frequencies(freqs):
    sorted_bases = sorted(freqs.items(), key=lambda x: x[1], reverse=True)
    max_freq = sorted_bases[0][1]
    selected_bases = {base.upper() for base, freq in sorted_bases if freq == max_freq}

    # 如果 GAP 存在但不是唯一最高频率，排除 GAP
    if '-' in selected_bases and len(selected_bases) > 1:
        selected_bases.remove('-')

    # 如果只有一个碱基具有最高频率，直接返回
    if len(selected_bases) == 1:
        return next(iter(selected_bases))

    # 返回对应的 IUPAC 符号
    iupac = IUPAC_CODES.get(frozenset(selected_bases), 'N')
    return iupac.upper()


# 核心函数：计算比重和共识序列
def get_frequencies_and_consensus(alignment):
    frequencies = []
    consensus_sequence = []
    for i in range(alignment.get_alignment_length()):
        column = alignment[:, i]
        counts = Counter(column)
        total = sum(counts.values())
        freqs = {base: round(count / total, 3) for base, count in counts.items()}
        frequencies.append(freqs)

        consensus_base = get_iupac_from_frequencies(freqs)
        consensus_sequence.append(consensus_base)
    return frequencies, "".join(consensus_sequence)


# 将共识序列写入 FASTA 文件
def write_consensus_to_fasta(consensus_sequence, output_file):
    with open(output_file, 'w') as f:
        f.write(f">Consensus_Sequence\n{consensus_sequence}\n")
        print(f"DEBUG: Writing consensus sequence to FASTA file: {consensus_sequence}")

# 清理 FASTA 文件中的换行符，整理成连续序列
def clean_fasta_sequences(input_file, cleaned_file):
    records = []
    with open(input_file, 'r') as infile:
        lines = infile.readlines()
        current_id = None
        current_seq = []
        for line in lines:
            line = line.strip()
            if line.startswith(">"):
                # 使用正则去除标题行中的非标准字符（如双引号）
                line = line.replace('"', '').replace('>', '')
                if current_id:
                    records.append(SeqRecord(Seq("".join(current_seq)), id=current_id))
                current_id = line  # 更新基因ID
                current_seq = []
            else:
                current_seq.append(line)
        if current_id:  # 添加最后一个序列
            records.append(SeqRecord(Seq("".join(current_seq)), id=current_id))

    # 写入清理后的文件
    with open(cleaned_file, 'w') as outfile:
        for record in records:
            outfile.write(f">{record.id}\n{record.seq}\n")

    return cleaned_file

# 将频率写入文本文件
def write_frequencies_to_txt(frequencies, output_file):
    with open(output_file, 'w') as f:
        for i, freq in enumerate(frequencies):
            f.write(f"Position {i+1}: {freq}\n")
            print(f"DEBUG: Writing frequencies for position {i+1}: {freq}")

# 主函数
def main():
    # 设置命令行参数解析
    parser = argparse.ArgumentParser(description="计算多序列比对的共识序列和每个位点的比重，并输出到文件")
    parser.add_argument(
        "input_file", 
        type=str, 
        help="输入的多序列比对文件（FASTA 格式）"
    )
    parser.add_argument(
        "output_prefix",
        type=str,
        help="输出文件的前缀"
    )
    args = parser.parse_args()

    # 清理输入文件
    cleaned_file = f"{args.output_prefix}_cleaned.fasta"
    cleaned_file = clean_fasta_sequences(args.input_file, cleaned_file)

    # 读取比对文件
    try:
        alignment = AlignIO.read(cleaned_file, "fasta")
    except FileNotFoundError:
        print(f"错误: 文件 '{args.input_file}' 不存在。")
        return
    except Exception as e:
        print(f"错误: 无法读取文件 '{args.input_file}'。请确保文件格式正确。")
        print(f"详细错误: {e}")
        return
    
    # 计算比重和共识序列
    frequencies, consensus_sequence = get_frequencies_and_consensus(alignment)
    
    # 输出文件名
    fasta_file = f"{args.output_prefix}_consensus.fasta"
    txt_file = f"{args.output_prefix}_frequencies.txt"
    
    # 写入文件
    write_consensus_to_fasta(consensus_sequence, fasta_file)
    write_frequencies_to_txt(frequencies, txt_file)
    
    print(f"共识序列已保存到 {fasta_file}")
    print(f"位点比重已保存到 {txt_file}")

# 调用主函数
if __name__ == "__main__":
    main()
