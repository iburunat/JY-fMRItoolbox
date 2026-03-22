function tfce = fmri_tfce(data, E, H, N)
% FMRI_TFCE  Threshold-free cluster enhancement (TFCE) of a statistical map.
%
% Computes the TFCE score for each voxel in a statistical map. TFCE
% integrates cluster extent and peak height across all possible thresholds,
% avoiding the need to choose a fixed cluster-forming threshold. Higher TFCE
% scores reflect voxels that are both part of large clusters and have high
% signal intensity.
%
% The TFCE statistic is defined as:
%
%   TFCE(v) = integral[ e(h)^E * h^H dh ]
%
% where e(h) is the cluster extent at threshold h, E weights cluster extent
% (default 0.5), and H weights peak height (default 2).
%
% Usage:
%   tfce = fmri_tfce(data)
%   tfce = fmri_tfce(data, E, H, N)
%
% Inputs:
%   DATA  - Statistical map, vectorized (228453 x 1). Must be non-negative;
%           run separately for positive and negative tails if needed.
%   E     - Extent exponent. Default: 0.5 (Smith & Nichols recommendation).
%   H     - Height exponent. Default: 2   (Smith & Nichols recommendation).
%   N     - Number of threshold bins for numerical integration. Default: 
%           50. More bins = more accurate but slower.
%
% Outputs:
%   TFCE  - TFCE map, vectorized (228453 x 1)
%
% Examples:
%   % Positive tail
%   tfce_pos = fmri_tfce(max(zmap, 0));
%   % Negative tail
%   tfce_neg = fmri_tfce(max(-zmap, 0));
%   % Visualize
%   fmri_showslices(tfce_pos, 1, 2, [0 max(tfce_pos)])
%
% References:
%   Smith, S.M. & Nichols, T.E. (2009). Threshold-free cluster enhancement:
%   addressing problems of smoothing, threshold dependence and localisation
%   in cluster inference. NeuroImage, 44(1), 83-98.
%
% See also: fmri_cleanclusters, fmri_csize, fmri_bin

if nargin < 4 || isempty(N), N = 50;  end
if nargin < 3 || isempty(H), H = 2;   end
if nargin < 2 || isempty(E), E = 0.5; end

if size(data, 2) > 1
    error('fmri_tfce:badInput', 'DATA must be a column vector (228453 x 1).');
end

% --- build threshold bins ---------------------------------------------
hmin  = 0;
hmax  = max(data);
if hmax == 0
    tfce = zeros(size(data));
    return
end
hlim  = linspace(hmin, hmax, N + 1);
dh    = hlim(2) - hlim(1);
h     = hlim(2:end) - dh/2;   % bin centres (1 x N)

% --- bin the statistical map ------------------------------------------
zz = fmri_bin(data, hmin, hmax, N);   % 228453 x N binary matrix

% --- compute cluster extent e(h) for each threshold bin ---------------
e = zeros(228453, N);
for k = 1:N
    zvol = fmri_vect2vol(zz(:, k));
    [label, num] = spm_bwlabel(zvol, 18);
    if num > 0
        labelvect = fmri_vol2vect(label);
        sizes             = accumarray(labelvect(labelvect>0), 1);
        nz                = labelvect > 0;
        e(nz, k)          = sizes(labelvect(nz));
    end
end

% --- TFCE integration: sum over bins ----------------------------------
tfce = (e .^ E) * (h .^ H)' * dh;   % 228453 x 1
