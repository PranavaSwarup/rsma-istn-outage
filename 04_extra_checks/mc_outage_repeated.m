function op = mc_outage_repeated(PsdB, T, N, p)
% MC_OUTAGE_REPEATED  Same as mc_outage, but HARQ-CC combining with the
% interference REPEATED in every round (the physically consistent model).
%
% Chase combining resends the SAME superposed packet, so the interfering
% streams are the same symbols in every round. After maximum-ratio combining
% over the T copies (weights h_t^*), the wanted part AND the interference
% both add coherently, while the noise adds incoherently:
%
%   wanted       ~ delta    * rho * (sum_t x_t)^2
%   interference ~ vartheta * rho * (sum_t x_t)^2
%   noise        ~                  (sum_t x_t)
%
%   =>  gamma_comb = delta*rho*S / (vartheta*rho*S + 1),   S = sum_t x_t
%
% i.e. the one-round SINR evaluated at the SUMMED gain. The paper (and
% mc_outage) instead uses  sum_t gamma_t,  which treats the interference as
% fresh noise in every round and is optimistic: its accumulated SINR can grow
% to T*theta, while gamma_comb never exceeds the ceiling theta = delta/vartheta.
% For OMA (vartheta = 0) both models are identical.
%
% Output fields as in mc_outage.

S   = sinr_streams(p);
K   = S.K_rsma;
U   = max(2, K);
rho = 10.^(PsdB/10) * p.g;
nP  = numel(rho);

names = {'oma_weak','oma_strong','noma_far','noma_near', ...
         'rsma_user','rsma_weak','rsma_PrA1','rsma_PrA2'};
for f = 1:numel(names), cnt.(names{f}) = zeros(1, nP); end

% decode iff the SINR of the summed gain clears the threshold
ok = @(s, r, x) sinr_value(s, r, sum(x, 1)) >= s.gth;

rng(p.seed);
nDone = 0;
while nDone < N
    n = min(p.chunk, N - nDone);
    h = zeros(T, n, U);
    for u = 1:U, h(:, :, u) = sr_gain([T n], p); end
    [xw, xs] = order_users(h(:, :, 1:2), p.order);
    xk  = h(:, :, 1);
    xkw = order_users(h(:, :, 1:K), p.order);

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
