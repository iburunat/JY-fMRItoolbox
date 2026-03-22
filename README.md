<table border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td valign="middle">
      <img src="source/_static/logo.png" alt="JY-fMRItoolbox logo" height="160"/>
    </td>
  </tr>
</table>

A lightweight, transparent MATLAB toolbox for human fMRI analysis.

## Philosophy

JY-fMRIToolbox is designed to be **inspectable**. Every function is a single readable `.m` file. There are no compiled MEX binaries, no black-box pipelines, and no hidden state. If you want to understand what the toolbox does, you read the code.

The toolbox uses a single, consistent data representation throughout: all brain data is stored as a **228,453-element vectorized array** (or `228453 × T` matrix for time series), corresponding to the in-brain voxels of the 91×109×91 MNI152 2mm template. Conversion between vector and volume forms is lossless and instantaneous via `fmri_vol2vect` / `fmri_vect2vol`.

## Requirements

- MATLAB R2014b or later
- [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) — required only for cluster-extent functions (`fmri_cleanclusters`, `fmri_tfce`, `fmri_csdist`)
- Jimmy Shen's [NIFTI toolbox](https://www.mathworks.com/matlabcentral/fileexchange/8797) — included in `external/NIFTI_20130306/`

## Installation

```matlab
% Option 1: run setup script each session
run('/path/to/JY-fMRItoolbox/fmritoolbox_setup.m')

% Option 2: add to startup.m for automatic loading
% Edit (or create) ~/Documents/MATLAB/startup.m and add:
run('/path/to/JY-fMRItoolbox/fmritoolbox_setup.m')
```

## Quick start

```matlab
% Load a NIfTI file
[data, meta] = fmri_readnii('subject01_bold.nii');

% Preprocess
data = fmri_vect2vol(fmri_vol2vect(data));   % round-trip: voxels only
data = fmri_vol2vect(data);                  % vectorize: 228453 x T
data = fmri_detrend(data);                   % remove drift
data = fmri_bandpassfilter(data', 0.5, 0.01, 0.10)';  % bandpass (TR=2s)
data = fmri_correctmovement(data', 'motion_params.txt')';
data = fmri_zscorevoldata(data);             % z-score voxelwise

% Correlate with a task regressor
r = fmri_corregressor(regressor, data);
fmri_showslices(r, 1, 2, [0.2 0.7])

% Get region label for a peak voxel
[~, peak] = max(r);
sub = fmri_ind2sub(peak);
[region, ~] = fmri_regionnumber(sub);
disp(region)
```

## Toolbox modules

| Module | Functions | Description |
|---|---|---|
| **I/O** | `fmri_readnii`, `fmri_export`, `fmri_resamplenii` | Read/write NIfTI files |
| **Space** | `fmri_vol2vect`, `fmri_vect2vol`, `fmri_sub2mni`, `fmri_mni2sub`, `fmri_mni2tal`, `fmri_ind2sub`, `fmri_sub2ind`, `fmri_mirror`, `fmri_big2small`, `fmri_small2big`, `fmri_bin` | Coordinate transforms and data representations |
| **Preprocessing** | `fmri_detrend`, `fmri_tempsmooth`, `fmri_bandpassfilter`, `fmri_correctmovement`, `fmri_downsample`, `fmri_upsample`, `fmri_wiener`, `fmri_zscorevoldata` | Signal cleaning and conditioning |
| **ROI** | `fmri_regionmask`, `fmri_regionnumber`, `fmri_nregion`, `fmri_regiontable`, `fmri_vox2reg`, `fmri_reg2vox`, `fmri_spheremask`, `fmri_banumber`, `fmri_maskdata`, `fmri_atlas`, `fmri_loadatlas` | 20-atlas ROI system |
| **Analysis** | `fmri_corregressor`, `fmri_corrvoldata`, `fmri_xcorr`, `fmri_simmat`, `fmri_partcorr`, `fmri_r2p`, `fmri_fisherz`, `fmri_fisherz2p`, `fmri_effdf`, `fmri_doublegamma`, `fmri_dicemirror` | GLM and connectivity analysis |
| **Inference** | `fmri_cleanclusters`, `fmri_tfce`, `fmri_acfestimate`, `fmri_csdist`, `fmri_csthreshold`, `fmri_findclusters`, `fmri_scramblephases` | Cluster-size and threshold-free correction |
| **Simulation** | `fmri_simdata`, `fmri_simget` | Synthetic fMRI data generation for testing and demos |
| **QC** | `fmri_snri`, `fmri_snrt`, `fmri_cnr` | Quality metrics |
| **Visualization** | `fmri_showslices`, `fmri_showslices_int`, `fmri_showselectslices`, `fmri_showselectslices_int`, `fmri_showplanes`, `fmri_show3d`, `fmri_show3dba`, `fmri_showcortex`, `fmri_showcortex_masked`, `fmri_braincake`, `fmri_show3dhalfbrains`, `fmri_brainvideo`, `fmri_makevizpar`  | Slice mosaics and 3D rendering |

