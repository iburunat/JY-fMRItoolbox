fmri_regionnumber
=================

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_REGIONNUMBER  Looks up atlas ROI name and number for voxel coordinates.
For each voxel location (subscript space), returns the name and index of
the atlas region that contains it. Handles single or multiple coordinates.

Usage
-----
.. code-block:: matlab

    [list_of_regions, regionnumber] = fmri_regionnumber(coords)
    [list_of_regions, regionnumber] = fmri_regionnumber(coords, atlas)

Inputs
------
- **COORDS**: Voxel subscripts (N x 3): [x1 y1 z1; x2 y2 z2; ...].
- **1**: based, x in [1 91], y in [1 109], z in [1 91].
- **ATLAS**: Atlas number (see atlas list below). Default: 1 (AAL).

Outputs
-------
- **LIST_OF_REGIONS**: Cell array of region name strings (N x 1).
- **REGIONNUMBER**: Region index numbers (N x 1). 0 = no atlas label.

Examples
--------
.. code-block:: matlab

    [name, num] = fmri_regionnumber([46 64 37]);     % brain centre
    [names, ~]  = fmri_regionnumber([30 50 40; 60 70 50], 3);
    % Look up peak voxel from a stat map
    [~, peak] = max(r_map);
    sub = fmri_ind2sub(peak);
    [region, ~] = fmri_regionnumber(sub);
    Atlas numbers:
    1  = AAL / MarsBar (Automated Anatomical Labeling, 116 ROIs, default)
    2  = Harvard-Oxford Subcortical Structural Atlas (21 ROIs)
    3  = Harvard-Oxford Cortical Structural Atlas (48 ROIs)
    4  = Cerebellar Atlas (MNI152, FLIRT affine, 28 ROIs)
    5  = Cerebellar Atlas (MNI152, FNIRT nonlinear, 28 ROIs)
    6  = JHU ICBM-DTI-81 White-Matter Labels (48 ROIs)
    7  = JHU White-Matter Tractography Atlas (20 ROIs)
    8  = Juelich Histological Atlas (62 ROIs)
    9  = MNI Structural Atlas (9 ROIs)
    10  = Oxford-Imanova Striatal Structural Atlas (3 ROIs)
    11  = Oxford-Imanova Striatal Connectivity Atlas, 3 sub-regions
    12  = Oxford-Imanova Striatal Connectivity Atlas, 7 sub-regions
    13  = Oxford Thalamic Connectivity Probability Atlas (25 ROIs)
    14  = Craddock Parcellation 200 ROI
    15  = Craddock Parcellation 400 ROI
    16  = Craddock Parcellation 500 ROI
    17  = Craddock Parcellation 600 ROI
    18  = Craddock Parcellation 950 ROI
    19  = Brodmann Areas (48 regions)

Notes
-----
- COORDS can also be given as linear brain indices (N x 1 vector of integers
- in [1, 228453]), in which case they are automatically converted to
- subscripts via fmri_ind2sub. This avoids the common pattern:
- fmri_regionnumber(fmri_ind2sub(ind), atlas)

See Also
--------
- fmri_nregion
- fmri_regionmask
- fmri_banumber
- fmri_ind2sub

