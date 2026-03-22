function newdata = fmri_detrend(data, no_of_anchor_points)
% FMRI_DETREND  Removes low-frequency drift from fMRI data using spline fitting.
%
% Fits a cubic spline to a set of equally-spaced anchor points along the
% temporal dimension and subtracts it from the data. This removes slow
% drifts (scanner drift, respiratory, movement artefacts) while preserving
% higher-frequency BOLD signal. Operates voxelwise.
%
% Usage:
%   newdata = fmri_detrend(data)
%   newdata = fmri_detrend(data, no_of_anchor_points)
%
% Inputs:
%   DATA                - fMRI time series, vectorized (228453 x T) or
%                         volume (91 x 109 x 91 x T).
%   NO_OF_ANCHOR_POINTS - Number of spline knots. More knots = more
%                         aggressive detrending. Default: 6.
%
% Outputs:
%   NEWDATA  - Detrended data in the same format as DATA.
%
% Examples:
%   data = fmri_detrend(data);          % default 6 knots
%   data = fmri_detrend(data, 4);       % gentler detrending
%   data = fmri_detrend(data, 10);      % more aggressive
%
% Notes:
%   For high-pass filtering in the frequency domain, see fmri_bandpassfilter.
%
% See also: fmri_tempsmooth, fmri_bandpassfilter, fmri_zscorevoldata

if nargin < 2,
    no_of_anchor_points=6;
end

if ndims(data)>2 data = fmri_vol2vect(data); end
    
s=size(data);
newdata=zeros(s);
N=s(2);

len=floor(N/no_of_anchor_points);
len2=no_of_anchor_points*len;
%xx=floor(len/2):len:len2;
xx=linspace(1,N,no_of_anchor_points);
xxx=1:N;
ind=interp1(xx,1:no_of_anchor_points,xxx,'nearest');

h = waitbar(0,'Please wait - Detrending .........');

for x=1:s(1)
    
    waitbar(x/s(1),h)

    tmp=double(data(x,:));
    for k=1:no_of_anchor_points
        y(k)=mean(tmp(ind==k));
    end
    yy=spline(xx,y,xxx);
    df=tmp-yy;
    newdata(x,:)=df-mean(df);
end

close(h)
