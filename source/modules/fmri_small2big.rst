fmri_small2big
==============

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_SMALL2BIG  Embeds a 79x95x68 volume into the 91x109x91 MNI grid.
Pads the smaller SPM5/FSL bounding-box volume back into the full
91x109x91 MNI152 2mm grid by adding appropriate zero margins. Inverse
of fmri_big2small.

Usage
-----
.. code-block:: matlab

    ds = fmri_small2big(dl)

Inputs
------
- **DL**: Volume data (79 x 95 x 68) or (79 x 95 x 68 x T).

Outputs
-------
- **DS**: Full-grid volume (91 x 109 x 91) or (91 x 109 x 91 x T). Voxels outside the crop region are zero.

Examples
--------
.. code-block:: matlab

    full = fmri_small2big(small_vol);

See Also
--------
- fmri_big2small
- fmri_small2big_craddock

