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

