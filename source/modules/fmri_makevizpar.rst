fmri_makevizpar
===============

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_MAKEVIZPAR  Creates a visualization parameter structure with defaults.
Returns a structure containing default values for all parameters used
across the toolbox visualization functions (fmri_show3d, fmri_showcortex,
fmri_braincake, fmri_showslices, fmri_showplanes, etc.). Modify fields
before passing to any visualization function.

Usage
-----
.. code-block:: matlab

    p = fmri_makevizpar()
    p = fmri_makevizpar('field', value, ...)

Inputs
------
- Optional name-value pairs to override specific defaults. Output fields: P.AZ          - Azimuth angle (degrees). Default: 40 P.EL          - Elevation angle (degrees). Default: 15 P.LEVEL       - Isosurface threshold (fraction). Default: 0.9 P.ALPHAVAL    - Surface opacity (0-1). Default: 1 P.MASKALPHA   - Brain shell opacity (0-1). Default: 0.05 P.CLIMITS     - Colour axis limits [min max]. Default: [] (auto) P.COLORMAP    - N x 3 RGB colormap. Default: jet(64) P.COLOR       - N x 3 activation colours. Default: standard 6-colour set P.LIGHT       - Light source matrix [az el; ...]. Default: [45 80; -45 80] P.CBAR        - Show colourbar: 1=yes, 0=no. Default: 1 P.DIRECTION   - Slice direction: 1=axial, 2=sagittal, 3=coronal. Default: 1 P.INTERVAL    - Slice interval (voxels). Default: 4 P.TXT         - Figure title string. Default: '' P.ALPHA       - Overlay opacity (slice views). Default: 1 P.CROP        - Bounding box [xmin xmax ymin ymax zmin zmax]. Default: [] (full) P.PLANE       - Braincake slice plane: 1=axial, 2=sagittal, 3=coronal. Default: 1 P.INTERSLICE  - Braincake gap between slabs. Default: 0 P.GREYPAR     - Directional shading strength (0=flat, 1=strong). Default: 0.4

Examples
--------
.. code-block:: matlab

    p = fmri_makevizpar();
    p.az = 180; p.el = 10; p.maskalpha = 0.1;
    fmri_show3d(data, p.az, p.el, p.level, p.alphaval, p.color, p.maskalpha)
    % Override at creation time
    p = fmri_makevizpar('az', 180, 'climits', [0 5]);

See Also
--------
- fmri_show3d
- fmri_showcortex
- fmri_braincake
- fmri_showslices

