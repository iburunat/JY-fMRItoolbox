% JY-fMRIToolbox — Lightweight MATLAB toolbox for transparent fMRI analysis
%
% Run fmritoolbox_setup.m to add the toolbox to your MATLAB path.
% Type "help <function_name>" for detailed documentation on any function.
%
% -------------------------------------------------------------------------
% I/O
% -------------------------------------------------------------------------
%   fmri_readnii            - Read 3D or 4D NIfTI (.nii / .img) file
%   fmri_export             - Save 3D or 4D data as NIfTI file
%   fmri_resamplenii        - Resample NIfTI to target voxel grid
%
% -------------------------------------------------------------------------
% Space: coordinates and data representation
% -------------------------------------------------------------------------
%   fmri_vol2vect           - Vectorize 91x109x91 volume to 228453 brain vector
%   fmri_vect2vol           - Devectorize 228453 brain vector to 91x109x91 volume
%   fmri_sub2mni            - Voxel subscripts to MNI coordinates (mm)
%   fmri_mni2sub            - MNI coordinates to voxel subscripts
%   fmri_mni2tal            - MNI to Talairach coordinates
%   fmri_ind2sub            - Linear brain index to voxel subscripts
%   fmri_sub2ind            - Voxel subscripts to linear brain index
%   fmri_mirror             - Left-right flip (sagittal mirror)
%   fmri_big2small          - Crop 91x109x91 to 79x95x68 bounding box
%   fmri_small2big          - Embed 79x95x68 into 91x109x91 grid
%   fmri_bin                - Bin continuous data into discrete colour bands
%
% -------------------------------------------------------------------------
% Preprocessing
% -------------------------------------------------------------------------
%   fmri_detrend            - Spline-based temporal detrending
%   fmri_tempsmooth         - Temporal Gaussian smoothing
%   fmri_bandpassfilter     - Non-causal FFT bandpass filter
%   fmri_correctmovement    - Regress out motion parameters (OLS)
%   fmri_downsample         - Spatial downsampling by integer factor
%   fmri_upsample           - Restore spatially downsampled data
%   fmri_wiener             - Wiener deconvolution (BOLD -> neural)
%   fmri_zscorevoldata      - Voxelwise z-scoring of time series
%
% -------------------------------------------------------------------------
% ROI
% -------------------------------------------------------------------------
%   fmri_regionmask         - Binary mask for one or more atlas regions
%   fmri_regionnumber       - Atlas ROI name and number for voxel coordinates
%   fmri_nregion            - Region name(s) for atlas ROI number(s)
%   fmri_regiontable        - Cluster and ROI table for thresholded map
%   fmri_vox2reg            - Average voxel data within atlas ROIs
%   fmri_reg2vox            - Map ROI-level data back to voxel space
%   fmri_spheremask         - Spherical ROI mask at a given voxel
%   fmri_banumber           - Brodmann area number for voxel coordinates
%   fmri_maskdata           - Masks volume data with a selected ROI mask
%   fmri_atlas              - List atlases and regions by atlas number
%   fmri_loadatlas          - Helper function used internally by atlas functions
% -------------------------------------------------------------------------
% Analysis
% -------------------------------------------------------------------------
%   fmri_corregressor       - Voxelwise correlation of regressor(s) with data
%   fmri_corrvoldata        - Voxelwise correlation between two datasets
%   fmri_xcorr              - Voxelwise lagged cross-correlation
%   fmri_simmat             - Temporal similarity (correlation) matrix
%   fmri_partcorr           - Partial correlation controlling for confounds
%   fmri_r2p                - Pearson r to p-value conversion
%   fmri_fisherz            - Pearson r to Fisher z-score conversion
%   fmri_fmri_fisherz2p     - Fisher z-score to p-value conversion
%   fmri_effdf              - Effective degrees of freedom (autocorrelation)
%   fmri_doublegamma        - Canonical double-gamma HRF
%   fmri_dicemirror         - DICE coefficient for left-right symmetry of brain map
%
% -------------------------------------------------------------------------
% Statistical inference
% -------------------------------------------------------------------------
%   fmri_cleanclusters      - Remove small/sparse clusters from thresholded map
%   fmri_tfce               - Threshold-free cluster enhancement (TFCE)
%   fmri_acfestimate        - Estimate spatial ACF for cluster-size correction
%   fmri_csdist             - Generate cluster-size null distribution
%   fmri_csthreshold        - Extract critical cluster sizes from distribution
%   fmri_findclusters       - Finds and labels voxel clusters in a binary brain map
%   fmri_scramblephases     - Phase-scramble a volume or time series
%
% -------------------------------------------------------------------------
% Simulation
% -------------------------------------------------------------------------
%   fmri_simdata            - Generate simulated 3D fMRI data for testing and demonstration
%   fmri_simget             - Extract one participant from fmri_simdata output
%
% -------------------------------------------------------------------------
% Quality control
% -------------------------------------------------------------------------
%   fmri_snri               - Image-domain SNR per scan (SNR-i)
%   fmri_snrt               - Temporal SNR per voxel (tSNR)
%   fmri_cnr                - Temporal contrast-to-noise ratio (tCNR)
%
% -------------------------------------------------------------------------
% Visualization
% -------------------------------------------------------------------------
%   fmri_showslices         - Continuous data: axial/sagittal/coronal mosaic
%   fmri_showslices_int     - Integer labels: coloured slice mosaic
%   fmri_showselectslices   - Continuous data on user-specified slices
%   fmri_showselectslices_int - Integer data on user-specified slices
%   fmri_showplanes         - Three-plane orthogonal view with crosshair
%   fmri_show3d             - 3D isosurface rendering on transparent brain
%   fmri_show3dba           - 3D rendering coloured by atlas region
%   fmri_showcortex         - Cortical surface with continuous colormap
%   fmri_showcortex_masked  - Cortical surface restricted to binary mask
%   fmri_braincake          - 3D layered-slice 'brain cake' rendering
%   fmri_show3dhalfbrains   - Four-panel lateral/medial hemisphere views
%   fmri_brainvideo         - Render rotating 3D brain activation as a video file
%   fmri_makevizpar         - Create parameter structure for visualisation functions
%
% -------------------------------------------------------------------------
% See also: fmritoolbox_setup, demos/demo_preprocessing.m,
%           demos/demo_glm.m, demos/demo_visualization.m,
%           demos/demo_naturalistic_pipeline.m
