function out = fmri_simget(X_compressed, svd_info, p, as_vector)
% FMRI_SIMGET  Extracts one participant's fMRI data from fmri_simdata output.
%
% Reconstructs the 4D fMRI volume (or 228453 x T brain vector) for a single
% participant from the SVD-compressed output of fmri_simdata.
%
% Usage:
%   X4D  = fmri_simget(X_compressed, svd_info, p)
%   data = fmri_simget(X_compressed, svd_info, p, 1)
%
% Inputs:
%   X_COMPRESSED - Cell array {1 x N} of compressed participant data,
%                  as returned by fmri_simdata.
%   SVD_INFO     - Struct array (1 x N) with SVD bases and volume dimensions,
%                  as returned by fmri_simdata.
%   P            - Participant index (integer in [1, N]).
%   AS_VECTOR    - If 1 (default), return vectorized data (228453 x T) directly.
%                  If 0, return 4D volume (91 x 109 x 91 x T).
%
% Outputs:
%   OUT  - Reconstructed fMRI data: 4D volume (91 x 109 x 91 x T) by default,
%          or vectorized brain data (228453 x T) if AS_VECTOR = 1.
%
% Examples:
%   % Extract participant 2 as 4D volume
%   X4D  = fmri_simget(X_comp, svd_info, 2);
%
%   % Extract directly as brain vector for analysis
%   data = fmri_simget(X_comp, svd_info, 1, 1);   % 228453 x T
%   r    = fmri_corregressor(regressor, data);
%
% See also: fmri_simdata, fmri_vol2vect, fmri_vect2vol

if nargin < 4 || isempty(as_vector), as_vector = 1; end

if p < 1 || p > numel(X_compressed)
    error('fmri_simget: participant index %d out of range [1 %d].', p, numel(X_compressed));
end

% reconstruct 2D (voxels x T) from compressed SVD
svd_p = X_compressed{p};
X2D   = svd_p.U * svd_p.S * svd_p.V';   % (xdim*ydim*zdim) x T

% reshape to 4D volume
xdim = svd_info(p).xdim;
ydim = svd_info(p).ydim;
zdim = svd_info(p).zdim;
X4D  = reshape(X2D, xdim, ydim, zdim, size(X2D,2));

if as_vector
    out = fmri_vol2vect(X4D);   % 228453 x T
else
    out = X4D;
end
end
