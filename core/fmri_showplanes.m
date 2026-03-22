function fmri_showplanes(data, coord, clim, cbar, colorMap, maskalpha)
% FMRI_SHOWPLANES  Three-plane (sagittal/coronal/axial) slice view with crosshair.
%
% Renders the three orthogonal slices passing through a given voxel
% coordinate: sagittal (YZ), coronal (XZ), and axial (XY). A crosshair
% marks the intersection point in all three planes. The three panels are
% displayed as a single composite RGB figure.
%
% Usage:
%   fmri_showplanes(data, coord)
%   fmri_showplanes(data, coord, climits, cbar, colorMap, maskalpha)
%
% Inputs:
%   DATA      - Continuous brain map, vectorized (228453 x 1).
%   COORD     - Voxel subscripts [x y z] of the crosshair centre.
%               Convert from MNI: coord = fmri_mni2sub([x y z]).
%   CLIM.     - Colour axis limits [min max]. Default: [min max] of DATA.
%   CBAR      - Show colourbar (1) or not (0). Default: 1.
%   COLORMAP  - (N x 3) colormap matrix. Default: jet.
%   MASKALPHA - Opacity of out-of-brain regions. Default: 0.
%
% Examples:
%   fmri_showplanes(z_map, fmri_mni2sub([20 -58 18]))
%   fmri_showplanes(r_map, [46 64 37], [0.2 0.8])
%   fmri_showplanes(data)              % peak voxel, all defaults
%   fmri_showplanes(data, coord)       % specified coord, all defaults
%   fmri_showplanes(data, p)           % peak voxel, struct params (coord from p.showplanes.coord)
%
% See also: fmri_showslices, fmri_showcortex, fmri_mni2sub

if ndims(data)>2 data=fmri_vol2vect(data); end
if size(data,2)>1 disp('Data contains several scans, showing 1st scan only.'); data=data(:,1); end

% Accept fmri_makevizpar struct as second argument
p_struct = nargin >= 2 && isstruct(coord);
if p_struct
    p = coord;
    if isfield(p,'showplanes'), f=fieldnames(p.showplanes); for k=1:length(f), p.(f{k})=p.showplanes.(f{k}); end; end
    if isfield(p,'coord'),     coord     = p.coord;     end
    if isfield(p,'climits'),   clim      = p.climits;   end
    if isfield(p,'cbar'),      cbar      = p.cbar;      end
    if isfield(p,'colormap'),  colorMap  = p.colormap;  end
    if isfield(p,'maskalpha'), maskalpha = p.maskalpha; end
end

if ~p_struct && (nargin<6 || isempty(maskalpha)) maskalpha=0; end
if ~p_struct && (nargin<5 || isempty(colorMap))  colorMap=[];  end
if ~p_struct && (nargin<4 || isempty(cbar))      cbar=0;       end
if ~p_struct && (nargin<3 || isempty(clim))      clim=[min(data) max(data)]; end
if ~p_struct && (nargin<2 || isempty(coord))     [~,coord] = max(data); end
if isempty(coord), [~, coord] = max(data); end   % when p passed with no coord set

if length(unique(data))==2
    data=data*1.001; % some rounding error issue
end

if length(coord)==1
    coord=fmri_ind2sub(coord);
end

%jetmap=interp1(1:64,jet,linspace(32,64,64)); colormap(jetmap)
jetmap=interp1(1:64, jet(64), linspace(32,64,64), 'linear', 'extrap'); colormap(jetmap)
data(find(data>clim(2)))=clim(2);
actmask=data>=clim(1);
volactmask=fmri_vect2vol(actmask);
data(actmask)=floor(63*(data(actmask)-clim(1))/(clim(2)-clim(1)))+1;
datacol=zeros(size(data,1),3);
datacol(actmask,:)=jetmap(data(actmask),:);

vol=fmri_vect2vol(data);
volcol=fmri_vect2vol(datacol);

load graybrain
mask=gb(:,:,:,1)>.5;
gb=gb.^3;

cl = [0 1 0]; %line color
c = [1 0 0]; % activation color

d=vol.*(mask>0);
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
for k=1:3
    ddd(coord(1),coord(2),6:86,k)=cl(k);
    ddd(6:86,coord(2),coord(3),k)=cl(k);
    ddd(coord(1),6:104,coord(3),k)=cl(k);
end

if cbar xsize=330; else xsize=309; end

% sagittal view
[y,z]=meshgrid(linspace(1,109,325),linspace(1,91,271));
tmp=zeros(271,325,3);
subplot('position',[0 0 109/xsize 1])
tmp2=squeeze(ddd(coord(1),:,end:-1:1,:));
for k=1:3
    tmp(:,:,k)=interp2(squeeze(tmp2(:,:,k))',y,z);
end
image(tmp)
text(5,10,['x = ' num2str(coord(1))],'color',[.95 .95 .95],'fontsize',32)
axis off

% coronal view
[x,z]=meshgrid(linspace(1,91,271),linspace(1,91,271));
subplot('position',[109/xsize 0 91/xsize 1]),
tmp2=(squeeze(ddd(:,coord(2),:,:)));
for k=1:3
    tmp3(:,:,k)=interp2(squeeze(tmp2(:,91:-1:1,k))',x,z);
end
image(tmp3)
text(5,10,['y = ' num2str(coord(2))],'color',[.95 .95 .95],'fontsize',32)
axis off

% axial view
[x,y]=meshgrid(linspace(1,109,271),linspace(1,91,325));
subplot('position',[200/xsize 0 109/xsize 1]),
tmp4 = squeeze(ddd(:,:,coord(3),:));
for k=1:3
    tmp5(:,:,k)=interp2(squeeze(tmp4(:,:,k)),x,y);
end
image(tmp5)
text(5,10,['z = ' num2str(coord(3))],'color',[.95 .95 .95],'fontsize',32)
axis off

% set figure proportions
pos=get(gcf,'Position'); pos(3)= 291/91*pos(4);
set(gcf,'Position',pos);
pos=get(gcf,'PaperPosition'); pos(3)= 291/91*pos(4);
set(gcf,'PaperPosition',pos);

if cbar
   h=colorbar('position',[.95 .1 .02 .8])
   l=get(h,'ylim');
   set(h,'ytick',[l(1) l(2)]);
   set(h,'yticklabel',[clim(1) clim(2)],'fontsize',16);
end
