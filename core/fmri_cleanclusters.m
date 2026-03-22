function newpmap = fmri_cleanclusters(pmap, CL_SIZE_THRES, NN_THRES, CONN)
% FMRI_CLEANCLUSTERS  Removes small and sparse clusters from a thresholded map.
%
% Applies two criteria to discard unreliable clusters from a binary brain map:
%   1. Cluster size: removes clusters smaller than CL_SIZE_THRES voxels.
%   2. Neighbour density: within surviving clusters, removes voxels with fewer
%      than NN_THRES neighbours (eliminates isolated or spikey voxels).
%
% Usage:
%   newpmap = fmri_cleanclusters(pmap, CL_SIZE_THRES, NN_THRES)
%   newpmap = fmri_cleanclusters(pmap, CL_SIZE_THRES, NN_THRES, CONN)
%
% Inputs:
%   PMAP           - Thresholded binary brain map, vectorized (228453 x 1)
%                    or volume (91 x 109 x 91).
%   CL_SIZE_THRES  - Minimum cluster size in voxels. Clusters smaller than
%                    this are removed entirely. Use fmri_csthreshold to obtain
%                    a statistically motivated value.
%   NN_THRES       - Minimum number of neighbours a voxel must have to be
%                    retained (range 0-26). Default: 0 (disabled).
%   CONN           - Connectivity criterion for spm_bwlabel cluster detection:
%                      6  = face connectivity (most conservative)
%                     18  = face + edge connectivity (default)
%                     26  = face + edge + corner connectivity (most liberal)
%                    Default: 18.
%
% Outputs:
%   NEWPMAP  - Cleaned binary map, same format as PMAP input.
%
% Examples:
%   clean = fmri_cleanclusters(thresh_map, 50, 0);
%   clean = fmri_cleanclusters(thresh_map, cs, 2);
%   clean = fmri_cleanclusters(thresh_map, 50, 0, 6);   % strict face-only
%   clean = fmri_cleanclusters(thresh_map, 50, 0, 26);  % liberal corner
%
% See also: fmri_csthreshold, fmri_csdist, fmri_regiontable, fmri_tfce

if nargin < 4 || isempty(CONN), CONN = 18; end
if ~ismember(CONN, [6 18 26])
    error('fmri_cleanclusters:badConn', 'CONN must be 6, 18, or 26.');
end

isvectorinput=0;
if ndims(pmap)<3 isvectorinput=1; end
if isvectorinput    
    pmap=fmri_vect2vol(pmap);
end

[label,num]=spm_bwlabel(pmap, CONN);
kernel = ones(3,3,3); % 3-D convolution kernel for counting number of neighbours
newpmap = zeros(91,109,91);
 h = waitbar(0,'Cleaning...');
for k=1:num
    waitbar(k/num,h)
    if sum(label(:)==k) >= CL_SIZE_THRES
        tmpmap = zeros(91,109,91);
        tmpmap(find(label==k)) = 1;
        clconv = convn(tmpmap,kernel,'same'); % result: number of neighbours+1 for each voxel
        newpmap(find(label==k & clconv>NN_THRES)) = 1;
    end
end
close(h)
if isvectorinput
    newpmap=fmri_vol2vect(newpmap);
end

