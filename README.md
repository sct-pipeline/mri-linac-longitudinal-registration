# Stability of cervical spinal cord positioning across MRI-LINAC sessions

This project investigates the stability of spinal cord positioning on Fixed-Position MRI-LINAC

## Main Dependencies
- [SCT 6.3](https://github.com/spinalcordtoolbox/spinalcordtoolbox/releases/tag/6.3)
- Python 3.9

## Data: 
```
git@data.neuro.polymtl.ca:datasets/head-neck-tumor-challenge-2024
```
From: [Head and Neck Tumor Segmentation for MR-Guided Applications Challenge](https://zenodo.org/records/11199559)

## Installation:
Clone this repository and hop inside:
```
git clone https://github.com/sct-pipeline/mri-linac-longitudinal-registration.git
cd mri-linac-longitudinal-registration
pip install -r requirements.txt
```

## Registration and evaluate similarity metrics:
```
cd scripts
./intersession_registration.sh 
```

## Evaluate similarity metrics on one subject

``` 
python scripts/calculate_similarity_metrics.py -ses2_file Fixed.nii.gz  -ses1reg_file Registered.nii.gz  -acquisition T2w -method SCT_rigid -mask_file Fixed_sc.nii.gz  -o metrics_registration_T2w.csv
```

## Citation
Wahid, K., Dede, C., Naser, M., & Fuller, C. (2024). Training Dataset for HNTSMRG 2024 Challenge [Data set]. Zenodo. https://doi.org/10.5281/zenodo.11199559