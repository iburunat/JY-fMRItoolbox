fmri_acfestimate
================

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_ACFESTIMATE  Estimates the mean spatial autocorrelation function (ACF).
Estimates the mean ACF of pseudo-normal statistical images (pn-SI) by
correlating phase-randomised regressors with brain data and computing the
3D autocorrelation of the resulting z-maps. This is the first step of the
cluster-size correction procedure (Ledberg et al., 1998).

Usage
-----
.. code-block:: matlab

    acf_vol = fmri_acfestimate(datapath, regr, n_perm)

Inputs
------
- **DATAPATH**: Path to directory containing vectorized fMRI data (.mat files). Each file should contain one variable: a (228453 x T) matrix.
- **REGR**: Regressor matrix (T x R) for R regressors of interest.
- **N_PERM**: Number of phase-randomisations per subject per regressor. Default: 10. More = better ACF estimate but slower.

Outputs
-------
- **ACF_VOL**: Cell array (1 x R), one ACF volume (228453 x 1) per regressor. Each volume is the mean 3D autocorrelation across subjects and permutations, to be used as convolution kernel in fmri_csdist.

References
----------
- Ledberg, A., Akerman, S., & Roland, P.E. (1998). Estimation of the probabilities of 3D clusters in functional brain images. NeuroImage, 8, 113-128.
- Ebisuzaki, W. (1997). J. Climate, 10(6), 2147-2153.

See Also
--------
- fmri_csdist
- fmri_csthreshold
- fmri_scramblephases
- fmri_corregressor

