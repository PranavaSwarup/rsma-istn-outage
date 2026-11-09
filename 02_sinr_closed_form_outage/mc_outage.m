function op = mc_outage(PsdB, T, N, p)
% MC_OUTAGE  Monte Carlo outage for OMA, NOMA and RSMA with HARQ-CC (T rounds),
% computed directly from the SINR template in sinr_streams (no threshold
% algebra), so it is an independent check of op_closed_form_T1.
%
% HARQ-CC: a stream is decoded if  sum_{t=1..T} gamma_t >= threshold.
% Weak/strong user chosen by order_users(.., p.order), as in 01_fig4_monte_carlo.
% Supports hardware impairments through p.hi_lambda.
%
% Same output fields as op_closed_form_T1.

S   = sinr_streams(p);
K   = S.K_rsma;
U   = max(2, K);                         % users to draw per trial
rho = 10.^(PsdB/10) * p.g;
nP  = numel(rho);

names = {'oma_weak','oma_strong','noma_far','noma_near', ...
         'rsma_user','rsma_weak','rsma_PrA1','rsma_PrA2'};
for f = 1:numel(names), cnt.(names{f}) = zeros(1, nP); end

ok = @(s, r, x) sum(sinr_value(s, r, x), 1) >= s.gth;   % 1 x n logical

rng(p.seed);
nDone = 0;
while nDone < N
    n = min(p.chunk, N - nDone);
    h = zeros(T, n, U);
    for u = 1:U, h(:, :, u) = sr_gain([T n], p); end
    [xw, xs] = order_users(h(:, :, 1:2), p.order);   % weak / strong of users 1-2
    xk  = h(:, :, 1);                                % generic RSMA user
    xkw = order_users(h(:, :, 1:K), p.order);        % weakest of K RSMA users

    for i = 1:nP
        r = rho(i);
        cnt.oma_weak(i)   = cnt.oma_weak(i)   + sum(~ok(S.oma, r, xw));
        cnt.oma_strong(i) = cnt.oma_strong(i) + sum(~ok(S.oma, r, xs));

        cnt.noma_far(i)   = cnt.noma_far(i)   + sum(~ok(S.noma_1, r, xw));
        cnt.noma_near(i)  = cnt.noma_near(i)  + ...
            sum(~(ok(S.noma_1, r, xs) & ok(S.noma_2, r, xs)));

        c_ok = ok(S.rsma_c, r, xk);   p_ok = ok(S.rsma_p, r, xk);
        cnt.rsma_PrA1(i)  = cnt.rsma_PrA1(i)  + sum(~c_ok);
        cnt.rsma_PrA2(i)  = cnt.rsma_PrA2(i)  + sum(~p_ok);
        cnt.rsma_user(i)  = cnt.rsma_user(i)  + sum(~(c_ok & p_ok));
        cnt.rsma_weak(i)  = cnt.rsma_weak(i)  + ...
            sum(~(ok(S.rsma_c, r, xkw) & ok(S.rsma_p, r, xkw)));
    end
    nDone = nDone + n;
end
for f = 1:numel(names), op.(names{f}) = cnt.(names{f}) / N; end
end
