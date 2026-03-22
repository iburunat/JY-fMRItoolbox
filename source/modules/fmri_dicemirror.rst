fmri_dicemirror
===============

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_DICEMIRROR  Mirrored Dice coefficient of a binary brain mask.
Measures the bilateral symmetry of a brain mask by computing the Dice
coefficient between the mask and its left-right mirror image. A value of
1 means the mask is perfectly symmetric; 0 means no overlap with its mirror.
Dice = 2 * |A ∩ mirror(A)| / (|A| + |mirror(A)|)
Because |A| = |mirror(A)| always, this simplifies to:
Dice = |A ∩ mirror(A)| / |A|

Usage
-----
.. code-block:: matlab

    [dice, overlap_map] = fmri_dicemirror(mask)

Inputs
------
- **MASK**: Binary brain mask, vectorized (228453 x 1).

Outputs
-------
- **DICE**: Mirrored Dice coefficient (scalar, range [0 1]).
- **OVERLAP_MAP**: Binary map (228453 x 1): 1 where mask and mirror overlap.

Examples
--------
.. code-block:: matlab

    % Symmetry of left hippocampus mask
    mask = fmri_regionmask(57, 1);   % L hippocampus
    [d, ov] = fmri_dicemirror(mask);
    fprintf('Mirrored Dice: %.3f\n', d)
    % Symmetry of a bilateral activation cluster
    [d, ov] = fmri_dicemirror(thresh_map);

See Also
--------
- fmri_mirror
- fmri_regionmask
- fmri_spheremask

