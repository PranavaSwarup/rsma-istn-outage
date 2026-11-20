%% ========================================================================
%  File:        sr_channel_pdf_annotated.m
%  Reference:   C. Hu et al., "Outage Analysis of RSMA Enabled Integrated
%               Satellite-Terrestrial Networks," IEEE Trans. Veh. Technol.,
%               vol. 74, no. 6, pp. 10023-10028, June 2025.
%  Description: Generates small-scale Shadowed-Rician (S-R) fading samples
%               h_{k,t}, computes empirical PDF knots, performs PCHIP
%               interpolation with shaded probability area, and overlays
%               exact analytical PDFs (Eq. 4) plus on-plot annotations for
%               key statistical landmarks and the T=1 RSMA outage region.
%  Toolboxes:   None required. (randg needs the Statistics Toolbox, so the
%               Nakagami-m LoS power uses gamma_core below instead.)
%  Author:      Abel (team), added to week3 branch with the randg fix.
% =========================================================================
clc; clear; close all;
rng(2025);                            % reproducible figure

%% 1. System & Channel Parameters (Tagged [paper] vs. [ASSUMED])
% --- Shadowed-Rician (S-R) Average Shadowing (AS) Parameters [paper, Sec. IV] ---
b     = 0.126;   % Half average scatter/multipath power (2b = 0.252)     [paper]
m     = 10.1;    % Nakagami-m fading severity parameter of LoS component  [paper]
Omega = 0.835;   % Average power of Line-of-Sight (LoS) component         [paper]

% --- Derived S-R Distribution Constants [paper, Eq. (4)] ---
beta   = 1 / (2 * b);                                    % Exponential rate parameter (3.9683)
delta  = (1 / (2 * b)) * (Omega / (2 * b * m + Omega));   % Hypergeometric scale (0.9803)
lambda = (1 / (2 * b)) * ((2 * b * m) / (2 * b * m + Omega))^m; % Density at x=0 (0.2260)
mean_x = Omega + 2 * b;                                  % Theoretical mean E[|h_{k,t}|^2] = 1.087

% --- ISTN Link Budget Parameters [paper, Sec. II & Sec. IV] ---
d_Sk      = 1000e3;      % LEO satellite slant distance: 1000 km          [paper]
f_c       = 1.55e9;      % Carrier frequency: 1.55 GHz                    [paper]
B_w       = 50e6;        % Carrier bandwidth: 50 MHz                      [paper]
T_noise   = 290;         % System noise temperature: 290 K                [paper]
kappa     = 1.38e-23;    % Boltzmann constant (J/K)                       [paper]
N_0       = kappa * B_w * T_noise; % AWGN noise power (~2.001e-13 W)      [paper]
G_max_dBi = 25;          % Max satellite beam gain: 25 dBi                [paper]
G_r_dBi   = 5;           % User receive antenna gain: 5 dBi               [paper]
c_light   = 3e8;         % Speed of light (m/s)                           [ASSUMED]

% Beam-center large-scale channel-to-noise ratio g_k = G_k^2 / N_0 [paper, Eq. (3), (5)]
G_s = 10^(G_max_dBi / 10);
G_r = 10^(G_r_dBi / 10);
cal_G_k = (c_light * sqrt(G_s * G_r)) / (4 * pi * f_c * d_Sk); % Scaling factor G_k [paper, Eq. (3)]
g_k     = (cal_G_k^2) / N_0;                                   % g_k = 1.186 (0.74 dB) [paper]

% --- Worked Operating Point & Fig. 4 RSMA Settings [paper, Sec. IV, Fig. 4] ---
Ps_dBW     = 5;                        % Satellite transmit power: 5 dBW  [paper, Fig. 2/4]
P_s        = 10^(Ps_dBW / 10);         % Linear transmit power (3.1623 W)
rho        = P_s * g_k;                % Average per-round SNR factor (3.75)
alpha_c    = 0.4;                      % Common stream power allocation   [paper, Fig. 4]
alpha_k    = 0.3;                      % Private stream power (K=2 users) [paper, Fig. 4]
gamma_c_th = 0.4;                      % Common stream SINR threshold     [paper, Fig. 4]
gamma_p_th = 0.4;                      % Private stream SINR threshold    [paper, Fig. 4]

