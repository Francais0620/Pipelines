from collections import defaultdict

def merge_lines(filename):
    # 使用defaultdict来存储每个键对应的所有行
    merged_lines = defaultdict(str)
    
    with open(filename, 'r') as file:
        for line in file:
            # 跳过空行
            if line.strip() == '':
                continue
            # 分割行名和内容
            parts = line.split(maxsplit=1)
            if len(parts) < 2:
                continue  # 跳过不符合格式的行
            name, content = parts
            merged_lines[name] += content.strip()  # 拼接内容
    
    # 将结果写入新文件或打印
    with open('merged_output.txt', 'w') as outfile:
        for name, content in merged_lines.items():
            outfile.write(f"{name:<15} {content}\n")
    
    print("合并完成，结果已保存到 merged_output.txt")

# 使用示例
merge_lines('cluster.txt')
