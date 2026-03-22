fmri_csdist
===========

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_CSDIST  Generates cluster-size (CS) distributions via ACF convolution.
Generates the null distribution of cluster sizes at one or more statistical
thresholds by convolving the estimated ACF kernel with Gaussian noise and
recording the resulting cluster sizes. This is the second step of the
Ledberg et al. (1998) cluster-size correction procedure.

Usage
-----
.. code-block:: matlab

    D = fmri_csdist(acf_vol, si_alpha, n_perm)

Inputs
------
- **ACF_VOL**: Cell array {1 x R} of ACF volumes, one per regressor, as returned by fmri_acfestimate. Each cell contains a (902629 x 1) vector (full 91x109x91 volume).
- **SI_ALPHA**: Statistical threshold(s) as alpha levels (two-tailed). Default: [0.01 0.001 0.0001]
- **N_PERM**: Number of random images to generate. Default: 100. More = smoother distribution but slower.

Outputs
-------
- **D**: Cluster-size distribution as a cell array {1 x R}. D{r} is a (500 x length(SI_ALPHA)) matrix: each entry is the empirical probability that a cluster of size >= k voxels occurs at the corresponding threshold under the null.

References
----------
- Ledberg, A., Akerman, S., & Roland, P.E. (1998). NeuroImage, 8, 113-128.

See Also
--------
- fmri_acfestimate
- fmri_csthreshold
- fmri_cleanclusters

