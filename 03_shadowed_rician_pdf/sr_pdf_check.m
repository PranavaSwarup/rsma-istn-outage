%% SR_PDF_CHECK  Shadowed-Rician |h|^2: simulation vs analysis, and how to
% recognise the distribution from its graph.
%
% Figure 1 - validation (paper's average-shadowing parameters, Hu et al.):
%   (a) histogram of N samples from sr_gain.m  vs  the eq. (4) PDF
%   (b) same on a log y-axis (shows the tail)
%   (c) empirical CDF vs closed-form CDF (sr_cdf.m)
% Figure 2 - shape guide: S-R with heavy / average / light shadowing next to
%   Rayleigh and Rician, all scaled to unit mean power so only SHAPE differs.
clear; clc;
here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, '..', '01_fig4_monte_carlo'));      % istn_params, sr_gain
addpath(fullfile(here, '..', '02_sinr_closed_form_outage'));% sr_cdf

p = istn_params();
N = 1e6;
rng(p.seed);
x = sr_gain([N 1], p);

fprintf('Shadowed-Rician, average shadowing: b = %.3f, m = %.1f, Omega = %.3f\n', p.b, p.m, p.Omega);
fprintf('E|h|^2  sim = %.4f   theory 2b+Omega = %.4f\n', mean(x), 2*p.b + p.Omega);

%% ---------------- Figure 1: simulation vs analysis
edges = linspace(0, 4, 81);
cnt   = histcounts(x, edges);
ctr   = (edges(1:end-1) + edges(2:end))/2;
fsim  = cnt / (N * diff(edges(1:2)));          % normalised histogram = PDF estimate
xg    = linspace(0, 4, 400);
fth   = sr_pdf(xg, p);

xs   = sort(x);  Femp = (1:N)'/N;
xc   = linspace(0, 4, 200);
Fth  = sr_cdf(xc, p);
Fe   = interp1(xs, Femp, xc, 'linear', 0);
fprintf('max |F_sim - F_eq4| on [0,4] = %.2e\n', max(abs(Fe - Fth)));
fprintf('integral of eq.(4) PDF on [0,20] = %.5f (should be 1)\n', trapz(linspace(0,20,4000), sr_pdf(linspace(0,20,4000), p)));

figure('Color','w', 'Position', [80 80 1250 380]);
subplot(1,3,1); hold on; box on; grid on;
bar(ctr, fsim, 1, 'FaceColor', [0.75 0.82 0.95], 'EdgeColor', 'none');
plot(xg, fth, 'r-', 'LineWidth', 1.8);
xlabel('x = |h|^2'); ylabel('f_{|h|^2}(x)');
title('(a) PDF: simulation vs eq. (4)'); legend('Simulation (histogram)', 'Analysis, eq. (4)');

subplot(1,3,2); hold on; box on; grid on;
ok = fsim > 0;
semilogy(ctr(ok), fsim(ok), 'bo', 'MarkerSize', 5);
semilogy(xg, fth, 'r-', 'LineWidth', 1.8);
set(gca, 'YScale', 'log');
xlabel('x = |h|^2'); ylabel('f_{|h|^2}(x)');
title('(b) Same, log scale (tail)'); legend('Simulation', 'Analysis');

subplot(1,3,3); hold on; box on; grid on;
plot(xc(1:8:end), Fe(1:8:end), 'bo', 'MarkerSize', 5);
plot(xc, Fth, 'r-', 'LineWidth', 1.8);
xlabel('x = |h|^2'); ylabel('F_{|h|^2}(x)');
title('(c) CDF: simulation vs closed form'); legend('Simulation', 'Analysis', 'Location', 'southeast');
saveas(gcf, 'sr_pdf_validation.png');

%% ---------------- Figure 2: shape guide (all unit mean)
% S-R parameter sets (Abdi et al. 2003): heavy (FHS), average (AS), light (ILS)
sets = { 'Heavy shadowing',   0.063, 0.739, 8.97e-4;
         'Average shadowing', 0.126, 10.1,  0.835;     % the paper's
         'Light shadowing',   0.158, 19.4,  1.29 };
xg = linspace(0, 4, 600);
figure('Color','w', 'Position', [80 520 1000 420]);
subplot(1,2,1); hold on; box on; grid on;
cols = lines(5);
for s = 1:size(sets,1)
    q.b = sets{s,2}; q.m = sets{s,3}; q.Omega = sets{s,4};
    c = 2*q.b + q.Omega;                 % mean power -> scale to 1
    q.b = q.b/c;  q.Omega = q.Omega/c;
    plot(xg, sr_pdf(xg, q), '-', 'Color', cols(s,:), 'LineWidth', 1.8, ...
         'DisplayName', sprintf('S-R: %s (m = %.3g, \\Omega/2b = %.2g)', sets{s,1}, sets{s,3}, sets{s,4}/(2*sets{s,2})));
end
% Rayleigh (no LOS): f(x) = exp(-x)
plot(xg, exp(-xg), 'k--', 'LineWidth', 1.4, 'DisplayName', 'Rayleigh');
% Rician with the same LOS/scatter ratio as average shadowing, LOS NOT fluctuating
K  = p.Omega/(2*p.b);
fr = (1+K)*exp(-K-(1+K)*xg).*besseli(0, 2*sqrt(K*(1+K)*xg));
plot(xg, fr, 'k:', 'LineWidth', 1.8, 'DisplayName', sprintf('Rician, K = %.2f', K));
xlabel('x = |h|^2 (unit mean)'); ylabel('PDF'); legend('Location','northeast');
title('Shape: shadowing moves S-R between Rayleigh and Rician');

subplot(1,2,2); hold on; box on; grid on;
for s = 1:size(sets,1)
    q.b = sets{s,2}; q.m = sets{s,3}; q.Omega = sets{s,4};
    c = 2*q.b + q.Omega;  q.b = q.b/c;  q.Omega = q.Omega/c;
    semilogy(xg, sr_pdf(xg, q), '-', 'Color', cols(s,:), 'LineWidth', 1.8);
end
semilogy(xg, exp(-xg), 'k--', 'LineWidth', 1.4);
semilogy(xg, fr, 'k:', 'LineWidth', 1.8);
set(gca,'YScale','log'); ylim([1e-4 3]);
xlabel('x = |h|^2 (unit mean)'); ylabel('PDF (log)');
title('Log scale: near-zero value and tail');
saveas(gcf, 'sr_shape_guide.png');

fprintf('\nf(0) = lambda = %.4f (finite, non-zero: deep fades are possible)\n', sr_pdf(0, p));
xa = linspace(0, 4, 4001);  [~, imax] = max(sr_pdf(xa, p));
fprintf('PDF peak at x = %.3f (hump from the LOS part)\n', xa(imax));
