function D = fmri_voxdist(ind1, ind2)
% FMRI_VOXDIST  Euclidean distance (mm) between brain voxels.
%
% Computes the pairwise Euclidean distance in millimetres between two sets
% of voxels specified as linear brain indices (228453-space). Returns a
% distance matrix D where D(i,j) is the distance between voxel ind1(i) and
% ind2(j) in mm (at 2mm isotropic voxel size).
%
% Usage:
%   D = fmri_voxdist(ind1, ind2)
%   D = fmri_voxdist(ind1)        % pairwise distances within ind1
%
% Inputs:
%   IND1  - Linear brain indices, vector of length N. Values in [1, 228453].
%   IND2  - Linear brain indices, vector of length M. Default: IND2 = IND1.
%
% Outputs:
%   D     - Distance matrix (N x M) in millimetres. D(i,j) = distance
%           between voxel ind1(i) and ind2(j).
%           If ind2 = ind1, D is symmetric with zeros on the diagonal.
%
% Examples:
%   % Distance between two peak voxels
%   d = fmri_voxdist(peak1, peak2);
%
%   % Pairwise distances within a cluster
%   cluster_ind = find(cluster_map > 0);
%   D = fmri_voxdist(cluster_ind);
%   max_diam = max(D(:));
%
%   % Distance from seed voxel to all brain voxels
%   seed = fmri_sub2ind(fmri_mni2sub([0 -51 27]));
%   D    = fmri_voxdist(seed, 1:228453);
%   fmri_showslices(D', 1, 3, [0 100])
%
% Notes:
%   Voxel size is 2mm isotropic. Distance is in millimetres.
%   For large index sets this function can be memory-intensive;
%   consider working in chunks for whole-brain distance matrices.
%
% See also: fmri_spheremask, fmri_mni2sub, fmri_ind2sub

if nargin < 2
    ind2 = ind1;
end

sub1 = fmri_ind2sub(ind1(:));   % N x 3
sub2 = fmri_ind2sub(ind2(:));   % M x 3

% Convert subscripts to mm (2mm isotropic)
mni1 = fmri_sub2mni(sub1);     % N x 3
mni2 = fmri_sub2mni(sub2);     % M x 3

% Pairwise Euclidean distance (vectorized)
N = size(mni1, 1);
M = size(mni2, 1);

D = sqrt( ...
    bsxfun(@minus, mni1(:,1), mni2(:,1)').^2 + ...
    bsxfun(@minus, mni1(:,2), mni2(:,2)').^2 + ...
    bsxfun(@minus, mni1(:,3), mni2(:,3)').^2 );  % N x M
