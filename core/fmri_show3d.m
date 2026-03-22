function fmri_show3d(data, az, el, level, alphaval, color, maskalpha, crop)
% FMRI_SHOW3D  3D isosurface rendering of brain activation.
%
% Renders one or more activation datasets as coloured isosurfaces on a
% transparent brain shell. Suitable for presenting whole-brain spatial
% distributions of activations, networks, or ROIs.
%
% Usage:
%   fmri_show3d(data)
%   fmri_show3d(data, az, el, level, alphaval, color, maskalpha, crop)
%
% Inputs:
%   DATA      - fMRI data, vectorized (228453 x N) or volume (91x109x91xN).
%               Each column N is rendered in a separate colour.
%   AZ        - Azimuth angle for view in degrees. Default: 40.
%   EL        - Elevation angle for view in degrees. Default: 15.
%   LEVEL     - Isosurface threshold (fraction of max). Default: 0.9.
%   ALPHAVAL  - Opacity of activation surface (0=transparent, 1=opaque). Default: 1.
%   COLOR     - (N x 3) RGB matrix: one colour per data column.
%               Default: [1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1].
%   MASKALPHA - Opacity of the background brain shell. Default: 0.05.
%   CROP      - Bounding box [xmin xmax ymin ymax zmin zmax] to restrict
%               rendering to a sub-volume. Default: full brain.
%
% Examples:
%   fmri_show3d(activation_map)
%   fmri_show3d(net1, 180, 10, 0.5, 0.8, [1 0 0], 0.1)
%   fmri_show3d([net1 net2 net3], 40, 15, 0.9, 1, [1 0 0; 0 1 0; 0 0 1])
%
% See also: fmri_show3dba, fmri_showcortex, fmri_showslices, fmri_braincake

if ndims(data)<3, data = fmri_vect2vol(data); end

% Accept fmri_makevizpar struct as second argument
p_struct = nargin >= 2 && isstruct(az);
if p_struct
    p = az; 
    if isfield(p,'show3d'), f=fieldnames(p.show3d); for k=1:length(f), p.(f{k})=p.show3d.(f{k}); end; end
    if isfield(p,'az'),        az        = p.az;            end
    if isfield(p,'el'),        el        = p.el;            end
    if isfield(p,'level'),     level     = p.level;         end
    if isfield(p,'alphaval'),  alphaval  = p.alphaval;      end
    if isfield(p,'color'),     color     = p.color;         end
    if isfield(p,'maskalpha'), maskalpha = p.maskalpha;     end
    if isfield(p,'crop'),      crop      = p.crop;          end
    if isfield(p,'greypar'),   greypar   = p.greypar;       end
    az = p.az; el = p.el;   % ensure az/el are set for view() call below
end
if ~p_struct && (nargin<9 || isempty(greypar)) greypar=.4; end
if ~p_struct && (nargin<8 || isempty(crop)) crop=[1 91 1 109 1 91]; end
if ~p_struct && (nargin<7 || isempty(maskalpha)) maskalpha=.10; end
if ~p_struct && (nargin<6 || isempty(color)) color=[1 0 0;0 1 0;0 0 1;1 1 0;1 0 1; 0 1 1; 0 0 0; 1 1 1]; end
% if ~p_struct && (nargin<5 || isempty(alphaval)) alphaval = ones(size(data,4),1); end %
if ~p_struct && (nargin<5 || isempty(alphaval)) alphaval = 1; end % ibi edited
if ~p_struct && (nargin<4 || isempty(level)) level=0.9; end
if ~p_struct && (nargin<3 || isempty(el)) el=0; end
if ~p_struct && (nargin<2 || isempty(az)) az=0; end
    
if size(data,2)>1 && length(alphaval)==1
    alphaval=repmat(alphaval,size(data,2),1);
end


load standard_brain_NZ

if length(crop)==6
    cropmask=zeros(91,109,91);
    cropmask(crop(1):crop(2),crop(3):crop(4),crop(5):crop(6)) = 1;
    mask2=double(A).*cropmask;
