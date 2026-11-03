function [OPweak, OPstrong] = oma_outage(PsdB, T, N, p)
% OMA_OUTAGE  Monte Carlo outage of HARQ-CC aided OMA (TDMA), 2 users.
%
%   [OPweak, OPstrong] = oma_outage(PsdB, T, N, p)
%     PsdB : vector of total transmit power (dBW)
%     T    : number of HARQ-CC rounds
%     N    : Monte Carlo samples per point
%     p    : struct from istn_params()
%
% Model (per round t, in the user's own TDMA slot, full power Ps):
%     gamma_t = Ps * g * |h_t|^2               (no interference)
% HARQ-CC (MRC of identical packets) -> accumulated SINR = sum_t gamma_t
% Outage if  sum_t gamma_t < g_oma,  g_oma = 2^(2*R1) - 1
% (rate doubled because each user only owns half the time).
% Weak/strong user: chosen by order_users(..., p.order). Default 'first' =
% roles fixed by the round-1 channel and kept for all T rounds.
%
% Run with no inputs for a quick stand-alone plot.

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
    [hw, hs] = order_users(cat(3,h1,h2), p.order);   % fixed roles across rounds
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
