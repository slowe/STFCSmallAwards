#!/usr/bin/perl

open(FILE,"smallawards.txt");
@lines = <FILE>;
close(FILE);

$round = 0;
$sources = 0;
$json = "{\n\t\"awards\": [\n";

$i = 0;	# The number of awards

foreach $line (@lines){

	if($line =~ /^Sources/){
		$sources = 1;
		$round = 0;
		next;
	}
	if($line =~ /^Round/){
		$round = 1;
		$sources = 0;
		next;
	}

	if($sources==1){
		if($line =~ /^\d\d\d\d/){
			($r,$url) = split(/\t/,$line);
			$source{$r} = $url;
		}
	}

	if($round==1){
		if($line =~ /^\d\d\d\d/){

			$i++;

			$line =~ s/\"/\'/g;	# replace all quotation marks
			$line =~ s/[\n\r]//g;	# remove new lines
			
			($r,$amount,$title,$org,$location,$region) = split(/\t/,$line);

			# Find the year from the round
			$r =~ /^(\d\d\d\d)/;
			$year = $1;

			# Construct the JSON output
			if($i > 1){
				$json .= ",\n";
			}
			$json .= "\t\t{ \"year\": $year, \"round\": \"$r\", \"amount\": $amount, \"title\": \"$title\", \"org\": \"$org\", \"location\": \"$location\", \"region\": \"$region\" }";

		}
	}
}
$json .= "\n\t]\n}";

open(FILE,">","smallawards.json");
print FILE $json;
close(FILE);