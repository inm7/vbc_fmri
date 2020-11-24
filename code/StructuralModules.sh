#!/bin/bash

startingtime=$(date +%s)

#Structural Modules
if [ -e $sMRI/$subject ] ; then 

echo "overwrite the subject directory" >> $sMRI/$subject/log.txt
 
rm -rf $sMRI/$subject

fi

mkdir -p $sMRI/$subject

date >> $sMRI/$subject/log.txt

echo "start stuctural preprocessing" >> $sMRI/$subject/log.txt

#set the images types, T1 only or both T1 and T2 

type=""

if [ $T2w = 1 ] ; then

type="$type T1w T2w"

else

type="$type T1w" 

fi
 
for img in $type

do

  mkdir -p $sMRI/$subject/$img

#copy the Orignal images to the running dirctory
  
  imglist=""

  n=1

  while [ $n -le $Session ] ; do  

  imcp $Orig/$subject/T1/session$n/*${postfix} $sMRI/$subject/$img/${img}${n}.${postfix}

##imcp $Orig/$subject/T1/*.${postfix} $sMRI/$subject/$img/${img}${n}.${postfix}

  imglist="$imglist ${img}${n}"

  n=$(($n+1))

  done

#start averging process, if structural averaging is included.
#create image list

if [ $Concat = 1 ] ; then 

  echo "start averaging processing">>$sMRI/$subject/log.txt

  mkdir -p $sMRI/$subject/$img/average

  source $Pipelines/anatomical_average.sh

  fslmaths $sMRI/$subject/$img/average/${img}1ToHalf0001.nii.gz -add $sMRI/$subject/$img/average/${img}2ToHalf0002.nii.gz -div 2 $sMRI/$subject/$img/${img}_average

echo "${img}_average is the output from the anatomical_average.sh" >>$sMRI/$subject/log.txt

else 

  echo "don't perform averaging processing" >>$sMRI/$subject/log.txt

fi

#start acpc-alignment procedure

  mkdir -p $sMRI/$subject/$img/acpc

  if [ -f $sMRI/$subject/$img/${img}_average.nii.gz ] ; then 

  input=${img}_average

  source $Pipelines/acpc_alignment.sh

echo "acpc is the output from the acpc_alignment.sh" >>$sMRI/$subject/log.txt

  else

  fslreorient2std $sMRI/$subject/$img/${img}1 $sMRI/$subject/$img/$img

  robustfov -i $sMRI/$subject/$img/$img -b $BrainSize -m $sMRI/$subject/$img/acpc/roi2full.mat -r $sMRI/$subject/$img/robustroi

  input=robustroi
 
  source $Pipelines/acpc_alignment.sh

echo "acpc is the output from the acpc-alignment">>$sMRI/$subject/log.txt

  fi

#start ants brain extraction

input=${img}_acpc

if [ $brainmethod=1 ] ; then 

echo "start brain extraction by antsbrain" >>$sMRI/$subject/log.txt

source $Pipelines/antsbrain.sh

echo "brain is the output from the autsbrain.sh" >>$sMRI/$subject/log.txt

fi

done

#bias-correction for T1w only,
#Compute T1w Bias Normalization using fsl_anat function

if [ $biascorr = 1 ]; then 

if [ $T2w = 0 ] ; then 

echo "start bias corrction without T2w images" >> $sMRI/$subject/log.txt

#perform T1 bias correction only. Bias and bias-corrected T1w images would be calculated by the fsl_anat

fsl_anat -i $sMRI/$subject/T1w/T1w_acpc -o $sMRI/$subject/T1w/T1w --noreorient --clobber --nocrop --noreg --nononlinreg --nosubcortseg --nocleanup --noseg --betfparam=0 

imcp $sMRI/$subject/T1w/T1w.anat/T1_biascorr $sMRI/$subject/T1w/T1_biascorr

imcp $sMRI/$subject/T1w/T1w.anat/T1_fast_bias $sMRI/$subject/T1w/bias_field

rm -rf $sMRI/$subject/$img/${img}.anat

fslmaths $sMRI/$subject/T1w/T1_biascorr.nii.gz -mas $sMRI/$subject/T1w/T1w_acpc_brain $sMRI/$subject/T1w/T1_biascorr_brain	

echo "*biascorr* is the output from fsl_anat" >>$sMRI/$subject/log.txt

else

#start T2w to T1w co-registration using EPI_REG (FSL)

mkdir -p $sMRI/$subject/T2wtoT1RegAndBias

#start T2w and T1w bias correction, co-register T2w to T1w images first, and correct bias then.

source $Pipelines/T2wtoT1wReg.sh

source $Pipelines/T2wT1wbiascorrection.sh 

imcp $sMRI/$subject/T2wtoT1RegAndBias/T1_biascorr $sMRI/$subject/T1w/T1_biascorr

imcp $sMRI/$subject/T2wtoT1RegAndBias/T1_biascorr_brain $sMRI/$subject/T1w/T1_biascorr_brain

imcp $sMRI/$subject/T2wtoT1RegAndBias/bias_field $sMRI/$subject/T1w/bias_field

echo "*biascorr* is the output from the T2wtoT1wReg.sh and T2wT1wbiascorrection.sh" >>$sMRI/$subject/log.txt

fi 

input=T1_biascorr

else 

echo "don't perform bias correction" >> $sMRI/$subject/log.txt

input=T1w_acpc

fi

#segment structural images at the native structural space

echo "start segmentation from $input"

fast -n 3 -p -o $sMRI/$subject/T1w/$input $sMRI/$subject/T1w/${input}_brain

fslmaths $sMRI/$subject/T1w/${input}_pve_0.nii.gz -thr 0.99 -bin $sMRI/$subject/T1w/CSF_mask.nii.gz

fslmaths $sMRI/$subject/T1w/${input}_pve_1.nii.gz -thr 0.99 -bin $sMRI/$subject/T1w/GM_mask.nii.gz 

fslmaths $sMRI/$subject/T1w/${input}_pve_2.nii.gz -thr 0.99 -bin $sMRI/$subject/T1w/WM_mask.nii.gz

fslmaths  $sMRI/$subject/T1w/CSF_mask.nii.gz -add $sMRI/$subject/T1w/GM_mask.nii.gz -add $sMRI/$subject/T1w/WM_mask.nii.gz -bin $sMRI/$subject/T1w/Global_mask.nii.gz

rm -rf $sMRI/$subject/T1w/*pve*

rm -rf $sMRI/$subject/T1w/*prob* 

#start structural normalization procedure. 

echo "start structural normalization"

mkdir -p $sMRI/$subject/T1w/fnirt

source  $Pipelines/StructuralNormalization.sh

echo "*MNI* is the output from the StructuralNormalization.sh" >>$sMRI/$subject/log.txt

date >>$sMRI/$subject/log.txt

et=$sMRI/$subject/sMRIelapsedtime.txt

elapsedtime=$(($(date +%s) - $startingtime))

printf "sMRI elapsed time = ${elapsedtime} seconds.\n"

echo "${elapsedtime}" >> ${et}

