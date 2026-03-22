function rho = fmri_partcorr(Y, x, Z)
% FMRI_PARTCORR  Partial correlation for group-level (second-level) fMRI analysis.
%
% Computes the partial correlation between a brain map Y and a participant-
% level regressor x, while controlling for one or more confound variables Z.
% Operates voxelwise across the whole brain.
%
% The partial correlation is obtained by:
%   1. Regressing Z out of both x and Y (separately)
%   2. Correlating the residuals
%
% Usage:
%   rho = fmri_partcorr(Y, x, Z)
%
% Inputs:
%   Y   - Brain data: participant-level maps, (participants x 228453).
%         Each row is one participant's vectorized statistical or BOLD map.
%   X   - Regressor of interest: participant-level variable, (participants x 1).
%         E.g., age, behavioural score, group membership.
%   Z   - Confound regressors: (participants x C) matrix of C confounds.
%         E.g., [age, sex, total-intracranial-volume].
%
% Outputs:
%   RHO - Partial correlation map, vectorized (228453 x 1). Values are
%         Pearson r after controlling for Z.
%
% Examples:
%   % Correlate musical ability with brain activity, controlling for age
%   rho = fmri_partcorr(subj_maps, musical_score, age_vector);
%   fmri_showslices(rho, 1, 2, [0.2 0.7])
%
%   % Multiple confounds
%   rho = fmri_partcorr(subj_maps, IQ, [age, sex, education]);
%
% Notes:
%   All inputs are z-scored internally. Y, x, and Z must all have the same
%   number of rows (participants). For significance testing, pass the output
%   to fmri_rtop with df = size(Y,1) - 2 - size(Z,2).
%
% See also: fmri_corregressor, fmri_rtop, fmri_effdf

x = zscore(x(:));
Y = zscore(Y);
Z = zscore(Z);

% Residualise x and Y with respect to Z (multiple regression)
ex  = x - Z * (Z \ x);     % residual of x after removing Z
eY  = Y - Z * (Z \ Y);     % residual of Y after removing Z (voxelwise)

% Partial correlation = correlation of residuals
rho = corr(ex, eY)';        % 228453 x 1
rho(isnan(rho)) = 0;
