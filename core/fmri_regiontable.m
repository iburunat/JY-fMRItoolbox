function [clust, s, ROI, list, roi, clus] = fmri_regiontable(data_thres, data, clsize, roisize, atlas)
% FMRI_REGIONTABLE  Cluster and ROI table for a thresholded statistical map.
%
% For a binary thresholded brain map, identifies all clusters, labels each
% voxel with its atlas region, and returns a structured summary table. Useful
% for reporting activation results: lists cluster size, peak coordinate, peak
% statistic, MNI location, and atlas region for every cluster.
%
% Usage:
%   [clust, s, ROI, list, roi, clus] = fmri_regiontable(data_thres, data)
%   [clust, s, ROI, list, roi, clus] = fmri_regiontable(data_thres, data, clsize, roisize, atlas)
%
% Inputs:
%   DATA_THRES  - Binary brain map (228453 x 1): 1 = suprathreshold voxel.
%   DATA        - Continuous statistical map (228453 x 1): used for peak values.
%   CLSIZE      - Minimum cluster size in voxels. Default: 0 (all clusters).
%   ROISIZE     - Minimum ROI size in voxels to appear in table. Default: 0.
%   ATLAS       - Atlas number (see atlas list below). Default: 1 (AAL).
%
% Outputs:
%   CLUST  - Struct array: one element per cluster, fields: centroid, n, region.
%   S      - Table of ROI information (printed to command window).
%   ROI    - Cell array: each cell is a (228453 x K) binary matrix of atlas
%            regions within cluster k.
%   LIST   - Cell array: region name strings corresponding to ROI columns.
%   ROI    - Same as ROI but stores voxel indices rather than binary maps.
%   CLUS   - (228453 x nClusters) matrix: column k = binary map of cluster k.
%            Fast plotting: fmri_show3d(clus(:,[1 3]))
%
% Examples:
%   [c, s] = fmri_regiontable(thresh_map, z_map);
%   [c, s] = fmri_regiontable(thresh_map, z_map, 50, 10, 3);
%
% Atlas numbers:
%    1  = AAL / MarsBar (Automated Anatomical Labeling, 116 ROIs, default)
%    2  = Harvard-Oxford Subcortical Structural Atlas (21 ROIs)
%    3  = Harvard-Oxford Cortical Structural Atlas (48 ROIs)
%    4  = Cerebellar Atlas (MNI152, FLIRT affine, 28 ROIs)
%    5  = Cerebellar Atlas (MNI152, FNIRT nonlinear, 28 ROIs)
%    6  = JHU ICBM-DTI-81 White-Matter Labels (48 ROIs)
%    7  = JHU White-Matter Tractography Atlas (20 ROIs)
%    8  = Juelich Histological Atlas (62 ROIs)
%    9  = MNI Structural Atlas (9 ROIs)
%   10  = Oxford-Imanova Striatal Structural Atlas (3 ROIs)
%   11  = Oxford-Imanova Striatal Connectivity Atlas, 3 sub-regions
%   12  = Oxford-Imanova Striatal Connectivity Atlas, 7 sub-regions
%   13  = Oxford Thalamic Connectivity Probability Atlas (25 ROIs)
%   14  = Craddock Parcellation 200 ROI
%   15  = Craddock Parcellation 400 ROI
%   16  = Craddock Parcellation 500 ROI
%   17  = Craddock Parcellation 600 ROI
%   18  = Craddock Parcellation 950 ROI
%   19  = Brodmann Areas (48 regions)
%
% See also: fmri_cleanclusters, fmri_regionnumber, fmri_csthreshold

if sum(data_thres)==0, 
    clust=[]; s=[]; ROI{1}=zeros(228453,1); list{1}=[]; roi=[]; clus=zeros(228453,1);
    return
end

if nargin<5 || isempty(atlas), atlas=1; end  % AAL atlas by default
if nargin<4 || isempty(roisize), roisize=0; end  
if nargin<3, clsize=0; end

if roisize > clsize,
    disp('roisize value must not exceed clsize value')
    disp('roisize changed to match clsize value')
    roisize=clsize;
end

data_thres_vol=fmri_vect2vol(data_thres);
data_vol=fmri_vect2vol(data); 

% Find clusters

[clustvol,num]=spm_bwlabel(data_thres_vol,18);
clustvect=fmri_vol2vect(clustvol);

% Find regions within each cluster; number of voxels within each region;
% coordinates of the voxel with the highest absolute z value within each region

for c=1:max(clustvect)
    subs=find(clustvect==c);
    inds=fmri_ind2sub(subs); % correct PT
    r=fmri_regionnumber(inds,atlas);
    rr=unique(r);
    
    clust(c).centroid = fmri_sub2mni(mean(inds,1));
    clust(c).n=size(inds,1);
    
    clear coord
    for k=1:length(rr)
        ind=find(strcmp(rr(k),r))';
        n(k)=length(ind);
        [tmp subtmp(k)]=max(abs(data(subs(ind))));
        z(k)=data(subs(ind(subtmp(k))));
        coord(k,:)=inds(ind(subtmp(k)),:);
        
        % --------------------------------
        roi{c}{k}=subs(ind);
        % --------------------------------
    end
    [tmp sortind]=sort(coord(:,1));
    
    for s=1:length(sortind)
        roisort{c}{s}=roi{c}{sortind(s)};   
    end
    
    % Convert from indeces to MNI coordinates
    mni=fmri_sub2mni(coord);
    
    for k=1:length(sortind)
        clust(c).region(k).name = rr{sortind(k)};
        clust(c).region(k).n = n(sortind(k));
        clust(c).region(k).coord = mni(sortind(k),:);
        clust(c).region(k).z = z(sortind(k));
        clust(c).region(k).BA = fmri_banumber(coord(sortind(k),:));   %%%% i
    end
   
