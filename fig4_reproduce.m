%% FIG4_REPRODUCE  Weak-user outage: HARQ-CC aided OMA vs NOMA vs RSMA
% Reproduces Fig. 4 of Hu et al., IEEE TVT 2025 (Monte Carlo only).
% Files needed in the same folder:
%   istn_params.m  sr_gain.m  order_users.m  oma_outage.m  noma_outage.m  rsma_outage.m
% RSMA curve = generic user (as in the paper's analysis). Set fairRSMA = true
% to also plot RSMA's weak user under the same ordering rule as NOMA/OMA.
clear; clc;

p    = istn_params();
PsdB = -20:2.5:10;          % paper's x-axis
Tset = [1 3];               % paper plots T = 1 and T = 3
N    = 1e7;                 % samples per point. OP below ~1e-6 needs N >= 1e8
fairRSMA = false;           % true: add RSMA weak-user curve (like-for-like)

fprintf('g_k = %.3f (%.2f dB),  N0 = %.3e W\n', p.g, 10*log10(p.g), p.N0);
fprintf('R1 = %.4f bps/Hz | thresholds: NOMA %.4f, OMA %.4f, RSMA c/p %.2f/%.2f\n', ...
        p.R1, p.g_noma, p.g_oma, p.gc_th, p.gp_th);
fprintf('ordering = %s | extra gain = %g dB\n', p.order, p.extra_gain_dB);

res = struct();
for it = 1:numel(Tset)
    T = Tset(it);
    fprintf('\nT = %d ...\n', T);
    tic;
    res(it).T    = T;
    res(it).oma  = oma_outage (PsdB, T, N, p);
    res(it).noma = noma_outage(PsdB, T, N, p);
    [res(it).rsma, A1, A2] = rsma_outage(PsdB, T, N, p);
    res(it).rsmaUp = min(A1 + A2, 1);
    res(it).rsmaLo = max(A1, A2);
    if fairRSMA
        q = p;  q.rsma_ordered = true;
        res(it).rsmaW = rsma_outage(PsdB, T, N, q);
    end
    fprintf('  done in %.1f s\n', toc);

    fprintf('  Ps(dBW)   OMA        NOMA       RSMA\n');
    for i = 1:numel(PsdB)
        fprintf('  %6.1f   %.3e  %.3e  %.3e', PsdB(i), res(it).oma(i), res(it).noma(i), res(it).rsma(i));
        if fairRSMA, fprintf('  (RSMA weak %.3e)', res(it).rsmaW(i)); end
        fprintf('\n');
    end
end

%% ---------------- Plot (styled like the paper's Fig. 4)
nz = @(v) v ./ (v > 0);                    % 0 -> NaN (dropped from log plot)
cO = [0.90 0.10 0.10];  cN = [0.10 0.80 0.10];  cR = [0.10 0.10 0.90];
mk = {'o','s'};

figure('Color','w'); hold on; box on; grid on;
if exist('theme','file') || exist('theme','builtin'), theme(gcf,'light'); end   % R2025a+ dark mode hides black markers
for it = 1:numel(Tset)
    m = mk{it};
    semilogy(PsdB, nz(res(it).oma),   ['-' m], 'Color', cO, 'LineWidth', 1.4, 'MarkerSize', 7);
    semilogy(PsdB, nz(res(it).noma),  ['-' m], 'Color', cN, 'LineWidth', 1.4, 'MarkerSize', 7);
    semilogy(PsdB, nz(res(it).rsmaUp), '-',     'Color', cR, 'LineWidth', 1.4);
    semilogy(PsdB, nz(res(it).rsmaLo), '--k',   'LineWidth', 1.2);
    semilogy(PsdB, nz(res(it).rsma),   m,       'Color', cR, 'LineWidth', 1.4, 'MarkerSize', 7);
    if fairRSMA
        semilogy(PsdB, nz(res(it).rsmaW), ['-.' m], 'Color', [0.3 0.6 1], 'LineWidth', 1.2, 'MarkerSize', 6);
    end
end
set(gca, 'YScale', 'log', 'FontSize', 11);
xlim([min(PsdB) max(PsdB)]);  ylim([1e-8 1.5]);
xlabel('P_s (dBW)');  ylabel('Outage probability');
title('Weak-user OP, HARQ-CC: OMA vs NOMA vs RSMA');

% legend with proxy handles (same entries as the paper)
h(1) = plot(nan, nan, 'ko', 'MarkerSize', 7);
h(2) = plot(nan, nan, 'ks', 'MarkerSize', 7);
h(3) = plot(nan, nan, '-',  'Color', cO, 'LineWidth', 1.4);
h(4) = plot(nan, nan, '-',  'Color', cN, 'LineWidth', 1.4);
h(5) = plot(nan, nan, '-',  'Color', cR, 'LineWidth', 1.4);
h(6) = plot(nan, nan, '--k','LineWidth', 1.2);
names = {'T=1','T=3','OMA','NOMA','RSMA upper bound','RSMA lower bound'};
if fairRSMA
    h(7) = plot(nan, nan, '-.', 'Color', [0.3 0.6 1], 'LineWidth', 1.2);
    names{end+1} = 'RSMA weak user';
end
legend(h, names, 'Location', 'southwest');

save('fig4_results.mat', 'res', 'PsdB', 'p', 'N');