## Atlas system

The toolbox includes 19 atlases accessible through a unified interface:

| # | Atlas | ROIs |
|---|---|---|
| 1 | AAL / MarsBar (default) | 116 |
| 2 | Harvard-Oxford Subcortical | 21 |
| 3 | Harvard-Oxford Cortical | 48 |
| 4–5 | Cerebellar (FLIRT / FNIRT) | 28 |
| 6–7 | JHU White Matter | 48 / 20 |
| 8 | Juelich Histological | 62 |
| 9 | MNI Structural | 9 |
| 10–12 | Oxford-Imanova Striatal | 3 / 3 / 7 |
| 13 | Oxford Thalamic | 7 |
| 15–19 | Craddock Parcellations | 200–950 |
| 20 | Brodmann Areas | 48 |

## Demos

Three worked examples are provided in `demos/`:

| Script | Description |
|---|---|
| `demo_naturalistic_pipeline.m` | Full naturalistic fMRI pipeline: simulation, preprocessing, GLM, group inference, visualisation |
| `demo_preprocessing.m` | Preprocessing pipeline on synthetic data |
| `demo_glm.m` | First- and second-level GLM, ROI analysis, TFCE |
| `demo_visualization.m` | Gallery of visualisation functions |

Run `demo_naturalistic_pipeline.m` for a complete end-to-end demonstration requiring no external data.

## Citation

If you use this toolbox in published work, please cite:

> [Authors]. JY-fMRItoolbox: a lightweight MATLAB toolbox for transparent fMRI analysis. *NeuroImage*, [year]. doi: [doi]

A BibTeX entry is available in `CITATION.cff`.

## License

MIT License — see `LICENSE.txt`.

## 🍎 macOS Users: Important Setup Instructions

If you encounter MEX file errors like:
Invalid MEX-file '...spm_bwlabel.mexmaca64': dlopen... not valid for use in process: library load disallowed by system policy

This is caused by macOS security quarantine flags on compiled files, especially when:
- Downloaded from the internet
- Synced via cloud services (Dropbox, Google Drive, etc.)
- Transferred from another computer

### Quick Fix

1. **Open Terminal** (Applications > Utilities > Terminal)
2. **Navigate to your SPM directory** (or use the full path):
```bash
   cd /path/to/your/spm25
```
3. **Remove quarantine attributes from all MEX files:**
```bash
xattr -d com.apple.quarantine *.mexmaca64
```
4. **Restart MATLAB and try again**

### Alternative: Fix Specific File

If you prefer to fix only the problematic file:
```bash
xattr -d com.apple.quarantine /full/path/to/spm_bwlabel.mexmaca64
```
### Why This Happens

macOS applies quarantine attributes to files from untrusted sources as a security measure. MATLAB needs to load these files into memory, which triggers the security check. Removing the attribute tells macOS these files are safe to use.

## Acknowledgements

The NIFTI I/O routines are provided by Jimmy Shen's NIfTI toolbox (BSD licence).  
Brain atlases are redistributed with permission from their original authors; see `atlas/ATLAS_LICENSES.md` for details.


