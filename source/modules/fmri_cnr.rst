fmri_cnr
========

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_CNR  Temporal contrast-to-noise ratio (tCNR) for fMRI data.
Calculates the functional CNR per unit time (fCNR), defined as the ratio
of the mean absolute scan-to-scan signal change (delta-S) to the temporal
standard deviation of the signal per voxel:
fCNR = mean|delta-St| / sigma_t

Usage
-----
.. code-block:: matlab

    CNR = fmri_cnr(v)

Inputs
------
- **V**: fMRI data, vectorized (228453 x T) or volume (91 x 109 x 91 x T)

Outputs
-------
- **CNR**: Voxelwise tCNR map, vectorized (228453 x 1). Voxels with zero temporal variance (e.g. outside the brain mask) are set to 0.

Examples
--------
.. code-block:: matlab

    CNR = fmri_cnr(data);
    fmri_showslices(CNR, 1, 2, [0 5])

References
----------
- Welvaert, M. & Rosseel, Y. (2013). On the definition of signal-to-noise ratio and contrast-to-noise ratio for fMRI data. PLoS ONE, 8(11).

See Also
--------
- fmri_snri
- fmri_snrt

