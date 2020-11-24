#!/bin/bash
##sigma=`echo "scale=10 ; ${FWHM}/2.3548" | bc`
##fslmaths ${rest}_filt.nii.gz -kernel gauss ${sigma} -fmean -mas ${rest}_pp_pre_mask.nii.gz ${rest}_res.nii.gz

echo "$input is the input for Smoothing.sh" >> $fMRI/$subject/fMRI$n.log.txt

Sigma=`echo "$SmoothingFWHM / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`

echo "Smoothing distance $SmoothingFWHM and Smoothing sigma $Sigma" >> $fMRI/$subject/fMRI$n.log.txt

wb_command -volume-smoothing $fMRI/$subject/fMRI$n/${input}.nii.gz $Sigma $fMRI/$subject/fMRI$n/${input}_s${SmoothingFWHM}.nii.gz -roi $StandardMask

input=${input}_s${SmoothingFWHM}
    
echo "${input}_s${SmoothingFWHM} is the output for Smoothing.sh" >>$fMRI/$subject/fMRI$n.log.txt

#SMOOTH A VOLUME FILE
#   wb_command -volume-smoothing
#      <volume-in> - the volume to smooth
#      <kernel> - the gaussian smoothing kernel sigma, in mm
#      <volume-out> - output - the output volume
#      [-roi] - smooth only from data within an ROI
#         <roivol> - the volume to use as an ROI
