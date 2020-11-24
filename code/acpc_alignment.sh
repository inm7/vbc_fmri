#!/bin/bash

         #Register cropped image to MNI152 (12 DOF)
         flirt -interp spline -in $sMRI/$subject/$img/$input -ref $StandardT11mm -omat $sMRI/$subject/$img/acpc/roi2std.mat -out $sMRI/$subject/$img/acpc/acpc_final.nii.gz -searchrx -30 30 -searchry -30 30 -searchrz -30 30

         if [ -f acpc/roi2full.mat ] ; then 

         convert_xfm -omat $sMRI/$subject/$img/acpc/full2roi.mat  -inverse $sMRI/$subject/$img/acpc/roi2full.mat

         convert_xfm -omat $sMRI/$subject/$img/acpc/full2std -concat $sMRI/$subject/$img/acpc/roi2std.mat acpc/full2roi.mat

         aff2rigid $sMRI/$subject/$img/acpc/full2std.mat $sMRI/$subject/$img/acpc/acpc.mat         

         else

         #Get a 6 DOF approximation which does the ACPC alignment (AC, ACPC line, and hemispheric plane)
         aff2rigid $sMRI/$subject/$img/acpc/roi2std.mat $sMRI/$subject/$img/acpc/acpc.mat

         fi

         #Create a resampled image (ACPC aligned) using spline interpolation
         applywarp --rel --interp=spline -i $sMRI/$subject/$img/$input -r $StandardT11mm --premat=$sMRI/$subject/$img/acpc/acpc.mat -o $sMRI/$subject/$img/${img}_acpc
