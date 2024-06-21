#!/bin/bash
# 
# This script does the following:
# 1. Registration all T2w non-fat-suppresed and fat suppresed images
# -- Registration from ses-01 to ses02
# -- Registration using sct_register_multimodal
# -- Registration only using anat images (not yet SC, not yet vertebral levels)
# -- Calculate the similarity metrics on registered images
# 
# Author: Nilser Laines Medina

# Create the metrics directory if it doesn't exist
mkdir -p metrics

# Path to dataset directory
bids_file="head-neck-tumor-challenge-2024"

# Function to perform registration and evaluate metrics
register_and_evaluate() {
    local subject=$1
    local acq_suffix=$2
    local sub=$(printf "%03g" $subject)

    # Rigid registration
    sct_register_multimodal -i "$bids_file/sub-$sub/ses-1/anat/sub-${sub}_ses-1_acq-${acq_suffix}_T2w.nii.gz" \
                            -d "$bids_file/sub-$sub/ses-2/anat/sub-${sub}_ses-2_acq-${acq_suffix}_T2w.nii.gz" \
                            -ofolder sct_rigid -param step=1,type=im,algo=rigid,metric=MI,iter=100,shrink=2

    # Rigid + affine + syn registration
    sct_register_multimodal -i "$bids_file/sub-$sub/ses-1/anat/sub-${sub}_ses-1_acq-${acq_suffix}_T2w.nii.gz" \
                            -d "$bids_file/sub-$sub/ses-2/anat/sub-${sub}_ses-2_acq-${acq_suffix}_T2w.nii.gz" \
                            -ofolder sct_syn -param step=1,type=im,algo=rigid,metric=MI,iter=100,shrink=2:step=2,type=im,algo=affine,metric=MI,iter=100,shrink=2:step=3,type=im,algo=syn,metric=MI,iter=100,shrink=2

    # Rigid + affine + syn + dl registration
    sct_register_multimodal -i "$bids_file/sub-$sub/ses-1/anat/sub-${sub}_ses-1_acq-${acq_suffix}_T2w.nii.gz" \
                            -d "$bids_file/sub-$sub/ses-2/anat/sub-${sub}_ses-2_acq-${acq_suffix}_T2w.nii.gz" \
                            -ofolder sct_dl -param step=1,type=im,algo=rigid,metric=MI,iter=100,shrink=2:step=2,type=im,algo=affine,metric=MI,iter=100,shrink=2:step=3,type=im,algo=syn,metric=MI,iter=100,shrink=2:step=4,type=im,algo=dl

    # Calculate similarity on full FOV images
    python calculate_similarity_metrics.py -ses2_file "$bids_file/sub-$sub/ses-2/anat/sub-${sub}_ses-2_acq-${acq_suffix}_T2w.nii.gz" \
                                           -ses1reg_file "$bids_file/sub-$sub/ses-2/anat/sub-${sub}_ses-1_acq-${acq_suffix}_desc-registered_T2w.nii.gz" \
                                           -acquisition T2w -method challenge -o "metrics/challenge_sub-${sub}_ses-2_acq-${acq_suffix}_T2w.csv"
    python calculate_similarity_metrics.py -ses2_file "$bids_file/sub-$sub/ses-2/anat/sub-${sub}_ses-2_acq-${acq_suffix}_T2w.nii.gz" \
                                           -ses1reg_file "sct_rigid/sub-${sub}_ses-1_acq-${acq_suffix}_T2w_reg.nii.gz" \
                                           -acquisition T2w -method sct_rigid -o "metrics/rigid_sub-${sub}_ses-2_acq-${acq_suffix}_T2w.csv"
    python calculate_similarity_metrics.py -ses2_file "$bids_file/sub-$sub/ses-2/anat/sub-${sub}_ses-2_acq-${acq_suffix}_T2w.nii.gz" \
                                           -ses1reg_file "sct_syn/sub-${sub}_ses-1_acq-${acq_suffix}_T2w_reg.nii.gz" \
                                           -acquisition T2w -method sct_syn -o "metrics/syn_sub-${sub}_ses-2_acq-${acq_suffix}_T2w.csv"
    python calculate_similarity_metrics.py -ses2_file "$bids_file/sub-$sub/ses-2/anat/sub-${sub}_ses-2_acq-${acq_suffix}_T2w.nii.gz" \
                                           -ses1reg_file "sct_dl/sub-${sub}_ses-1_acq-${acq_suffix}_T2w_reg.nii.gz" \
                                           -acquisition T2w -method sct_dl -o "metrics/dl_sub-${sub}_ses-2_acq-${acq_suffix}_T2w.csv"

    # Calculate similarity masked by the SC
    local mask_file="$bids_file/derivatives/labels/sub-$sub/ses-2/anat/sub-${sub}_ses-2_acq-${acq_suffix}_T2w_label-SC_seg.nii.gz"
    python calculate_similarity_metrics.py -ses2_file "$bids_file/sub-$sub/ses-2/anat/sub-${sub}_ses-2_acq-${acq_suffix}_T2w.nii.gz" \
                                           -ses1reg_file "$bids_file/sub-$sub/ses-2/anat/sub-${sub}_ses-1_acq-${acq_suffix}_desc-registered_T2w.nii.gz" \
                                           -acquisition T2w -method challenge -o "metrics/challenge_sub-${sub}_ses-2_acq-${acq_suffix}_T2w_masked.csv" -mask_file "$mask_file"
    python calculate_similarity_metrics.py -ses2_file "$bids_file/sub-$sub/ses-2/anat/sub-${sub}_ses-2_acq-${acq_suffix}_T2w.nii.gz" \
                                           -ses1reg_file "sct_rigid/sub-${sub}_ses-1_acq-${acq_suffix}_T2w_reg.nii.gz" \
                                           -acquisition T2w -method sct_rigid -o "metrics/rigid_sub-${sub}_ses-2_acq-${acq_suffix}_T2w_masked.csv" -mask_file "$mask_file"
    python calculate_similarity_metrics.py -ses2_file "$bids_file/sub-$sub/ses-2/anat/sub-${sub}_ses-2_acq-${acq_suffix}_T2w.nii.gz" \
                                           -ses1reg_file "sct_syn/sub-${sub}_ses-1_acq-${acq_suffix}_T2w_reg.nii.gz" \
                                           -acquisition T2w -method sct_syn -o "metrics/syn_sub-${sub}_ses-2_acq-${acq_suffix}_T2w_masked.csv" -mask_file "$mask_file"
    python calculate_similarity_metrics.py -ses2_file "$bids_file/sub-$sub/ses-2/anat/sub-${sub}_ses-2_acq-${acq_suffix}_T2w.nii.gz" \
                                           -ses1reg_file "sct_dl/sub-${sub}_ses-1_acq-${acq_suffix}_T2w_reg.nii.gz" \
                                           -acquisition T2w -method sct_dl -o "metrics/dl_sub-${sub}_ses-2_acq-${acq_suffix}_T2w_masked.csv" -mask_file "$mask_file"
}

