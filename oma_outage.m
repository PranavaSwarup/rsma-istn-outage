function [OPweak, OPstrong] = oma_outage(PsdB, T, N, p)
% OMA_OUTAGE  Monte Carlo outage of HARQ-CC aided OMA (TDMA), 2 users.
%
%   [OPweak, OPstrong] = oma_outage(PsdB, T, N, p)
%
% Per round t, in the user's own TDMA slot at full power:
%     gamma_t = rho * x_t,   rho = Ps*g        (no interference, no ceiling)
% HARQ-CC (MRC of identical packets) -> accumulated SINR = sum_t gamma_t   (eq. 1)
% Outage if sum_t gamma_t < g_oma = 2^(2*R1) - 1   ([12]: K slots -> 2^(K*R)-1)
% Weak/strong users from order_users(..., p.order).

if nargin == 0
    p = istn_params(); PsdB = -20:2.5:10; N = 2e6;
    figure; hold on;
    for T = [1 3]
        OP = oma_outage(PsdB, T, N, p);
        semilogy(PsdB, max(OP,eps), '-o', 'DisplayName', sprintf('OMA weak, T=%d',T));
    end
    set(gca,'YScale','log'); grid on; legend show; xlabel('P_s (dBW)'); ylabel('Outage probability');
    return;
end

rng(p.seed);
Ps   = 10.^(PsdB/10);
nP   = numel(Ps);
cntW = zeros(1,nP);  cntS = zeros(1,nP);
nDone = 0;
while nDone < N
    n  = min(p.chunk, N - nDone);
    h1 = sr_gain([T n], p);
    h2 = sr_gain([T n], p);
    [hw, hs] = order_users(h1, h2, p.order);
    for i = 1:nP
        sw = Ps(i)*p.g*hw;  ss = Ps(i)*p.g*hs;
        cntW(i) = cntW(i) + sum(sum(sw,1) < p.g_oma);
        cntS(i) = cntS(i) + sum(sum(ss,1) < p.g_oma);
    end
    nDone = nDone + n;
end
OPweak   = cntW / N;
OPstrong = cntS / N;
end
