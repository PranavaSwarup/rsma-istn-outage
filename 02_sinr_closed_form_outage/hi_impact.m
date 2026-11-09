%% HI_IMPACT  Extension: effect of hardware impairments (lambda) on outage.
% Distortion noise scales with the received signal (Singh et al., IEEE TVT
% 2024), so it adds lambda^2 to every vartheta and lowers every ceiling:
%   OMA ceiling       : 1/lambda^2            (was Inf)
%   NOMA s1 ceiling   : a1/(a2 + lambda^2)
%   RSMA ceilings     : alpha_c/(1-alpha_c+lambda^2), alpha_k/(...+lambda^2)
% Once a threshold passes its ceiling, outage = 1 at every power.
% With the paper's thresholds the ceilings stay above the targets until
%   RSMA common  lambda > 0.632    RSMA private lambda > 0.671
%   OMA          lambda > 0.757    NOMA s1      lambda > 0.875
% so realistic EVMs (lambda <= 0.2) only shift the curves; RSMA's common
% stream is the first stream to break as hardware gets worse.
% Black lines: T = 1 closed form.  Circles: T = 1 Monte Carlo.
% Blue lines: T = 3 Monte Carlo (HARQ-CC sums SINRs, so the per-round
% ceiling no longer caps the accumulated SINR).
clear; clc;
setup_paths();

PsdB = -20:2.5:20;
N    = 1e6;
lams = [0 0.1 0.2];
sty  = {'-', '-.', ':'};
tl   = {'OMA weak user', 'NOMA far user', 'RSMA user'};
fl   = {'oma_weak', 'noma_far', 'rsma_user'};

figure('Color', 'w');
ax = gobjects(1, 3);
for j = 1:3
    ax(j) = subplot(1, 3, j); hold(ax(j), 'on'); box(ax(j), 'on'); grid(ax(j), 'on');
end

for i = 1:numel(lams)
    p = istn_params();  p.hi_lambda = lams(i);
    cf  = op_closed_form_T1(PsdB, p);
    mc1 = mc_outage(PsdB, 1, N, p);
    mc3 = mc_outage(PsdB, 3, N, p);
    S = sinr_streams(p);
    fprintf('lambda = %.1f | ceilings: OMA %.2f, NOMA s1 %.3f, RSMA c %.3f, p %.3f\n', ...
            lams(i), S.oma.ceiling, S.noma_1.ceiling, S.rsma_c.ceiling, S.rsma_p.ceiling);
    for j = 1:3
        q = fl{j};
        semilogy(ax(j), PsdB, cf.(q), ['k' sty{i}], 'LineWidth', 1.3, ...
                 'DisplayName', sprintf('\\lambda = %.1f', lams(i)));
        semilogy(ax(j), PsdB, mc1.(q) ./ (mc1.(q) > 0), 'ko', 'HandleVisibility', 'off');
        semilogy(ax(j), PsdB, mc3.(q) ./ (mc3.(q) > 0), ['b' sty{i}], 'HandleVisibility', 'off');
    end
end

for j = 1:3
    set(ax(j), 'YScale', 'log');  ylim(ax(j), [1e-6 1.5]);
    title(ax(j), tl{j});  xlabel(ax(j), 'P_s (dBW)');  ylabel(ax(j), 'Outage probability');
    legend(ax(j), 'Location', 'southwest');
end
