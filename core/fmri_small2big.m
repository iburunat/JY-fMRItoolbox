function dl = fmri_small2big(ds)
% FMRI_SMALL2BIG  Embeds a 79x95x68 volume into the 91x109x91 MNI grid.
%
% Pads the smaller SPM5/FSL bounding-box volume back into the full
% 91x109x91 MNI152 2mm grid by adding appropriate zero margins. Inverse
% of fmri_big2small.
%
% Usage:
%   ds = fmri_small2big(dl)
%
% Inputs:
%   DL  - Volume data (79 x 95 x 68) or (79 x 95 x 68 x T).
%
% Outputs:
%   DS  - Full-grid volume (91 x 109 x 91) or (91 x 109 x 91 x T).
%         Voxels outside the crop region are zero.
%
% Examples:
%   full = fmri_small2big(small_vol);
%
% See also: fmri_big2small, fmri_small2big_craddock

sl=[91 109 91]; % size of large template
ol=[46 64 37];%[45 63 36] in FSL but zero-indexed 
vl=5; % voxel size of large template (here arbitrary)

ss=[79 95 68]; % size of small template 
os=[40 57 26]; % origin of small template
vs=5; % voxel size of small template (here arbitrary)

dl = zeros(91,109,91,size(ds,4));
dl(7:85,8:102,12:79,:)=ds;  
