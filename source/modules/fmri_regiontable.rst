fmri_regiontable
================

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_REGIONTABLE  Cluster and ROI table for a thresholded statistical map.
For a binary thresholded brain map, identifies all clusters, labels each
voxel with its atlas region, and returns a structured summary table. Useful
for reporting activation results: lists cluster size, peak coordinate, peak
statistic, MNI location, and atlas region for every cluster.

Usage
-----
.. code-block:: matlab

    [clust, s, ROI, list, roi, clus] = fmri_regiontable(data_thres, data)
    [clust, s, ROI, list, roi, clus] = fmri_regiontable(data_thres, data, clsize, roisize, atlas)

Inputs
------
- **DATA_THRES**: Binary brain map (228453 x 1): 1 = suprathreshold voxel.
- **DATA**: Continuous statistical map (228453 x 1): used for peak values.
- **CLSIZE**: Minimum cluster size in voxels. Default: 0 (all clusters).
- **ROISIZE**: Minimum ROI size in voxels to appear in table. Default: 0.
- **ATLAS**: Atlas number (see atlas list below). Default: 1 (AAL).

Outputs
-------
- **CLUST**: Struct array: one element per cluster, fields: centroid, n, region.
- **S**: Table of ROI information (printed to command window).
- **ROI**: Cell array: each cell is a (228453 x K) binary matrix of atlas regions within cluster k.
- **LIST**: Cell array: region name strings corresponding to ROI columns.
- **ROI**: Same as ROI but stores voxel indices rather than binary maps.
- **CLUS**: (228453 x nClusters) matrix: column k = binary map of cluster k. Fast plotting: fmri_show3d(clus(:,[1 3]))

Examples
--------
.. code-block:: matlab

    [c, s] = fmri_regiontable(thresh_map, z_map);
    [c, s] = fmri_regiontable(thresh_map, z_map, 50, 10, 3);
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

See Also
--------
- fmri_cleanclusters
- fmri_regionnumber
- fmri_csthreshold

