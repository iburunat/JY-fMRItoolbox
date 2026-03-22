function fmri2 = fmri_downsample(fmri, factor)
% FMRI_DOWNSAMPLE  Spatially downsamples vectorized fMRI data by integer factor.
%
% Retains every Nth voxel along each spatial dimension (x, y, z), reducing
% data size for computationally expensive operations. The output is a
% sub-sampled vectorized brain (fewer voxels x T). Inverse: fmri_upsample.
%
% Usage:
%   fmri2 = fmri_downsample(fmri)
%   fmri2 = fmri_downsample(fmri, factor)
%
% Inputs:
%   FMRI    - Vectorized fMRI data (228453 x T).
%   FACTOR  - Downsampling factor (integer). Every FACTOR-th voxel is kept
%             in each dimension. Default: 2 (keeps 1/8 of voxels).
%
% Outputs:
%   FMRI2   - Downsampled vectorized data. Number of rows depends on FACTOR:
%             factor=2: ~28542 voxels, factor=3: ~8468, etc.
%
% Examples:
%   small = fmri_downsample(data);         % factor 2
%   small = fmri_downsample(data, 3);      % factor 3
%   orig  = fmri_upsample(small);          % restore full resolution
%
% See also: fmri_upsample

if nargin==1 factor=2; end

mask=zeros(91,109,91);
mask(1:factor:end,1:factor:end,1:factor:end)=1; 
maskv=fmri_vol2vect(mask);
fmri2=fmri(find(maskv),:);
