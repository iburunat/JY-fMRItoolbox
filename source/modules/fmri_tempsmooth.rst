fmri_tempsmooth
===============

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_TEMPSMOOTH  Temporal Gaussian smoothing of fMRI time series.
Convolves each voxel time series with a Gaussian kernel, suppressing
high-frequency noise while preserving low-frequency BOLD signal. Useful
as a preprocessing step before GLM analyses with slow HRFs.

Usage
-----
.. code-block:: matlab

    newdata = fmri_tempsmooth(data)
    newdata = fmri_tempsmooth(data, sigma)

Inputs
------
- **DATA**: fMRI time series, vectorized (228453 x T) or volume (91 x 109 x 91 x T).
- **SIGMA**: Standard deviation of the Gaussian kernel in scans (not seconds). Default: 5 scans. For TR-specific smoothing: sigma = FWHM/(2.355*TR).

Outputs
-------
- **NEWDATA**: Temporally smoothed data, same format as DATA.

Examples
--------
.. code-block:: matlab

    data = fmri_tempsmooth(data);        % default sigma=5
    data = fmri_tempsmooth(data, 3);     % lighter smoothing

Notes
-----
- For frequency-domain bandpass filtering use fmri_bandpassfilter instead.
- The kernel is zero-padded at the edges (boundary effects possible for
- first and last ~sigma scans).

See Also
--------
- fmri_bandpassfilter
- fmri_detrend

