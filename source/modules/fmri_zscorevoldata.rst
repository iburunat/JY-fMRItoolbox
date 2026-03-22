fmri_zscorevoldata
==================

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_ZSCOREVOLDATA  Voxelwise z-scoring of fMRI time series.
Standardises each voxel time series to zero mean and unit variance
(z-score), operating independently at each voxel. Equivalent to MATLAB's
zscore(d, 0, 2) but adapted for the toolbox data format.

Usage
-----
.. code-block:: matlab

    c = fmri_zscorevoldata(d)

Inputs
------
- **D**: fMRI time series, vectorized (228453 x T). Each row is a voxel.

Outputs
-------
- **C**: Z-scored data (228453 x T). Each row has mean=0 and std=1. Constant voxels (zero variance) are set to zero.

Examples
--------
.. code-block:: matlab

    data_z = fmri_zscorevoldata(data);

Notes
-----
- Typically applied after fmri_detrend and before correlation analyses
- to remove voxel-level amplitude differences.

See Also
--------
- fmri_detrend
- fmri_corregressor

