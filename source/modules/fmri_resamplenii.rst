fmri_resamplenii
================

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_RESAMPLENII  Resamples a NIfTI image to a target voxel grid.
Resamples a NIfTI image to a specified target grid size using trilinear
interpolation. The primary use case is rescaling images from non-standard
resolutions to the toolbox standard (91 x 109 x 91, 2mm MNI152).

Usage
-----
.. code-block:: matlab

    fmri_resamplenii(input_file, output_file)
    fmri_resamplenii(input_file, output_file, target_size)

Inputs
------
- **INPUT_FILE**: Path to the input NIfTI file (string).
- **OUTPUT_FILE**: Path for the output NIfTI file (string). The .nii extension is added if absent.
- **TARGET_SIZE**: Desired output dimensions [X Y Z]. Default: [91 109 91] (standard 2mm MNI152 grid)

Outputs
-------
- **(none)**: Saves the resampled image to OUTPUT_FILE.

Examples
--------
.. code-block:: matlab

    % Resample a 4mm atlas to standard 2mm grid
    fmri_resamplenii('atlas_4mm.nii', 'atlas_2mm.nii');
    % Resample to a custom grid
    fmri_resamplenii('bold.nii', 'bold_resampled.nii', [91 109 91]);

Notes
-----
- This function uses trilinear interpolation (interp3 'linear'). For
- label images (atlases), use nearest-neighbour instead by modifying
- the interp3 call to use 'nearest'.

See Also
--------
- fmri_readnii
- fmri_export
- fmri_big2small
- fmri_small2big