# Subjects IDs of T2w non-fat-suppressed images
non_fat_sup_subjects=(2 3 4 5 6 8 10 12 14 18 20 23 24 26 27 30 33 37 44 45 46 48 49 55 56 60 61 63 64 66 69 71 74 75 80 83 86 90 91 93 94 95 96 101 107 108 109 111 112 113 118 122 125 129 130 131 136 138 139 141 144 145 146 149 150 152 153 154 158 159 161 163 164 169 171 174 175 176 180 181 183 185 187 188 190 196 197)

# Registration and evaluation for non-fat-suppressed images
for subject in "${non_fat_sup_subjects[@]}"; do
    register_and_evaluate $subject "ax"
done

# Subjects IDs of T2w fat-suppressed images
fat_sup_subjects=(11 13 17 21 22 25 29 31 32 34 36 39 41 42 47 50 52 53 54 57 59 62 65 67 68 70 73 77 78 79 81 82 85 88 89 92 98 100 102 103 105 106 110 115 116 117 119 121 123 124 126 127 132 133 134 135 137 140 143 147 148 151 155 156 157 160 162 165 166 167 168 170 172 173 178 179 182 184 186 191 192 193 194 195)

# Registration and evaluation for fat-suppressed images
for subject in "${fat_sup_subjects[@]}"; do
    register_and_evaluate $subject "ax-FS"
done