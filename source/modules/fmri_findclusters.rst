fmri_findclusters
=================

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_FINDCLUSTERS  Finds and label connected clusters in a binary brain map.
Identifies all connected clusters of suprathreshold voxels in a binary
brain map, returns a labelled map and a summary of cluster sizes. Clusters
are defined using 18-connectivity (face and edge connected voxels).

Usage
-----
.. code-block:: matlab

    [clusters, n_clusters, sizes] = fmri_findclusters(data)
    [clusters, n_clusters, sizes] = fmri_findclusters(data, min_size)

Inputs
------
- **DATA**: Binary brain map, vectorized (228453 x 1) or volume (91 x 109 x 91). Non-zero voxels define clusters.
- **MIN_SIZE**: Minimum cluster size in voxels. Clusters smaller than this are removed from the output. Default: 1 (keep all).

Outputs
-------
- **CLUSTERS**: Integer-labelled map (same format as DATA). Each connected cluster has a unique integer label 1..n_clusters, sorted by descending cluster size. Zero = background.
- **N_CLUSTERS**: Number of clusters found (after applying MIN_SIZE).
- **SIZES**: Vector of cluster sizes in voxels (descending order), one entry per cluster.

Examples
--------
.. code-block:: matlab

    [cl, n, sz] = fmri_findclusters(thresh_map);
    fprintf('%d clusters found; largest = %d voxels\n', n, sz(1))
    % Only keep clusters > 50 voxels
    [cl, n, sz] = fmri_findclusters(thresh_map, 50);
    fmri_showslices_int(cl, 1, 3)
    % Get binary map of largest cluster only
    biggest = double(cl == 1);

See Also
--------
- fmri_cleanclusters
- fmri_regiontable
- fmri_csthreshold