else
    mask2=double(A).*fmri_vect2vol(crop);
end


[x,y,z]=ndgrid(1:91,1:109,1:91);

% for k=1:size(data,4)
%     data(:,:,:,k) = double(data(:,:,:,k)).*mask2;
% end
if size(data,4) > 0
    data = bsxfun(@times, data, mask2);
end

data=data(end:-1:1,:,:,:);
%mask2=mask2(end:-1:1,:,:,:);
mask2=mask2(end:-1:1,:,:);

tmp=max(max(A,[],3),[],2);
miny=min(find(tmp>0));
maxy=max(find(tmp>0));

% plot transparent head surface to initialize axes
clf
p=patch(isosurface(A,5500));  % default=5500
isonormals(A,p)
%set(p,'facecolor','w','edgecolor','none');
set(p,'facecolor',[.5 .5 .5],'edgecolor','none');
daspect([1 1.1 1]);
alpha(p,0) % transparent
axis vis3d
axis off
view(0,0);
axis manual % freeze axis

% actual plotting starts here
% plot head surface
    lev=5500;
    p=patch(isosurface(mask2,lev));
    isonormals(mask2,p)
    set(p,'facecolor',[.5 .5 .5],'edgecolor','none');
    %set(p,'FaceAlpha',0.10); % specified by the user
    set(p,'SpecularExponent',0.25);     % .25
    set(p,'SpecularStrength',0.75);     %.75
    set(p,'SpecularColorReflectance',1); %1
    set(p,'DiffuseStrength',0.75);   %.25
    set(p,'AmbientStrength',0.1); %.1
    set(p,'BackFaceLighting','reverselit'); % unlit  % reverselit
    px=get(p,'YData');
    minpx=min(px(1,:)); maxpx=max(px(1,:));
    alpha(p,maskalpha)
    %material metal  % tqke off maybe
    axis off

% plot activation
hold on
for m=1:size(data,4)
    q=patch(isosurface(data(:,:,:,m),level));
    qx=get(q,'XData'); qx=qx-46;
    qy=get(q,'YData'); qy=qy-55;
    qz=get(q,'ZData'); qz=qz-46;
    if size(qx,1)>0
        qq=[qx(1,:)' qy(1,:)' qz(1,:)'];
        
        s1 = sin(pi*el/180); % or -sin(el)
        c1 = cos(pi*el/180);
        s3 = sin(pi*az/180); % or -sin(az)
        c3 = cos(pi*az/180);
        
        R1 = [1 0 0; 0 c1 s1; 0 -s1 c1];
        R3 = [c3 -s3 0; s3 c3 0; 0 0 1];
        
        qqq=qq*R3*R1;
        w=-qqq(:,2);
        w=w/30;
        w=greypar*w+(1-greypar);
        w=max(w,-1);w=min(w,1);
        w=repmat(w,1,3);
        cm1=repmat(color(m,:),size(w,1),1);
        cm2=repmat([1 1 1],size(w,1),1);
        colmat=w.^2.*cm1 + (1-w.^2).*cm2;
        set(q,'FaceVertexCData',colmat, 'FaceColor','flat');
        isonormals(data(:,:,:,m),q)
        set(q,'edgecolor','none');
        alpha(q,alphaval(m));
    end
end
set(gcf,'Color','w');
hold off

camlight(az+45,el+30);
%camlight(az-45,el);


lighting phong;
view(az,el);

set(gcf,'paperunits','inches')
set(gcf, 'PaperPosition',[0 0 12 8])  % figure on printed page
%set(gcf, 'PaperPosition',[0.1 0.1 .8 .8])  % figure on printed page
%set(gca, 'position', [0 0 1 1])
set(gca, 'position', [0.1 0.1 0.8 0.8]) % Adjust the values as needed
set(gca, 'CameraViewAngle', [7.19636])
