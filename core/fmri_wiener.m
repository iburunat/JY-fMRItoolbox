function neural = fmri_wiener(bold, hrf, noise_level)
% FMRI_WIENER  Wiener deconvolution: estimate neural signal from BOLD response.
%
% Estimates the underlying neural activity time series from an observed BOLD
% signal using Wiener deconvolution. The method works in the frequency domain:
% it divides the BOLD spectrum by the HRF spectrum while applying a regulariser
% (the noise term) to suppress amplification of noise at frequencies where the
% HRF has low power.
%
% Usage:
%   neural = fmri_wiener(bold, hrf, noise_level)
%
% Inputs:
%   BOLD        - Observed BOLD time series (N x 1). Will be mean-centred.
%   HRF         - Haemodynamic response function sampled at the same rate as
%                 BOLD (M x 1). Does not need to be the same length as BOLD;
%                 it will be zero-padded to match. A canonical HRF can be
%                 generated with fmri_doublegamma.
%   NOISE_LEVEL - Regularisation strength: noise power relative to BOLD
%                 amplitude. Typical range: 0.05 to 0.20. Default: 0.1
%
% Outputs:
%   NEURAL - Estimated neural time series (N x 1), same length as BOLD.
%
% Examples:
%   % Generate canonical HRF at TR = 2s
%   t   = 0:2:32;
%   hrf = fmri_doublegamma(t);
%
%   % Deconvolve BOLD signal from one voxel
%   bold_ts = data(voxel_idx, :)';
%   neural  = fmri_wiener(bold_ts, hrf', 0.1);
%
% Notes:
%   Results are sensitive to the noise_level parameter. Too low: noisy output.
%   Too high: over-smoothed, response is blurred. Values of 0.05-0.20 are
%   typically reasonable for standard fMRI data.
%
% References:
%   Wiener, N. (1949). Extrapolation, Interpolation, and Smoothing of
%   Stationary Time Series. MIT Press.
%
% See also: fmri_doublegamma, fmri_corregressor, fmri_detrend

if nargin < 3 || isempty(noise_level), noise_level = 0.1; end

bold = bold(:) - mean(bold(:));   % mean-centre BOLD signal
N    = length(bold);

H = fft(hrf(:), N);               % HRF spectrum (zero-padded to N if needed)
B = fft(bold,   N);               % BOLD spectrum

% Noise power estimate: noise_level * mean amplitude of BOLD spectrum
noise_pwr = noise_level * mean(abs(B)) * ones(N, 1);

% Wiener filter: conj(H) * |S|^2 / (|H|^2 * |S|^2 + |N|^2)
S = B;
D = conj(H) .* abs(S).^2 ./ (abs(H).^2 .* abs(S).^2 + abs(noise_pwr).^2);

neural = real(ifft(D .* B));
neural = neural(1:N);   % truncate to original length
