function fmri_showselectslices(data, slices, clim, txt, alpha, cbar)
% FMRI_SHOWSELECTSLICES  Displays continuous data on a user-specified set of slices.
%
% Renders a continuous brain map on a manually chosen set of axial slice
% positions. Useful for targeting specific anatomical levels in a figure
% rather than displaying a uniform mosaic.
%
% Usage:
%   fmri_showselectslices(data, slices)
%   fmri_showselectslices(data, slices, clim, txt, alpha, cbar)
%
% Inputs:
%   DATA    - Continuous brain map, vectorized (228453 x 1).
%   SLICES  - Vector of axial slice indices to display (e.g. [20 35 50 65]).
%   CLIM    - Colour axis limits [min max]. Default: auto.
%   TXT     - Title string. Default: ''.
%   ALPHA   - Overlay opacity (0-1). Default: 1.
%   CBAR    - Show colourbar: 1=yes, 0=no. Default: 1.
%
% Examples:
%   fmri_showselectslices(z_map, [20 35 50 65])
%   fmri_showselectslices(r_map, [30 45 60], [0.2 0.7], 'Correlation')
%
% See also: fmri_showslices, fmri_showselectslices_int, fmri_showplanes

VERT_PRINT_SIZE = 4;

if ndims(data)>2 data=fmri_vol2vect(data); end
% Accept fmri_makevizpar struct as third argument
p_struct = nargin >= 3 && isstruct(clim);
if p_struct
    p = clim; clim = [];
    if isfield(p,'showselectslices'), f=fieldnames(p.showselectslices); for k=1:length(f), p.(f{k})=p.showselectslices.(f{k}); end; end
    if isfield(p,'climits'),  clim  = p.climits;  end
    if isfield(p,'txt'),      txt   = p.txt;      end
    if isfield(p,'alpha'),    alpha = p.alpha;    end
    if isfield(p,'cbar'),     cbar  = p.cbar;     end
end
if size(data,2)>1 disp('Data contains several scans, showing 1st scan only.'); data=data(:,1); end
if ~p_struct && (nargin<6 || isempty(cbar)) cbar=0; end
if ~p_struct && (nargin<5 || isempty(alpha)) alpha=1; end
if ~p_struct && (nargin<4 || isempty(txt)) txt=0; end
if ~p_struct && (nargin<3 || isempty(clim)) clim=[0 1]; end

N=length(slices);
[x,y]=meshgrid(linspace(1,109,325),linspace(1,91,271));

jetmap=interp1(1:64,jet,linspace(32,64,64)); colormap(jetmap)
data(find(data>clim(2)))=clim(2);
actmask=data>=clim(1);
volactmask=fmri_vect2vol(actmask);
data(actmask)=floor(63*(data(actmask)-clim(1))/(clim(2)-clim(1)))+1;
datacol=zeros(size(data,1),3);
datacol(actmask,:)=jetmap(data(actmask),:);

vol=fmri_vect2vol(data);
volcol=fmri_vect2vol(datacol);

data=fmri_vect2vol(data);

% set figure dimensions
clf
pos=get(gcf,'Position'); pos(3)=1000; pos(4)= 1.1*round(325*(pos(3)/((N+1)*271)));
set(gcf,'Position',pos);
pos=get(gcf,'PaperPosition'); pos(4)=VERT_PRINT_SIZE; pos(3)= 1.0*round(271*pos(4)*(N+1)/325);
set(gcf,'PaperPosition',pos);

load graybrain
mask=gb(:,:,:,1)>.5;
gb=gb.^3;

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

% plot horizontal slices
% slices_no=length(slices);

if ~cbar spwidth = (N*271+390); else spwidth=1.1*(N*271+390); end

for k=1:N
    subplot('position',[390/spwidth+271*(k-1)/spwidth 0 271/spwidth 1])
    tmp2=squeeze(ddd(:,end:-1:1,slices(k),:));
%    tmp2=squeeze(ddd(:,:,slices(k),:));
    for m=1:3
        tmp3(:,:,m)=interp2(tmp2(:,:,m),x,y);
    end
    for m=1:3
        sl(:,:,m)=tmp3(:,:,m)';
    end
    image(sl);axis off
    if txt
        text(100,310,['z=' num2str(slices(k))],'color','w','fontsize',12)
    end
end


% plot vertical slice with lines indicating the locations of horizontal
% slices
subplot('position',[271*0/spwidth 0 390/spwidth 1])
tmp2=squeeze(gb(45,:,end:-1:1,:));

for m=1:3
    tmp5(:,:,m)=interp2(tmp2(:,:,m),y',x');
end
tmp=zeros(271,325,3);
for k=1:3
    tmp(:,:,k)=squeeze(tmp5(:,:,k)');
end
col=[.5 1 .5];
tmp(271-3*slices+3,:,1)=col(1);
tmp(271-3*slices+3,:,2)=col(2);
tmp(271-3*slices+3,:,3)=col(3);

tmp=max(tmp,0); tmp=min(tmp,1);
image(tmp),axis off
% if txt
%     for k=1:N
%         text(10,271-3*slices(k)-10,['z=' num2str(slices(k))],'color','w','fontsize',20)
%     end
% end

if cbar
   h=colorbar('position',[.93 .1 .02 .8]);
   l=get(h,'ylim');
   set(h,'ytick',[l(1) l(2)]);
   set(h,'yticklabel',[clim(1) clim(2)],'fontsize',16);
end
