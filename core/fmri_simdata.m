function [X_compressed, S_3D, W_participants, svd_info, X_full] = fmri_simdata(...
    n_sources, n_participants, T, TR, sigma_ratio, n_comp, phase_strength, n_network, do_plot)
% FMRI_SIMDATA  Generates simulated 3D fMRI data for testing and demonstration.
%
% Generates realistic synthetic fMRI data consisting of spatially smooth
% activation blobs (sources) with realistic BOLD time courses embedded in
% noise. Neural-domain time courses (sparse event sequences) are convolved
% with the canonical HRF to produce BOLD-domain signals, making the output
% suitable for demonstrating the full regressor preparation pipeline.
% Participant variability is introduced via FFT phase perturbation of the
% base time courses. Output is compressed via SVD for memory efficiency and
% is immediately compatible with all fMRItoolbox functions via fmri_simget.
%
% The first N_NETWORK blobs all share time course 1, simulating a
% distributed brain network that responds coherently to stimulus feature 1.
% Remaining blobs each have their own independent time course.
%
% Spatial sources are placed within the standard MNI152 2mm brain mask
% (91x109x91), so all outputs are directly compatible with fmri_vol2vect,
% fmri_showslices, fmri_corregressor, and all other toolbox functions.
%
% Usage:
%   [X_compressed, S_3D, W_participants, svd_info] = fmri_simdata()
%   [X_compressed, S_3D, W_participants, svd_info, X_full] = fmri_simdata(...)
%
% Inputs:
%   N_SOURCES      - Number of spatial activation sources (blobs). Default: 10.
%   N_PARTICIPANTS - Number of simulated participants. Default: 2.
%   T              - Number of time points per participant. Default: 200.
%   TR             - Repetition time in seconds. Used for HRF generation.
%                    Default: 2.
%   SIGMA_RATIO    - Controls blob smoothness as a fraction of blob radius r.
%                    sigma = r * sigma_ratio. Default: 0.5 (moderately compact).
%                    Smaller values (e.g. 0.3) give sharper blobs; larger
%                    values (e.g. 0.8) give more diffuse, spread-out blobs.
%   N_COMP         - Number of SVD components for compression. Use 0 (default)
%                    for automatic selection retaining 95% of variance.
%                    Set explicitly (e.g. 20) to fix the number of components.
%   PHASE_STRENGTH - Controls inter-participant similarity via FFT phase
%                    perturbation strength. Range [0,1]: 0 = identical
%                    participants, 1 = fully decorrelated. Default: 0.2.
%   N_NETWORK      - Number of blobs sharing time course 1 (network blobs).
%                    Default: 3. The last floor(N_NETWORK/3) network blobs
%                    are driven by -TC1 (negative correlation with regressor).
%                    Must be <= N_SOURCES.
%                    Use W_participants.neural(:,1,p) as regressor (after HRF
%                    convolution) to recover the full network — positive blobs
%                    appear in p_pos map, negative blobs in p_neg map.
%   DO_PLOT        - Display diagnostic figures (1) or suppress (0). Default: 0.
%
% Outputs:
%   X_COMPRESSED   - Cell array {1 x N_PARTICIPANTS} of SVD-compressed data.
%                    Each cell contains a struct with fields U, S, V.
%                    Use fmri_simget to reconstruct participant volumes.
%   S_3D           - Spatial source maps (91 x 109 x 91 x N_SOURCES).
%                    S_3D(:,:,:,k) is the k-th activation blob.
%   W_PARTICIPANTS - Struct with two fields:
%                    .neural (T x N_SOURCES x N_PARTICIPANTS): sparse event
%                       sequences in neural/stimulus domain.
%                    .bold   (T x N_SOURCES x N_PARTICIPANTS): HRF-convolved
%                       BOLD-domain time courses used in volume assembly.
%                    Use .neural(:,1,p) as stimulus regressor — after HRF
%                    convolution it recovers the N_NETWORK distributed blobs.
%   SVD_INFO       - Struct array (1 x N_PARTICIPANTS) with SVD basis and
%                    volume dimension fields. Required by fmri_simget.
%   X_FULL         - Cell array {1 x N_PARTICIPANTS} of full 4D volumes
%                    (91 x 109 x 91 x T). Only computed if requested (nargout==5).
%
% Examples:
%   % Default: 10 sources, first 3 share time course 1 (network)
%   [X_comp, S_3D, W, svd_info] = fmri_simdata(10, 8, 200, 2);
%   % W.neural(:,1,1) correlates with blobs 1,2,3 after HRF convolution
%
%   % Custom network size: first 5 blobs share time course 1
%   [X_comp, S_3D, W, svd_info] = fmri_simdata(10, 8, 200, 2, [], [], [], 5);
%
% See also: fmri_simget, fmri_doublegamma, fmri_vol2vect, fmri_corregressor