% Asymptotic SINR ceilings [paper, Theorem 1 & Corollary 1]
theta_kc = alpha_c / (1 - alpha_c);              % Common SINR ceiling = 2/3 (0.6667)
theta_kp = alpha_k / (1 - alpha_c - alpha_k);    % Private SINR ceiling = 1.0 (for K=2)

% Single-round (T=1) binding channel gain threshold x_th [Review Deck, Slides 12 & 17]
x_th_c = gamma_c_th / (rho * (alpha_c - (1 - alpha_c) * gamma_c_th)); % 2.50 / rho = 0.6667
x_th_p = gamma_p_th / (rho * (alpha_k - (1 - alpha_c - alpha_k) * gamma_p_th)); % 2.222 / rho
x_th   = max(x_th_c, x_th_p);          % Binding threshold x_{k,t} < 0.6667 for outage

%% 2. Monte Carlo Realization of S-R Fading Coefficient h_{k,t} (Matches sr_gain.m)
N_mc = 5e5;                            % Number of Monte Carlo channel realizations [ASSUMED]

% Physical S-R decomposition: h_{k,t} = LoS (Nakagami-m) + Multipath (Rayleigh)
A2_los = (Omega / m) * gamma_core(m, [1, N_mc]);                      % Nakagami-m LoS power |A|^2
Z_mp   = sqrt(b) * (randn(1, N_mc) + 1j * randn(1, N_mc));     % Complex Gaussian scatter Z
h_kt   = sqrt(A2_los) .* exp(1j * 2 * pi * rand(1, N_mc)) + Z_mp; % Complex channel h_{k,t}

r_kt = abs(h_kt);                      % Fading envelope |h_{k,t}| (Modified Rician)
x_kt = abs(h_kt).^2;                   % Fading power gain |h_{k,t}|^2 [paper, Eq. (4)]

%% 3. Empirical PDF Knots & Shape-Preserving Cubic (PCHIP) Interpolation
% --- A. Envelope PDF f_{|h_{k,t}|}(r) ---
[pdf_r_knots_raw, edges_r] = histcounts(r_kt, 28, 'Normalization', 'pdf');
r_emp_knots = 0.5 * (edges_r(1:end-1) + edges_r(2:end)); % Histogram bin centers

% Anchor at origin (0,0) because f_{|h_{k,t}|}(0) = 2*0*f_{|h|^2}(0) = 0
r_knots     = [0, r_emp_knots];
pdf_r_knots = [0, pdf_r_knots_raw];

r_grid       = linspace(0, max(r_emp_knots), 1000);           % Fine grid for shaded area
pdf_r_area   = interp1(r_knots, pdf_r_knots, r_grid, 'pchip', 0);

r_interp_pts = linspace(0.03, max(r_emp_knots), 90);          % Explicit interpolated markers
pdf_r_interp = interp1(r_knots, pdf_r_knots, r_interp_pts, 'pchip', 0);

% --- B. Power Gain PDF f_{|h_{k,t}|^2}(x) [paper, Eq. (4)] ---
[pdf_x_knots_raw, edges_x] = histcounts(x_kt, 32, 'Normalization', 'pdf');
x_emp_knots = 0.5 * (edges_x(1:end-1) + edges_x(2:end)); % Histogram bin centers

% Extrapolate first 4 knots to x = 0 so area meets analytical intercept f(0) = lambda
pdf_x_zero  = interp1(x_emp_knots(1:4), pdf_x_knots_raw(1:4), 0, 'pchip', 'extrap');
x_knots     = [0, x_emp_knots];
pdf_x_knots = [pdf_x_zero, pdf_x_knots_raw];

