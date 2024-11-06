from Bio import SeqIO

def read_fasta(file):
    sequences = {}
    for record in SeqIO.parse(file, "fasta"):
        sequences[record.id] = str(record.seq)
    return sequences

def find_differences(sequences, reference):
    reference_seq = sequences[reference]
    differences = {}

    for name, seq in sequences.items():
        if name != reference:
            diff_positions = [i for i in range(len(seq)) if seq[i] != reference_seq[i]]
            differences[name] = diff_positions
    return differences

def extract_union_diff_positions(differences):
    all_diff_positions = set()
    for pos in differences.values():
        all_diff_positions.update(pos)
    return sorted(all_diff_positions)

def create_position_dict(sequences, positions):
    position_dict = {}
    for pos in positions:
        position_dict[pos] = [sequences[seq][pos] for seq in sequences]
    return position_dict

def analyze_positions(position_dict):
    results = []
    
    for pos, bases in position_dict.items():
        for i in range(len(bases) - 1):
            if bases[i] != bases[i + 1]:
                changes = f"{bases[i]}->{bases[i + 1]}"
                results.append((pos + 1, f"{i + 1}->{i + 2}", changes))  # pos + 1 for 1-based index
    return results

def write_results(results, output_file):
    with open(output_file, 'w') as f:
        for result in results:
            f.write(f"{result}\n")

def main():
    fasta_file = "seq.fasta"
    output_file = "results.txt"
    
    sequences = read_fasta(fasta_file)
    reference = "L1PA6"
    
    differences = find_differences(sequences, reference)
    union_positions = extract_union_diff_positions(differences)
    position_dict = create_position_dict(sequences, union_positions)
    results = analyze_positions(position_dict)
    
    write_results(results, output_file)

if __name__ == "__main__":
    main()
