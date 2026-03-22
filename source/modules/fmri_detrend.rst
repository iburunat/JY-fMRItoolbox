fmri_detrend
============

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_DETREND  Removes low-frequency drift from fMRI data using spline fitting.
Fits a cubic spline to a set of equally-spaced anchor points along the
temporal dimension and subtracts it from the data. This removes slow
drifts (scanner drift, respiratory, movement artefacts) while preserving
higher-frequency BOLD signal. Operates voxelwise.

Usage
-----
.. code-block:: matlab

    newdata = fmri_detrend(data)
    newdata = fmri_detrend(data, no_of_anchor_points)

Inputs
------
- **DATA**: fMRI time series, vectorized (228453 x T) or volume (91 x 109 x 91 x T).
- **NO_OF_ANCHOR_POINTS**: Number of spline knots. More knots = more aggressive detrending. Default: 6.

Outputs
-------
- **NEWDATA**: Detrended data in the same format as DATA.

Examples
--------
.. code-block:: matlab

    data = fmri_detrend(data);          % default 6 knots
    data = fmri_detrend(data, 4);       % gentler detrending
    data = fmri_detrend(data, 10);      % more aggressive

Notes
-----
- For high-pass filtering in the frequency domain, see fmri_bandpassfilter.

See Also
--------
- fmri_tempsmooth
- fmri_bandpassfilter
- fmri_zscorevoldata

