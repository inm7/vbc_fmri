#!/bin/bash

startingtime=$(date +%s)

n=1
#Session loop
while [ $n -le $Session ] ; do 

#detect the input for full preprocessing

date >> $fMRI/$subject/fMRI$n.log.txt

if [ ! -f $fMRI/$subject/fMRI$n/prefiltered_func_data_mcf_norm.nii.gz ] ; then

echo "don't detect input for full preprocessing" >> $fMRI/$subject/fMRI$n.log.txt

else

input=prefiltered_func_data_mcf_norm

#start functional spatial normalization
source $Pipelines/FunctionalNormalization.sh

#start EPI signal smoothing 
if [ $Smoothing = 1 ] ; then 

source $Pipelines/RestSmoothing.sh

else 

echo "don't perform smooting" >> $fMRI/$subject/fMRI$n.log.txt

fi

#start temporal filtering procedure
if [ $TemporalFilter = 1 ] ; then 

source $Pipelines/RestTemporalFiltering.sh

else 

echo "do not perform temporal filtering" >> $fMRI/$subject/fMRI$n.log.txt

fi

#start covariance regression

if [ $CovarianceRegression = 1 ]; then 

source $Pipelines/RestCovarianceRegression.sh

else 

echo "don't perform covariance regression">>$fMRI/$subject/fMRI$n.log.txt

fi

fi

mv $fMRI/$subject/fMRI$n/${input}.nii.gz $fMRI/$subject/fMRI$n/filtered_func_data.nii.gz

##rm -rf $fMRI/$subject/fMRI$n/*MNI*.nii.gz

n=$(($n+1))

done

et=$fMRI/$subject/Enhancedelapsedtime.txt

elapsedtime=$(($(date +%s) - $startingtime))

printf "enhanced processing elapsed time = ${elapsedtime} seconds.\n"

echo "${elapsedtime}" >> ${et}

