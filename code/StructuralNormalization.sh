#!/bin/bash

NonlinDir=$sMRI/$subject/T1w/fnirt

if [ -e ${NonlinDir} ] ; then
	rm -r ${NonlinDir}
	mkdir ${NonlinDir}
else
	mkdir -p ${NonlinDir}
fi

if [ $StructuralNormalization = 1 ] ; then 

#perform FSL normalization 
#Linear registration to MNI (initial guess for non-linear transformation

flirt -interp spline -dof 12 -in $sMRI/$subject/T1w/${input}_brain -ref $StandardT12mm_brain -omat ${NonlinDir}/acpc2MNILinear.mat -out ${NonlinDir}/acpc_to_MNILinear

#then non-linear registration to MNI

fnirt --in=$sMRI/$subject/T1w/${input} --ref=$StandardT12mm --aff=${NonlinDir}/acpc2MNILinear.mat --refmask=$StandardMask --fout=${NonlinDir}/str2standard_warp --jout=${NonlinDir}/NonlinearRegJacobians.nii.gz --refout=${NonlinDir}/IntensityModulatedT1.nii.gz --iout=${NonlinDir}/2mmReg.nii.gz --logout=${NonlinDir}/NonlinearReg.txt --intout=${NonlinDir}/NonlinearIntensities.nii.gz --cout=${NonlinDir}/NonlinearReg.nii.gz 

#Input and reference spaces are the same, using 2mm reference to save time
invwarp -w ${NonlinDir}/str2standard_warp -o ${NonlinDir}/str2standard_warp_inv -r $StandardT12mm

applywarp --rel --interp=spline -i $sMRI/$subject/T1w/${input} -r $StandardT12mm -w ${NonlinDir}/str2standard_warp  -o ${NonlinDir}/${input}_to_MNI

applywarp --rel --interp=nn -i $sMRI/$subject/T1w/${input}_brain -r $StandardT12mm -w ${NonlinDir}/str2standard_warp -o ${NonlinDir}/${input}_brain_to_MNI


elif [ $StructuralNormalization = 2 ] ; then 

#perform ANTS normalization
antsRegistrationSyN.sh -d 3 -m $sMRI/$subject/T1w/${input}_brain.nii.gz -f $StandardT12mm_brain -t s -n $threads -o ${NonlinDir}/antsReg

fi
