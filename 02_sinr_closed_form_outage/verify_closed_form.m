%% VERIFY_CLOSED_FORM  Check the exact T = 1 outage formulas three ways:
%   (1) closed form, op_closed_form_T1
%   (2) Monte Carlo from the SINR template, mc_outage
%   (3) the week-1 Monte Carlo functions (oma/noma/rsma_outage)
% and check the Shadowed-Rician CDF against samples from sr_gain.
% Points with fewer than 100 outage events are not used for the error check.
clear; clc;
setup_paths();

p    = istn_params();
PsdB = -20:2.5:10;
N    = 2e6;
minEvents = 100;

%% ---- Shadowed-Rician CDF vs samples
x  = sr_gain([1 N], p);
xq = [0.01 0.05 0.1 0.2 0.5 1 2];
Femp = arrayfun(@(t) mean(x < t), xq);
Fcf  = sr_cdf(xq, p);
fprintf('Shadowed-Rician CDF check\n   x        closed form   empirical\n');
fprintf('  %5.2f     %.5f       %.5f\n', [xq; Fcf; Femp]);
fprintf('  E|h|^2: empirical %.4f vs 2b+Omega = %.4f\n\n', mean(x), 2*p.b + p.Omega);

%% ---- Outage, T = 1
cf = op_closed_form_T1(PsdB, p);
mc = mc_outage(PsdB, 1, N, p);
[w1.oma_weak, w1.oma_strong] = oma_outage(PsdB, 1, N, p);
[w1.noma_far, w1.noma_near]  = noma_outage(PsdB, 1, N, p);
[w1.rsma_user, w1.rsma_PrA1, w1.rsma_PrA2] = rsma_outage(PsdB, 1, N, p);

fields = {'oma_weak','oma_strong','noma_far','noma_near', ...
          'rsma_user','rsma_PrA1','rsma_PrA2','rsma_weak'};
fprintf('%-11s %15s %15s %15s\n', 'quantity', 'max rel.err MC', 'max rel.err wk1', 'points used');
for f = fields
    q = f{1};
    use = mc.(q) * N >= minEvents;
    e1 = max(abs(mc.(q)(use) - cf.(q)(use)) ./ cf.(q)(use));
    if isfield(w1, q)
        e2 = max(abs(w1.(q)(use) - cf.(q)(use)) ./ cf.(q)(use));
    else
        e2 = NaN;
    end
    fprintf('%-11s %15.3f %15.3f %15d\n', q, e1, e2, nnz(use));
end

fprintf('\nT = 1 closed form (weak users, Fig. 4 settings)\n  Ps(dBW)   OMA        NOMA       RSMA user  RSMA weak\n');
for i = 1:numel(PsdB)
    fprintf('  %6.1f   %.3e  %.3e  %.3e  %.3e\n', PsdB(i), cf.oma_weak(i), ...
            cf.noma_far(i), cf.rsma_user(i), cf.rsma_weak(i));
end

%% ---- Fig. 2 settings (K = 3), RSMA user, T = 1
p3 = p;  p3.alpha_p = [0.2 0.2 0.2];
cf3 = op_closed_form_T1(PsdB, p3);
mc3 = mc_outage(PsdB, 1, N, p3);
use = mc3.rsma_user * N >= minEvents;
fprintf('\nFig. 2 settings, RSMA user, T = 1: max rel. error %.3f over %d points\n', ...
        max(abs(mc3.rsma_user(use) - cf3.rsma_user(use)) ./ cf3.rsma_user(use)), nnz(use));

%% ---- Plot
nz = @(v) v ./ (v > 0);
figure('Color', 'w'); hold on; box on; grid on;
cO = [0.85 0.1 0.1]; cN = [0.1 0.65 0.1]; cR = [0.1 0.1 0.85];
semilogy(PsdB, cf.oma_weak,  '-', 'Color', cO, 'LineWidth', 1.4);
semilogy(PsdB, cf.noma_far,  '-', 'Color', cN, 'LineWidth', 1.4);
semilogy(PsdB, cf.rsma_user, '-', 'Color', cR, 'LineWidth', 1.4);
semilogy(PsdB, nz(mc.oma_weak),  'o', 'Color', cO);
semilogy(PsdB, nz(mc.noma_far),  'o', 'Color', cN);
semilogy(PsdB, nz(mc.rsma_user), 'o', 'Color', cR);
set(gca, 'YScale', 'log');  ylim([1e-6 1.5]);
xlabel('P_s (dBW)');  ylabel('Outage probability');
title('T = 1: closed form (lines) vs Monte Carlo (circles)');
legend({'OMA weak', 'NOMA far', 'RSMA user'}, 'Location', 'southwest');
