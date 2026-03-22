function frames = fmri_brainvideo(data, filename, varargin)
% FMRI_BRAINVIDEO  Creates a rotating 3D brain video from a brain map.
%
% Renders a 360-degree rotation of a brain map using fmri_show3d, capturing
% each frame. Optionally writes to an MP4 file. Supports multiple rotation
% trajectories.
%
% Usage:
%   frames = fmri_brainvideo(data)
%   frames = fmri_brainvideo(data, filename)
%   frames = fmri_brainvideo(data, filename, 'param', value, ...)
%
% Optional name-value parameters:
%   'nframes'    - Number of frames in a full rotation. More frames = smoother
%                  rotation. Default: 72 (5° per frame at default fps, ~3 s video)
%   'fps'        - Frames per second for output video. Default: 25.
%   'el'         - Elevation angle(s). Scalar, vector, or empty (gentle dip ~30°). Default: [].
%   'climits'    - Colour axis limits [min max]. Default: [] (auto-scale).
%   'maskalpha'  - Brain shell transparency. Default: 0.05.
%   'color'      - N x 3 RGB activation colour. Default: [1 0.2 0.2] (red).
%   'level'      - Isosurface threshold. Default: 0.9.
%   'trajectory' - Rotation style: 'cinematic' (default), 'linear', 'reverse', 'flat'.
%                  Options:
%                  'cinematic' (default) – Smooth ease-in/ease-out azimuth
%                                 with gentle elevation dip (~30°).
%                  'linear'    - Constant-speed 360° azimuth rotation. 
%                                 Elevation follows the default gentle sinusoidal dip 
%                                 unless overridden with 'el'.
%                  'reverse'    – Linear rotation clockwise (opposite direction).
%                  'flat'       – Uniform 360° rotation at constant elevation
%                                 (default 0° if 'el' not set).
%
% 
% Example runs:
%
%   Cinematic rotation (default)
%       fmri_brainvideo(data, 'brain.mp4', 'nframes', 300)
%
%   Constant elevation but linear speed:
%       fmri_brainvideo(data, 'brain.mp4', 'trajectory', 'linear', 'el', 30)
%
%   Reverse rotation (clockwise)
%       fmri_brainvideo(data, 'brain.mp4', 'trajectory', 'reverse')
%
%   Flat rotation (zero elevation)
%       fmri_brainvideo(data, 'brain.mp4', 'trajectory', 'flat')
%
% Notes:
%   - 'el' may be a scalar (constant) or vector of length NFRAMES.
%     (per frame, interpolated across nframes if length differs).
%   - Total video duration = nframes / fps seconds.
%   - nframes controls smoothness; fps controls playback speed.
%
%
% --- parse optional parameters ---
p.nframes    = 72;
p.fps        = 25;
p.el         = [];
p.climits    = [];
p.maskalpha  = 0.05;
p.color      = [1 0.2 0.2];
p.level      = 0.9;
p.trajectory = 'cinematic';

for k = 1:2:length(varargin)
    field = lower(varargin{k});
    if isfield(p, field)
        p.(field) = varargin{k+1};
    else
        warning('fmri_brainvideo:unknownParam', 'Unknown parameter: %s', field);
    end
end

if nargin < 2, filename = ''; end

% --- rotation trajectory ---
nf = p.nframes;
t  = linspace(0,1,nf);

switch lower(p.trajectory)
    
    case 'cinematic'   % smooth cinematic rotation (ease-in / ease-out)
        t_eased = interp1([0 0.1 0.4 0.6 0.9 1], 
                          [0 0.065 0.475 0.525 0.935 1], ...
                          t, 'spline');
        az = 90 + 360*t_eased;

    case 'linear'      % constant speed
        az = linspace(90, 90+360, nf);

    case 'reverse'     % constant speed, opposite direction
        az = linspace(90, 90-360, nf);

    case 'flat'        % constant speed + flat elevation
        az = linspace(90, 90+360, nf);
        if isempty(p.el)
            el = zeros(1,nf);
        end

    otherwise
        error('Unknown trajectory type: %s', p.trajectory);
end

% --- elevation (unless already defined by 'flat') ---
if ~exist('el','var')
    if isempty(p.el)
        % gentle elevation dip
        el = 30*sin(linspace(0,pi,nf));
    elseif isscalar(p.el)
        el = p.el*ones(1,nf);
    else
        el = interp1(linspace(0,1,length(p.el)), p.el, t, 'linear');
    end
end


% --- render frames ---
frames = cell(1, nf);
hfig   = figure('Visible', 'on', 'Color', 'k');
opengl hardware
set(hfig,'Renderer','opengl')

for k = 1:nf
    clf(hfig);
    fmri_show3d(data, az(k), el(k), p.level, 1, p.color, p.maskalpha);
    axis vis3d   % <<< prevents camera rescaling jitter
    set(gca,'Projection','perspective')
    % camlight headlight
    if ~isempty(p.climits)
        caxis(p.climits);
    end
    drawnow;
    frames{k} = getframe(hfig);
end

close(hfig);

% --- write MP4 video if filename given ---
if ~isempty(filename)
    if isstring(filename)
        filename = char(filename);  % convert string to char
    end
    [~,~,ext] = fileparts(filename);
    if ~strcmpi(ext, '.mp4')
        filename = [filename '.mp4'];
    end
    v = VideoWriter(filename, 'MPEG-4');
    v.FrameRate = p.fps;
    open(v);
    for k = 1:nf
        writeVideo(v, frames{k});
    end
    close(v);
    fprintf('Video written to: %s\n', filename);
end
end