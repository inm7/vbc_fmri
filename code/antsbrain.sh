#!/bin/bash

BetDir=$sMRI/$subject/T1w/bet

if [ -e ${BetDir} ] ; then
	rm -r ${BetDir}
	mkdir ${BetDir}
else
	mkdir -p ${BetDir}
fi

bash antsBrainExtraction.sh -d 3 -a $sMRI/$subject/$img/${img}_acpc.nii.gz -e $ANTSTEMP/T_template0.nii.gz -m $ANTSTEMP/T_template0_BrainCerebellumProbabilityMask.nii.gz -f $ANTSTEMP/T_template0_BrainCerebellumRegistrationMask.nii.gz -o $BetDir/${img}_acpc

mv $BetDir/${img}_acpcBrainExtractionBrain.nii.gz $sMRI/$subject/$img/${img}_acpc_brain.nii.gz
