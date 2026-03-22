function regionnumber = fmri_banumber(coords)
% FMRI_BANUMBER  Shortcut for quick Brodmann lookups.
%
% Looks up the Brodmann area label for each voxel location using the
% toolbox Brodmann atlas (BRODMANNlookup.mat). Returns 0 for voxels outside
% any labelled Brodmann area. It is equivalent to:
%
%   fmri_regionnumber(coords, 19)
%
% Usage:
%   regionnumber = fmri_banumber(coords)
%
% Inputs:
%   COORDS  - Voxel subscripts (N x 3): [x1 y1 z1; x2 y2 z2; ...].
%             1-based MNI152 2mm grid, x in [1 91], y in [1 109], z in [1 91].
%
% Outputs:
%   REGIONNUMBER - Brodmann area numbers (N x 1). 0 = no Brodmann label.
%
% Examples:
%   ba = fmri_banumber([56 34 27]);          
%   ba = fmri_banumber([56 34 27; 65 30 50]);
%
%   % Equivalent explicit call
%   ba2 = fmri_regionnumber([56 34 27], 19);
%
% See also: fmri_regionnumber, fmri_regionmask, fmri_roin

load BRODMANNlookup
brodmann_vect=brodmann_nos(:);
for n=1:size(coords,1)
    index = sub2ind([91 109 91],coords(n,1),coords(n,2),coords(n,3));
    regionnumber(n)=brodmann_vect(index);
end

