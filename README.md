# Containerized Functional MRI data preprocessing pipeline

## REQUIREMENTS

1. To use this containerized pipeline, please install 'singularity' on your computing system. https://sylabs.io/guides/3.3/user-guide/installation.html

2. Filesa: Container_sMRI_rfMRI.simg (This container uses a combination of tools from well-known software packages, including FSL (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki), ANTs (https://github.com/ANTsX/ANTs), and AFNI (https://afni.nimh.nih.gov/).) 

```
StructuralAndRestPreprocessing.sh
README.md
```

### 3. Additional files

antsTemp: The folder includes prior brain extraction template for `antsBrainExtraction.sh
MNI152_T2_1mm.nii.gz/MNI152_T2_1mm_brain.nii.gz`: The template images for T2w image processings.

The additional files have been included in the container. AntsTemp is highly recommended to be stored in the directory of Ants. `MNI152_T2_1mm.nii.gz` and `MNI152_T2_1mm_brain.nii.gz` are suggested to be stored in the `$FSLDIR/data/standard`.


## INSTRUCTION

### 1. ARGUMENTS

The containerized fMRI pipeline consists of 4 modules: sMRI model, functional minimal preprocessing model, enhanced preprocessing model, and signal extraction model.
To execute this container models, the singularity function and two arguments should be defined.
Example:


    singularity exec --bind /mount/path:/mnt Container_sMRI_rfMRI.simg StructuralAndRestPreprocessing.sh $subject

The first argument specifies all necessary parameters for preprocessing and the second one specifies the subject ID.

An example of a `StructuralAndRestPreprocessing.sh` is as followed.

## 2. Input variables

    # ---------------
    #module selection
    Module load: default settings for software within the container. Don’t change it.
    Model selection: select the models you want to use (1 = on; 0 = off).

    #Path settings. 
    Orig=/mnt/path/to/raw_data      #Raw data path. The raw data path should have a data structure as below.
    Orig
    |-- ${subject}
    |   |--T1--session1--nifti (T1w) 
    |   |-- rfMRI--session1--nifti (Rest)
    |   |-- Parad--session1--nifti (Task)

    sMRI=/mnt/path/to/sMRI          #sMRI output path
    fMRI=/mnt/path/to/fMRI          #fMRI output path
    ANTSTEMP=/path/to/ants/priors   #brain extraction template for ants (used only for ants brain extraction).
    atlas=/mnt/path/to/atlas        #the path to the atlas.
    Pipelines=/usr/local/bin        #script path within the container.

    atlasname=Schaefer              #the name of the atlas.
    postfix=nii.                    #Raw data postfix, in case of different dcm2nii software.

    #sMRI model parameter.
    T2w=0                       #if T2w used, set 1; if not, set 0.
    Session=1                   #session number of dataset (1 = 1 session, 2 = 2 sessions).
    Concat=0:                   #If the structural images are scanned with 2 sessions. Only used ( Concat = 1), when $Session=2.
    Standard*:                  default MNI paths within FSL (for registration, don't change it).
    BrainSize=150               #Z-axis for cropping (150-180), remove the long neck.
    biascorr=0                  #bias correction for structural images (1 = on, 0 = off). Note, you don't perform it in this version, antsBrainExtraction is applied, which has bias correction, so that you don't need to do bias correction twice.
    StructuralNormalization=2   #different normalization ways (1 for FSL, 2 for ANTs).
    Threads=5                   #only used for ANTs registration, consistent with paralleling threads.

    #Note: sMRI model should be performed first. The brain extracted structural images will be used for other models.

    #Minimal model parameter. 
    TR=2            #repeat time.
    exvol=4         #exclusion volumes. 
    Slicetiming=1   #correct slice timing differences (1 = on, 0 = off), it's optional.

    #Note: Slice timing correction should be selected by your slice-order. In this case, our data was scanned by bottom-up order. The images with *norm* is the output for this model.

    #Enhanced model parameter. 
    Smoothing=1         #smooth epi images (1 = on, 0 = off), it's optional. 
    SmoothingFWHM=8     #the kernel of smoothing, which is commonly 2 or 3 times of the voxel-size. 
    TemporalFilter=1    #filter frequency-band signals (1 = on, 0 = off). Its' optional.
    lowbands=0.01       #low-pass
    highbands=0.1       #high-pass

    CovarianceRegression=1: regress out covariances (1 = on, 0 = off). It's optional.
    Covariances: 27         #Sevearal options are available. 24 = only regress out 24 head-motion parameters, 25 = regress out 24 head-motion parameters + global singals, 26 = 24 head-motion parameters + WM + CSF signals, 27 = 24 head-motion parameters + CSF + Global + WM signals.

    #Note: For saving the space, final output of this model is filtered_func_data.nii.gz. 

    #Singal extraction model parameter.


## TROUBLESHOOT

If you have a problem to use the containerized pipeline. Please feel free to contact Shufei Zhang (sh.zhang@fz-juelich.de).

