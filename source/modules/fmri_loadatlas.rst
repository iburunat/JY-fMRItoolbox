fmri_loadatlas
==============

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_LOADATLAS  Loads atlas ROI map and region labels by atlas number.
Shared helper used internally by atlas functions. Returns the voxel-wise
ROI index map and a cell array of region name strings for the requested
atlas. All 19 atlases in the toolbox are supported.

Usage
-----
.. code-block:: matlab

    [ROI_nos, ROI_labels]                    = fmri_loadatlas(atlasnumber)
    [ROI_nos, ROI_labels, name, ref]         = fmri_loadatlas(atlasnumber)
    [~, ~, atlases]                          = fmri_loadatlas()  % metadata only

Inputs
------
- **ATLASNUMBER**: Atlas number (1-19). If omitted, returns only metadata.

Outputs
-------
- **ROI_NOS**: Vectorized atlas map (228453 x 1).
- **ROI_LABELS**: Cell array of region name strings {N x 1}.
- **ATLAS_NAME**: Atlas name string (or full metadata cell array if no input).
- **REFERENCE**: Reference string.

See Also
--------
- fmri_atlas
- fmri_regionmask
- fmri_regionnumber
- fmri_nregion

