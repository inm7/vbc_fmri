#!/bin/bash

#This script is about all preprocessing steps for functional images. The main steps included volume exclusion, slice-timing (optional), motion correction, 
#smoothing (optional), temporal filtering (optional), and normalization. Further steps about ICA+AROMA and ICA+FIX could be seen in another scripts.
#Before running it, you should make sure you have installed HCP workbench software, scripts and T2w images.
#During functional preprocessing, this script will call other separated scripts for different functions.

startingtime=$(date +%s)

n=1
#Session loop
while [ $n -le $Session ] ; do 

fMRIlist=""

mkdir -p $fMRI/$subject/fMRI${n}

date >> $fMRI/$subject/fMRI${n}.log.txt

if [ -f $fMRI/$subject/fMRI${n}/prefiltered_func_data.nii.gz ] ; then 

echo "detect prefiltered_func_data" >> $fMRI/$subject/fMRI${n}.log.txt

elif [ -f $Orig/$subject/rfMRI/session${n}/Rest*.${postfix} ] ; then 

echo "functional image is copying" >> $fMRI/$subject/fMRI${n}.log.txt

#start pre-exclusion processes for fMRI images, remove the initial volumes
imcp $Orig/$subject/rfMRI/session${n}/Rest*.${postfix} $fMRI/$subject/fMRI${n}/prefiltered_func_data.${postfix}

totalvol=$(fslinfo $Orig/$subject/rfMRI/session${n}/Rest*.${postfix} | sed -n '5p' | awk '{ print $2 }')

length=$(expr $totalvol - $exvol )

fslroi $fMRI/$subject/fMRI$n/prefiltered_func_data.${postfix} $fMRI/$subject/fMRI$n/prefiltered_func_data.nii.gz $exvol $length

if [ -f $fMRI/$subject/fMRI${n}/prefiltered_func_data.nii ] ; then

rm -rf $fMRI/$subject/fMRI${n}/prefiltered_func_data.nii

fi 

else 

echo "can't find functional images" >> $fMRI/$subject/fMRI${n}.log.txt

fi 

#check and copy the structural images

if [ ! -f $fMRI/$subject/fMRI$n/reg/highres.nii.gz ] ; then 

mkdir -p $fMRI/$subject/fMRI$n/reg

if [ $biascorr = 1 ] ; then 

imcp $sMRI/$subject/T1w/T1_biascorr_brain.nii.gz $fMRI/$subject/fMRI$n/reg/highres.nii.gz

else

imcp $sMRI/$subject/T1w/T1*brain.nii.gz $fMRI/$subject/fMRI$n/reg/highres.nii.gz

fi

else 

echo "detect highres" >> $fMRI/$subject/fMRI${n}.log.txt

fi

#Slice-timing and motion correction procedures

if [ ! -f $fMRI/$subject/fMRI$n/prefiltered_func_data_mcf.nii.gz ] ; then 

input=prefiltered_func_data

source $Pipelines/SliceAndMotionCorrection.sh 

else 

echo "detect prefiltered_func_data_mcf" >> $fMRI/$subject/fMRI${n}.log.txt

fi

#start intensity normalization

date >> $fMRI/$subject/fMRI$n.log.txt

input=prefiltered_func_data_mcf

source $Pipelines/IntensityNormalization.sh

#Start head-motion parameters calculation

if [ ! -f $fMRI/$subject/fMRI$n/mc/Friston-24.txt ] ; then 

mkdir -p $fMRI/$subject/fMRI$n/mc

echo "start calculating Friston-24 parameters" >> $fMRI/$subject/fMRI$n.log.txt

source $Pipelines/MotionParameters.sh

echo "Friston-24 is the output from the Head-motion-parameters.sh" >> $fMRI/$subject/fMRI$n.log.txt

else 

echo "detect Friston-24" >> $fMRI/$subject/fMRI$n.log.txt

fi

date >>$fMRI/$subject/fMRI$n.log.txt

n=$(($n+1))

done

et=$fMRI/$subject/Minimalelapsedtime.txt

elapsedtime=$(($(date +%s) - $startingtime))

printf "minimal processing elapsed time = ${elapsedtime} seconds.\n"

echo "${elapsedtime}" >> ${et}

