fmri_brainvideo
===============

.. currentmodule:: fmri_toolbox

Description
-----------
FMRI_BRAINVIDEO  Creates a rotating 3D brain video from a brain map.
Renders a 360-degree rotation of a brain map using fmri_show3d, capturing
each frame. Optionally writes to an MP4 file. Supports multiple rotation
trajectories.

Usage
-----
.. code-block:: matlab

    frames = fmri_brainvideo(data)
    frames = fmri_brainvideo(data, filename)
    frames = fmri_brainvideo(data, filename, 'param', value, ...)
    Optional name-value parameters:
    'nframes'    - Number of frames in a full rotation. More frames = smoother
    rotation. Default: 72 (5° per frame at default fps, ~3 s video)
    'fps'        - Frames per second for output video. Default: 25.
    'el'         - Elevation angle(s). Scalar, vector, or empty (gentle dip ~30°). Default: [].
    'climits'    - Colour axis limits [min max]. Default: [] (auto-scale).
    'maskalpha'  - Brain shell transparency. Default: 0.05.
    'color'      - N x 3 RGB activation colour. Default: [1 0.2 0.2] (red).
    'level'      - Isosurface threshold. Default: 0.9.
    'trajectory' - Rotation style: 'cinematic' (default), 'linear', 'reverse', 'flat'.
    Options:
    'cinematic' (default) – Smooth ease-in/ease-out azimuth
    with gentle elevation dip (~30°).
    'linear'    - Constant-speed 360° azimuth rotation.
    Elevation follows the default gentle sinusoidal dip
    unless overridden with 'el'.
    'reverse'    – Linear rotation clockwise (opposite direction).
    'flat'       – Uniform 360° rotation at constant elevation
    (default 0° if 'el' not set).
    Example runs:
    Cinematic rotation (default)
    fmri_brainvideo(data, 'brain.mp4', 'nframes', 300)
    Constant elevation but linear speed:
    fmri_brainvideo(data, 'brain.mp4', 'trajectory', 'linear', 'el', 30)
    Reverse rotation (clockwise)
    fmri_brainvideo(data, 'brain.mp4', 'trajectory', 'reverse')
    Flat rotation (zero elevation)
    fmri_brainvideo(data, 'brain.mp4', 'trajectory', 'flat')

Notes
-----
- - 'el' may be a scalar (constant) or vector of length NFRAMES.
- (per frame, interpolated across nframes if length differs).
- - Total video duration = nframes / fps seconds.
- - nframes controls smoothness; fps controls playback speed.
- --- parse optional parameters ---