end

% Print table

% Sort clusters from larger to smaller
for k=1:length(clust)
    nn(k)=clust(k).n;
end
[tmp ind2]=sort(-nn);
clust=clust(ind2);
roisort=roisort(ind2);

% Sort clusters from left to right
for k=1:length(clust)
    x(k)=clust(k).centroid(1);
end

indl=find(x<0);
indr=find(x>=0);

roil=roisort(indl);
roir=roisort(indr);


% 
s=[]; cn=0;
% left
if isempty(indl)
    cl=[];
else
s=[s sprintf('Left hemisphere -------------------------\n\n')];

    for c=1:length(indl)
        if clust(indl(c)).n>=clsize
            cn=cn+1;s=[s sprintf('Cluster #%d: N = %d\n',cn,clust(indl(c)).n)];
            cl(c)=1;
            clear ns
            for k=1:length(clust(indl(c)).region)
                ns(k)=clust(indl(c)).region(k).n;
            end

            % Sort regions within cluster from largest to smallest
            [tmp ind3]=sort(-ns);

            % Remove regions with less than n voxels
            ind4=ind3(abs(tmp)>=roisize);

            clust(indl(c)).region=clust(indl(c)).region(ind4);

            roil{c}=roil{c}(ind4);

            for m=1:length(clust(indl(c)).region)
                        listl{c}{m}=clust(indl(c)).region(m).name;
                s=[s sprintf('%s\t',clust(indl(c)).region(m).name)];
                s=[s sprintf('%d\t',clust(indl(c)).region(m).n)];
                s=[s sprintf('%d\t',clust(indl(c)).region(m).coord(1))];
                s=[s sprintf('%d\t',clust(indl(c)).region(m).coord(2))];
                s=[s sprintf('%d\t',clust(indl(c)).region(m).coord(3))];
                s=[s sprintf('%f\t',clust(indl(c)).region(m).z)];
                s=[s sprintf('%d\n',clust(indl(c)).region(m).BA)];


            end
            s=[s sprintf('\n')];

        elseif clust(indl(c)).n<clsize || isempty(clust(indl(c)).n)
            cl(c)=0;
        end
    end
end

% right
if isempty(indr)
    cr=[];
else
s=[s sprintf('Right hemisphere -------------------------\n\n')];
    for c=1:length(indr)
        if clust(indr(c)).n>=clsize
            cn=cn+1;
            cr(c)=1;
            s=[s sprintf('Cluster #%d: N = %d\n',cn,clust(indr(c)).n)];
            clear ns
            for k=1:length(clust(indr(c)).region)
                ns(k)=clust(indr(c)).region(k).n;
            end

            % Sort regions within cluster from largest to smallest
            [tmp ind3]=sort(-ns);

            % Remove regions with less than n voxels
            ind4=ind3(abs(tmp)>=roisize);

            clust(indr(c)).region=clust(indr(c)).region(ind4);
            roir{c}=roir{c}(ind4);

            for m=1:length(clust(indr(c)).region)
                listr{c}{m}=clust(indr(c)).region(m).name;
                s=[s sprintf('%s\t',clust(indr(c)).region(m).name)];
                s=[s sprintf('%d\t',clust(indr(c)).region(m).n)];
                s=[s sprintf('%d\t',clust(indr(c)).region(m).coord(1))];
                s=[s sprintf('%d\t',clust(indr(c)).region(m).coord(2))];
                s=[s sprintf('%d\t',clust(indr(c)).region(m).coord(3))];
                s=[s sprintf('%f\t',clust(indr(c)).region(m).z)];
                s=[s sprintf('%d\n',clust(indr(c)).region(m).BA)];
            end
            s=[s sprintf('\n')];

        elseif clust(indr(c)).n<clsize || isempty(clust(indl(c)).n)
            cr(c)=0;

        end
    end
end

% % create brain maps for each ROI

clear roi
if isempty(cl)
    roil=[];
else
    d=find(cl);
    roil=roil(d); clear d
end
if isempty(cr)
    roir=[];
else
    d=find(cr);
    roir=roir(d);
end

roi=[roil roir];


if isempty(roi)
	ROI{1}=zeros(228453,1);
    list{1}=[];
    clus=zeros(228453,1);
else

% allocate
    for q=1:length(roi)
        ROI{q}=zeros(228453,length(roi{q}));
    end


    % create maps
    for c=1:length(ROI)
        for k=1:length(roi{c})
            map=zeros(228453,1);
            map(roi{c}{k})=1;
            ROI{c}(:,k)=map; clear map;
        end
    end


    % create brain maps for each cluster
    % preallocate
    clus=zeros(228453,length(ROI));

    for c=1:length(roi)
        r=[];
        for k=1:length(roi{c})
            r=[r; roi{c}{k}];
        end
        clus(r,c)=1;
    end

    if exist('listl') & exist('listr')
        list=[listl listr];
    elseif ~exist('listr') & exist('listl')
        list=listl;
    elseif ~exist('listl') & ~exist('listr')
        list=listr;
    else
        list=[];
    end
end
end
