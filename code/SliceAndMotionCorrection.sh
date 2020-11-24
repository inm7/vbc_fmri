#!/bin/bash

#start slice-timing procedures

if [ $Slicetiming = 1 ] ; then 

echo "start slice-timing (bottom-up slice order), if you use different slice timing scanning, please change the parameters accordingly" >>$fMRI/$subject/fMRI${n}.log.txt

slicetimer -i $fMRI/$subject/fMRI$n/${input} -o $fMRI/$subject/fMRI$n/${input} -r $TR --down

fi 

#extract and average the 10th-20th volumes as the example_func image

fslroi $fMRI/$subject/fMRI$n/$input $fMRI/$subject/fMRI$n/example_func 10 10

mcflirt -in $fMRI/$subject/fMRI$n/example_func -out $fMRI/$subject/fMRI$n/example_func 

fslmaths $fMRI/$subject/fMRI$n/example_func -Tmean  $fMRI/$subject/fMRI$n/example_func

bet  $fMRI/$subject/fMRI$n/example_func  $fMRI/$subject/fMRI$n/example_func_brain -f 0.4 -m 

#start head-motion correction. This step is necessary for further analysis.

mcflirt -in $fMRI/$subject/fMRI$n/$input -out $fMRI/$subject/fMRI$n/${input}_mcf -mats -plots -reffile $fMRI/$subject/fMRI$n/example_func -rmsrel -rmsabs -spline_final

fslmaths $fMRI/$subject/fMRI$n/${input}_mcf -mas $fMRI/$subject/fMRI$n/example_func_brain $fMRI/$subject/fMRI$n/${input}_mcf

echo "${input}_mcf is the output for SliceAndMotionCorrection.sh" >>$fMRI/$subject/fMRI${n}.log.txt

input=${input}_mcf

#mcflirt -in <infile> [options]
#        -out, -o <outfile>               (default is infile_mcf)
#        -cost {mutualinfo,woods,corratio,normcorr,normmi,leastsquares}        (default is normcorr)
#        -bins <number of histogram bins>   (default is 256)
#        -dof  <number of transform dofs>   (default is 6)
#        -refvol <number of reference volume> (default is no_vols/2)- registers to (n+1)th volume in series
#        -reffile, -r <filename>            use a separate 3d image file as the target for registration (overrides refvol option)
#        -stages <number of search levels>  (default is 3 - specify 4 for final sinc interpolation)
#        -spline_final                      (applies final transformations using spline interpolation)
#        -nn_final                          (applies final transformations using Nearest Neighbour interpolation)
#        -meanvol                           register timeseries to mean volume (overrides refvol and reffile options)
#        -mats                              save transformation matricies in subdirectory outfilename.mat
#        -plots                             save transformation parameters in file outputfilename.par

#the function for slice-timing correction
#slicetimer -i <timeseries> [-o <corrected_timeseries>] [options]

#           -i, filename of input timeseries
#           -o, filename of output timeseries
#           -r, Specify TR of data
#           -v, switch on diagnostic messages
#           --odd, use interleaved acquisition
#           --tcustom, filename of single-column slice timings, in fractions of TR, +ve values shift slices forwards in time
#           --ocustom, filename of single-column custom interleave order file (first slice is referred to as 1 not 0)
#           make sure about the slice order during scanning, contact with scanning operators