% --- defaults -------------------------------------------------------------
if nargin < 1 || isempty(n_sources),      n_sources      = 10;  end
if nargin < 2 || isempty(n_participants), n_participants = 2;   end
if nargin < 3 || isempty(T),              T              = 200; end
if nargin < 4 || isempty(TR),             TR             = 2;   end
if nargin < 5 || isempty(sigma_ratio),    sigma_ratio    = 0.5; end
if nargin < 6 || isempty(n_comp),         n_comp         = 0;   end
if nargin < 7 || isempty(phase_strength), phase_strength = 0.2; end
if nargin < 8 || isempty(n_network),      n_network      = 3;   end
if nargin < 9 || isempty(do_plot),        do_plot        = 0;   end

if n_network > n_sources
    error('fmri_simdata: n_network (%d) cannot exceed n_sources (%d).', n_network, n_sources);
end

% --- signal amplitude -----------------------------------------------------
sig_amp = 20;   % BOLD signal amplitude (consistent across all branches)

% --- fixed volume dimensions (MNI152 2mm standard) -----------------------
xdim = 91; ydim = 109; zdim = 91;

% --- load standard brain mask --------------------------------------------
load standard_brain_NZ
brain_mask = A > 0;
[bx, by, bz] = ind2sub([xdim ydim zdim], find(brain_mask));
n_brain = length(bx);
fprintf('Brain mask: %d voxels (MNI152 2mm standard)\n', n_brain);

% --- initialise outputs --------------------------------------------------
X_compressed  = cell(1, n_participants);
S_3D          = zeros(xdim, ydim, zdim, n_sources);
svd_info      = struct([]);
X_full        = cell(1, n_participants);
W_neural      = zeros(T, n_sources, n_participants);
W_bold        = zeros(T, n_sources, n_participants);

% =========================================================================
%  1. SPATIAL SOURCES — angular-noise blobs within brain mask
% =========================================================================
fprintf('Generating %d spatial source blobs (%d share time course 1)...\n', ...
        n_sources, n_network);

[Xg, Yg, Zg] = ndgrid(1:xdim, 1:ydim, 1:zdim);

size_cat    = [2 4; 4 7; 7 10; 10 13];
cat_weights = [0.4 0.3 0.2 0.1];
centers     = [];

