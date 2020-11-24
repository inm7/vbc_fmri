#!/bin/bash
 
if [ -f ${fMRI}/${subject}/fMRI${n}/mc/covariance.txt ] ; then 

rm -rf ${fMRI}/${subject}/fMRI${n}/mc/covariance.txt

fi

if [ -f $fMRI/$subject/fMRI$n/mc/WM.txt ] ; then 

rm -rf $fMRI/$subject/fMRI$n/mc/WM.txt

fi

if [ -f $fMRI/$subject/fMRI$n/mc/CSF.txt ] ; then 

rm -rf $fMRI/$subject/fMRI$n/mc/CSF.txt

fi

if [ -f $fMRI/$subject/fMRI$n/mc/Global.txt ] ; then 

rm -rf $fMRI/$subject/fMRI$n/mc/Global.txt

fi

for mask in CSF WM Global

do

if [ $StructuralNormalization = 1 ] ; then 

applywarp -i $sMRI/$subject/T1w/${mask}_mask.nii.gz -r $StandardT12mm_brain -w $sMRI/$subject/T1w/fnirt/str2standard_warp -o $fMRI/$subject/fMRI$n/reg/${mask}_mask_MNI

fslmaths $fMRI/$subject/fMRI$n/reg/${mask}_mask_MNI -thr 0.9 -bin $fMRI/$subject/fMRI$n/reg/${mask}_mask_MNI

elif [ $StructuralNormalization = 2 ] ; then 

$ANTSPATH/antsApplyTransforms -i $sMRI/$subject/T1w/${mask}_mask.nii.gz -r $StandardT12mm_brain -o $fMRI/$subject/fMRI$n/reg/${mask}_mask_MNI.nii.gz -t $fMRI/$subject/fMRI$n/reg/antsReg21Warp.nii.gz -t $fMRI/$subject/fMRI$n/reg/antsReg20GenericAffine.mat

fslmaths $fMRI/$subject/fMRI$n/reg/${mask}_mask_MNI.nii.gz -thr 0.9 -bin $fMRI/$subject/fMRI$n/reg/${mask}_mask_MNI.nii.gz
      
fi

fslmeants -i $fMRI/$subject/fMRI$n/${input}.nii.gz -m $fMRI/$subject/fMRI$n/reg/${mask}_mask_MNI.nii.gz -o $fMRI/$subject/fMRI$n/mc/${mask}.txt

done

if [ $Covariances = 26 ] ; then 

paste $fMRI/$subject/fMRI$n/mc/CSF.txt $fMRI/$subject/fMRI$n/mc/WM.txt ${fMRI}/${subject}/fMRI${n}/mc/Friston-24.txt >> ${fMRI}/${subject}/fMRI${n}/mc/covariance.txt

fi 

if [ $Covariances = 27 ] ; then 

paste $fMRI/$subject/fMRI$n/mc/CSF.txt $fMRI/$subject/fMRI$n/mc/WM.txt $fMRI/$subject/fMRI$n/mc/Global.txt ${fMRI}/${subject}/fMRI${n}/mc/Friston-24.txt >> ${fMRI}/${subject}/fMRI${n}/mc/covariance.txt 

fi

if [ $Covariances = 24 ] ; then

cp ${fMRI}/${subject}/fMRI${n}/mc/Friston-24.txt ${fMRI}/${subject}/fMRI${n}/mc/covariance.txt

fi

if [ $Covariances = 25 ] ; then

paste $fMRI/$subject/fMRI$n/mc/Global.txt ${fMRI}/${subject}/fMRI${n}/mc/Friston-24.txt >> ${fMRI}/${subject}/fMRI${n}/mc/covariance.txt

fi 

echo "Covariance.txt is the covariance with/without whole-brain covariance" >> $fMRI/$subject/fMRI$n.log.txt

fsl_glm -i ${fMRI}/${subject}/fMRI${n}/${input}.nii.gz -d ${fMRI}/${subject}/fMRI${n}/mc/covariance.txt --demean --out_res=${fMRI}/${subject}/fMRI${n}/${input}_covs.nii.gz

echo "covs is the output for the CovarianceRegression.sh" >> $fMRI/$subject/fMRI$n.log.txt

input=${input}_covs

