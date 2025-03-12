# RepeatLengthEstimatorFromShortRead
Estimate repeat length of a specific from short read data aligned to a reference genome from a directory of srWGS bams or crams.

### Details:
RepeatLengthEstimatorFromShortRead.sh is a simple bash script which allows the estimation of the length of a tandem repeat in both bp and number of repeat copies from short read whole genome sequencing crams. It accomplishes this by comparing the depth of read coverage at the repeat locus with 2 regions of the human genome with a low abundance of repeat elements. We use this with widely available short read whole genome sequence datasets, such as the 1000 Genomes Project in order to assess variation accross populations. This is an important tool, as short reads fail to correctly align when the length of a repeat region is greater than the length of the read. This opens up new ways to investigate the effects of repeat expansions and contractions in short read data, which is much more widely available than long read data.

### Dependencies:
The bash script must be run in a terminal with samtools installed. It has been tested on both MacOS and the Ubuntu distro of WSL. 

### How to run:
Simply drop the shell script into the directory containing the .crams and run it, using ./RepeatLengthEstimatorFromShortRead.sh

### Output
The output is report.csv, with the name of each .cram in the first column, the estimated number of basepairs at the repeat locus in the second column, and the estimated number of copies of the repeat in the third column.

### Code
```
#!/bin/bash

# Create a CSV file with headers
echo "Sample,Repeat_Length,Repeat_Copies" > report.csv

# Loop through all .cram files in the current directory
for cram_file in *.cram; do
    # Extract the sample name from the cram file name
    sample=$(basename "$cram_file" .cram)

    # Extract regions to .sam files
    samtools view -S "$cram_file" chr12:6490000-6590000 > "${sample}_100k_r1.sam"
    samtools view -S "$cram_file" chr7:5500000-5600000 > "${sample}_100k_r2.sam"
    samtools view -S "$cram_file" chr12:40482139-40491565 > "${sample}_MUC19.sam"

    # Count the lines of each .sam file
    count_r1=$(wc -l < "${sample}_100k_r1.sam")
    count_r2=$(wc -l < "${sample}_100k_r2.sam")
    count_MUC19=$(wc -l < "${sample}_MUC19.sam")

    # Calculate enrichment
    enrichment=$(echo "scale=6; ($count_MUC19 / 9426) / (($count_r1 / 100000 + $count_r2 / 100000) / 2)" | bc)

    # Estimate repeat length and number of repeat copies
    repeat_length=$(echo "scale=2; $enrichment * 9426" | bc)
    repeat_copies=$(echo "scale=2; $enrichment * 287" | bc)

    # Append the results to the CSV file
    echo "$sample,$repeat_length,$repeat_copies" >> report.csv

    # Clean up intermediate .sam files
    rm "${sample}_100k_r1.sam" "${sample}_100k_r2.sam" "${sample}_MUC19.sam"
done

echo "Report generated: report.csv"
```
### Modifying it

There are various ways to modify the script to work for other repeat loci and types of data. 

To modify it to work with .bam files, simply replace find and cram in the file with bam. To modify it to work with other reference genomes, use LiftOver from the UCSC Genome Browser. Additionally, when modifying it to change the reference genome, ensure that the number of basepairs of the repeat locus and the number of copies of the repeat remain the same, else you will have to change those too. To modify it to work with other loci, change the third samtools view command to reference a different region of the genome, and modify the number of bp of the repeat to match with the new locus, as well as the number of repeat copies in the locus in the reference genome you are using.

### Future plans

It is possible this will become a commandline tool, but at this time, this has been sufficient.