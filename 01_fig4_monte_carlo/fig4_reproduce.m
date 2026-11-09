%% FIG4_REPRODUCE  Weak-user outage: HARQ-CC aided OMA vs NOMA vs RSMA
% Reproduces Fig. 4 of Hu et al., IEEE TVT 2025 (Monte Carlo only), for BOTH
% ways of choosing the weak user across HARQ rounds (see order_users.m):
%   'round' : weak user re-chosen every round   -> the paper's ranking
%   'first' : weak user fixed by round 1        -> physically consistent
% Files needed in the same folder:
%   istn_params.m  sr_gain.m  order_users.m  oma_outage.m  noma_outage.m  rsma_outage.m
clear; clc;

p      = istn_params();
PsdB   = -20:2.5:10;        % paper's x-axis
Tset   = [1 3];             % paper plots T = 1 and T = 3
orders = {'round', 'first'};
N      = 4e6;               % samples per point. OP below ~1e-5 needs N >= 1e7

fprintf('g_k = %.3f (%.2f dB),  N0 = %.3e W\n', p.g, 10*log10(p.g), p.N0);
fprintf('R1 = %.4f bps/Hz | thresholds: NOMA %.4f, OMA %.4f, RSMA c/p %.2f/%.2f\n', ...
        p.R1, p.g_noma, p.g_oma, p.gc_th, p.gp_th);

res = cell(numel(orders), numel(Tset));
for io = 1:numel(orders)
    p.order = orders{io};
    for it = 1:numel(Tset)
        T = Tset(it);
        fprintf('\nordering = ''%s'', T = %d ...\n', p.order, T);  tic;
        r.T    = T;
        r.oma  = oma_outage (PsdB, T, N, p);
        r.noma = noma_outage(PsdB, T, N, p);
        [r.rsma, A1, A2] = rsma_outage(PsdB, T, N, p);   % generic RSMA user (as in paper)
        r.rsmaUp = min(A1 + A2, 1);
        r.rsmaLo = max(A1, A2);
        res{io, it} = r;
        fprintf('  done in %.1f s\n', toc);
        fprintf('  Ps(dBW)   OMA        NOMA       RSMA\n');
        for i = 1:numel(PsdB)
            fprintf('  %6.1f   %.3e  %.3e  %.3e\n', PsdB(i), r.oma(i), r.noma(i), r.rsma(i));
        end
    end
end

%% ---------------- Plot: one panel per ordering (styled like the paper's Fig. 4)
nz = @(v) v ./ (v > 0);                    % 0 -> NaN (dropped from log plot)
cO = [0.90 0.10 0.10];  cN = [0.10 0.70 0.10];  cR = [0.10 0.10 0.90];
mk = {'o','s'};

figure('Color','w', 'Position', [100 100 1100 450]);
for io = 1:numel(orders)
    subplot(1, numel(orders), io); hold on; box on; grid on;
    for it = 1:numel(Tset)
        r = res{io, it};  m = mk{it};
        semilogy(PsdB, nz(r.oma),    ['-' m], 'Color', cO, 'LineWidth', 1.4, 'MarkerSize', 7);
        semilogy(PsdB, nz(r.noma),   ['-' m], 'Color', cN, 'LineWidth', 1.4, 'MarkerSize', 7);
        semilogy(PsdB, nz(r.rsmaUp), '-',     'Color', cR, 'LineWidth', 1.4);
        semilogy(PsdB, nz(r.rsmaLo), '--k',   'LineWidth', 1.2);
        semilogy(PsdB, nz(r.rsma),   m,       'Color', cR, 'LineWidth', 1.4, 'MarkerSize', 7);
    end
    set(gca, 'YScale', 'log', 'FontSize', 11);
    xlim([min(PsdB) max(PsdB)]);  ylim([1e-7 1.5]);
    xlabel('P_s (dBW)');  ylabel('Outage probability');
    title(sprintf('Weak-user ordering: ''%s''', orders{io}));
    h = gobjects(1, 6);
    h(1) = plot(nan, nan, 'ko', 'MarkerSize', 7);
    h(2) = plot(nan, nan, 'ks', 'MarkerSize', 7);
    h(3) = plot(nan, nan, '-',  'Color', cO, 'LineWidth', 1.4);
    h(4) = plot(nan, nan, '-',  'Color', cN, 'LineWidth', 1.4);
    h(5) = plot(nan, nan, '-',  'Color', cR, 'LineWidth', 1.4);
    h(6) = plot(nan, nan, '--k','LineWidth', 1.2);
    legend(h, {'T=1','T=3','OMA','NOMA','RSMA upper bound','RSMA lower bound'}, ...
           'Location', 'southwest');
end
saveas(gcf, 'fig4_both_orderings.png');
save('fig4_results.mat', 'res', 'PsdB', 'p', 'N', 'orders');
