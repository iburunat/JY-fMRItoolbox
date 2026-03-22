function newdata = fmri_tempsmooth(data, var)
% FMRI_TEMPSMOOTH  Temporal Gaussian smoothing of fMRI time series.
%
% Convolves each voxel time series with a Gaussian kernel, suppressing
% high-frequency noise while preserving low-frequency BOLD signal. Useful
% as a preprocessing step before GLM analyses with slow HRFs.
%
% Usage:
%   newdata = fmri_tempsmooth(data)
%   newdata = fmri_tempsmooth(data, sigma)
%
% Inputs:
%   DATA   - fMRI time series, vectorized (228453 x T) or
%            volume (91 x 109 x 91 x T).
%   SIGMA  - Standard deviation of the Gaussian kernel in scans (not seconds).
%            Default: 5 scans. For TR-specific smoothing: sigma = FWHM/(2.355*TR).
%
% Outputs:
%   NEWDATA  - Temporally smoothed data, same format as DATA.
%
% Examples:
%   data = fmri_tempsmooth(data);        % default sigma=5
%   data = fmri_tempsmooth(data, 3);     % lighter smoothing
%
% Notes:
%   For frequency-domain bandpass filtering use fmri_bandpassfilter instead.
%   The kernel is zero-padded at the edges (boundary effects possible for
%   first and last ~sigma scans).
%
% See also: fmri_bandpassfilter, fmri_detrend

if nargin < 2,
    var=5;    
end
mu = 0;
time_points=-32:2:32;

if length(size(data))==4
    ds=size(data);
    data=reshape(data,ds(1)*ds(2)*ds(3),ds(4));
end

s=size(data);
newdata=zeros(s);
N=s(2);

h = waitbar(0,'Please wait - Smoothing.........');

for x=1:s(1)
    waitbar(x/s(1),h)
        tmp=double(data(x,:));
        gauss_kernel=normpdf(time_points,mu,var);
        smoothed_curve=conv(tmp,gauss_kernel);
        newdata(x,:)=(smoothed_curve(17:end-16));
        clear tmp
end

close(h)



