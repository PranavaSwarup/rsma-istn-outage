%% FIG4_CALIBRATED  Can the model match the published Fig. 4? Only with an
% unstated gain offset, and that offset then breaks Fig. 2.
%
% 1) Fit an extra gain (dB, added to g) to the T = 1 points read off Fig. 4
%    (paper_fig4_points, reading error ~10-20 %), using the exact closed form.
% 2) Compare T = 1 and T = 3 against the paper at 0 dB and at the fitted offset.
% 3) Check the paper's Fig. 2 text value (K = 3, Ps = 5 dBW, true OP 8.74e-3,
%    bounds 8.5e-3 / 8.9e-3; only consistent with T = 3) at both settings.
%
% The offset is a CALIBRATION, not physics: the stated link budget gives
% g = 1.186 (0.74 dB). Default code stays at 0 dB.
% Weak-user ordering: 'round' (the only ordering under which the paper's T = 3
% ranking RSMA < NOMA < OMA appears; see ordering_compare.m).
clear; clc;
setup_extra_paths();
p0 = istn_params();  p0.order = 'round';
P  = paper_fig4_points();
lg = @(v) log10(max(v, 1e-12));

%% 1) Fit the offset on T = 1 (closed form, exact)
offs = 0:0.25:8;
err  = zeros(size(offs));
for i = 1:numel(offs)
    p = p0;  p.g = p0.g * 10^(offs(i)/10);
    cf = op_closed_form_T1(P.T1.Ps, p);
    d  = [lg(cf.oma_weak) - lg(P.T1.oma), lg(cf.noma_far) - lg(P.T1.noma), ...
          lg(cf.rsma_user) - lg(P.T1.rsma)];
    err(i) = sqrt(mean(d.^2));
end
[emin, ib] = min(err);
off = offs(ib);
fprintf('Fit of an extra gain to Fig. 4, T = 1 (rms error in decades)\n');
fprintf('  0 dB (paper link budget): %.3f    best: %.2f dB -> %.3f\n\n', err(1), off, emin);

%% 2) Compare with the paper, T = 1 (closed form) and T = 3 (Monte Carlo)
N = 2e6;
names = {'stated link budget (0 dB)', sprintf('calibrated (+%.2f dB)', off)};
gains = [0 off];
for c = 1:2
    p = p0;  p.g = p0.g * 10^(gains(c)/10);
    cf = op_closed_form_T1(P.T1.Ps, p);
    fprintf('=== %s ===\nT = 1      OMA ours/paper       NOMA ours/paper      RSMA ours/paper\n', names{c});
    for i = 1:numel(P.T1.Ps)
        fprintf('  %3d dBW   %.3f / %.3f        %.3f / %.3f        %.3f / %.3f\n', P.T1.Ps(i), ...
            cf.oma_weak(i), P.T1.oma(i), cf.noma_far(i), P.T1.noma(i), cf.rsma_user(i), P.T1.rsma(i));
    end
    use = P.T3.Ps <= 5;                              % lower OP needs N >> 2e6
    mc = mc_outage(P.T3.Ps(use), 3, N, p);
    fprintf('T = 3      OMA ours/paper       NOMA ours/paper      RSMA ours/paper\n');
    k = find(use);
    for j = 1:numel(k)
        i = k(j);
        fprintf('  %3d dBW   %.1e / %.1e    %.1e / %.1e    %.1e / %.1e\n', P.T3.Ps(i), ...
            mc.oma_weak(j), P.T3.oma(i), mc.noma_far(j), P.T3.noma(i), mc.rsma_user(j), P.T3.rsma(i));
    end
    fprintf('\n');
end

%% 3) The same offset applied to the paper's Fig. 2 point (K = 3, T = 3, 5 dBW)
fprintf('=== Fig. 2 check: K = 3, T = 3, Ps = 5 dBW (paper: true 8.74e-3, bounds 8.5e-3 to 8.9e-3) ===\n');
for c = 1:2
    p = p0;  p.alpha_p = [0.2 0.2 0.2];  p.g = p0.g * 10^(gains(c)/10);
    mc = mc_outage(5, 3, N, p);
    fprintf('  %-28s true %.2e   bounds %.2e to %.2e\n', names{c}, mc.rsma_user, ...
        max(mc.rsma_PrA1, mc.rsma_PrA2), min(mc.rsma_PrA1 + mc.rsma_PrA2, 1));
end
fprintf(['\nConclusion: 0 dB reproduces Fig. 2; about +5 dB is needed for Fig. 4.\n' ...
         'No single setting matches both, so the paper''s Fig. 4 uses an unstated setting.\n']);
