function acf_vol = fmri_acfestimate(datapath, regr, n_perm)
% FMRI_ACFESTIMATE  Estimates the mean spatial autocorrelation function (ACF).
%
% Estimates the mean ACF of pseudo-normal statistical images (pn-SI) by
% correlating phase-randomised regressors with brain data and computing the
% 3D autocorrelation of the resulting z-maps. This is the first step of the
% cluster-size correction procedure (Ledberg et al., 1998).
%
% Usage:
%   acf_vol = fmri_acfestimate(datapath, regr, n_perm)
%
% Inputs:
%   DATAPATH - Path to directory containing vectorized fMRI data (.mat files).
%              Each file should contain one variable: a (228453 x T) matrix.
%   REGR     - Regressor matrix (T x R) for R regressors of interest.
%   N_PERM   - Number of phase-randomisations per subject per regressor.
%              Default: 10. More = better ACF estimate but slower.
%
% Outputs:
%   ACF_VOL  - Cell array (1 x R), one ACF volume (228453 x 1) per regressor.
%              Each volume is the mean 3D autocorrelation across subjects and
%              permutations, to be used as convolution kernel in fmri_csdist.
%
% References:
%   Ledberg, A., Akerman, S., & Roland, P.E. (1998). Estimation of the
%   probabilities of 3D clusters in functional brain images. NeuroImage, 8, 113-128.
%   Ebisuzaki, W. (1997). J. Climate, 10(6), 2147-2153.
%
% See also: fmri_csdist, fmri_csthreshold, fmri_scramblephases, fmri_corregressor

if nargin < 3 || isempty(n_perm), n_perm = 10; end

X    = zscore(regr);
R    = size(X, 2);
dirls = dir(fullfile(datapath, '*.mat'));

% Initialise ACF accumulator per regressor
acf_vol = cell(1, R);
for r = 1:R
    acf_vol{r} = zeros(91*109*91, 1);
end

fprintf('Estimating mean ACF (%d subjects, %d regressors, %d perm each)...\n', ...
        length(dirls), R, n_perm);

for s = 1:length(dirls)
    tmp      = load(fullfile(datapath, dirls(s).name));
    fname    = fieldnames(tmp);
    voldata  = tmp.(fname{1});

    for r = 1:R
        reg = X(:, r);
        for p = 1:n_perm
            ph_reg  = fmri_scramblephases(reg);
            corr_map = fmri_corregressor(ph_reg, voldata);
            corr_map(isnan(corr_map)) = 0;
            z_vol   = fmri_vect2vol(atanh(corr_map));
            fft_vol = fftn(z_vol);
            acf_raw = real(fftshift(ifftn(abs(fft_vol))));
            acf_vol{r} = acf_vol{r} + acf_raw(:);
        end
    end
    fprintf('  Subject %d/%d done.\n', s, length(dirls));
end
