fmri_r2p
========

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_R2P  Converts Pearson correlation coefficient(s) to p-values.
Transforms a correlation coefficient r to a p-value using the Fisher
z-transformation followed by normal-distribution inference. Supports
one-tailed and two-tailed tests, and handles both scalar and map inputs.

Usage
-----
.. code-block:: matlab

    [p_pos, p_neg] = fmri_r2p(r, df)
    [p_pos, p_neg] = fmri_r2p(r, df, tail)

Inputs
------
- **R**: Correlation coefficient(s). Scalar, vector, or brain map (228453 x 1). Values should be in [-1, 1].
- **DF**: Degrees of freedom. Use fmri_effdf for autocorrelated data; otherwise df = N - 2 where N is the number of time points.
- **TAIL**: Test direction: 2  = two-tailed (default) 1  = one-tailed, positive (r > 0) -1  = one-tailed, negative (r < 0)

Outputs
-------
- **P_POS**: P-values for positive correlations (r > 0 is the signal). Empty [] when tail = -1.
- **P_NEG**: P-values for negative correlations (r < 0 is the signal). Empty [] when tail = 1.

Examples
--------
.. code-block:: matlab

    % Whole-brain significance map (two-tailed)
    r_map = fmri_corregressor(regressor, data);
    df    = size(data, 2) - 2;
    [p_pos, p_neg] = fmri_r2p(r_map, df);
    % Single correlation with autocorrelation-corrected df (positive)
    df = fmri_effdf(ts1, ts2);
    r  = corr(ts1, ts2);
    p  = fmri_r2p(r, df, 1);
    % One-tailed test for negative correlations
    [~, p_neg] = fmri_r2p(r_map, df, -1);
    % Threshold map at p < 0.001 (positive correlations)
    sig_map = p_pos < 0.001;
    fmri_showslices(sig_map, 1, 2)

See Also
--------
- fmri_effdf
- fmri_corregressor
- fmri_cleanclusters
- fmri_tfce

