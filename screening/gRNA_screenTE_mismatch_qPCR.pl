#!perl
use Getopt::Long;
use File::Basename;
GetOptions(
            "sgRNA=s" =>\$sgRNA,
			"workingdir=s" =>\$wkdir,
			"project=s" =>\$project,
			"length=s" =>\$length,
			"mismatch=s" =>\$mismatch,
			"fastaindex=s" =>\$fastaindex,
            "h|help" =>\$help,
 
);
if($help)
{
print
"
usage:
-sgRNA     : A text file containing sgRNA sequences, with each line representing a candidate sequence; the default file name is gRNA.txt;
-workingdir     : Working directory;/home/xxzhang/workplace/project/CRISPRa/basic/allTE
-project     :TE/off target gene
-mismatch     : Mismatch number when searching,default:0;
-fastaindex      : Fasta file name used to build the BLAST index;default:hg38_bedtools_TE.chr1-Y.processed.final.50.fasta;
-h         : usage of this scripts
"
}
open (MARK, "< ".$sgRNA) or die "can not open it!";
my $filename = basename $sgRNA;
$filename =~ s/\.txt$//;
print $searchLen;
$Result = "Result_combine_".$filename; #result folder
#$Count = "Count_combine_".$filename."_".$mismatch;
$tmpfile = $filename."_".$mismatch."combine.blast.result"; #tmp file 
#$outfile = "Output".$mismatch.".txt";
while ($line = <MARK>){
		print($line);
		chomp($line);
		print($line);
		$line = uc($line);
		$length = length($line); #
		$searchLen = $length - $mismatch;
		system_call("mkdir -p ".$Result);
		#system_call("mkdir -p ".$Count);
		system_call("mkdir -p ".$wkdir."/resultFiles/tmpCombine");
		system_call("echo '>".$line."\' > ".$line.".fa");
		system_call("echo ".$line." >>".$line.".fa");
		if($project eq "TE"){
			printf "a 的值为 30\n";
			system_call("blastn -db ".$wkdir."/index/".$fastaindex." -query ".$line.".fa -word_size 4 -dust no -outfmt 6 -task blastn-short -max_target_seqs 100000  -strand plus  | awk '((\$3 == 100.000 && \$4 >= ".$searchLen.")||(\$4 == ".$length." && \$5 <= ".$mismatch."))' >".$Result."/".$line.".blast.TE.result");#default:word_size 4
		}
		else{
			system_call("blastn -remote -db nt -query ".$line.".fa -word_size 4 -dust no -outfmt 6 -task blastn-short -max_target_seqs 100000  -strand plus  | awk '((\$3 == 100.000 && \$4 >= ".$searchLen.")||(\$4 == ".$length." && \$5 <= ".$mismatch."))' >".$Result."/".$line.".blast.gene.result");#default:word_size 4
		}
};
system_call("cat ".$Result."/* >".$tmpfile);
#system_call("cat  ".$tmpfile."| awk '{print \$2 }'| sort |uniq |awk -v FS=\":\" -v OFS=\":\" '{print \$1,\$2,\$3}' |sort |uniq -c |awk -v OFS=\"\t\" '{print \$2,\$1}' >".$filename."combine.count".$mismatch.".result");
system_call("awk '
{
    if (NF < 2) {  # 跳过不足两列的行
        next
    }
    key = \$2       # 提取第二列作为键
    if (FILENAME != last_file) {  # 新文件时重置临时记录
        last_file = FILENAME
        delete seen_in_current_file
    }
    if (!seen_in_current_file[key]++) {  # 当前文件内去重
        global_count[key]++              # 全局统计出现次数
    }
}
END {
    file_count = ARGC - 1                # 文件总数（ARGC 包含命令自身）
    for (k in global_count) {
        if (global_count[k] == file_count) {  # 输出所有文件共有的键
            print k
        }
    }
}' ".$Result."/*  >".$tmpfile);

system_call("cat ".$tmpfile."|awk -v FS=\":\" -v OFS=\":\" '{print \$1,\$2,\$3}' |sort |uniq -c |awk -v OFS=\"\t\" '{print \$2,\$1}' >".$filename."_".$project."_combine.count".$mismatch.".result ");
system_call("rm *.fa ");
#system_call("rm -R ".$Result);
system_call("mv ".$tmpfile." ".$wkdir."/resultFiles/tmpCombine/");
system_call("mv ".$filename."_".$project."_combine.count".$mismatch.".result  ".$wkdir."/resultFiles/");
close(MARK);
sub system_call
{
  my $command=$_[0];
  print "\n\n".$command."\n\n";
  system($command);
}
