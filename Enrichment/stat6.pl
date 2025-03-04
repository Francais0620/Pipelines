#!perl
#change Alu/SVA; change input files
#Ins_TE.chr1-X.bed
use Getopt::Long;
GetOptions(
            "c=s" =>\$celltype_files,
            "h|help" =>\$help,
);

open (CELL, "< ".$celltype_files) or die "can not open it!";

while ($celltype = <CELL>){
	print($celltype);
	chomp($celltype);
	print($celltype);
	@ID=split(".bed",$celltype);
	#system_call("giggle search -i /home/xxzhang/workplace/project/multiomics/ref/cCRE_index/ -q \"/home/xxzhang/workplace/project/multiomics/Enrichment_cCRE/Enrichment_input-AUPs_gz/".$ID[0].".bed.gz\" -s >./giggle_AUPs_cCRE/".$ID[0].".cCRE.giggle.result");
	#system_call("giggle search -i /home/xxzhang/workplace/project/multiomics/ref/HistomeMarker_index/ -q \"/home/xxzhang/workplace/project/multiomics/Enrichment_cCRE/Enrichment_input-AUPs_gz/".$ID[0].".bed.gz\" -s >./giggle_AUPs_HM/".$ID[0].".HM.giggle.result");
	@TE = ("Alu","MIR","L1","L2","ERV1","ERVK","ERVL","ERVL-MaLR");
	foreach $sub(@TE){
	#system_call("giggle search -i /home/xxzhang/workplace/project/multiomics/ref/cCRE_index/ -q \"/home/xxzhang/workplace/project/multiomics/Enrichment_cCRE/Enrichment_input-TE_gz/TE-".$ID[0]."-".$sub.".bed.gz\" -s >./giggle_TE_cCRE/".$ID[0]."-".$sub.".cCRE.giggle.result");
	#system_call("../sort_bed TE-".$ID[0]."-".$sub.".bed ./ 32");
	system_call("giggle search -i /home/xxzhang/workplace/project/multiomics/ref/HistomeMarker_adult_index/ -q \"./Region-TE-gz/TE-".$ID[0]."-".$sub.".bed.gz\" -s >./Region-giggle/".$ID[0]."-".$sub.".HM.giggle.result");
	#$output=join('-', @ID);
	#system_call("bedtools intersect -a TE_overlap.sorted.bed -b ./Enrichment_input-AUPs/".$celltype." -wa >./TE-homer-input/TE-".$ID[0].".bed");
	#system_call("mkdir ".$sub);
	#system_call("cat /home/xxzhang/workplace/project/multiomics/Homer/TE-homer-input-major/TE-".$ID[0].".bed |awk -v OFS=\"\\t\" \'\$10==\"".$sub."\" {print \$1,\$2,\$3,\"+\"}\' >./Enrichment_input-TE/TE-".$ID[0]."-".$sub.".bed");
	#system_call("cd TE-homer-output-major");
	#system_call("mkdir 50bp".$ID[0]."-".$sub);
	#system_call("findMotifsGenome.pl ./TE-homer-input/".$sub."/TE-".$ID[0]."-".$sub.".bed  hg38 ./TE-homer-output/50bp".$ID[0]."-".$sub."/ -size  50 -float");
		}
 }

close(CELL);
sub system_call
{
  my $command=$_[0];
  print "\n\n".$command."\n\n";
  system($command);
}