for s = 1:n_sources
    cat_cdf = cumsum(cat_weights / sum(cat_weights));
    cat     = find(rand() <= cat_cdf, 1, 'first');
    r_lo    = size_cat(cat,1);
    r_hi    = size_cat(cat,2);
    r       = r_lo + (r_hi - r_lo) * rand();

    min_sep = max(12, r * 2.5);
    placed  = false;
    for attempt = 1:500
        idx = randi(n_brain);
        cx = bx(idx); cy = by(idx); cz = bz(idx);
        if isempty(centers)
            placed = true; break;
        end
        dists = sqrt((centers(:,1)-cx).^2 + (centers(:,2)-cy).^2 + (centers(:,3)-cz).^2);
        if min(dists) > min_sep
            placed = true; break;
        end
    end
    if ~placed
        idx = randi(n_brain);
        cx = bx(idx); cy = by(idx); cz = bz(idx);
    end
    centers = [centers; cx cy cz];

    dist  = sqrt((Xg-cx).^2 + (Yg-cy).^2 + (Zg-cz).^2);
    theta = atan2(Yg-cy, Xg-cx);
    phi   = atan2(sqrt((Xg-cx).^2+(Yg-cy).^2), Zg-cz);

    noise_amp = 0.3 * r;
    dist_eff  = dist + noise_amp * (sin(3*theta).*cos(2*phi) + 0.5*randn(size(dist)));
    dist_eff  = max(0, dist_eff);

    sigma = r * sigma_ratio;
    blob  = exp(-(dist_eff.^2) / (2*sigma^2));
    blob(dist > r*1.8) = 0;
    blob(~brain_mask)  = 0;
    S_3D(:,:,:,s) = blob;

    if s <= n_network
        fprintf('  Source %2d [network]: radius=%.1f voxels, center=[%d %d %d]\n', s, r, cx, cy, cz);
    else
        fprintf('  Source %2d:           radius=%.1f voxels, center=[%d %d %d]\n', s, r, cx, cy, cz);
    end
end

% =========================================================================
%  2. BASE TIME COURSES — neural domain + HRF convolution
% =========================================================================
fprintf('Generating base time courses (neural + HRF convolution, TR=%ds)...\n', TR);

hrf           = fmri_doublegamma(0:TR:30)';
W_base_neural = zeros(T, n_sources);
W_base_bold   = zeros(T, n_sources);

% Generate one neural time course per independent source
% Sources 1..n_network all share time course 1
n_independent = n_sources - n_network + 1;   % time course 1 + one per remaining blob
TC_neural     = zeros(T, n_independent);
TC_bold       = zeros(T, n_independent);

for tc = 1:n_independent
    event_rate      = 0.04 + 0.02*rand();
    events          = double(rand(T,1) < event_rate);
    neural_tc       = events + 0.2*randn(T,1);
    TC_neural(:,tc) = zscore(neural_tc);
    bold_tc         = conv(TC_neural(:,tc), hrf);
    TC_bold(:,tc)   = zscore(bold_tc(1:T));
end

% Assign time courses to blobs:
% blobs 1..n_network -> time course 1
% blob n_network+1   -> time course 2
% blob n_network+2   -> time course 3  ... etc.
% network blobs: assign TC1, last third negated
n_neg_network = floor(n_network/3);
n_pos_network = n_network - n_neg_network;

for s = 1:n_sources
    if s <= n_network
        if s > n_pos_network
            W_base_neural(:,s) = -TC_neural(:,1);
            W_base_bold(:,s)   = -TC_bold(:,1);
        else
            W_base_neural(:,s) =  TC_neural(:,1);
            W_base_bold(:,s)   =  TC_bold(:,1);
        end
    else
        tc_idx             = s - n_network + 1;
        W_base_neural(:,s) = TC_neural(:,tc_idx);
        W_base_bold(:,s)   = TC_bold(:,tc_idx);
    end
end
fprintf('  Network: %d positive blobs (+TC1), %d negative blobs (-TC1)\n', ...
        n_pos_network, n_neg_network);

% =========================================================================
%  3. PARTICIPANT VARIATIONS — FFT phase perturbation
% =========================================================================
fprintf('Generating %d participant variations (phase_strength=%.2f)...\n', ...
        n_participants, phase_strength);

W_neural(:,:,1) = W_base_neural;
W_bold(:,:,1)   = W_base_bold;

