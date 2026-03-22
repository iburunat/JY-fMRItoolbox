fmri_big2small
==============

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_BIG2SMALL  Cros a 91x109x91 volume to the 79x95x68 SPM5 bounding box.
Extracts the smaller FSL/SPM5-style bounding box from the full MNI152 2mm
grid. Useful when interfacing with data processed using the smaller MNI
bounding box (used by SPM5 and earlier). Inverse of fmri_small2big.

Usage
-----
.. code-block:: matlab

    ds = fmri_big2small(dl)

Inputs
------
- **DL**: Volume data (91 x 109 x 91) or (91 x 109 x 91 x T).

Outputs
-------
- **DS**: Cropped volume (79 x 95 x 68) or (79 x 95 x 68 x T).

Examples
--------
.. code-block:: matlab

    small = fmri_big2small(vol);
    small = fmri_big2small(timeseries_4d);

Notes
-----
- Origin offset: x+6, y+7, z+11 (voxels). The crop is [7:85, 8:102, 12:79].

See Also
--------
- fmri_small2big
- fmri_small2big_craddock

