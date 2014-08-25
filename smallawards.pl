#!/usr/bin/perl

open(FILE,"smallawards.txt");
@lines = <FILE>;
close(FILE);

$inrounds = 0;
$insources = 0;

$i = 0;	# The number of awards
$j = 0; # The number of regions

$json = "{\n";
$json_awards = "\t\"awards\": [\n";
$json_regions = "\t\"regions\": {\n";

foreach $line (@lines){

	$line =~ s/\"/\'/g;	# replace all quotation marks
	$line =~ s/[\n\r]//g;	# remove new lines
	

	if($line =~ /^Sources/){
		$insources = 1;
		$inrounds = 0;
		$inregions = 0;
		next;
	}

	if($line =~ /^Round/){
		$inrounds = 1;
		$insources = 0;
		$inregions = 0;
		next;
	}

	if($line =~ /^Regions/){
		$inrounds = 0;
		$insources = 0;
		$inregions = 1;
		next;
	}

	if($insources==1){
		if($line =~ /^\d\d\d\d/){
			($r,$url) = split(/\t/,$line);
			$source{$r} = $url;
		}
	}

	if($inregions==1){
		if($line =~ /^[a-zA-Z]/){
		
			($r,$pop) = split(/\t/,$line);
			$j++;
			# Construct the JSON output
			if($j > 1){
				$json_regions .= ",\n";
			}
			$json_regions .= "\t\t\"$r\": $pop";
		}	
	}

	if($inrounds==1){
		if($line =~ /^\d\d\d\d/){

			$i++;

			($r,$amount,$title,$org,$location,$region) = split(/\t/,$line);

			# Find the year from the round
			$r =~ /^(\d\d\d\d)/;
			$year = $1;

			# Construct the JSON output
			if($i > 1){
				$json_awards .= ",\n";
			}
			$json_awards .= "\t\t{ \"year\": $year, \"round\": \"$r\", \"amount\": $amount, \"title\": \"$title\", \"org\": \"$org\", \"location\": \"$location\", \"region\": \"$region\", \"source\": \"$source{$r}\" }";
		}
	}
}
$json_awards .= "\n\t]";
$json_regions .= "\n\t}";
$json .= $json_regions.",\n".$json_awards;
$json .= "\n}";

open(FILE,">","smallawards.json");
print FILE $json;
close(FILE);