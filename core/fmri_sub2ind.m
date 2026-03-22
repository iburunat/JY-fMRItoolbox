function ind = fmri_sub2ind(sub)
% FMRI_SUB2IND  Converts voxel subscripts to linear brain indices.
%
% Converts one or more voxel subscripts [x y z] in the 91x109x91 volume
% space to linear indices in the 228453-element vectorized brain space.
%
% Usage:
%   ind = fmri_sub2ind(sub)
%
% Inputs:
%   SUB  - Subscript matrix (N x 3): [x1 y1 z1; x2 y2 z2; ...].
%          1-based MATLAB indices in the 91x109x91 volume.
%
% Outputs:
%   IND  - Linear brain indices (N x 1). Values in [1, 228453].
%          Returns NaN for subscripts outside the brain mask.
%
% Examples:
%   ind  = fmri_sub2ind([46 64 37]);        % centre of the brain
%   inds = fmri_sub2ind([46 64 37; 30 50 45]);
%
% See also: fmri_ind2sub, fmri_mni2sub, fmri_spheremask

load standard_brain_NZ
vol_inds = find(A(:) > 0);   % 228453 x 1: vol_inds(k) = volume index of brain voxel k

% Convert subscripts to volume indices
vol_idx = sub2ind([91 109 91], sub(:,1), sub(:,2), sub(:,3));

% Find position of each volume index in the brain mask
[found, ind] = ismember(vol_idx, vol_inds);
ind(~found) = NaN;   % outside brain mask