x_grid       = linspace(0, max(x_emp_knots), 1000);           % Fine grid for shaded area
pdf_x_area   = interp1(x_knots, pdf_x_knots, x_grid, 'pchip', 0);

x_interp_pts = linspace(0.06, max(x_emp_knots), 90);          % Explicit interpolated markers
pdf_x_interp = interp1(x_knots, pdf_x_knots, x_interp_pts, 'pchip', 0);

%% 4. Exact Analytical PDFs & Closed-Form T=1 Outage Probability [paper, Eq. (4)]
f_x_exact = eval_sr_power_pdf(x_grid, lambda, beta, delta, m);         % Eq. (4) PDF
f_r_exact = 2 .* r_grid .* eval_sr_power_pdf(r_grid.^2, lambda, beta, delta, m); % Jacobian

% Compute T=1 RSMA outage probability P_k^1 = Pr{|h_{k,t}|^2 < x_th}
idx_out   = x_grid <= x_th;
OP_interp = trapz(x_grid(idx_out), pdf_x_area(idx_out)); % Numerical area under PCHIP PDF
OP_exact  = eval_sr_cdf(x_th, 1, b, m, Omega);           % Exact Gamma-mixture CDF F_1(x_th)

fprintf('=== Hu et al. (IEEE TVT 2025) Shadowed-Rician Verification ===\n');
fprintf('Link budget g_k = %.4f (%.2f dB) | rho at %d dBW = %.4f\n', g_k, 10*log10(g_k), Ps_dBW, rho);
fprintf('Analytical constants: lambda = %.4f, beta = %.4f, delta = %.4f\n', lambda, beta, delta);
fprintf('Total integrated PDF area (|h| vs |h|^2): %.4f vs %.4f\n', ...
        trapz(r_grid, pdf_r_area), trapz(x_grid, pdf_x_area));
fprintf('T=1 Outage Prob at x_th = %.4f: Interpolated Area = %.4f | Exact F_1 = %.4f\n', ...
        x_th, OP_interp, OP_exact);

%% 5. Visualization with Paper Notations & On-Plot Annotations
fig = figure('Color', 'w', 'Position', [60, 80, 1280, 520]);

% =========================================================================
% SUBPLOT 1: Modified Rician Fading Envelope |h_{k,t}|
% =========================================================================
ax1 = subplot(1, 2, 1);
area(r_grid, pdf_r_area, 'FaceColor', [0.12 0.47 0.71], 'FaceAlpha', 0.20, ...
     'EdgeColor', [0.12 0.47 0.71], 'LineWidth', 1.8);
hold on;
plot(r_grid, f_r_exact, '--', 'Color', [0.49 0.18 0.56], 'LineWidth', 1.8);
plot(r_interp_pts, pdf_r_interp, '.', 'Color', [0.00 0.35 0.65], 'MarkerSize', 10);
plot(r_emp_knots, pdf_r_knots_raw, 'o', 'Color', [0.85 0.33 0.10], ...
     'MarkerFaceColor', [1.00 0.85 0.75], 'MarkerSize', 6, 'LineWidth', 1.4);

% Annotate peak mode of envelope PDF
[r_peak_val, idx_r_pk] = max(f_r_exact);
r_peak_loc = r_grid(idx_r_pk);
plot(r_peak_loc, r_peak_val, 'kp', 'MarkerFaceColor', 'y', 'MarkerSize', 9);
text(r_peak_loc + 0.18, r_peak_val - 0.03, ...
     sprintf('\\leftarrow Mode: r = %.2f\n     f_{|h_{k,t}|}(r) = %.2f', r_peak_loc, r_peak_val), ...
     'FontSize', 9, 'Color', 'k', 'FontWeight', 'bold');

