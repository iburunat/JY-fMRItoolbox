function masked_data = fmri_maskdata(data, mask)
% FMRI_MASKDATA  Applies a binary ROI mask to volume data.
%
% Retains voxels where MASK is non-zero and sets all other voxels to zero.
% Both inputs are accepted as either a 91x109x91 volume or a 228453x1
% vector; the output matches the format of VOL_DATA.
%
% Usage:
%   masked_data = fmri_maskdata(data, mask)
%
% Inputs:
%   DATA      - Brain data: volume (91x109x91) or vector (228453x1).
%   MASK      - Binary mask: volume (91x109x91) or vector (228453x1).
%               Typically produced by fmri_regionmask or fmri_spheremask.
%
% Outputs:
%   MASKED_DATA - Vector (228453x1) with out-of-mask voxels set to zero.
%
% Examples:
%   % Mask data to left and right hippocampus (AAL atlas regions 37-38)
%   mask = fmri_regionmask(1, [37 38]);
%   masked_data = fmri_maskdata(data, mask);
%
%   % Mask data to a 10mm sphere around a peak voxel
%   mask = fmri_spheremask(peak_mni, 10);
%   masked_data = fmri_maskdata(r_map, mask);
%
% See also: fmri_regionmask, fmri_spheremask, fmri_vol2vect, fmri_vect2vol
if ndims(data) == 3, data = fmri_vol2vect(data); end
if ndims(mask) == 3, mask = fmri_vol2vect(mask);  end
if size(data, 2) > 1, error('fmri_maskdata: DATA must be a single volume (228453x1), not a time series.'); end

masked_data = data & mask;
