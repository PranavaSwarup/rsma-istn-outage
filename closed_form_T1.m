function out = closed_form_T1(PsdB, p)
% CLOSED_FORM_T1  Exact outage probabilities for T = 1 (no retransmission).
% With one round every SINR is a monotone function of a single |h|^2, so each
% outage event is { |h|^2 < c } and the OP is just a CDF value. Weak/strong
% users are the min/max of two i.i.d. gains: F_min = 1-(1-F)^2, F_max = F^2.
%
%   out.oma_weak, out.oma_strong     TDMA, threshold g_oma = 2^(2R1)-1
%   out.noma_far, out.noma_near      NOMA a1 = 0.7 / a2 = 0.3, threshold 2^R1-1
%   out.rsma                         generic (unordered) RSMA user, exact OP
%   out.rsma_A1, out.rsma_A2         Pr{A1}, Pr{A2} (for T = 1, OP = max of the two)
F  = @(z) sr_cdf(z, 1, p);
Ps = 10.^(PsdB/10);
for i = 1:numel(Ps)
    rho = Ps(i)*p.g;
    % OMA: gamma = rho*x  ->  x < g_oma/rho
    cO = p.g_oma/rho;
    out.oma_weak(i)   = 1 - (1 - F(cO))^2;
    out.oma_strong(i) = F(cO)^2;
    % NOMA far: a1*rho*x/(a2*rho*x+1) < gN  <=>  x < gN/(rho*(a1 - a2*gN))   (needs gN < a1/a2)
    a1 = p.a1_noma; a2 = p.a2_noma; gN = p.g_noma;
    cF = gN/(rho*(a1 - a2*gN));
    cS = max(cF, gN/(a2*rho));          % near user must pass SIC step AND own step
    out.noma_far(i)  = 1 - (1 - F(cF))^2;
    out.noma_near(i) = F(cS)^2;
    % RSMA user k = 1 (unordered, as in eqs (9)/(11))
    ac = p.alpha_c; ak = p.alpha_p(1); oth = sum(p.alpha_p) - ak;
    cc = p.gc_th/(rho*(ac - (1-ac)*p.gc_th));
    cp = p.gp_th/(rho*(ak - oth*p.gp_th));
    out.rsma_A1(i) = F(cc);
    out.rsma_A2(i) = F(cp);
    out.rsma(i)    = F(max(cc, cp));    % events are nested when T = 1
end
end
