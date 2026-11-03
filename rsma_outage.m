function [OP, PrA1, PrA2] = rsma_outage(PsdB, T, N, p)
% RSMA_OUTAGE  Monte Carlo outage of HARQ-CC aided 1-layer RSMA, user k = 1.
%
%   [OP, PrA1, PrA2] = rsma_outage(PsdB, T, N, p)
%     OP   : true outage, Pr{A1 U A2}                       (eq. (7))
%     PrA1 : Pr{ sum_t gamma_c < gc_th }  (common fails)
%     PrA2 : Pr{ sum_t gamma_p < gp_th }  (private fails)
%   Paper's bounds (eq. (8)):  max(PrA1,PrA2) <= OP <= min(PrA1+PrA2, 1)
%
% Per round t, rho = Ps*g, x = |h_{k,t}|^2 :
%   common  (eq. 5): gamma_c = a_c*rho*x / ( sum_j a_j * rho*x + 1 )
%   private (eq. 6): gamma_p = a_k*rho*x / ( sum_{j~=k} a_j * rho*x + 1 )   (after perfect SIC of s_c)
% HARQ-CC: SINRs are summed over T rounds (eq. (1)).
% K = numel(p.alpha_p). If p.rsma_ordered, user 1 = weakest of the K users,
% chosen by order_users(..., p.order) (same rule as NOMA/OMA).
%
% Run with no inputs for a quick stand-alone plot.

if nargin == 0
    p = istn_params(); PsdB = -20:2.5:10; N = 2e6;
    figure; hold on;
    for T = [1 3]
        [OP, A1, A2] = rsma_outage(PsdB, T, N, p);
        semilogy(PsdB, max(OP,eps), 'o', 'DisplayName', sprintf('RSMA sim, T=%d',T));
        semilogy(PsdB, max(min(A1+A2,1),eps), '-',  'DisplayName', sprintf('upper, T=%d',T));
        semilogy(PsdB, max(max(A1,A2),eps),   '--', 'DisplayName', sprintf('lower, T=%d',T));
    end
    set(gca,'YScale','log'); grid on; legend show; xlabel('P_s (dBW)'); ylabel('Outage probability');
    return;
end

ac = p.alpha_c;  ap = p.alpha_p;  K = numel(ap);  k = 1;
if abs(ac + sum(ap) - 1) > 1e-9
    error('Power coefficients must satisfy alpha_c + sum(alpha_p) = 1 (eq. 2); got %.4f.', ac + sum(ap));
end
sumP   = sum(ap);              % all private powers (interference for s_c)
sumOth = sumP - ap(k);         % other users' private powers (interference for s_k)

thc = ac/sumP;  thp = ap(k)/max(sumOth,eps);
if p.gc_th >= thc || p.gp_th >= thp
    warning('Threshold above SINR ceiling (theta_c=%.3g, theta_p=%.3g): no full diversity.', thc, thp);
end

rng(p.seed);
Ps   = 10.^(PsdB/10);
nP   = numel(Ps);
cOP  = zeros(1,nP); cA1 = zeros(1,nP); cA2 = zeros(1,nP);
nDone = 0;
while nDone < N
    n = min(p.chunk, N - nDone);
    if p.rsma_ordered
        H = sr_gain([T n], p);
        for u = 2:K, H = cat(3, H, sr_gain([T n], p)); end
        x = order_users(H, p.order);
    else
        x  = sr_gain([T n], p);
        x2 = sr_gain([T n], p);  %#ok<NASGU> keep RNG stream aligned with OMA/NOMA
    end
    for i = 1:nP
        rho = Ps(i)*p.g;
        gc  = ac*rho*x    ./ (sumP*rho*x   + 1);
        gp  = ap(k)*rho*x ./ (sumOth*rho*x + 1);
        A1  = sum(gc,1) < p.gc_th;
        A2  = sum(gp,1) < p.gp_th;
        cA1(i) = cA1(i) + sum(A1);
        cA2(i) = cA2(i) + sum(A2);
        cOP(i) = cOP(i) + sum(A1 | A2);
    end
    nDone = nDone + n;
end
OP   = cOP / N;
PrA1 = cA1 / N;
PrA2 = cA2 / N;
end
