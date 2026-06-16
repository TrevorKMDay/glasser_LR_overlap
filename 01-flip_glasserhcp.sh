#!/bin/bash

# Give this a more usable name
rsync -u \
    HumanCorticalParcellations/Q1-Q6_RelatedValidation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR.dlabel.nii \
    seg-glasser.dlabel.nii

# Do the flip
./rois_create_mirror.sh \
    "$(which wb_command)" \
    seg-glasser.dlabel.nii \
    seg-glasserflipped.dscalar.nii

# Export table labels for reading into R
wb_command -cifti-label-export-table \
    seg-glasser.dlabel.nii 1 seg-glasser_labels.txt

wb_command -cifti-label-import          \
    seg-glasserflipped.dscalar.nii      \
    seg-glasser_labels.txt              \
    seg-glasserflipped.dlabel.nii

