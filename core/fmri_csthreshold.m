function [CSIZE, report, CS_table] = fmri_csthreshold(D, si_alpha, cs_alpha)
% FMRI_CSTHRESHOLD  Extracts critical cluster sizes from a CS distribution.
%
% Given a cluster-size (CS) null distribution (from fmri_csdist), extracts
% the critical cluster size at one or more family-wise error rate (FWER) levels.
% This is the third and final step of the Ledberg et al. (1998) procedure.
%
% Usage:
%   [CSIZE, report] = fmri_csthreshold(D, si_alpha, cs_alpha)
%
% Inputs:
%   D         - CS distribution cell array {1 x R}, as returned by fmri_csdist.
%   SI_ALPHA  - Statistical image alpha levels used to generate D.
%               Default: [0.01 0.001 0.0001]
%   CS_ALPHA  - FWER alpha level(s) for cluster-size thresholding.
%               Default: [0.05 0.01 0.001]
%
% Outputs:
%   CSIZE     - Cell array {1 x R}. Each cell is a
%               (length(SI_ALPHA) x length(CS_ALPHA)) matrix of critical
%               cluster sizes.
%   REPORT    - Formatted string summarising the critical cluster sizes,
%               suitable for printing (disp(report)) or saving to a file.
%   CS_table - Cell array {1 x R}, one table per regressor.  
%              Each table has rows = SI alpha levels and columns = FWER alpha levels.  
%              Columns are named like "CS_FWER_0_05", "CS_FWER_0_01", etc.,  
%              and an extra column "SI_alpha" shows the statistical image thresholds.  
%              Example: CS_table{1} is a table for regressor #1.
%
% Examples:
%   % Full pipeline
%   acf   = fmri_acfestimate(datapath, regressor, 10);
%   D     = fmri_csdist(acf, [0.001 0.0001], 200);
%   [CS, report] = fmri_csthreshold(D, [0.001 0.0001], [0.05 0.01]);
%   disp(report)
%
%   % Apply threshold to a z-map
%   z_thresh = zmap > norminv(1 - 0.001);
%   clean    = fmri_cleanclusters(z_thresh, CS{1}(1,1), 0);
%
% References:
%   Ledberg, A., Akerman, S., & Roland, P.E. (1998). NeuroImage, 8, 113-128.
%
% See also: fmri_acfestimate, fmri_csdist, fmri_cleanclusters, fmri_tfce

if nargin < 3 || isempty(cs_alpha), cs_alpha = [0.05 0.01 0.001];     end
if nargin < 2 || isempty(si_alpha), si_alpha = [0.01 0.001 0.0001];   end

R     = numel(D);
CSIZE = cell(1, R);

for r = 1:R
    csizes = zeros(length(si_alpha), length(cs_alpha));
    for zi = 1:length(si_alpha)
        for ci = 1:length(cs_alpha)
            idx          = find(D{r}(:, zi) >= cs_alpha(ci));
            csizes(zi,ci) = length(idx);
        end
    end
    CSIZE{r} = csizes;

    % --- Optional: create a readable table for each regressor ---
    T = array2table(csizes, 'VariableNames', strcat("CS_FWER_", strrep(string(cs_alpha),'.','_')));
    T.SI_alpha = si_alpha(:);
    T = movevars(T,'SI_alpha','Before',1);
    CS_table{r} = T;  %# store in a new cell array

end

% --- build report string ----------------------------------------------
report = sprintf('=== CRITICAL CLUSTER SIZES ===\n');
report = [report sprintf('CS FWER alpha: %s\n\n', num2str(cs_alpha))];
for r = 1:R
    report = [report sprintf('Regressor #%d\n', r)]; %#ok<AGROW>
    report = [report sprintf('  SI alpha\t%s\n', strjoin(arrayfun(@num2str,cs_alpha,'uni',0),'\t'))];
    for zi = 1:length(si_alpha)
        report = [report sprintf('  %.4f  \t%s\n', si_alpha(zi), ...
            strjoin(arrayfun(@num2str, CSIZE{r}(zi,:),'uni',0), '\t'))]; %#ok<AGROW>
    end
    report = [report sprintf('\n')]; %#ok<AGROW>
end
