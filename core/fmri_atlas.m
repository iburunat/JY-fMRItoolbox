function fmri_atlas(atlas)
% FMRI_ATLAS  Lists all available atlases and their region counts.
%
% Usage:
%   fmri_atlas()     % print full atlas list
%   fmri_atlas(n)    % print region list for atlas n
%
% See also: fmri_loadatlas, fmri_regionmask, fmri_regionnumber, fmri_nregion


[~, ~, atlases] = fmri_loadatlas();   % fetch metadata table

if nargin == 0
    fprintf('\n%-4s  %-46s  %-5s  %s\n', '#', 'Atlas', 'ROIs', 'Reference');
    fprintf('%s\n', repmat('-', 1, 90));

    % Convert numeric ROIs to strings
    roi_str = string(atlases.ROIs);
    roi_str = cellstr(roi_str);

    % Print atlas table
    for k = 1:height(atlases)
        fprintf('%-4d  %-46s  %-5s  %s\n', atlases.ID(k), atlases.Name{k}, roi_str{k}, atlases.Reference{k});
    end

    fprintf('\nUsage: fmri_atlas(n) to list region names for atlas n.\n\n');

else
    % Find requested atlas
    idx = find(atlases.ID == atlas, 1);

    if isempty(idx)
        error('fmri_atlas:badAtlas', ...
            'Atlas %d not found. Run fmri_atlas() to see valid numbers.', atlas);
    end

    fprintf('\n=== Atlas %d: %s ===\n', atlases.ID(idx), atlases.Name{idx});
    nrois = atlases.ROIs(idx);

    % Craddock atlases have no labels
    if atlas >= 14 && atlas <= 18
        regions = arrayfun(@num2str, 1:nrois, 'UniformOutput', false);
    else
        regions = fmri_nregion(1:nrois, atlas);
    end

    for k = 1:numel(regions)
        fprintf('  %3d  %s\n', k, regions{k});
    end

    fprintf('\n');
end
