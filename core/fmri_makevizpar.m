function p = fmri_makevizpar(varargin)
% FMRI_MAKEVIZPAR  Creates a visualization parameter structure with defaults.
%
% Returns a structure containing default values for all parameters used
% across the toolbox visualization functions (fmri_show3d, fmri_showcortex,
% fmri_braincake, fmri_showslices, fmri_showplanes, etc.). Modify fields
% before passing to any visualization function.
%
% Usage:
%   p = fmri_makevizpar()
%   p = fmri_makevizpar('field', value, ...)
%
% Inputs:
%   Optional name-value pairs to override specific defaults.
%
% Output fields:
%   P.AZ          - Azimuth angle (degrees). Default: 40
%   P.EL          - Elevation angle (degrees). Default: 15
%   P.LEVEL       - Isosurface threshold (fraction). Default: 0.9
%   P.ALPHAVAL    - Surface opacity (0-1). Default: 1
%   P.MASKALPHA   - Brain shell opacity (0-1). Default: 0.05
%   P.CLIMITS     - Colour axis limits [min max]. Default: [] (auto)
%   P.COLORMAP    - N x 3 RGB colormap. Default: jet(64)
%   P.COLOR       - N x 3 activation colours. Default: standard 6-colour set
%   P.LIGHT       - Light source matrix [az el; ...]. Default: [45 80; -45 80]
%   P.CBAR        - Show colourbar: 1=yes, 0=no. Default: 1
%   P.DIRECTION   - Slice direction: 1=axial, 2=sagittal, 3=coronal. Default: 1
%   P.INTERVAL    - Slice interval (voxels). Default: 4
%   P.TXT         - Figure title string. Default: ''
%   P.ALPHA       - Overlay opacity (slice views). Default: 1
%   P.CROP        - Bounding box [xmin xmax ymin ymax zmin zmax]. Default: [] (full)
%   P.PLANE       - Braincake slice plane: 1=axial, 2=sagittal, 3=coronal. Default: 1
%   P.INTERSLICE  - Braincake gap between slabs. Default: 0
%   P.GREYPAR     - Directional shading strength (0=flat, 1=strong). Default: 0.4
%
% Examples:
%   p = fmri_makevizpar();
%   p.az = 180; p.el = 10; p.maskalpha = 0.1;
%   fmri_show3d(data, p.az, p.el, p.level, p.alphaval, p.color, p.maskalpha)
%
%   % Override at creation time
%   p = fmri_makevizpar('az', 180, 'climits', [0 5]);
%
% See also: fmri_show3d, fmri_showcortex, fmri_braincake, fmri_showslices

p.az         = 40;
p.el         = 15;
p.level      = 0.9;
p.alphaval   = 1;
p.maskalpha  = 0.05;
p.climits    = [];
p.colormap   = jet(64);
p.color      = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
p.light      = [45 80; -45 80];
p.cbar       = 1;
p.direction  = 1;
p.interval   = 4;
p.txt        = '';
p.alpha      = 1;
p.crop       = [];
p.plane      = 1;
p.interslice = 0;

% Apply any override name-value pairs
if mod(length(varargin), 2) ~= 0
    error('fmri_makevizpar:badArgs', 'Arguments must be name-value pairs.');
end
for k = 1:2:length(varargin)
    field = lower(varargin{k});
    if isfield(p, field)
        p.(field) = varargin{k+1};
    else
        warning('fmri_makevizpar:unknownField', 'Unknown parameter: %s', field);
    end
end

% --- function-specific default overrides -----------------------------------
% Use: if isfield(p,'show3d'), p = mergefields(p, p.show3d); end
p.show3d.az          = 0;
p.show3d.el          = 0;
p.show3d.maskalpha   = 0.10;
p.show3d.greypar     = 0.4;
p.show3d.specular_exponent    = 0.25;
p.show3d.specular_strength    = 0.75;
p.show3d.specular_reflectance = 1;
p.show3d.diffuse_strength     = 0.75;
p.show3d.ambient_strength     = 0.1;
p.show3d.backface_lighting    = 'reverselit';

p.showcortex.az        = 0;
p.showcortex.el        = 0;
p.showcortex.light     = [45 0; -45 0];
p.showcortex.maskalpha = 0;

p.braincake.az        = -90;
p.braincake.el        = 10;
p.braincake.maskalpha = 0;
p.braincake.light     = [45 80; -45 80];
p.braincake.climits   = [0 1];

p.showplanes.climits  = [];   % auto from data
p.showplanes.coord = [];   % default: peak voxel



p.showslices.climits   = [-1 1];
p.showslices.direction = 1;
p.showslices.interval = 2;   % maps to interval in fmri_showslices
p.showselectslices.climits = [0 1];
