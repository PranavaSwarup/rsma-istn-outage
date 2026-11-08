%% FIG4_REPRODUCE  Weak-user outage: HARQ-CC aided OMA vs NOMA vs RSMA
% Reproduces Fig. 4 of Hu et al., IEEE TVT 2025, with NOMA/OMA modelled as in
% the paper's ref. [12] (Singh et al., IEEE TVT 2024).
%
% Two settings are run:
%   'fig4'     order 'round' + 5.25 dB calibration: best match to the published figure
%   'physical' order 'first' + 0 dB: the link budget as stated, roles fixed by round 1
% Lines = analytic_outage (numerical, exact up to grid), markers = Monte Carlo,
% black crosses = values read off the published Fig. 4.
clear; clc;

PsdB = -20:2.5:10;
Tset = [1 3];
N    = 1e7;                 % MC samples per point (OP below ~1e-6 needs N >= 1e8)
cfgs = {'fig4', {'preset','fig4'};  'physical', {'order','first','extra_gain_dB',0}};
paper = paper_fig4_points();

for c = 1:size(cfgs,1)
    clear R
    name = cfgs{c,1};
    p = istn_params(cfgs{c,2}{:});
    fprintf('\n===== %s: order = %s, extra gain = %.2f dB, g = %.3f =====\n', ...
            name, p.order, p.extra_gain_dB, p.g);
    for it = 1:numel(Tset)
        T = Tset(it);
        R(it).T  = T;
        R(it).an = analytic_outage(PsdB, T, p);
        R(it).oma  = oma_outage (PsdB, T, N, p);
        R(it).noma = noma_outage(PsdB, T, N, p);
        R(it).rsma = rsma_outage(PsdB, T, N, p);
        fprintf('T = %d\n  Ps    OMA(an/MC)            NOMA(an/MC)           RSMA lo/up (an) | MC\n', T);
        for i = 1:numel(PsdB)
            fprintf('%6.1f  %.2e/%.2e  %.2e/%.2e  %.2e/%.2e | %.2e\n', PsdB(i), ...
                R(it).an.oma(i), R(it).oma(i), R(it).an.noma(i), R(it).noma(i), ...
                R(it).an.rsmaLo(i), R(it).an.rsmaUp(i), R(it).rsma(i));
        end
    end

    % ---- plot, styled like the paper's Fig. 4
    nz = @(v) v ./ (v > 0);
    cO = [0.90 0.10 0.10];  cN = [0.10 0.75 0.10];  cR = [0.10 0.10 0.90];
    mk = {'o','s'};
    figure('Color','w'); hold on; box on; grid on;
    for it = 1:numel(Tset)
        m = mk{it}; A = R(it).an;
        semilogy(PsdB, nz(A.oma),    '-',  'Color', cO, 'LineWidth', 1.4);
        semilogy(PsdB, nz(A.noma),   '-',  'Color', cN, 'LineWidth', 1.4);
        semilogy(PsdB, nz(A.rsmaUp), '-',  'Color', cR, 'LineWidth', 1.4);
        semilogy(PsdB, nz(A.rsmaLo), '--k','LineWidth', 1.2);
        semilogy(PsdB, nz(R(it).oma),  m, 'Color', cO, 'MarkerSize', 7);
        semilogy(PsdB, nz(R(it).noma), m, 'Color', cN, 'MarkerSize', 7);
        semilogy(PsdB, nz(R(it).rsma), m, 'Color', cR, 'MarkerSize', 7);
        P = paper.(sprintf('T%d', R(it).T));
        semilogy(P.Ps, P.oma, 'x', 'Color', cO, 'MarkerSize', 10, 'LineWidth', 1.5);
        semilogy(P.Ps, P.noma,'x', 'Color', cN, 'MarkerSize', 10, 'LineWidth', 1.5);
        semilogy(P.Ps, P.rsma,'x', 'Color', cR, 'MarkerSize', 10, 'LineWidth', 1.5);
    end
    set(gca, 'YScale', 'log', 'FontSize', 11);
    xlim([min(PsdB) max(PsdB)]);  ylim([1e-8 1.5]);
    xlabel('P_s (dBW)');  ylabel('Outage probability');
    title(sprintf('Weak-user OP (%s): order %s, +%.2f dB', name, p.order, p.extra_gain_dB));
    h = gobjects(7,1);
    h(1) = plot(nan,nan,'ko'); h(2) = plot(nan,nan,'ks'); h(3) = plot(nan,nan,'kx','MarkerSize',10);
    h(4) = plot(nan,nan,'-','Color',cO,'LineWidth',1.4); h(5) = plot(nan,nan,'-','Color',cN,'LineWidth',1.4);
    h(6) = plot(nan,nan,'-','Color',cR,'LineWidth',1.4); h(7) = plot(nan,nan,'--k','LineWidth',1.2);
    legend(h, {'Sim T=1','Sim T=3','Paper Fig. 4 (read off)','OMA','NOMA', ...
               'RSMA upper bound','RSMA lower bound'}, 'Location','southwest');
    exportgraphics(gcf, sprintf('fig4_%s.png', name), 'Resolution', 200);
    save(sprintf('fig4_%s.mat', name), 'R', 'PsdB', 'p', 'N');
end
