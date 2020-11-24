#!/bin/bash

#This script is about functional normalization with different methods (ANTs or fsl-fnirt)

echo "$input is the input for FunctionalNormalization.sh" >> $fMRI/$subject/fMRI$n.log.txt

if [ $StructuralNormalization = 1 ] ; then  

  if [ -f $fMRI/$subject/fMRI$n/reg/fMRI2standard_warp.nii.gz ]; then 

  echo "detect fMRI2standard_warp.nii.gz" >> $fMRI/$subject/fMRI$n.log.txt

  elif [ -f $fMRI/$subject/fMRI$n/reg/example_func2highres.mat ] ; then 

  echo "detect example_func2highres" >> $fMRI/$subject/fMRI$n.log.txt

  convertwarp -o $fMRI/$subject/fMRI$n/reg/fMRI2standard_warp -r $StandardT12mm -m $fMRI/$subject/fMRI$n/reg/example_func2highres.mat -w $sMRI/$subject/T1w/fnirt/str2standard_warp

  else 

  echo "create example_func2highres" >> $fMRI/$subject/fMRI$n.log.txt

  flirt -in fMRI/$subject/fMRI$n/example_func_brain -ref $fMRI/$subject/fMRI$n/reg/highres -dof $dof -omat $fMRI/$subject/fMRI$n/reg/example_func2highres.mat -o $fMRI/$subject/fMRI$n/reg/example_func2highres.nii.gz 

  convertwarp -o $fMRI/$subject/fMRI$n/reg/fMRI2standard_warp -r $StandardT12mm -m $fMRI/$subject/fMRI$n/reg/example_func2highres.mat -w $sMRI/$subject/T1w/fnirt/str2standard_warp

  fi

  applywarp -i $fMRI/$subject/fMRI$n/$input -w $fMRI/$subject/fMRI$n/reg/fMRI2standard_warp -r $StandardT12mm --rel --interp=spline -o $fMRI/$subject/fMRI$n/${input}_MNI -m $StandardMask

elif [ $StructuralNormalization = 2 ] ; then

  if [ ! -f $fMRI/$subject/fMRI$n/reg/example_func_brain2highres0GenericAffine.mat ] ; then 

  echo "create ants_example_func2highres0GernericAffine"

  antsRegistrationSyN.sh -d 3 -m $fMRI/$subject/fMRI$n/example_func_brain.nii.gz -f $fMRI/$subject/fMRI$n/reg/highres.nii.gz -t a -o $fMRI/$subject/fMRI$n/reg/example_func_brain2highres -n $threads

  antsApplyTransforms -d 3 -i $fMRI/$subject/fMRI$n/example_func_brain_mask.nii.gz -r $fMRI/$subject/fMRI$n/reg/highres.nii.gz -t $fMRI/$subject/fMRI$n/reg/example_func_brain2highres0GenericAffine.mat -n NearestNeighbor -o $fMRI/$subject/fMRI$n/reg/example_func_brain2highres_mask.nii.gz

  fi

  imcp $sMRI/$subject/T1w/T1w_acpc.nii.gz $fMRI/$subject/fMRI$n/reg/highres_head.nii.gz

  fslmaths $fMRI/$subject/fMRI$n/reg/highres.nii.gz -add  $fMRI/$subject/fMRI$n/reg/example_func_brain2highres_mask.nii.gz -bin  $fMRI/$subject/fMRI$n/reg/highres_func_mask.nii.gz

  fslmaths $fMRI/$subject/fMRI$n/reg/highres_head.nii.gz -mas $fMRI/$subject/fMRI$n/reg/highres_func_mask.nii.gz $fMRI/$subject/fMRI$n/reg/highres2.nii.gz

  if [ ! -f $fMRI/$subject/fMRI$n/reg/antsReg21Warp.nii.gz ] ; then 

  antsRegistrationSyN.sh -d 3 -m $fMRI/$subject/fMRI$n/reg/highres2.nii.gz -f $StandardT12mm_brain -t s -o $fMRI/$subject/fMRI$n/reg/antsReg2 -n $threads

  fi

  antsApplyTransforms -d 3 -i $fMRI/$subject/fMRI${n}/example_func_brain.nii.gz -r $StandardT12mm_brain -t $fMRI/$subject/fMRI$n/reg/antsReg21Warp.nii.gz -t $fMRI/$subject/fMRI$n/reg/antsReg20GenericAffine.mat -t $fMRI/$subject/fMRI$n/reg/example_func_brain2highres0GenericAffine.mat -o $fMRI/$subject/fMRI${n}/mc/example_func_brain2std.nii.gz

  antsApplyTransforms -e 3 -i $fMRI/$subject/fMRI${n}/${input}.nii.gz -r $StandardT12mm_brain -t $fMRI/$subject/fMRI$n/reg/antsReg21Warp.nii.gz -t $fMRI/$subject/fMRI$n/reg/antsReg20GenericAffine.mat -t $fMRI/$subject/fMRI$n/reg/example_func_brain2highres0GenericAffine.mat -o $fMRI/$subject/fMRI${n}/${input}_MNI.nii.gz

fi

input=${input}_MNI

echo "${input}_MNI.nii.gz is the output for FunctionalNormalization.sh" >> $fMRI/$subject/fMRI$n.log.txt

#usage
#convertwarp -m affine_matrix_file -r refvol -o output_warp
#convertwarp --ref=refvol --premat=mat1 --warp1=vol1 --warp2=vol2 --postmat=mat2 --out=output_warp
#applywarp -i invol -o outvol -r refvol -w warpvol
#antsApplyTransforms -e image types -i input -r reference image -o output image -t transform matrix and field
#antsRegistrationSyN.sh -d image dimensionality -m movable image -f fixed image -t transformation methods -o output image 
