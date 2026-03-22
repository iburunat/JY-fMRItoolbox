function [data, metadata] = fmri_readnii(filename)
% FMRI_READNII  Reads a 3D or 4D NIfTI (.nii) or Analyze (.img/.hdr) file.
%
% Reads volumetric brain data and returns both the image array and a
% metadata structure. Works for both 3D (single volume) and 4D (time series)
% files. If no filename is supplied, a file-open dialog is shown.
%
% Usage:
%   [data, metadata] = fmri_readnii()
%   [data, metadata] = fmri_readnii('subject01.nii')
%   [data, metadata] = fmri_readnii('/path/to/data.img')
%
% Inputs:
%   FILENAME  - Path to a .nii or .img file (string). Optional: if omitted,
%               a file-open dialog is displayed.
%
% Outputs:
%   DATA      - Image array. Shape: [X Y Z] for 3D, [X Y Z T] for 4D.
%   METADATA  - Structure with fields:
%                 .hdr        - Full NIfTI/Analyze header
%                 .filetype   - File type code
%                 .fileprefix - Filename without extension
%                 .machine    - Byte-order string
%                 .original   - Original header struct
%
% Examples:
%   [vol, meta] = fmri_readnii('anat.nii');
%   [ts,  meta] = fmri_readnii('bold_run1.nii');
%   [vol, meta] = fmri_readnii();   % opens file dialog
%
% Notes:
%   This function replaces the earlier fmri_read3Dnii and fmri_read4Dnii,
%   which were identical. Both 3D and 4D files are handled automatically.
%
% See also: fmri_export, fmri_vol2vect, fmri_vect2vol, fmri_resamplenii

if nargin < 1 || isempty(filename)
    [fname, fpath] = uigetfile({'*.nii;*.img', 'NIfTI and Analyze files (*.nii, *.img)'}, ...
                                'Select a NIfTI or Analyze file');
    if isequal(fname, 0)
        error('fmri_readnii:noFileSelected', 'No file selected.');
    end
    filename = fullfile(fpath, fname);
end

% Ensure .nii extension is appended when base name given without extension
[~, ~, ext] = fileparts(filename);
if isempty(ext)
    filename = [filename '.nii'];
end

img = load_nii(filename);

data                = img.img;
metadata.hdr        = img.hdr;
metadata.filetype   = img.filetype;
metadata.fileprefix = img.fileprefix;
metadata.machine    = img.machine;
metadata.original   = img.original;
