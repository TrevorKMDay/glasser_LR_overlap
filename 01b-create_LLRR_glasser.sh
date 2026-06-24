#!/bin/bash

orig=seg-glasser.dlabel.nii
flip=seg-glasserflipped.dlabel.nii

# Originally, the values to from 1-180 in RH and 181-360 in LH
# Remap the flipped values to +400, so 401-580 and 581-760 to make them
# distinct

mkdir -p LLRR/

o=LLRR/seg-glasserflipped_newlabels2.txt

if [ ! -e ${o} ] ; then

    # Create new label file
    echo "Creating +400 file"
    echo -n "" > LLRR/newlabel_indices.txt
    for i in $(seq 1 360) ; do

        echo "${i} $(echo "${i} + 400" | bc)" >> LLRR/newlabel_indices.txt

    done

    # Create new label names
    echo "Creating label file with +400 and new labels"
    sed \
        -e 's/^R_/R2L_/'        \
        -e 's/^L_/L2R_/'        \
        seg-glasser_labels.txt  > \
        LLRR/seg-glasserflipped_newlabels1.txt

    # Increase the label index by 400 and save to new file
    echo -n "" > ${o}
    while read -r i x ; do

        if [[ ${i} =~ ^[0-9]*$ ]] ; then
            # echo "Number: ${i}"
            echo "$(echo "${i} + 400" | bc) ${x}" >> ${o}
        else
            echo "${i}" >> ${o}
        fi

    done < LLRR/seg-glasserflipped_newlabels1.txt

fi

cat seg-glasser_labels.txt ${o} > LLRR/all_labels.txt

# Modify the imaging files

if [ ! -e LLRR/seg-glasserflipped_newlabels.dlabel.nii ] ; then

    echo "Modifying keys"
    wb_command -cifti-label-modify-keys \
        ${flip} \
        LLRR/all_labels.txt \
        LLRR/seg-glasserflipped_newlabels.dlabel.nii

fi

final_flipped_file=LLRR/seg-glasserflipped_newlabels2.dlabel.nii

if [ ! -e ${final_flipped_file} ] ; then

    wb_command -cifti-label-import \
        LLRR/seg-glasserflipped_newlabels.dlabel.nii \
        LLRR/all_labels.txt \
        ${final_flipped_file}

fi

echo "Splitting orig and flipped files ..."
for i in ${orig} ${final_flipped_file} ; do

    L_file=$(basename "${i}" .dlabel.nii)_left.label.gii
    R_file=$(basename "${i}" .dlabel.nii)_right.label.gii

    wb_command -cifti-separate                  \
        "${i}" COLUMN                           \
        -label CORTEX_LEFT  "LLRR/${L_file}"    \
        -label CORTEX_RIGHT "LLRR/${R_file}"

done

# Create the dscalars, do this manually to ensure things are properly matched

wb_command -cifti-create-label    \
    LLRR/seg-glasser_LL.dlabel.nii                     \
    -left-label  LLRR/seg-glasser_left.label.gii        \
    -right-label LLRR/seg-glasserflipped_newlabels2_right.label.gii

wb_command -cifti-create-label                          \
    LLRR/seg-glasser_RR.dlabel.nii                      \
    -left-label  LLRR/seg-glasserflipped_newlabels2_left.label.gii \
    -right-label LLRR/seg-glasser_right.label.gii

