function op = mc_outage_isic(PsdB, N, p, OmegaI)
% MC_OUTAGE_ISIC  T = 1 outage with IMPERFECT SIC, in the form of Singh et al.
% (ref. [12], IEEE TVT 2024, eq. (6)): a step that comes AFTER a SIC
% subtraction sees a residual interference  rho*|g_I|^2,  |g_I|^2 ~ Exp(OmegaI):
%
%   gamma = delta*rho*x / (vartheta*rho*x + varpi*rho*|g_I|^2 + 1),  varpi = 1
%
% Steps with a residual (a user that has already cancelled something):
%   NOMA near user, decode s1 and decode s2 (Singh: every SIC user, k >= 2)
%   RSMA private stream (decoded after removing the common stream)
% Steps without one: OMA, NOMA far user, RSMA common stream (decoded first).
%
% As rho -> Inf the residual grows with rho, so the SINR tends to
% delta*x / (vartheta*x + |g_I|^2): it no longer grows with power and the
% outage hits an error floor (diversity order 0, Singh et al. Remark 2).
%
%   OmegaI : mean residual power |g_I|^2 (linear, e.g. 10^(-20/10))

S   = sinr_streams(p);
rho = 10.^(PsdB/10) * p.g;
nP  = numel(rho);
names = {'oma_weak','noma_far','noma_near','rsma_user'};
for f = 1:numel(names), cnt.(names{f}) = zeros(1, nP); end

sinr_r = @(s, r, x, g) s.delta .* r .* x ./ (s.vartheta .* r .* x + r .* g + 1);
okp    = @(s, r, x)    sinr_value(s, r, x) >= s.gth;          % no residual
okr    = @(s, r, x, g) sinr_r(s, r, x, g)  >= s.gth;          % with residual

rng(p.seed);
nDone = 0;
while nDone < N
    n  = min(p.chunk, N - nDone);
    x1 = sr_gain([1 n], p);  x2 = sr_gain([1 n], p);
    xw = min(x1, x2);  xs = max(x1, x2);  xk = x1;
    g  = -OmegaI * log(rand(1, n));                    % Exp(OmegaI)
    for i = 1:nP
        r = rho(i);
        cnt.oma_weak(i)  = cnt.oma_weak(i)  + sum(~okp(S.oma, r, xw));
        cnt.noma_far(i)  = cnt.noma_far(i)  + sum(~okp(S.noma_1, r, xw));
        cnt.noma_near(i) = cnt.noma_near(i) + ...
            sum(~(okr(S.noma_1, r, xs, g) & okr(S.noma_2, r, xs, g)));
        cnt.rsma_user(i) = cnt.rsma_user(i) + ...
            sum(~(okp(S.rsma_c, r, xk) & okr(S.rsma_p, r, xk, g)));
    end
    nDone = nDone + n;
end
for f = 1:numel(names), op.(names{f}) = cnt.(names{f}) / N; end
end
