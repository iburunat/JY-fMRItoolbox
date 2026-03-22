fmri_mni2tal
============

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_MNI2TAL  Converts MNI152 coordinates to Talairach space.
Transforms a 3D coordinate from MNI152 space to Talairach space using the
linear transform by Lancaster et al. (2007). This is useful when comparing
results with older literature that used Talairach coordinates.
The transform is: tal = A * mni + B
where A = diag([0.88, 0.97, 0.88]) with a shear on z,
and   B = [-0.8; -3.32; -0.44]

Usage
-----
.. code-block:: matlab

    tal = fmri_mni2tal(mni)

Inputs
------
- **MNI**: MNI coordinate in mm, (3 x 1) column vector: [x; y; z].

Outputs
-------
- **TAL**: Talairach coordinate in mm, (3 x 1) column vector.

Examples
--------
.. code-block:: matlab

    tal = fmri_mni2tal([0; 0; 0]);
    tal = fmri_mni2tal([-42; -18; 60]);

Notes
-----
- Input must be a column vector (3 x 1). To convert a row vector, transpose
- first: tal = fmri_mni2tal(mni').

References
----------
- Lancaster, J.L. et al. (2007). Bias between MNI and Talairach coordinates analyzed using the ICBM-152 brain template. Human Brain Mapping, 28(11), 1194-1205.

See Also
--------
- fmri_sub2mni
- fmri_mni2sub

