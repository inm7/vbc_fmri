#!/bin/bash

startingtime=$(date +%s)

date >> $fMRI/$subject/fMRI$n.log.txt

n=1

#Session loop
while [ $n -le $Session ] ; do 

date >> $fMRI/$subject/fMRI$n.log.txt

if [ ! -f $fMRI/$subject/fMRI$n/filtered_func_data.nii.gz ] ; then 

echo "don't detect input" >>$fMRI/$subject/fMRI$n.log.txt

else

if [ -e $fMRI/$subject/fMRI$n/Atlas ] ; then

rm -rf $fMRI/$subject/fMRI$n/Atlas

fi

mkdir -p $fMRI/$subject/fMRI$n/Atlas

fslmeants -i $fMRI/$subject/fMRI$n/filtered_func_data.nii.gz --label=$atlas -o $fMRI/$subject/fMRI$n/Atlas/${atlasname}-bold.txt

#atlas-based ROI-ROI FC calculation
#3dNetCorr -prefix $fMRI/$subject/fMRI$n/Atlas/Atlas -inset  $fMRI/$subject/fMRI$n/filtered_func_data.nii.gz -in_rois $atlas -ts_out -mask $StandardT12mm_brain_mask
#echo "atlas-based functional connectivity is done"

if [ -f $fMRI/$subject/fMRI$n/Atlas/${atlasname}-bold.txt ] ; then

echo "atlas-based ROI-ROI bold extraction is done" >> $fMRI/$subject/fMRI$n.log.txt

fi

fi

date >>$fMRI/$subject/fMRI$n.log.txt

n=$(($n+1))

done

et=$fMRI/$subject/Extractionelapsedtime.txt

elapsedtime=$(($(date +%s) - $startingtime))

printf "singal extraction elapsed time = ${elapsedtime} seconds.\n"

echo "${elapsedtime}" >> ${et}
