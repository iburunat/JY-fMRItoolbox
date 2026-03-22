fmri_bandpassfilter
===================

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_BANDPASSFILTER  Non-causal FFT-based bandpass filter for fMRI time series.
Applies a sharp (brick-wall) bandpass filter in the frequency domain by
zeroing all FFT coefficients outside the specified frequency band. Because
the filter is applied in the frequency domain and the result is the real
part of the inverse FFT, it is non-causal (zero phase shift) and has no
edge effects due to filter order. Suitable for resting-state fMRI (e.g.
0.01-0.1 Hz bandpass) and task-based filtering.

Usage
-----
.. code-block:: matlab

    data_filt = fmri_bandpassfilter(data, fs, f_low, f_high)

Inputs
------
- **DATA**: Time series to filter. Each column is filtered independently. Accepts vectorized fMRI (T x 228453) or a single time series (T x 1).
- **FS**: Sampling frequency in Hz (= 1 / TR). E.g., for TR=2s: fs=0.5
- **F_LOW**: Low-frequency cutoff in Hz (pass above this). E.g. 0.01
- **F_HIGH**: High-frequency cutoff in Hz (pass below this). E.g. 0.10

Outputs
-------
- **DATA_FILT**: Filtered data, same size as DATA

Examples
--------
.. code-block:: matlab

    % Resting-state bandpass (TR = 2s)
    data_filt = fmri_bandpassfilter(data, 0.5, 0.01, 0.10);
    % High-pass only (remove drift below 0.008 Hz, TR = 1.5s)
    data_filt = fmri_bandpassfilter(data, 1/1.5, 0.008, Inf);

Notes
-----
- - The filter is applied column-wise, so T must be the first dimension.
- - Setting f_low = 0 results in low-pass filtering only.
- - Setting f_high = Inf results in high-pass filtering only.

See Also
--------
- fmri_detrend
- fmri_tempsmooth
- fmri_correctmovement