% Parameter summary callout box [paper, Sec. IV]
text(1.48, 0.68, { ...
    '\bf{AS Channel [paper, Sec. IV]}', ...
    sprintf('b = %.3f, m = %.1f, \\Omega = %.3f', b, m, Omega), ...
    'f_{|h_{k,t}|}(r) = 2r f_{|h_{k,t}|^2}(r^2)', ...
    sprintf('\\int f_{|h_{k,t}|}(r)dr = %.4f', trapz(r_grid, pdf_r_area))}, ...
    'FontSize', 8.5, 'Color', 'k', 'BackgroundColor', [0.97 0.98 1.00], ...
    'EdgeColor', [0.5 0.6 0.7], 'Margin', 5);

set(ax1, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.82 0.82 0.82]);
grid on;
xlim([0, 2.8]); ylim([0, 1.22]);
xlabel('Fading Envelope r = |h_{k,t}|', 'Color', 'k', 'FontWeight', 'bold');
ylabel('PDF f_{|h_{k,t}|}(r)', 'Color', 'k', 'FontWeight', 'bold');
title('Modified Rician Envelope PDF of |h_{k,t}| (Hu et al., 2025)', 'Color', 'k');
legend('Interpolated PDF Area (PCHIP)', 'Exact Analytical PDF', ...
       'Interpolated Points', 'Empirical Histogram Knots', ...
       'Location', 'northeast', 'TextColor', 'k', 'Color', 'w');

% =========================================================================
% SUBPLOT 2: Shadowed-Rician Power Gain |h_{k,t}|^2 [paper, Eq. (4)]
% =========================================================================
ax2 = subplot(1, 2, 2);
% Full interpolated PDF area
area(x_grid, pdf_x_area, 'FaceColor', [0.00 0.62 0.45], 'FaceAlpha', 0.18, ...
     'EdgeColor', [0.00 0.62 0.45], 'LineWidth', 1.8);
hold on;
% Shaded outage probability region Pr{|h_{k,t}|^2 < x_th} for T=1, Ps=5 dBW
area(x_grid(idx_out), pdf_x_area(idx_out), 'FaceColor', [0.85 0.20 0.20], ...
     'FaceAlpha', 0.28, 'EdgeColor', [0.85 0.20 0.20], 'LineWidth', 1.5);

plot(x_grid, f_x_exact, '--', 'Color', [0.49 0.18 0.56], 'LineWidth', 1.8);
plot(x_interp_pts, pdf_x_interp, '.', 'Color', [0.00 0.45 0.30], 'MarkerSize', 10);
plot(x_emp_knots, pdf_x_knots_raw, 'o', 'Color', [0.85 0.33 0.10], ...
     'MarkerFaceColor', [1.00 0.85 0.75], 'MarkerSize', 6, 'LineWidth', 1.4);

% Mark theoretical mean E[|h_{k,t}|^2] = Omega + 2b = 1.087
xline(mean_x, ':', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.5);

% Annotate origin intercept f(0) = lambda [paper, Eq. (4)]
plot(0, lambda, 'bs', 'MarkerFaceColor', 'c', 'MarkerSize', 7);
text(0.15, lambda - 0.02, sprintf('\\leftarrow f_{|h_{k,t}|^2}(0) = \\lambda = %.3f', lambda), ...
     'FontSize', 8.5, 'Color', 'k', 'FontWeight', 'bold');

% Annotate theoretical mean
text(mean_x + 0.12, 0.47, sprintf('\\leftarrow Mean E[|h_{k,t}|^2] = \\Omega+2b = %.3f', mean_x), ...
     'FontSize', 8.5, 'Color', 'k');

% Annotate T=1 outage threshold & shaded outage area [Review Deck, Slide 14]
text(0.08, 0.08, sprintf('Outage Area (T=1, 5 dBW)\nx < x_{th}=%.2f: P_k^1 = %.3f', ...
     x_th, OP_exact), 'FontSize', 8.2, 'Color', [0.65 0.05 0.05], 'FontWeight', 'bold');

