fmri_showslices
===============

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_SHOWSLICES  Displays continuous brain data as a series of 2D slices.
Renders a continuous-valued brain map as a mosaic of axial, sagittal, or
coronal slices overlaid on the greyscale brain template. Each slice is
equally spaced by INTERVAL voxels. Suitable for statistical maps, correlation
maps, tSNR maps, etc.

Usage
-----
.. code-block:: matlab

    fmri_showslices(data)
    fmri_showslices(data, direction, interval, clim, txt, alpha, cbar)

Inputs
------
- **DATA**: Continuous brain map, vectorized (228453 x 1).
- **DIRECTION**: Slice plane: 1=axial (default), 2=sagittal
- **INTERVAL**: Voxel spacing between displayed slices (1 or 2). Default: 2.
- **CLIM**: Colour axis limits [min max]. Default: auto.
- **TXT**: Title string. Default: '' (no title).
- **ALPHA**: Opacity of the overlay (0=transparent, 1=opaque). Default: 1. CBAR (optional) = colorbar flag (default = 0 (no colorbar))

Examples
--------
.. code-block:: matlab

    fmri_showslices(r_map)
    fmri_showslices(z_map, 1, 2, [2 6])
    fmri_showslices(tsnr, 1, 3, [0 100], hot)
    D = fmri_voxdist(ind1, 1:228453);   % 1 x 228453
    fmri_showslices(D',  1, 2, [0 128],1)           % default diverging
    fmri_showslices(D',  1, 2, [0 128],1,[],[], 'hot')   % named colormap
    fmri_showslices(D',  1, 2, [0 128],1,[],[], 'winter')
    fmri_showslices(D',  1, 2, [0 128],1,[],1, [0 0 0.8; 0.7 0.5 1; 1 1 1; 0.4 1 0.4; 1 0 0]) % custom Nx3 matrix
    2 colors: simple black to white
    fmri_showslices(D, 1, 2, [-128 128], 1, [], [], [0 0 0; 1 1 1])
    % 3 colors: classic diverging
    fmri_showslices(D, 1, 2, [0 128], 1, [], [], [0 0 0.8; 0.7 0.7 0.7; 1 0 0])
    % 5 colors: multi-transition
    fmri_showslices(D, 1, 2, [0 128], 1, [], [], [0 0 0.8; 0.7 0.5 1; 1 1 1; 0.4 1 0.4; 1 0 0])
    % 7 colors: rainbow-like
    fmri_showslices(D, 1, 2, [0 128], 1, [], [], [0 0 1; 0 0.5 1; 0 1 1; 0 1 0; 1 1 0; 1 0.5 0; 1 0 0])
    % black to red (heat)
    fmri_showslices(D, 1, 2, [0 128], 1, [], [], [0 0 0; 1 0 0])
    % black to yellow (like 'hot')
    fmri_showslices(D, 1, 2, [0 128], 1, [], [], [0 0 0; 1 0 0; 1 1 0])

