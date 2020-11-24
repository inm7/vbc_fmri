#!/bin/bash

#This script is about epi signal normalization

#transform bias filed of T1 images to functional time series 

#start FSL-epi-reg registration 

##if [ $StructuralNormalization = 1 ] ; then

##fslmaths $sMRI/$subject/T1w/WM_mask -edge -bin -mas $sMRI/$subject/T1w/WM_mask $fMRI/$subject/fMRI$n/reg/WM_edge

##${HCPPIPEDIR_Global}/epi_reg_dof --dof=${dof} --epi=$fMRI/$subject/fMRI$n/mc/example_func_brain --t1=$fMRI/$subject/fMRI$n/reg/T1 --t1brain=$fMRI/$subject/fMRI$n/reg/highres --out=$fMRI/$subject/fMRI$n/reg/example_func2highres --wmseg=$fMRI/$subject/fMRI$n/reg/WM_edge

##mv $fMRI/$subject/fMRI$n/reg/example_func2highres_init.mat $fMRI/$subject/fMRI$n/reg/example_func2highres.mat

##convert_xfm -inverse $fMRI/$subject/fMRI$n/reg/example_func2highres.mat -omat $fMRI/$subject/fMRI$n/reg/highres2example_func.mat 

#Usage: flirt [options] -in <inputvol> -ref <refvol> -out <outputvol>
#       flirt [options] -in <inputvol> -ref <refvol> -omat <outputmatrix>
#       flirt [options] -in <inputvol> -ref <refvol> -applyxfm -init <matrix> -out <outputvol>

##flirt -in $sMRI/$subject/T1w/bias_field -ref $fMRI/$subject/fMRI$n/mc/example_func_brain -applyxfm -init $fMRI/$subject/fMRI$n/reg/highres2example_func.mat -interp spline -out $fMRI/$subject/fMRI$n/reg/T1_bias2example_func

##elif [ $StructuralNormalization = 2 ] ; then

##$ANTSPATH/antsRegistrationSyN.sh -d 3 -m $fMRI/$subject/fMRI$n/mc/example_func_brain.nii.gz -f $fMRI/$subject/fMRI$n/reg/highres.nii.gz -t a -o $fMRI/$subject/fMRI$n/reg/ants_example_func2highres

##$ANTSPATH/antsApplyTransforms -i $sMRI/$subject/T1w/bias_field.nii.gz -r $fMRI/$subject/fMRI$n/mc/example_func_brain.nii.gz -o $fMRI/$subject/fMRI$n/reg/T1_bias2example_func.nii.gz -t  [$fMRI/$subject/fMRI$n/reg/ants_example_func2highres0GenericAffine.mat,1]

##fi 

##meanvalue=`fslstats $fMRI/$subject/fMRI$n/mc/${input} -M` 

##fslmaths $fMRI/$subject/fMRI$n/mc/${input} -div $meanvalue -ing 10000 $fMRI/$subject/fMRI$n/mc/${input}_norm

fslmaths $fMRI/$subject/fMRI$n/${input} -inm 10000 $fMRI/$subject/fMRI$n/${input}_norm

fslmaths $fMRI/$subject/fMRI$n/${input}_norm -Tmean $fMRI/$subject/fMRI$n/tempMean

echo "${input}_norm is the output for IntensityNormalization.sh" >>$fMRI/$subject/fMRI$n.log.txt
