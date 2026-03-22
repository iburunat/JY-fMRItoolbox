function fmri_showslices(data, direction, interval, clim, txt, alpha, cbar, colorMap)
% FMRI_SHOWSLICES  Displays continuous brain data as a series of 2D slices.
%
% Renders a continuous-valued brain map as a mosaic of axial, sagittal, or
% coronal slices overlaid on the greyscale brain template. Each slice is
% equally spaced by INTERVAL voxels. Suitable for statistical maps, correlation
% maps, tSNR maps, etc.
%
% Usage:
%   fmri_showslices(data)
%   fmri_showslices(data, direction, interval, clim, txt, alpha, cbar)
%
% Inputs:
%   DATA       - Continuous brain map, vectorized (228453 x 1).
%   DIRECTION  - Slice plane: 1=axial (default), 2=sagittal
%   INTERVAL   - Voxel spacing between displayed slices (1 or 2). Default: 2.
%   CLIM       - Colour axis limits [min max]. Default: auto.
%   TXT        - Title string. Default: '' (no title).
%   ALPHA      - Opacity of the overlay (0=transparent, 1=opaque). Default: 1.
%   CBAR (optional) = colorbar flag (default = 0 (no colorbar))
%
% Examples:
%   fmri_showslices(r_map)
%   fmri_showslices(z_map, 1, 2, [2 6])
%   fmri_showslices(tsnr, 1, 3, [0 100], hot)
%   D = fmri_voxdist(ind1, 1:228453);   % 1 x 228453
%   fmri_showslices(D',  1, 2, [0 128],1)           % default diverging
%   fmri_showslices(D',  1, 2, [0 128],1,[],[], 'hot')   % named colormap
%   fmri_showslices(D',  1, 2, [0 128],1,[],[], 'winter')
%   fmri_showslices(D',  1, 2, [0 128],1,[],1, [0 0 0.8; 0.7 0.5 1; 1 1 1; 0.4 1 0.4; 1 0 0]) % custom Nx3 matrix
%  2 colors: simple black to white
% fmri_showslices(D, 1, 2, [-128 128], 1, [], [], [0 0 0; 1 1 1])
% % 3 colors: classic diverging
% fmri_showslices(D, 1, 2, [0 128], 1, [], [], [0 0 0.8; 0.7 0.7 0.7; 1 0 0])
% % 5 colors: multi-transition
% fmri_showslices(D, 1, 2, [0 128], 1, [], [], [0 0 0.8; 0.7 0.5 1; 1 1 1; 0.4 1 0.4; 1 0 0])
% % 7 colors: rainbow-like
% fmri_showslices(D, 1, 2, [0 128], 1, [], [], [0 0 1; 0 0.5 1; 0 1 1; 0 1 0; 1 1 0; 1 0.5 0; 1 0 0])
% % black to red (heat)
% fmri_showslices(D, 1, 2, [0 128], 1, [], [], [0 0 0; 1 0 0])
% % black to yellow (like 'hot')
% fmri_showslices(D, 1, 2, [0 128], 1, [], [], [0 0 0; 1 0 0; 1 1 0])

% % or just use a named MATLAB colormap
% fmri_showslices(D, 1, 2, [0 128], 1, [], [1], 'turbo')
% fmri_showslices(D, 1, 2, [0 128], 1, [], [1], 'hsv')
% fmri_showslices(D, 1, 2, [0 128], 1, [], [], 'hot')
% fmri_showslices(D, 1, 2, [0 128], 1, [], [], 'winter')
% fmri_showslices(D, 1, 2, [0 128], 1, [], [], 'parula')
% See also: fmri_showslices_int, fmri_showselectslices, fmri_showplanes

if ndims(data)>2 data=fmri_vol2vect(data); end
if size(data,2)>1 disp('Data contains several scans, showing 1st scan only.'); data=data(:,1); end

% Accept fmri_makevizpar struct as second argument
p_struct = nargin >= 2 && isstruct(direction);
if p_struct
    p = direction; direction = [];
    if isfield(p,'showslices'), f=fieldnames(p.showslices); for k=1:length(f), p.(f{k})=p.showslices.(f{k}); end; end
    if isfield(p,'direction'),  direction = p.direction;  end
    if isfield(p,'interval'),   interval  = p.interval;       end
    if isfield(p,'climits'),    clim      = p.climits;    end
    if isfield(p,'txt'),        txt       = p.txt;        end
    if isfield(p,'alpha'),      alpha     = p.alpha;      end
    if isfield(p,'cbar'),       cbar      = p.cbar;       end
    if isfield(p,'colormap'),   colorMap  = p.colormap;   end
end

if ~p_struct && (nargin<7 || isempty(cbar)) cbar=0; end
if ~p_struct && (nargin<6 || isempty(alpha)) alpha=1; end
if ~p_struct && (nargin<5 || isempty(txt)) txt=0; end
if ~p_struct && (nargin<4 || isempty(clim)) clim=[-1 1]; end
if ~p_struct && (nargin<3 || isempty(interval)) interval=2; end
if ~p_struct && (nargin<2 || isempty(direction)) direction=1; end
if ~p_struct && (nargin<8 || isempty(colorMap)) colorMap = []; end

    % build jetmap from colorMap (always runs)
if isempty(colorMap)
    % default: diverging blue-gray-red
    n          = 64;
    half       = floor(n/2);
    startColor = [0 0 0.8];
    midColor   = [0.7 0.7 0.7];
    endColor   = [1 0 0];
    jetmap = [ ...
        linspace(startColor(1), midColor(1), half)' ...
        linspace(startColor(2), midColor(2), half)' ...
        linspace(startColor(3), midColor(3), half)'; ...
        linspace(midColor(1), endColor(1), n-half)' ...
        linspace(midColor(2), endColor(2), n-half)' ...
        linspace(midColor(3), endColor(3), n-half)' ...
    ];
elseif ischar(colorMap)
    jetmap = feval(colorMap, 64);
elseif isnumeric(colorMap)
    n_in   = size(colorMap, 1);
    jetmap = interp1(linspace(0,1,n_in), colorMap, linspace(0,1,64));
end
colormap(jetmap);

% bp=[0 0 1;.8 .8 .8;1 0 0]; bx=[1 32.5 64]; 
% jetmap=interp1(bx,bp,1:64); colormap(jetmap)

% % set diverging color map ------------------------------------------------|
% n = 64;                   % total number of colors
% startColor = [0 0 0.8];     % negative values
% midColor   = [0.7 0.7 0.7]; % zero values
% endColor   = [1 0 0];     % positive values

% half = floor(n/2);
% jetmap = [ ...
%     linspace(startColor(1), midColor(1), half)' linspace(startColor(2),...
%     midColor(2), half)' linspace(startColor(3), midColor(3), half)'; ...
%     linspace(midColor(1), endColor(1), n-half)'   linspace(midColor(2),...
%     endColor(2), n-half)'   linspace(midColor(3), endColor(3), n-half)' ...
% ];

% colormap(jetmap);
% % ------------------------------------------------------------------------|

% % set multi-transition diverging colormap --------------------------------|
% n = 64;  % total number of colors

% % define key colors [0 0 0.8; 0.7 0.5 1; 1 1 1; 0.4 1 0.4; 1 0 0]
% c1 = [0 0 0.8];    % blue
% c2 = [0.7 0.5 1];  % light purple
% c3 = [1 1 1];      % white
% c4 = [0.4 1 0.4];  % light green
% c5 = [1 0 0];      % red

% % number of segments
% segments = 4;
% m = floor(n/segments);

% jetmap = [ ...
%     linspace(c1(1),c2(1),m)' linspace(c1(2),c2(2),m)' linspace(c1(3),c2(3),m)'; ...
%     linspace(c2(1),c3(1),m)' linspace(c2(2),c3(2),m)' linspace(c2(3),c3(3),m)'; ...
%     linspace(c3(1),c4(1),m)' linspace(c3(2),c4(2),m)' linspace(c3(3),c4(3),m)'; ...
%     linspace(c4(1),c5(1),n-3*m)' linspace(c4(2),c5(2),n-3*m)' linspace(c4(3),c5(3),n-3*m)' ...
% ];

% colormap(jetmap);
% % ------------------------------------------------------------------------|


data(find(data>clim(2)))=clim(2);
actmask=data>=clim(1);
%actmask = abs(data) >= clim(1);
volactmask=fmri_vect2vol(actmask);

ncolors = size(jetmap, 1);
data(actmask) = floor((ncolors-1)*(data(actmask) - clim(1))/(clim(2) - clim(1))) + 1;
datacol=zeros(size(data,1),3);
datacol(actmask,:) = jetmap(data(actmask),:);

vol=fmri_vect2vol(data);
volcol=fmri_vect2vol(datacol);

data=fmri_vect2vol(data);

load graybrain
mask=sum(gb,4)>1;
c = [1 0 0]; % color red
d=(data>0).*(mask>0);
dd=zeros(91,109,91,3);
for k=1:3
    dd(:,:,:,k)=d;
end
ddd=zeros(91,109,91,3);

gbl=gb;
for k=1:3
    tmp=squeeze(gbl(:,:,:,k));
    tmpcol=volcol(:,:,:,k);
    tmp(volactmask>0)=alpha*tmpcol((volactmask>0))+(1-alpha)*tmp((volactmask>0));
    ddd(:,:,:,k) = tmp;
end

if ~cbar & interval==1 spsize=[9 8 9 8]; end
if ~cbar & interval==2 spsize=[6 6 6 6]; end
if cbar & interval==1 spsize=[10 8 10 8]; end
if cbar & interval==2 spsize=[6.7 6 6.7 6]; end
        
if direction==1
    if interval==1
        for k=1:72
            x=mod(k-1,9); y=floor((k-1)/9);
            subplot('position',[x/spsize(1) y/spsize(2) 1/spsize(3) 1/spsize(4)]),
            
            image(squeeze(ddd(:,:,5+k,:)));
            if txt
                text(10,10,num2str(5+k),'color','w')
            end
            axis off
        end
    elseif interval==2
        
        for k=1:36
            x=mod(k-1,6); y=floor((k-1)/6);
            subplot('position',[x/spsize(1) y/spsize(2) 1/spsize(3) 1/spsize(4)]),
            
            image(squeeze(ddd(:,:,6+2*k,:)));
            if txt
                text(10,10,num2str(6+2*k),'color','w')
            end
            axis off
        end
    end
elseif direction==2
    tmp=zeros(91,109,3);
    if interval==1
        for k=1:72
            x=mod(k-1,9); y=floor((k-1)/9);
            subplot('position',[x/spsize(1) y/spsize(2) 1/spsize(3) 1/spsize(4)]),
            tmp2=squeeze(ddd(10+k,:,end:-1:1,:));
            for m=1:3
                tmp(:,:,m)=squeeze(tmp2(:,:,m))';
            end
            image(tmp)
            if txt
                text(10,10,num2str(10+k),'color','w')
            end
            axis off
        end
    elseif interval==2
        for k=1:36
            ind=2*k+9;
            x=mod(k-1,6);
            y=floor((k-1)/6);
            subplot('position',[x/spsize(1) y/spsize(2) 1/spsize(3) 1/spsize(4)]),
            tmp2=squeeze(ddd(ind,:,end:-1:1,:));
            for m=1:3
                tmp(:,:,m)=squeeze(tmp2(:,:,m))';
            end
            image(tmp)
            if txt
                text(10,10,num2str(ind),'color','w')
            end
            axis off
        end
    end
    pos=get(gcf,'Position'); pos(3)= 1.5*pos(4);
    set(gcf,'Position',pos);
    pos=get(gcf,'PaperPosition'); pos(3)= 1.5*pos(4);
    set(gcf,'PaperPosition',pos);
end
if cbar
   h=colorbar('position',[.91 .1 .02 .8]);
   l=get(h,'ylim');
   set(h,'ytick',[l(1) l(2)]);
   set(h,'yticklabel',[clim(1) clim(2)],'fontsize',16);
end