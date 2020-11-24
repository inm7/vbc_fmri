#!/bin/bash

#This script is about structural preprocessing and functional preprocessing. It will will call other separated scripts for each module.
#The first step for you to run this script, please change the following parameters based on your conditions.

subject=$1

threads=5 #if ants applied, select the threads (consistent with your server). Or you can fix the threads with a constant as you wish.

#module load 
#afni
source /etc/fsl/fsl.sh
#fsl
source /etc/afni/afni.sh
#ants
export ANTSPATH=/usr/lib/ants
export PATH=${PATH}:/usr/lib/ants

#module selection, Structural Module and rest minimal preprocessing are recommended to be mandatory. Rest enhanced preprocessing and Rest extraction are optional. 1: to do; 0: not to do.
StructuralModule=1
MinimalModule=1
EnhancedModule=1
ExtractionModule=1

#server path for Jurece
#set the path for Raw data and out directory
Orig=/mnt/to/path #Raw data path
sMRI=/mnt/to/sMRI/output #strucutral output directory
fMRI=/mnt/to/rfMRI/output #functional output directory
#Original dataset could be nii.gz or nii, which depends on the converting settings
postfix=nii #we may find different postfix name for converted images (nii or nii.gz).
#set the path for the directory saving the functional scripts
Pipelines=/usr/local/bin #please make sure all the separated scripts are saved in one directory
ANTSTEMP=${ANTSPATH}/antsTemp #ants prior brain extraction

#Here are parameters for structural module
#set the image types. 
T2w=0 #If T2w is included for structural preprocessing, please set T2w=1, or T2w=0.
#set the number of sessions. 
Session=1 #If the data is not multi-session scanned, just set Session=1
#Structural average.
Concat=0 #If the structural images are scanned with 2 sessions. Only used ( Concat = 1), when $Session=2.
#Standard template images for normalization with different resolutions. Here is the default-in images in the FSL source directory.
StandardT12mm=$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz
StandardT12mm_brain=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz
StandardT12mm_brain_mask=$FSLDIR/data/standard/MNI152_T1_2mm_brain_mask.nii.gz
StandardT11mm=$FSLDIR/data/standard/MNI152_T1_1mm.nii.gz
StandardMask=$FSLDIR/data/standard/MNI152_T1_2mm_brain_mask_dil.nii.gz
StandardT2=$FSLDIR/data/standard/MNI152_T2_1mm.nii.gz #This image is only for T2w image preprocessing. Please copy it from HCP pipelines
#BrainSize for image cropping
BrainSize=150 #BrainSize cropping at the Z axis. Numbers from 150 to 180 are accepted.
biascorr=0 #biascorr using fsl_anat
#set structural normalization methods.
StructuralNormalization=2 # If fsl-fnirt is included, please set StructuralNormalization = 1. If ants is included, please set StructuralNormalization = 2.
#Here are specific parameters for the functional module.
TR=2.2 #Repeat Time (TR).
exvol=4 #exclusion of the initial volumes.
#Slice-timing procedure
Slicetiming=1 #If Silice-timing is included, please set Slicetiming=1, or 0.
#Smoothing procedure
Smoothing=1 #If Smoothing is included, please set Smoothing=1, or 0.
SmoothingFWHM=8 #The number for Smoothing kernel
#Temporal filtering procedure.
TemporalFilter=1 #If Temporal filtering procedure is included, please set TemporalFilter = 1, or 0. 
highbands=0.1 
lowbands=0.01
#regress out covariances or not
CovarianceRegression=1
Covariances=27 #Sevearal options are available. 24 = only regress out 24 head-motion parameters, 25 = regress out 24 head-motion parameters + global singals, 26 = 24 head-motion parameters + WM + CSF signals, 27 = 24 head-motion parameters + CSF + Global + WM signals. 

#Atlases for extraction module, set the path of your atlases and atlas names for them.
atlasname=atlas name #your atlas name
atlas=/mnt/to/your/atlas nifti #your atlas path

if [ $StructuralModule = 1 ] ; then 

source $Pipelines/StructuralModules.sh

fi

if [ $MinimalModule = 1 ] ; then 

source $Pipelines/RestMinimalPreprocessing.sh

fi

if [ $EnhancedModule = 1 ] ; then 

source $Pipelines/RestEnhancedPreprocessingModules.sh

fi

if [ $ExtractionModule = 1 ] ; then 

source $Pipelines/RestExtraction.sh

fi 
