function fs = fmri_scramblephases(f)
% FMRI_SCRAMBLEPHASES  Phase-scrambles a 3D brain volume or time series.
%
% Randomises the phase spectrum of the input while preserving the amplitude
% spectrum exactly. The result is a surrogate with the same spatial or
% temporal autocorrelation structure as the original but with shuffled
% phase relationships — i.e. same power spectrum, destroyed signal.
%
% Used for generating null distributions in permutation tests: by correlating
% phase-randomised regressors with brain data you obtain pseudo-normal
% statistical images with the same autocorrelation as the true SI, which is
% the basis of the cluster-size correction in fmri_csize.
%
% Usage:
%   fs = fmri_scramblephases(f)
%
% Inputs:
%   F   - Input array (any dimension: 1D time series, 2D, or 3D volume).
%         For fMRI time series: pass a (T x 1) vector to scramble temporal phases.
%         For a 3D volume: pass a (91 x 109 x 91) array to scramble spatial phases.
%
% Outputs:
%   FS  - Phase-scrambled array of the same size and class as F.
%         The output is real-valued (imaginary residuals from IFFT are discarded).
%
% Examples:
%   % Scramble temporal phases of a regressor
%   regr_null = fmri_scramblephases(regressor);
%
%   % Scramble spatial phases of a statistical volume
%   vol_null = fmri_scramblephases(stat_volume);
%
%   % Generate null correlations for permutation test
%   r_null = fmri_corregressor(fmri_scramblephases(regressor), data);
%
% References:
%   Ebisuzaki, W. (1997). A method to estimate the statistical significance
%   of a correlation when the data are serially correlated. Journal of
%   Climate, 10(6), 2147-2153.
%
% See also: fmri_csize, fmri_corregressor, fmri_tfce

fs = real(ifftn( abs(fftn(f)) .* exp(1i * angle(fftn(rand(size(f))))) ));
