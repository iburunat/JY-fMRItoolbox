fmri_readnii
============

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_READNII  Reads a 3D or 4D NIfTI (.nii) or Analyze (.img/.hdr) file.
Reads volumetric brain data and returns both the image array and a
metadata structure. Works for both 3D (single volume) and 4D (time series)
files. If no filename is supplied, a file-open dialog is shown.

Usage
-----
.. code-block:: matlab

    [data, metadata] = fmri_readnii()
    [data, metadata] = fmri_readnii('subject01.nii')
    [data, metadata] = fmri_readnii('/path/to/data.img')

Inputs
------
- **FILENAME**: Path to a .nii or .img file (string). Optional: if omitted, a file-open dialog is displayed.

Outputs
-------
- **DATA**: Image array. Shape: [X Y Z] for 3D, [X Y Z T] for 4D.
- **METADATA**: Structure with fields: .hdr        - Full NIfTI/Analyze header .filetype   - File type code .fileprefix - Filename without extension .machine    - Byte-order string .original   - Original header struct

Examples
--------
.. code-block:: matlab

    [vol, meta] = fmri_readnii('anat.nii');
    [ts,  meta] = fmri_readnii('bold_run1.nii');
    [vol, meta] = fmri_readnii();   % opens file dialog

Notes
-----
- This function replaces the earlier fmri_read3Dnii and fmri_read4Dnii,
- which were identical. Both 3D and 4D files are handled automatically.

See Also
--------
- fmri_export
- fmri_vol2vect
- fmri_vect2vol
- fmri_resamplenii

