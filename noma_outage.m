function [OPfar, OPnear] = noma_outage(PsdB, T, N, p)
% NOMA_OUTAGE  Monte Carlo outage of HARQ-CC aided downlink NOMA, 2 users.
%
%   [OPfar, OPnear] = noma_outage(PsdB, T, N, p)
%
% Transmit: x = sqrt(a1*Ps)*s1 + sqrt(a2*Ps)*s2,  a1 = 0.7 (far), a2 = 0.3 (near)
% Let  rho = Ps*g  (transmit SNR incl. link budget),  x_k = |h_k|^2.
%
% FAR (weak) user 1 -- decodes s1 directly, s2 treated as noise:
%       gamma_1     = a1*rho*x1 / (a2*rho*x1 + 1)
%
% NEAR (strong) user 2 -- SIC:
%   step 1, decode s1 (treat s2 as noise):
%       gamma_{2->1} = a1*rho*x2 / (a2*rho*x2 + 1)
%   step 2, cancel s1 (perfect SIC), decode s2:
%       gamma_2     = a2*rho*x2
%
% HARQ-CC: each SINR is summed over the T rounds (MRC of identical packets).
%   far outage  : sum gamma_1 < g_noma
%   near outage : sum gamma_{2->1} < g_noma  OR  sum gamma_2 < g_noma
% with g_noma = 2^R1 - 1, R1 = Rc/2 + Rp  (same per-user rate as RSMA).
% Far/near = min/max of the two channel gains in each round.
%
% Run with no inputs for a quick stand-alone plot.

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
if gth >= a1/a2
    warning('NOMA far user: threshold >= SINR ceiling a1/a2, outage floor appears.');
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
    xf = min(h1,h2);  xn = max(h1,h2);
    for i = 1:nP
        rho = Ps(i)*p.g;
        % far user
        gF   = a1*rho*xf ./ (a2*rho*xf + 1);
        cntF(i) = cntF(i) + sum(sum(gF,1) < gth);
        % near user with SIC
        g21  = a1*rho*xn ./ (a2*rho*xn + 1);
        g2   = a2*rho*xn;
        outN = (sum(g21,1) < gth) | (sum(g2,1) < gth);
        cntN(i) = cntN(i) + sum(outN);
    end
    nDone = nDone + n;
end
OPfar  = cntF / N;
OPnear = cntN / N;
end