for p = 2:n_participants
    for s = 1:n_sources
        Yf  = fft(W_base_bold(:,s));
        mag = abs(Yf);
        ph  = angle(Yf) + phase_strength * randn(size(Yf));
        amp = mag * (1 + 0.1*randn());
        ts  = real(ifft(amp .* exp(1i*ph)));
        W_bold(:,s,p) = zscore(ts);

        Yf  = fft(W_base_neural(:,s));
        mag = abs(Yf);
        ph  = angle(Yf) + phase_strength * randn(size(Yf));
        amp = mag * (1 + 0.1*randn());
        ts  = real(ifft(amp .* exp(1i*ph)));
        W_neural(:,s,p) = zscore(ts);
    end
end


% if n_participants > 1
%     fprintf('Inter-participant correlations, source 1 (BOLD domain):\n');
%     r_isc = zeros(n_participants, n_participants);
%     for p1 = 1:n_participants
%         for p2 = 1:n_participants
%             r_isc(p1,p2) = corr(W_bold(:,1,p1), W_bold(:,1,p2));
%         end
%     end
%     % extract upper triangle (unique pairs)
%     upper = r_isc(triu(true(n_participants), 1));
%     fprintf('  All pairwise: mean=%.3f, min=%.3f, max=%.3f (%d pairs)\n', ...
%             mean(upper), min(upper), max(upper), length(upper));
% end
% --------- Participant similarity diagnostics  -------------------------------- %
if n_participants > 1
    fprintf('Inter-participant correlations, source 1 (BOLD domain):\n');
    r_isc = zeros(n_participants, n_participants);
    for p1 = 1:n_participants
        for p2 = 1:n_participants
            r_isc(p1,p2) = corr(W_bold(:,1,p1), W_bold(:,1,p2));
        end
    end
    % extract upper triangle (unique pairs)
    upper = r_isc(triu(true(n_participants), 1));
    fprintf('  All pairwise: mean=%.3f, min=%.3f, max=%.3f (%d pairs)\n', ...
            mean(upper), min(upper), max(upper), length(upper));
    
    % print matrix
    fprintf('     ');
    for p = 1:n_participants, fprintf('  P%d  ', p); end
    fprintf('\n');
    for p1 = 1:n_participants
        fprintf('  P%d ', p1);
        for p2 = 1:n_participants
            fprintf(' %.2f ', r_isc(p1,p2));
        end
        fprintf('\n');
    end
    upper = r_isc(triu(true(n_participants), 1));
    fprintf('  Mean pairwise r = %.3f (range %.3f-%.3f)\n', ...
            mean(upper), min(upper), max(upper));

    % plot matrix if do_plot
    if do_plot
        figure('Name', 'fmri_simdata: Inter-participant ISC');
        imagesc(r_isc, [0 1]);
        colormap(hot); colorbar;
        axis square;
        xlabel('Participant'); ylabel('Participant');
        title('Inter-participant correlations (source 1, BOLD domain)');
        xticks(1:n_participants); yticks(1:n_participants);
    end
 end
% --------- Participant similarity diagnostics (end) ---------------------------- %

W_participants.neural = W_neural;
W_participants.bold   = W_bold;

% =========================================================================
%  4. ASSEMBLE VOLUMES — BOLD-domain time courses
% =========================================================================
compute_full = (nargout == 5);
% baseline     = 100 * double(brain_mask);
S_2D         = reshape(S_3D, xdim*ydim*zdim, n_sources);

if compute_full
    fprintf('Assembling full 4D volumes...\n');
    for p = 1:n_participants
        % X2D = baseline(:) + S_2D * W_bold(:,:,p)' * sig_amp;
        % X2D = X2D .* brain_mask(:) + 2*randn(xdim*ydim*zdim, T) .* brain_mask(:);
        X2D = S_2D * W_bold(:,:,p)' * sig_amp;
        X2D = X2D .* brain_mask(:) + 2*randn(xdim*ydim*zdim, T) .* brain_mask(:);
        Xp  = reshape(X2D, xdim, ydim, zdim, T);
        X_full{p} = Xp;
        fprintf('  Participant %d/%d assembled.\n', p, n_participants);
    end
else
    fprintf('Assembling volumes for compression (X_full not stored)...\n');
end

