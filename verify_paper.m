%% VERIFY_PAPER  Numerical checks of Hu et al. (IEEE TVT 2025) used in the verification notes.
% Needs: istn_params.m  sr_gain.m  sr_cdf.m  closed_form_T1.m  rsma_bounds_analytic.m
clear; clc;
p = istn_params();
N = 4e6;  rng(1);

%% 1. T = 1: exact closed forms vs Monte Carlo (all three schemes)
PsdB = [0 5 10];
cf = closed_form_T1(PsdB, p);
fprintf('T = 1, closed form vs Monte Carlo\n');
fprintf(' Ps   OMA-weak(CF/MC)        NOMA-far(CF/MC)        NOMA-near(CF/MC)       RSMA(CF/MC)\n');
x1 = sr_gain([1 N], p);  x2 = sr_gain([1 N], p);
xw = min(x1,x2);  xs = max(x1,x2);
for i = 1:numel(PsdB)
    rho = 10^(PsdB(i)/10)*p.g;
    mO = mean(rho*xw < p.g_oma);
    mF = mean(p.a1_noma*rho*xw./(p.a2_noma*rho*xw+1) < p.g_noma);
    mS = mean((p.a1_noma*rho*xs./(p.a2_noma*rho*xs+1) < p.g_noma) | (p.a2_noma*rho*xs < p.g_noma));
    gc = 0.4*rho*x1./(0.6*rho*x1+1);  gp = 0.3*rho*x1./(0.3*rho*x1+1);
    mR = mean(gc < 0.4 | gp < 0.4);
    fprintf('%3d  %.3e/%.3e  %.3e/%.3e  %.3e/%.3e  %.3e/%.3e\n', PsdB(i), ...
        cf.oma_weak(i), mO, cf.noma_far(i), mF, cf.noma_near(i), mS, cf.rsma(i), mR);
end

%% 2. Paper's eq (9)/(11) vs Monte Carlo (K = 3, Fig. 2 setting)
fprintf('\nEq (9)/(11) as printed (N = 20, M = 10) vs Monte Carlo, K = 3\n');
cases = {'A1',5,3,0.4,0.6; 'A2',5,3,0.2,0.4; 'A2',10,3,0.2,0.4; 'A2',10,2,0.2,0.4};
for c = 1:size(cases,1)
    [nm,Ps,T,a,bI] = cases{c,:};
    x  = sr_gain([T N], p);  rho = 10^(Ps/10)*p.g;
    mc = mean(sum(a*rho*x./(bI*rho*x+1),1) < 0.4);
    gs = rsma_bounds_analytic(Ps, T, a, bI, 0.4, p, 'gs');
    st = rsma_bounds_analytic(Ps, T, a, bI, 0.4, p, 'step');
    fprintf('%s  %2d dBW T=%d  MC %.3e   eq(G-S) %.3e   step %.3e\n', nm, Ps, T, mc, gs, st);
end

%% 3. Fig. 3 (K = 2) vs Fig. 4: same parameters, 10 dBW
fprintf('\nK = 2, alpha_k = 0.3, 10 dBW (the setting shared by Fig. 3 at K = 2 and Fig. 4)\n');
for T = [1 3]
    [OP, A1, A2] = rsma_outage(10, T, 1e7, p);
    fprintf('T=%d  OP %.3e   lower %.3e   upper %.3e\n', T, OP, max(A1,A2), min(A1+A2,1));
end
fprintf('Paper Fig. 3 (K=2): T=1 ~0.105 (bounds 0.07/0.14), T=3 ~1.8e-5\n');
fprintf('Paper Fig. 4      : T=1 ~0.017,                    T=3 ~7e-8\n');
