function fmri_resamplenii(input_file, output_file, target_size)
% FMRI_RESAMPLENII  Resamples a NIfTI image to a target voxel grid.
%
% Resamples a NIfTI image to a specified target grid size using trilinear
% interpolation. The primary use case is rescaling images from non-standard
% resolutions to the toolbox standard (91 x 109 x 91, 2mm MNI152).
%
% Usage:
%   fmri_resamplenii(input_file, output_file)
%   fmri_resamplenii(input_file, output_file, target_size)
%
% Inputs:
%   INPUT_FILE   - Path to the input NIfTI file (string).
%   OUTPUT_FILE  - Path for the output NIfTI file (string).
%                  The .nii extension is added if absent.
%   TARGET_SIZE  - Desired output dimensions [X Y Z]. 
%                  Default: [91 109 91] (standard 2mm MNI152 grid)
%
% Outputs:
%   (none) - Saves the resampled image to OUTPUT_FILE.
%
% Examples:
%   % Resample a 4mm atlas to standard 2mm grid
%   fmri_resamplenii('atlas_4mm.nii', 'atlas_2mm.nii');
%
%   % Resample to a custom grid
%   fmri_resamplenii('bold.nii', 'bold_resampled.nii', [91 109 91]);
%
% Notes:
%   This function uses trilinear interpolation (interp3 'linear'). For
%   label images (atlases), use nearest-neighbour instead by modifying
%   the interp3 call to use 'nearest'.
%
% See also: fmri_readnii, fmri_export, fmri_big2small, fmri_small2big

if nargin < 3 || isempty(target_size)
    target_size = [91 109 91];
end

% Load input
nii  = load_nii(input_file);
orig = double(nii.img);
orig_size = size(orig);

if length(orig_size) < 3
    error('fmri_resamplenii:badInput', 'Input must be a 3D NIfTI image.');
end

% Build coordinate grids for original and target
[oX, oY, oZ] = meshgrid(1:orig_size(2), 1:orig_size(1), 1:orig_size(3));
[tX, tY, tZ] = meshgrid( ...
    linspace(1, orig_size(2), target_size(2)), ...
    linspace(1, orig_size(1), target_size(1)), ...
    linspace(1, orig_size(3), target_size(3)));

% Interpolate
resampled = interp3(oX, oY, oZ, orig, tX, tY, tZ, 'linear', 0);

% Build output NIfTI and save
out_nii               = nii;
out_nii.hdr.dime.dim(2:4) = target_size;
out_nii.img           = single(resampled);

[~, ~, ext] = fileparts(output_file);
if isempty(ext), output_file = [output_file '.nii']; end

save_nii(out_nii, output_file);
fprintf('Saved resampled image (%dx%dx%d) to: %s\n', target_size, output_file);
