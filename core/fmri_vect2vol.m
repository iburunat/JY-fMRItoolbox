function vol = fmri_vect2vol(v, mask)
% FMRI_VECT2VOL  Devectorizes a 228453-element brain vector to a 91x109x91 volume.
%
% Reconstructs a full 3D (or 4D) volume array from vectorized brain data by
% placing each value back into its corresponding voxel position. The inverse
% of fmri_vol2vect.
%
% Usage:
%   vol = fmri_vect2vol(v)
%   vol = fmri_vect2vol(v, mask)
%
% Inputs:
%   V     - Vectorized brain data: (228453 x 1) for a single map, or
%           (228453 x T) for a time series. A transposed (1 x 228453) input
%           is automatically corrected.
%   MASK  - Binary brain mask (91 x 109 x 91). Optional. If omitted, the
%           standard toolbox brain mask (standard_brain_NZ.mat) is used.
%
% Outputs:
%   VOL   - Volume array: (91 x 109 x 91) for single map,
%           or (91 x 109 x 91 x T) for time series. Voxels outside the
%           brain mask are set to zero.
%
% Examples:
%   vol  = fmri_vect2vol(v);              % standard mask
%   vol4 = fmri_vect2vol(timeseries);     % 91x109x91xT
%   vol  = fmri_vect2vol(v, my_mask);     % custom mask
%
% See also: fmri_vol2vect, fmri_showslices, fmri_show3d

if size(v, 2) == 228453
    v = v';   % auto-transpose row vectors
end

if nargin == 1
    load standard_brain_NZ
    mask = A(:);
else
    mask = mask(:);
end
ind = find(mask > 0);

nic = size(v, 2);
vv  = zeros(size(mask,1), nic);
vv(ind, :) = v;
vol = reshape(vv, 91, 109, 91, nic);
end
