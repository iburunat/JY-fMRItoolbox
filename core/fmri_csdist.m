function D = fmri_csdist(acf_vol, si_alpha, n_perm)
% FMRI_CSDIST  Generates cluster-size (CS) distributions via ACF convolution.
%
% Generates the null distribution of cluster sizes at one or more statistical
% thresholds by convolving the estimated ACF kernel with Gaussian noise and
% recording the resulting cluster sizes. This is the second step of the
% Ledberg et al. (1998) cluster-size correction procedure.
%
% Usage:
%   D = fmri_csdist(acf_vol, si_alpha, n_perm)
%
% Inputs:
%   ACF_VOL   - Cell array {1 x R} of ACF volumes, one per regressor, as returned
%               by fmri_acfestimate. Each cell contains a (902629 x 1) vector
%               (full 91x109x91 volume).
%   SI_ALPHA  - Statistical threshold(s) as alpha levels (two-tailed).
%               Default: [0.01 0.001 0.0001]
%   N_PERM    - Number of random images to generate. Default: 100.
%               More = smoother distribution but slower.
%
% Outputs:
%   D         - Cluster-size distribution as a cell array {1 x R}.
%               D{r} is a (500 x length(SI_ALPHA)) matrix: each entry is the
%               empirical probability that a cluster of size >= k voxels occurs
%               at the corresponding threshold under the null.
%
% References:
%   Ledberg, A., Akerman, S., & Roland, P.E. (1998). NeuroImage, 8, 113-128.
%
% See also: fmri_acfestimate, fmri_csthreshold, fmri_cleanclusters

if nargin < 3 || isempty(n_perm),   n_perm   = 100;                  end
if nargin < 2 || isempty(si_alpha), si_alpha = [0.01 0.001 0.0001];  end

load standard_brain
Z = -norminv(si_alpha);   % z-thresholds (two-tailed)

% Wrap single volume in cell for uniform processing
if ~iscell(acf_vol), acf_vol = {acf_vol}; end
R = numel(acf_vol);

D = cell(1, R);

for r = 1:R
    kernel = reshape(acf_vol{r}, 91, 109, 91);
    DIST   = zeros(500, length(Z));

    h = waitbar(0, sprintf('CS distribution: regressor %d/%d', r, R));
    for p = 1:n_perm
        waitbar(p/n_perm, h);

        % Convolve noise with ACF kernel, z-score within brain mask
        noise  = randn(91, 109, 91);
        C      = kernel(41:51, 50:60, 41:51);          % central ACF kernel
        CU     = convn(noise, C, 'same');
        CUz    = zscore(fmri_vol2vect(CU));
        CUvol  = fmri_vect2vol(CUz);

        % threshold the map
        for zi = 1:length(Z)
            brain_thresh = (abs(CUvol) > Z(zi)) .* br;
            [L, NUM]     = spm_bwlabel(brain_thresh, 18);
            c = arrayfun(@(n) sum(L(:)==n), 1:NUM);

            for cs = 1:500
                DIST(cs, zi) = DIST(cs, zi) + any(c > cs);
            end
        end
    end
    close(h);
    D{r} = DIST / n_perm;   % convert counts to probabilities
end
