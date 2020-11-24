#!/bin/bash

#This script is about temporal filtering

#bold signal filtering, formulas highpass=1/(2*f*TR), lowpass=1/(18*f*TR) from FSL Mattew Webster# 

echo "the main input for TemporalFiltering.sh is $input" >>$fMRI/$subject/fMRI$n.log.txt

hp=`echo "1 / ( $highbands * $TR * 2 )" | bc -l`

lp=`echo "1 / ( $lowbands * $TR *18 )" | bc -l`  

fslmaths $fMRI/$subject/fMRI$n/${input}.nii.gz -bptf $hp $lp $fMRI/$subject/fMRI$n/${input}_filter

input=${input}_filter

#Usage: fslmaths vol -bptf {highpass} {lowpass} filtered_volumes


    
    
