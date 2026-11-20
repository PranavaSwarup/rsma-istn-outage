%% OMA_DIVERSITY_EXACT  Exact OMA outage over T HARQ-CC rounds and its slope.
% An OMA user's SNR is rho*|h|^2 (no interference), so the summed SNR over T
% rounds is rho*S, S = sum of T gains, and
%     P_out = Pr{S < (2^(2R)-1)/rho} = F_T(bar)      (sr_cdf_T, exact)
% This is a single (generic) OMA user; no weak/strong ordering.
% At high power the outage should fall 10^T-fold per 10 dB (diversity T).
clear; clc;
setup_extra_paths();
p = istn_params();

PsdB = [5 10 20 30];
rho  = 10.^(PsdB/10) * p.g;
bar  = p.g_oma ./ rho;

% Monte Carlo cross-check at 5 and 10 dBW
N = 2e6;  rng(p.seed);
fprintf('Exact OMA outage (generic user), threshold %.3f\n', p.g_oma);
fprintf('%8s', 'Ps(dBW)'); fprintf('%14s', 'T = 1', 'T = 2', 'T = 3'); fprintf('\n');
P = zeros(3, numel(PsdB));
for T = 1:3, P(T, :) = sr_cdf_T(bar, p, T); end
for i = 1:numel(PsdB)
    fprintf('%8d', PsdB(i)); fprintf('%14.3e', P(:, i)); fprintf('\n');
end

fprintf('\nDrop from 20 to 30 dBW (should be about 10^T):\n');
for T = 1:3
    fprintf('  T = %d : x%.0f\n', T, P(T, 3) / P(T, 4));
end

fprintf('\nMonte Carlo check (N = %g):\n', N);
for T = 1:3
    S = sum(sr_gain([T N], p), 1);
    fprintf('  T = %d :  5 dBW  exact %.3e  MC %.3e |  10 dBW  exact %.3e  MC %.3e\n', ...
        T, P(T, 1), mean(S < bar(1)), P(T, 2), mean(S < bar(2)));
end
