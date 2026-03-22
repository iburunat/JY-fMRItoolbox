function df = fmri_effdf(ts1, ts2)
% FMRI_EFFDF  Estimates effective degrees of freedom for correlated time series.
%
% Estimates the effective degrees of freedom (df) for the correlation
% between two time series, accounting for temporal autocorrelation in both
% signals. Temporal autocorrelation inflates Type I error when using the
% nominal df (N-2); this function provides a corrected value suitable for
% significance testing via fmri_rtop.
%
% The effective df is computed using the formula:
%
%   1/df_eff = 1/N + (2/N) * sum_{k=1}^{N/4} ((N-k)/N) * AC1(k) * AC2(k)
%
% where AC1 and AC2 are the normalised autocorrelation functions of ts1 and
% ts2 respectively, evaluated up to lag N/4.
%
% Usage:
%   df = fmri_effdf(ts1, ts2)
%
% Inputs:
%   TS1, TS2  - Time series vectors (N x 1) or (1 x N). Must be the same length.
%
% Outputs:
%   DF  - Effective degrees of freedom (scalar). Will be <= N-2.
%
% Examples:
%   % Compute effective df before testing a correlation
%   r   = corr(ts1, ts2);
%   df  = fmri_effdf(ts1, ts2);
%   p   = fmri_rtop(r, df);
%
% References:
%   Pyper, B.J. & Peterman, R.M. (1998). Comparison of methods to account
%   for autocorrelation in correlation analyses of fish data. Canadian
%   Journal of Fisheries and Aquatic Sciences, 55(9), 2127-2140.
%
% See also: fmri_rtop, fmri_corregressor

ts1 = ts1(:) - mean(ts1(:));
ts2 = ts2(:) - mean(ts2(:));
N   = length(ts1);

if length(ts2) ~= N
    error('fmri_effdf:sizeMismatch', 'TS1 and TS2 must have the same length.');
end

% Normalised autocorrelation, lags 0 to N/4
ac1 = xcorr(ts1, 'normalized');
ac1 = ac1(ceil(end/2) : ceil(end/2) + floor(N/4));

ac2 = xcorr(ts2, 'normalized');
ac2 = ac2(ceil(end/2) : ceil(end/2) + floor(N/4));

lags   = (1 : length(ac1))';
weight = (N - lags) / N;                   % Bartlett window
df     = 1 / (1/N + (2/N) * sum(weight .* ac1 .* ac2));
