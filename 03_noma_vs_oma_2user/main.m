% MAIN  NOMA vs OMA outage, 2 users, single transmission, Shadowed-Rician.
% Edit params.m, then run this script. Figures are also saved to figures/.
%
%   Fig 1: NOMA vs OMA, analysis only        (lines + squares)
%   Fig 2: NOMA vs OMA, simulation only      (stars)
%   Fig 3: NOMA, analysis vs simulation, with relative-error panel
%   Fig 4: OMA,  analysis vs simulation, with relative-error panel

clear; close all;   % (helpers live in their own .m files so this runs in MATLAB and Octave)
p = params();

fprintf('rho = Ps*g, g = %.3f | a1 = %.2f, a2 = %.2f | R1 = %.3f, R2 = %.3f\n', ...
        p.g, p.a1, p.a2, p.R1, p.R2);
fprintf('NOMA thresholds: gth1 = %.3f, gth2 = %.3f, ceiling a1/a2 = %.3f\n', ...
        p.gth1, p.gth2, p.theta);
fprintf('OMA  thresholds: weak = %.3f, strong = %.3f\n', p.gth1OMA, p.gth2OMA);

A = outage_analysis(p);
tic; S = outage_simulation(p); fprintf('Simulation: %d trials, %.1f s\n', p.N, toc);

Ps = p.PsdB;
% Colour = scheme, line style = user, marker = method
cN = [0.00 0.45 0.74];   % NOMA colour (blue)
cO = [0.85 0.15 0.15];   % OMA colour  (red)
% weak user = solid line '-', strong user = dashed line '--'
% analysis  = squares 's',     simulation  = stars '*'
if ~exist('figures', 'dir'), mkdir('figures'); end
fl = 1/p.N;              % floor: smallest outage the simulation can show

%% ---------------- Fig 1: analysis only
figure('Name', 'Fig 1 - analysis');
semilogy(Ps, A.noma_w, '-s',  'Color', cN, 'DisplayName', 'NOMA weak');  hold on;
semilogy(Ps, A.noma_s, '--s', 'Color', cN, 'DisplayName', 'NOMA strong');
semilogy(Ps, A.oma_w,  '-s',  'Color', cO, 'DisplayName', 'OMA weak');
semilogy(Ps, A.oma_s,  '--s', 'Color', cO, 'DisplayName', 'OMA strong');
style_axes('NOMA vs OMA - analysis', fl);
saveas(gcf, fullfile('figures', 'fig1_analysis_noma_vs_oma.png'));

%% ---------------- Fig 2: simulation only
figure('Name', 'Fig 2 - simulation');
semilogy(Ps, pos_nan(S.noma_w), '-*',  'Color', cN, 'DisplayName', 'NOMA weak');  hold on;
semilogy(Ps, pos_nan(S.noma_s), '--*', 'Color', cN, 'DisplayName', 'NOMA strong');
semilogy(Ps, pos_nan(S.oma_w),  '-*',  'Color', cO, 'DisplayName', 'OMA weak');
semilogy(Ps, pos_nan(S.oma_s),  '--*', 'Color', cO, 'DisplayName', 'OMA strong');
style_axes(sprintf('NOMA vs OMA - simulation (N = %g)', p.N), fl);
saveas(gcf, fullfile('figures', 'fig2_simulation_noma_vs_oma.png'));

%% ---------------- Fig 3: NOMA, analysis vs simulation
compare_plot(Ps, A.noma_w, S.noma_w, A.noma_s, S.noma_s, cN, ...
             'NOMA - analysis vs simulation', fl);
saveas(gcf, fullfile('figures', 'fig3_noma_analysis_vs_simulation.png'));

%% ---------------- Fig 4: OMA, analysis vs simulation
compare_plot(Ps, A.oma_w, S.oma_w, A.oma_s, S.oma_s, cO, ...
             'OMA - analysis vs simulation', fl);
saveas(gcf, fullfile('figures', 'fig4_oma_analysis_vs_simulation.png'));

%% ---------------- Table in the command window
fprintf('\n Ps(dBW) | NOMA weak ana/sim     | NOMA strong ana/sim   | OMA weak ana/sim      | OMA strong ana/sim\n');
for i = 1:numel(Ps)
    fprintf('%7.0f  | %.3e / %.3e | %.3e / %.3e | %.3e / %.3e | %.3e / %.3e\n', Ps(i), ...
        A.noma_w(i), S.noma_w(i), A.noma_s(i), S.noma_s(i), ...
        A.oma_w(i),  S.oma_w(i),  A.oma_s(i),  S.oma_s(i));
end
