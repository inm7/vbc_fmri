#!/usr/bin/env bash
## resting-state filename (no extension)
MC=$input

## directory setup
mkdir -p $fMRI/$subject/fMRI$n/mc/nuisance

## generate the temporal derivates of motion
cp $fMRI/$subject/fMRI$n/${MC}.par $fMRI/$subject/fMRI$n/mc/${MC}_mc.1D

1d_tool.py -infile $fMRI/$subject/fMRI$n/mc/${MC}_mc.1D -derivative -write $fMRI/$subject/fMRI$n/mc/${MC}_mcdt.1D

## 2.2 Seperate motion parameters into seperate files
echo "Splitting up ${subject} motion parameters"
awk '{print $1}' $fMRI/$subject/fMRI$n/mc/${MC}_mc.1D > $fMRI/$subject/fMRI$n/mc/nuisance/mc1.1D
awk '{print $2}' $fMRI/$subject/fMRI$n/mc/${MC}_mc.1D > $fMRI/$subject/fMRI$n/mc/nuisance/mc2.1D
awk '{print $3}' $fMRI/$subject/fMRI$n/mc/${MC}_mc.1D > $fMRI/$subject/fMRI$n/mc/nuisance/mc3.1D
awk '{print $4}' $fMRI/$subject/fMRI$n/mc/${MC}_mc.1D > $fMRI/$subject/fMRI$n/mc/nuisance/mc4.1D
awk '{print $5}' $fMRI/$subject/fMRI$n/mc/${MC}_mc.1D > $fMRI/$subject/fMRI$n/mc/nuisance/mc5.1D
awk '{print $6}' $fMRI/$subject/fMRI$n/mc/${MC}_mc.1D > $fMRI/$subject/fMRI$n/mc/nuisance/mc6.1D
awk '{print $1}' $fMRI/$subject/fMRI$n/mc/${MC}_mcdt.1D > $fMRI/$subject/fMRI$n/mc/nuisance/mcdt1.1D
awk '{print $2}' $fMRI/$subject/fMRI$n/mc/${MC}_mcdt.1D > $fMRI/$subject/fMRI$n/mc/nuisance/mcdt2.1D
awk '{print $3}' $fMRI/$subject/fMRI$n/mc/${MC}_mcdt.1D > $fMRI/$subject/fMRI$n/mc/nuisance/mcdt3.1D
awk '{print $4}' $fMRI/$subject/fMRI$n/mc/${MC}_mcdt.1D > $fMRI/$subject/fMRI$n/mc/nuisance/mcdt4.1D
awk '{print $5}' $fMRI/$subject/fMRI$n/mc/${MC}_mcdt.1D > $fMRI/$subject/fMRI$n/mc/nuisance/mcdt5.1D
awk '{print $6}' $fMRI/$subject/fMRI$n/mc/${MC}_mcdt.1D > $fMRI/$subject/fMRI$n/mc/nuisance/mcdt6.1D
echo "Preparing 1D files for Friston-24 motion correction"

for ((k=1 ; k <= 6 ; k++))
do
	# calculate the squared MC files
	1deval -a $fMRI/$subject/fMRI$n/mc/nuisance/mc${k}.1D -expr 'a*a' > $fMRI/$subject/fMRI$n/mc/nuisance/mcsqr${k}.1D


	# calculate the AR and its squared MC files
	1deval -a $fMRI/$subject/fMRI$n/mc/nuisance/mc${k}.1D -b $fMRI/$subject/fMRI$n/mc/nuisance/mcdt${k}.1D -expr 'a-b' > $fMRI/$subject/fMRI$n/mc/nuisance/mcar${k}.1D
	1deval -a $fMRI/$subject/fMRI$n/mc/nuisance/mcar${k}.1D -expr 'a*a' > $fMRI/$subject/fMRI$n/mc/nuisance/mcarsqr${k}.1D
done

HMlist=""

for label in mc mcar mcsqr mcarsqr
do 

for ((k=1; k <= 6 ; k++))
do

HMlist="$HMlist $fMRI/$subject/fMRI$n/mc/nuisance/${label}${k}.1D"

done
done

echo $HMlist >> $fMRI/$subject/fMRI$n/mc/nuisance/HMlist.txt

paste $HMlist >>$fMRI/$subject/fMRI$n/mc/Friston-24.txt

