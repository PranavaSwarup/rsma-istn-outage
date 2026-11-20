%% RSMA_NESTING_DEMO  Why the paper needs bounds for RSMA when T > 1.
% T = 1: both decoding steps are bars on the SAME |h|^2, so "private fails"
% implies "common fails" (A2 inside A1) and P_out = Pr{A1} exactly.
% T > 1: SINRs are summed over rounds. The common stream gains more in WEAK
% rounds (more power, 0.4 vs 0.3), the private stream more in STRONG rounds
% (higher ceiling, 1 vs 0.667), so either can fail alone and the events are no
% longer nested. The paper then uses
%     max(Pr A1, Pr A2) <= P_out <= Pr A1 + Pr A2.
clear; clc;
setup_extra_paths();
p = istn_params();
S = sinr_streams(p);
rho = 10^(5/10) * p.g;                                   % 5 dBW

%% Worked examples (two rounds)
ex = [0.2 0.2; 0.62 0.0; 0.5 0.3];
fprintf('Two-round examples at 5 dBW (thresholds %.1f / %.1f)\n', S.rsma_c.gth, S.rsma_p.gth);
fprintf('  x1     x2     sum common   sum private   result\n');
for i = 1:size(ex, 1)
    x  = ex(i, :)';
    sc = sum(sinr_value(S.rsma_c, rho, x));
    sp = sum(sinr_value(S.rsma_p, rho, x));
    if sc >= S.rsma_c.gth && sp >= S.rsma_p.gth, res = 'success';
    elseif sc >= S.rsma_c.gth,                   res = 'only PRIVATE fails';
    elseif sp >= S.rsma_p.gth,                   res = 'only COMMON fails';
    else,                                        res = 'both fail'; end
    fprintf('  %.2f   %.2f   %.3f        %.3f         %s\n', x(1), x(2), sc, sp, res);
end

%% Bounds vs true outage, T = 1..3
N = 2e6;
fprintf('\nRSMA generic user at 5 dBW (N = %g)\n', N);
fprintf('  T   Pr A1      Pr A2      lower      true       upper      Pr(A2 and not A1)\n');
for T = 1:3
    rng(p.seed + T);
    x  = sr_gain([T N], p);
    A1 = sum(sinr_value(S.rsma_c, rho, x), 1) < S.rsma_c.gth;
    A2 = sum(sinr_value(S.rsma_p, rho, x), 1) < S.rsma_p.gth;
    fprintf('  %d   %.3e  %.3e  %.3e  %.3e  %.3e  %.3e\n', T, mean(A1), mean(A2), ...
        max(mean(A1), mean(A2)), mean(A1 | A2), min(mean(A1) + mean(A2), 1), mean(A2 & ~A1));
end
fprintf('\nT = 1: A2 never happens without A1 (last column 0), lower bound exact.\n');
fprintf('T > 1: the bottleneck flips to the private stream and the lower bound stays tight.\n');