set(ax2, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.82 0.82 0.82]);
grid on;
xlim([0, 7.2]); ylim([0, 0.70]);
xlabel('Channel Power Gain x = |h_{k,t}|^2', 'Color', 'k', 'FontWeight', 'bold');
ylabel('PDF f_{|h_{k,t}|^2}(x)', 'Color', 'k', 'FontWeight', 'bold');
title('Shadowed-Rician Gain PDF f_{|h_{k,t}|^2}(x) [paper, Eq. (4)]', 'Color', 'k');
legend('Interpolated PDF Area', 'T=1 Outage Region (x < 2.5/\rho)', ...
       'Exact Analytical PDF (Eq. 4)', 'Interpolated Points', 'Empirical Knots', ...
       'Location', 'northeast', 'TextColor', 'k', 'Color', 'w');
saveas(fig, 'sr_rician.png');

%% ========================================================================
%  Local Helper 1: Exact Shadowed-Rician PDF [paper, Eq. (4)]
%  Evaluates f_{|h_{k,t}|^2}(x) = lambda * exp(-beta*x) * 1F1(m; 1; delta*x)
% =========================================================================
function f = eval_sr_power_pdf(x, lambda, beta, delta, m)
    term = ones(size(x));
    F11  = term;
    for n = 1:150
        term = term .* ((m + n - 1) .* delta .* x) ./ (n^2);
        F11  = F11 + term;
        if max(abs(term(:))) < 1e-14
            break;
        end
    end
    f = lambda .* exp(-beta .* x) .* F11;
end

%% ========================================================================
%  Local Helper 2: Exact Shadowed-Rician CDF F_T(z) [Review Deck, Slide 14]
%  Gamma-mixture series expansion of 1F1 for T=1 round:
%  F_1(z) = sum_{n=0}^{inf} w_n * gammainc(beta * z, n + 1, 'lower')
% =========================================================================
function F = eval_sr_cdf(z, T, b, m, Omega)
    beta   = 1 / (2 * b);
    delta  = (1 / (2 * b)) * (Omega / (2 * b * m + Omega));
    lambda = (1 / (2 * b)) * ((2 * b * m) / (2 * b * m + Omega))^m;

    % Compute Gamma-mixture weights w_n for single round (T = 1)
    N_terms = 120;
    n_vec   = 0:N_terms-1;
    poch    = gamma(m + n_vec) ./ gamma(m);
    w_n     = lambda .* poch .* (delta.^n_vec) ./ (factorial(n_vec) .* (beta.^(n_vec + 1)));

    if T == 1
        F = sum(w_n .* gammainc(beta .* z, n_vec + 1, 'lower'));
    else
        % T-fold discrete convolution of weights for T HARQ-CC rounds
        w_T = w_n;
        for round_idx = 2:T
            w_T = conv(w_T, w_n);
        end
        k_vec = 0:length(w_T)-1;
        F = sum(w_T .* gammainc(beta .* z, k_vec + T, 'lower'));
    end
end

%% ========================================================================
%  Local Helper 3: Gamma(shape a, scale 1) samples without any toolbox
%  Marsaglia & Tsang (2000); same sampler as sr_gain.m
% =========================================================================
function g = gamma_core(a, sz)
    if a < 1
        g = gamma_core(a + 1, sz) .* rand(sz).^(1/a);
        return;
    end
    d = a - 1/3;  c = 1/sqrt(9*d);
    g = zeros(sz);  todo = true(sz);
    while any(todo(:))
        k = nnz(todo);
        z = randn(k, 1);  v = (1 + c*z).^3;  u = rand(k, 1);
        ok = v > 0;
        ok(ok) = log(u(ok)) < 0.5*z(ok).^2 + d - d*v(ok) + d*log(v(ok));
        idx = find(todo);
        g(idx(ok)) = d * v(ok);
        todo(idx(ok)) = false;
    end
end
