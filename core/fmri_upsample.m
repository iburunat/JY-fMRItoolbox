function fmri2 = fmri_upsample(fmri, method)
% FMRI_UPSAMPLE  Restores spatially downsampled fMRI data to full resolution.
%
% Interpolates a downsampled brain dataset (from fmri_downsample) back to
% the full 228453-voxel vectorized space using the specified interpolation
% method. The downsampling factor is inferred automatically from the number
% of rows.
%
% Usage:
%   fmri2 = fmri_upsample(fmri)
%   fmri2 = fmri_upsample(fmri, method)
%
% Inputs:
%   FMRI    - Downsampled vectorized data (M x T), where M is the number
%             of voxels after downsampling (M < 228453).
%   METHOD  - Interpolation method string: 'linear', 'nearest', 'cubic',
%             'spline'. Default: 'linear'.
%
% Outputs:
%   FMRI2   - Upsampled data (228453 x T) at full brain resolution.
%
% Examples:
%   small = fmri_downsample(data, 2);
%   full  = fmri_upsample(small);
%   full  = fmri_upsample(small, 'spline');
%
% Notes:
%   Supported input sizes (factor: voxel count): 2: 28542, 3: 8468, 4: 3574,
%   5: 1820, 6: 1065, 7: 674, 8: 449, 9: 312, 10: 223.
%
% See also: fmri_downsample

if size(fmri,1)==28542  
    factor=2;
elseif size(fmri,1)==8468  
    factor=3;
elseif size(fmri,1)==3574 
    factor=4;
elseif size(fmri,1)==1820 
    factor=5;
elseif size(fmri,1)==1065 
    factor=6;
elseif size(fmri,1)==674 
    factor=7;
elseif size(fmri,1)==449 
    factor=8;
elseif size(fmri,1)==312 
    factor=9;
elseif size(fmri,1)==223 
    factor=10;
else
    disp('Can''t resolve upsampling factor.'), return; 
end

if nargin==1 method='linear'; end

mask=zeros(91,109,91);
mask(1:factor:end,1:factor:end,1:factor:end)=1;
maskv=fmri_vol2vect(mask);
[x,y,z]=ndgrid(1:91,1:109,1:91);
xv=fmri_vol2vect(x);
yv=fmri_vol2vect(y);
zv=fmri_vol2vect(z);
xvmask=xv(find(maskv));
yvmask=yv(find(maskv));
zvmask=zv(find(maskv));

fmri2=zeros(length(xv),size(fmri,2));
for k=1:size(fmri,2)
    tmp=griddata(xvmask,yvmask,zvmask,fmri(:,k),x,y,z,method);
    fmri2(:,k)=fmri_vol2vect(tmp);
end
