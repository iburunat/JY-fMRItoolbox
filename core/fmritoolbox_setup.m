%% FMRITOOLBOX_SETUP  Add JY-fMRItoolbox and dependencies to the MATLAB path.
%
% Run this script once per MATLAB session before using the toolbox.
% Alternatively, add the call to your startup.m file for automatic loading.
%
% Usage:
%   Run this script from the JY-fMRItoolbox root directory, or provide the
%   full path:
%       run('/path/to/JY-fMRIToolbox/fmritoolbox_setup.m')
%
% Requirements:
%   - MATLAB R2014b or later
%   - SPM8 or later (for cluster inference functions only). Required by:
%       fmri_cleanclusters, fmri_findclusters, fmri_tfce,
%       fmri_csdist, fmri_regiontable, fmri_acfestimate, fmri_csdist, 
%       and fmri_csthreshold
%     All other functions work without SPM.
%
% See also: fmri_readnii, fmri_showslices, fmri_corregressor

% ── Toolbox root ──────────────────────────────────────────────────────────
toolbox_root = fileparts(mfilename('fullpath'));
if isempty(toolbox_root)
    toolbox_root = pwd;
end

% ── Toolbox root (all fmri_*.m functions live here) ───────────────────────
addpath(toolbox_root);

% ── NIFTI I/O dependency (bundled) ────────────────────────────────────────
nifti_path = fullfile(toolbox_root, 'external', 'NIFTI_20130306');
if exist(nifti_path, 'dir')
    addpath(nifti_path);
else
    warning('fmritoolbox_setup:noNIfTI', ...
        ['NIFTI_20130306 not found at:\n  %s\n' ...
         'NIfTI read/write (fmri_readnii, fmri_export) will not work.\n' ...
         'Download from: https://www.mathworks.com/matlabcentral/fileexchange/8797'], ...
        nifti_path);
end

% ── masks (brain masks, rendering meshes) ──────────────────────────────
mat_path = fullfile(toolbox_root, 'masks');
if exist(mat_path, 'dir')
    addpath(mat_path);
end

% ── Demos  ──────────────────────────────────────────────────────────────
ex_path = fullfile(toolbox_root, 'demos');
if exist(ex_path, 'dir')
    addpath(ex_path);
end

% ── Atlases  ──────────────────────────────────────────────────────────────
ex_path = fullfile(toolbox_root, 'atlases');
if exist(ex_path, 'dir')
    addpath(ex_path);
end

% ── SPM check ─────────────────────────────────────────────────────────────
% Five cluster inference functions require spm_bwlabel from SPM8 or later.

spm_functions = { ...
    'fmri_cleanclusters', 'fmri_findclusters', 'fmri_tfce', ...
    'fmri_csdist', 'fmri_regiontable' };

if exist('spm_bwlabel', 'file')
    spm_loc = fileparts(which('spm_bwlabel'));
    fprintf('spm_bwlabel found at: %s\n', spm_loc);
    fprintf('Cluster inference functions enabled.\n');
else
    warning('fmritoolbox_setup:noSPM', ...
        ['\nspm_bwlabel was not found on the MATLAB path.\n' ...
         'The following 5 functions will not work without it:\n' ...
         '  %s\n' ...
         'All other JY-fMRItoolbox functions are fully operational.\n\n' ...
         'spm_bwlabel is part of SPM8 or later (free):\n' ...
         '  https://www.fil.ion.ucl.ac.uk/spm/\n' ...
         'Once SPM is installed, add it to your path:\n' ...
         '  addpath(''/path/to/spmxx'')\n' ...
         'or run spm_add_path() if SPM is already installed.\n'], ...
        strjoin(spm_functions, ', '));
end

% ── Done ──────────────────────────────────────────────────────────────────
fprintf('\nJY-fMRItoolbox loaded from: %s\n', toolbox_root);
fprintf('Run ''help fmri_readnii'' to get started.\n');
fprintf('Open examples/demo_preprocessing.m for a guided walkthrough.\n');
clear all
