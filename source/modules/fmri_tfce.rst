fmri_tfce
=========

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_TFCE  Threshold-free cluster enhancement (TFCE) of a statistical map.
Computes the TFCE score for each voxel in a statistical map. TFCE
integrates cluster extent and peak height across all possible thresholds,
avoiding the need to choose a fixed cluster-forming threshold. Higher TFCE
scores reflect voxels that are both part of large clusters and have high
signal intensity.
The TFCE statistic is defined as:
TFCE(v) = integral[ e(h)^E * h^H dh ]
where e(h) is the cluster extent at threshold h, E weights cluster extent
(default 0.5), and H weights peak height (default 2).

Usage
-----
.. code-block:: matlab

    tfce = fmri_tfce(data)
    tfce = fmri_tfce(data, E, H, N)

Inputs
------
- **DATA**: Statistical map, vectorized (228453 x 1). Must be non-negative; run separately for positive and negative tails if needed.
- **E**: Extent exponent. Default: 0.5 (Smith & Nichols recommendation).
- **H**: Height exponent. Default: 2   (Smith & Nichols recommendation).
- **N**: Number of threshold bins for numerical integration. Default: 50. More bins = more accurate but slower.

Outputs
-------
- **TFCE**: TFCE map, vectorized (228453 x 1)

Examples
--------
.. code-block:: matlab

    % Positive tail
    tfce_pos = fmri_tfce(max(zmap, 0));
    % Negative tail
    tfce_neg = fmri_tfce(max(-zmap, 0));
    % Visualize
    fmri_showslices(tfce_pos, 1, 2, [0 max(tfce_pos)])

References
----------
- Smith, S.M. & Nichols, T.E. (2009). Threshold-free cluster enhancement: addressing problems of smoothing, threshold dependence and localisation in cluster inference. NeuroImage, 44(1), 83-98.

See Also
--------
- fmri_cleanclusters
- fmri_csize
- fmri_bin

