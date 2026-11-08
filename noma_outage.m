function [OPfar, OPnear] = noma_outage(PsdB, T, N, p)
% NOMA_OUTAGE  Monte Carlo outage of HARQ-CC aided downlink NOMA, 2 users.
%
%   [OPfar, OPnear] = noma_outage(PsdB, T, N, p)
%
% Modelling follows ref. [12] (Singh et al., IEEE TVT 2024), eqs. (6)-(7) and (11),
% specialised to K = 2 users, one direct link (no IRS) and HARQ-CC:
%
%   x = sqrt(a1*Ps)*s1 + sqrt(a2*Ps)*s2,   a1 = 0.7 (far/weak), a2 = 0.3 (near/strong)
%   rho = Ps*g,  x_k = |h_k|^2,  lam2 = lambda_hi^2,  I = isic*rho*|gI|^2
%
%   FAR user 1, decodes s1 treating s2 as noise (no SIC, so no I-SIC term in [12]):
%       gamma_1     = a1*rho*x1 / ( (a2 + lam2)*rho*x1 + 1 )
%   NEAR user 2, SIC:
%       gamma_{2->1} = a1*rho*x2 / ( (a2 + lam2)*rho*x2 + I + 1 )
%       gamma_2      = a2*rho*x2 / (  lam2      *rho*x2 + I + 1 )
%   [12] eq. (11): a user is in outage if it fails to decode ANY x_l, l <= k.
%   HARQ-CC: each SINR is summed over the T rounds (Hu et al. eq. 1).
%   Hu et al. assume lam2 = 0 and isic = 0, which gives their NOMA benchmark.
%
% Ceiling: the far user needs g_noma < a1/(a2 + lam2)  ([12]: gamma_th < delta/vartheta).

if nargin == 0
    p = istn_params(); PsdB = -20:2.5:10; N = 2e6;
    figure; hold on;
    for T = [1 3]
        [OPf, OPn] = noma_outage(PsdB, T, N, p);
        semilogy(PsdB, max(OPf,eps), '-o', 'DisplayName', sprintf('NOMA far, T=%d',T));
        semilogy(PsdB, max(OPn,eps), '--s','DisplayName', sprintf('NOMA near, T=%d',T));
    end
    set(gca,'YScale','log'); grid on; legend show; xlabel('P_s (dBW)'); ylabel('Outage probability');
    return;
end

a1 = p.a1_noma;  a2 = p.a2_noma;  gth = p.g_noma;
lam2 = p.lambda_hi^2;
if gth >= a1/(a2 + lam2)
    warning('NOMA far user: threshold >= SINR ceiling a1/(a2+lambda^2): outage floor.');
end

rng(p.seed);
Ps   = 10.^(PsdB/10);
nP   = numel(Ps);
cntF = zeros(1,nP);  cntN = zeros(1,nP);
nDone = 0;
while nDone < N
    n  = min(p.chunk, N - nDone);
    h1 = sr_gain([T n], p);
    h2 = sr_gain([T n], p);
    [xf, xn] = order_users(h1, h2, p.order);
    gI = p.Omega_I * (randn(T,n).^2 + randn(T,n).^2)/2;   % |gI|^2 ~ Exp(Omega_I), per round
    for i = 1:nP
        rho = Ps(i)*p.g;
        I   = p.isic*rho*gI;
        % far user
        gF   = a1*rho*xf ./ ((a2 + lam2)*rho*xf + 1);
        cntF(i) = cntF(i) + sum(sum(gF,1) < gth);
        % near user with SIC
        g21  = a1*rho*xn ./ ((a2 + lam2)*rho*xn + I + 1);
        g2   = a2*rho*xn ./ (lam2*rho*xn + I + 1);
        outN = (sum(g21,1) < gth) | (sum(g2,1) < gth);
        cntN(i) = cntN(i) + sum(outN);
    end
    nDone = nDone + n;
end
OPfar  = cntF / N;
OPnear = cntN / N;
end
