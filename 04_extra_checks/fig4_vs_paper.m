%% FIG4_VS_PAPER  Why our Fig. 4 does not match the paper: one figure + 4 checks.
%
% Figure: our weak-user curves (T = 1 exact closed form, T = 3 Monte Carlo)
%   at the stated link budget (0 dB, solid) and with the +5.5 dB offset that
%   best fits the paper's T = 1 points (dashed), against the points read off
%   the published Fig. 4 (markers, paper_fig4_points).
% Checks printed:
%   1) Lower-bound check: OP >= Pr{A1} = F(2.5/rho) at T = 1 (exact).
%   2) Bound-gap check (no link budget involved): at T = 1, K = 2,
%      upper/lower = 1 + F(2.22/rho)/F(2.5/rho) >= 1.86 at EVERY power.
%   3) Fig. 3 vs Fig. 4: same parameters (K = 2, 10 dBW, T = 1).
%   4) The +5.5 dB offset applied to the paper's Fig. 2 text value.
clear; clc;
setup_extra_paths();
p0 = istn_params();  p0.order = 'round';
P  = paper_fig4_points();
off = 5.5;                                  % from fig4_calibrated.m
Ps1 = -20:0.5:10;  Ps3 = -10:2.5:10;  N = 2e6;
nz  = @(v) v ./ (v > 0);

cols = struct('oma', [0.85 0.10 0.10], 'noma', [0.05 0.60 0.05], 'rsma', [0.10 0.20 0.85]);
figure('Color', 'w', 'Position', [80 80 1250 500]);
gains = [0 off];  ls = {'-', '--'};
for T = [1 3]
    subplot(1, 2, (T > 1) + 1); hold on; box on; grid on;
    for c = 1:2
        p = p0;  p.g = p0.g * 10^(gains(c)/10);
        if T == 1
            r = op_closed_form_T1(Ps1, p);  x = Ps1;
            o = r.oma_weak;  nm = r.noma_far;  rs = r.rsma_user;
        else
            r = mc_outage(Ps3, 3, N, p);  x = Ps3;
            o = r.oma_weak;  nm = r.noma_far;  rs = r.rsma_user;
        end
        semilogy(x, nz(o),  ls{c}, 'Color', cols.oma,  'LineWidth', 1.6);
        semilogy(x, nz(nm), ls{c}, 'Color', cols.noma, 'LineWidth', 1.6);
        semilogy(x, nz(rs), ls{c}, 'Color', cols.rsma, 'LineWidth', 1.6);
    end
    if T == 1, d = P.T1; else, d = P.T3; end
    semilogy(d.Ps, d.oma,  'o', 'Color', cols.oma,  'MarkerSize', 9, 'LineWidth', 1.6);
    semilogy(d.Ps, d.noma, 's', 'Color', cols.noma, 'MarkerSize', 9, 'LineWidth', 1.6);
    semilogy(d.Ps, d.rsma, 'd', 'Color', cols.rsma, 'MarkerSize', 9, 'LineWidth', 1.6);
    set(gca, 'YScale', 'log', 'FontSize', 12);
    xlim([-20 10]);  if T == 1, ylim([1e-3 1.2]); else, ylim([1e-8 1.2]); end
    xlabel('P_s (dBW)');  ylabel('Weak-user outage probability');
    title(sprintf('T = %d: ours (solid 0 dB, dashed +%.1f dB) vs paper (markers)', T, off));
    h = gobjects(1, 5);
    h(1) = plot(nan, nan, '-', 'Color', cols.oma, 'LineWidth', 1.6);
    h(2) = plot(nan, nan, '-', 'Color', cols.noma, 'LineWidth', 1.6);
    h(3) = plot(nan, nan, '-', 'Color', cols.rsma, 'LineWidth', 1.6);
    h(4) = plot(nan, nan, 'k-', 'LineWidth', 1.6);
    h(5) = plot(nan, nan, 'k--', 'LineWidth', 1.6);
    legend(h, {'OMA', 'NOMA', 'RSMA', 'ours, stated link budget', sprintf('ours, +%.1f dB', off)}, ...
           'Location', 'southwest');
end
try, theme(gcf, 'light'); catch, end
saveas(gcf, 'fig4_vs_paper.png');

%% Check 1: OP >= Pr{A1} at T = 1
r = op_closed_form_T1([0 5 10], p0);
fprintf('Check 1 (T = 1, stated link budget): RSMA OP = Pr{A1} exactly\n');
fprintf('  Ps(dBW)  ours Pr{A1} = OP   paper Fig. 4\n');
for i = 1:3, fprintf('  %4d     %.4f             %.3f\n', 5*(i-1), r.rsma_PrA1(i), P.T1.rsma(i)); end

%% Check 2: upper/lower bound ratio at T = 1, K = 2, over a wide power range
Pw = -10:1:40;  r = op_closed_form_T1(Pw, p0);
ratio = min(r.rsma_PrA1 + r.rsma_PrA2, 1) ./ max(r.rsma_PrA1, r.rsma_PrA2);
ok = min(r.rsma_PrA1 + r.rsma_PrA2, 1) < 1;      % where the upper bound is not clipped at 1
fprintf('\nCheck 2 (no link budget needed): T = 1, K = 2, upper/lower bound ratio\n');
fprintf('  min over %d..%d dBW (upper < 1): %.3f   at 5 dBW: %.3f   at 10 dBW: %.3f\n', ...
        min(Pw(ok)), max(Pw(ok)), min(ratio(ok)), ratio(Pw == 5), ratio(Pw == 10));
fprintf('  Paper Fig. 4 inset at 5 dBW: upper ~0.066, lower ~0.061 -> ratio ~1.08\n');

%% Check 3: Fig. 3 vs Fig. 4, same parameters (K = 2, 10 dBW, T = 1)
r = op_closed_form_T1(10, p0);
fprintf('\nCheck 3: K = 2, Ps = 10 dBW, T = 1 (identical settings in Fig. 3 and Fig. 4)\n');
fprintf('  ours: lower %.3f, upper %.3f | paper Fig. 3: lower ~0.07, upper ~0.15 | paper Fig. 4: ~0.017\n', ...
        r.rsma_PrA1, min(r.rsma_PrA1 + r.rsma_PrA2, 1));

%% Check 4: the offset vs the paper's Fig. 2 text value (K = 3, T = 3, 5 dBW)
fprintf('\nCheck 4: Fig. 2 text value, K = 3, T = 3, 5 dBW (paper: 8.74e-3)\n');
for c = 1:2
    p = p0;  p.alpha_p = [0.2 0.2 0.2];  p.g = p0.g * 10^(gains(c)/10);
    m = mc_outage(5, 3, N, p);
    fprintf('  offset %+4.1f dB: ours %.2e\n', gains(c), m.rsma_user);
end
