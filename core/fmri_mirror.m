function d2 = fmri_mirror(d)
% FMRI_MIRROR  Flips a vectorized brain map left-to-right (sagittal mirror).
%
% Flips the brain image along the x-axis (left-right) to produce its
% mirror image. Useful for testing laterality or creating symmetric
% averages (hemisphere-averaged FC maps, etc.).
%
% Usage:
%   d2 = fmri_mirror(d)
%
% Inputs:
%   D   - Vectorized brain data (228453 x N) or volume (91 x 109 x 91 x N).
%
% Outputs:
%   D2  - Mirror-flipped brain, same format as D.
%
% Examples:
%   d_mirror = fmri_mirror(d);
%   bilateral = (d + fmri_mirror(d)) / 2;   % bilateral average
%
% See also: fmri_vol2vect, fmri_vect2vol

d2=fmri_vol2vect(flipud(fmri_vect2vol(d)));