% =========================================================================
%  5. SVD COMPRESSION
% =========================================================================
if n_comp == 0
    fprintf('Compressing via SVD (auto components, 95%% variance)...\n');
else
    fprintf('Compressing via SVD (%d components)...\n', n_comp);
end

for p = 1:n_participants
    if compute_full
        Xp = X_full{p};
    else
        % X2D = baseline(:) + S_2D * W_bold(:,:,p)' * sig_amp;
        % X2D = X2D .* brain_mask(:) + 2*randn(xdim*ydim*zdim, T) .* brain_mask(:);
        X2D = S_2D * W_bold(:,:,p)' * sig_amp;
        X2D = X2D .* brain_mask(:) + 2*randn(xdim*ydim*zdim, T) .* brain_mask(:);
        Xp  = reshape(X2D, xdim, ydim, zdim, T);
    end

    X2D        = reshape(Xp, xdim*ydim*zdim, T);
    [U, Sv, V] = svd(X2D, 'econ');

    if n_comp == 0
        sv      = diag(Sv);
        var_exp = cumsum(sv.^2) / sum(sv.^2);
        nc      = find(var_exp >= 0.95, 1);
        fprintf('  P%d: %d components explain 95%% variance.\n', p, nc);
    else
        nc = min(n_comp, size(Sv,1));
    end

    X_compressed{p} = struct('U', U(:,1:nc), 'S', Sv(1:nc,1:nc), 'V', V(:,1:nc));

    svd_info(p).U_full = U;
    svd_info(p).S      = Sv;
    svd_info(p).V_full = V;
    svd_info(p).xdim   = xdim;
    svd_info(p).ydim   = ydim;
    svd_info(p).zdim   = zdim;

    fprintf('  Participant %d/%d compressed.\n', p, n_participants);
end

% =========================================================================
%  6. DIAGNOSTIC PLOTS (optional)
% =========================================================================
if do_plot
    all_blobs = max(S_3D, [], 4);
    t_vec     = (1:T)';

    figure('Name', 'fmri_simdata: Spatial Sources');
    subplot(1,3,1); imagesc(max(all_blobs,[],3));
    colormap(hot); colorbar; axis image;
    title(sprintf('Axial (max proj.) — blobs 1-%d share TC1', n_network));
    subplot(1,3,2); imagesc(squeeze(max(all_blobs,[],2))');
    colormap(hot); colorbar; axis image; title('Coronal (max projection)');
    subplot(1,3,3); imagesc(squeeze(max(all_blobs,[],1)));
    colormap(hot); colorbar; axis image; title('Sagittal (max projection)');
    sgtitle(sprintf('fmri\\_simdata: %d sources, %d share TC1', n_sources, n_network));

    figure('Name', 'fmri_simdata: Time Courses (source 1)');
    subplot(3,1,1);
    stem(t_vec, double(W_base_neural(:,1) > 0.3), 'k', 'MarkerSize', 3);
    title(sprintf('Neural TC1 (sparse events, shared by blobs 1-%d)', n_network));
    xlabel('Volume'); ylabel('Amplitude'); axis tight;

    subplot(3,1,2);
    plot(t_vec, W_base_bold(:,1), 'r', 'LineWidth', 1.5);
    title('BOLD TC1: HRF-convolved');
    xlabel('Volume'); ylabel('Amplitude'); axis tight;

    subplot(3,1,3);
    n_show = min(4, n_participants);
    cols   = lines(n_show);
    hold on;
    for p = 1:n_show
        plot(t_vec, W_bold(:,1,p), 'Color', cols(p,:), 'LineWidth', 1.2);
    end
    title('BOLD TC1 across participants');
    xlabel('Volume'); ylabel('Amplitude'); axis tight;
    legend(arrayfun(@(p) sprintf('P%d',p), 1:n_show, 'UniformOutput', false), ...
           'Location', 'best', 'FontSize', 7);
    hold off;
end

fprintf('fmri_simdata: done.\n');
end
