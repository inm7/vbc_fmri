#!/bin/bash

         translist="" 

         averagelist=""

         im1=`echo $imglist | awk '{ print $1 }'`

         for fn in $imglist 

         do

         fslreorient2std $sMRI/$subject/$img/${fn} $sMRI/$subject/$img/average/${fn}_reorient

         robustfov -i $sMRI/$subject/$img/average/${fn}_reorient -r $sMRI/$subject/$img/average/${fn}_roi -m $sMRI/$subject/$img/average/${fn}_roi2orig.mat -b $BrainSize

         convert_xfm -omat $sMRI/$subject/$img/average/${fn}TOroi.mat -inverse $sMRI/$subject/$img/average/${fn}_roi2orig.mat

         flirt -in $sMRI/$subject/$img/average/${fn}_roi -ref $StandardT12mm -omat $sMRI/$subject/$img/average/${fn}roi_to_std.mat -out $sMRI/$subject/$img/average/${fn}roi_to_std -dof 12 -searchrx -30 30 -searchry -30 30 -searchrz -30 30

         convert_xfm -omat $sMRI/$subject/$img/average/${fn}_std2roi.mat -inverse $sMRI/$subject/$img/average/${fn}roi_to_std.mat

         if [ $fn != $im1 ] ; then

         #register version of two images (whole heads still)
	 flirt -in $sMRI/$subject/$img/average/${fn}_roi -ref $sMRI/$subject/$img/average/${im1}_roi -omat $sMRI/$subject/$img/average/${fn}_to_im1.mat -out $sMRI/$subject/$img/average/${fn}_to_im1 -dof 6 -searchrx -30 30 -searchry -30 30 -searchrz -30 30 
		
         #transform std space brain mask
	 flirt -init $sMRI/$subject/$img/average/${im1}_std2roi.mat -in $StandardMask -ref $sMRI/$subject/$img/average/${im1}_roi -out $sMRI/$subject/$img/average/${im1}_roi_linmask -applyxfm
		
         #re-register using the brain mask as a weighting image
	 flirt -in $sMRI/$subject/$img/average/${fn}_roi -init $sMRI/$subject/$img/average/${fn}_to_im1.mat -omat $sMRI/$subject/$img/average/${fn}_to_im1_linmask.mat -out $sMRI/$subject/$img/average/${fn}_to_im1_linmask -ref $sMRI/$subject/$img/average/${im1}_roi -refweight $sMRI/$subject/$img/average/${im1}_roi_linmask -nosearch
    
         else
 
         cp $FSLDIR/etc/flirtsch/ident.mat $sMRI/$subject/$img/average/${fn}_to_im1_linmask.mat
    
         fi
 
         translist="$translist $sMRI/$subject/$img/average/${fn}_to_im1_linmask.mat"

         done

         #get the halfway space transforms (midtrans output is the *template* to halfway transform)
         midtrans --separate=$sMRI/$subject/$img/average/ToHalfTrans --template=$sMRI/$subject/$img/average/${im1}_roi $translist

         #interpolate
         n=1
         for im in $imglist; do 
         num=`zeropad $n 4`;
         n=`echo $n + 1 | bc`;

         applywarp --rel -i $sMRI/$subject/$img/average/${im}_roi --premat=$sMRI/$subject/$img/average/ToHalfTrans${num}.mat -r $sMRI/$subject/$img/average/${im1}_roi -o $sMRI/$subject/$img/average/${im}ToHalf${num} --interp=spline        
         
         done



















