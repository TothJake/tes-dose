# Dose Standardization for Transcranial Electrical Stimulation: An Accessible Approach

This repository contains MATLAB functions for estimating peak E-field magnitudes ($EF_{95th}$) from Transcranial Electrical Stimulation (tES). 

![Model Overview](/images/model_overview.png)

## Overview
Individual anatomical differences significantly impact the intensity of electrical current reaching the brain. `conv_predict_ef` and `hd_predict_ef` provide an accessible way to standardize dosage by accounting for participant-specific metrics (sex, age, head circumference, cephalic index, and BMI) without requiring individual MRI scans or complex finite element method (FEM) modeling.

---

## Included Functions

### 1. Conventional tES (`conv_predict_ef`)
Predicts the 95th percentile E-field magnitude for standard two-electrode montages.
* **Supported Montages:** `F4Cz`, `C3FP2`, `F3F4`, `FPzOz`, `C3C4`, `P3FP2`.
* **Agnostic Mode:** Use `[]` as the montage input to use a montage-agnostic model (requires inter-electrode distance).

### 2. High-Definition tES (`hd_predict_ef`)
Predicts the 95th percentile E-field magnitude for High-Definition (HD) configurations (e.g., 4x1 ring).
* **Supported Montages:** Anodes at `F4`, `C3`, `P3`, or `PO8`.
* **Agnostic Mode:** Use `[]` as the montage input for a montage-agnostic HD model (requires inter-electrode distance).

![Montages](/images/montages.png)

---

## Usage

Add the functions to your MATLAB path and call them using the following syntax:

### Basic Example (Conventional)
```matlab
% Predict EF for a specific montage (FPz-Oz) for a 45-year-old male
EF = conv_predict_ef('FPzOz', 'M', 45, 565, 85, 25);
```

### ⚠️ Disclaimer
These models provide population-based approximations and may not accurately reflect individual E-fields. The user is solely responsible for determining and setting safe stimulation parameters. The authors and contributors assume no liability for any injuries, damages, or claims arising from the use of this software.


### Keywords
`tDCS` `tACS` `tRNS` `tES` `E-field` `Dose Standardization` `Neuromodulation` `neurotechnology` 

