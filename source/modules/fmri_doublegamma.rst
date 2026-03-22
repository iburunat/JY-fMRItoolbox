fmri_doublegamma
================

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_DOUBLEGAMMA  Canonical double-gamma haemodynamic response function.
Computes the double-gamma HRF at time points T. The function is the
difference of two gamma functions, modelling the initial positive BOLD
peak followed by the post-stimulus undershoot:
h(t) = (t/t1)^d1 * exp(-d1*(t-t1)/t1) - c*(t/t2)^d2 * exp(-d2*(t-t2)/t2)
where t1 = 0.9*d1 and t2 = 0.9*d2.

Usage
-----
.. code-block:: matlab

    g = fmri_doublegamma(t)
    g = fmri_doublegamma(t, d1, d2, c)

Inputs
------
- **T**: Time vector in seconds (e.g. 0:TR:30). Row or column vector.
- **D1**: Delay of response peak in seconds. Default: 6
- **D2**: Delay of undershoot peak in seconds. Default: 12
- **C**: Undershoot-to-peak ratio. Default: 0.35

Outputs
-------
- **G**: HRF values at each time point in T (same size as T).

Examples
--------
.. code-block:: matlab

    t   = 0:0.5:30;
    hrf = fmri_doublegamma(t);
    plot(t, hrf)
    % At TR = 2s
    hrf_tr2 = fmri_doublegamma(0:2:30);

See Also
--------
- fmri_corregressor
- fmri_wiener

