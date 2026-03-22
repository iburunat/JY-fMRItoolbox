function sub = fmri_ind2sub(ind)
% FMRI_IND2SUB  Converts linear brain indices to voxel subscripts.
%
% Converts one or more linear indices in the 228453-element vectorized brain
% space to voxel subscripts [x y z] in the 91x109x91 volume space.
%
% Usage:
%   sub = fmri_ind2sub(ind)
%
% Inputs:
%   IND  - Linear brain indices, vector of length N. Values in [1, 228453].
%
% Outputs:
%   SUB  - Subscript matrix (N x 3): [x1 y1 z1; x2 y2 z2; ...].
%          1-based MATLAB indices in the 91x109x91 volume.
%
% Examples:
%   sub  = fmri_ind2sub(114227);        % centre of the brain
%   subs = fmri_ind2sub([1000; 5000; 100000]);
%   mni  = fmri_sub2mni(fmri_ind2sub(peak_voxel));
%
% See also: fmri_sub2ind, fmri_sub2mni, fmri_regionnumber

% Load brain mask to get the linear-to-volume index mapping
load standard_brain_NZ
vol_inds = find(A(:) > 0);          % same mapping used by fmri_vect2vol
vol_idx  = vol_inds(ind(:));
[x, y, z] = ind2sub([91 109 91], vol_idx);
sub = [x y z];
