function S = sinr_streams(p)
% SINR_STREAMS  Every decoding step of OMA, NOMA and RSMA written in ONE form.
%
% Let X = Ps * g * |h|^2 be the received SNR of a user in one round.
% Every SINR in Hu et al. (and in the NOMA reference, Singh et al. 2024) is
%
%                  delta * X
%     gamma  =  -----------------          ceiling (X -> inf):  delta / vartheta
%               vartheta * X  +  1
%
%   delta    = power fraction of the stream being decoded
%   vartheta = power fraction still interfering (+ lambda^2 for hardware
%              impairments, which scale with the signal just like interference)
%
% Stream                       delta      vartheta                  threshold
% --------------------------   --------   -----------------------   ---------
% OMA (TDMA, own slot)         1          lambda^2                  g_oma
% NOMA far user, decode s1     a1         a2 + lambda^2             g_noma
% NOMA near user, decode s1    a1         a2 + lambda^2             g_noma
% NOMA near user, decode s2    a2         lambda^2  (after SIC)     g_noma
% RSMA common s_c   (eq. 5)    alpha_c    sum(alpha_p) + lambda^2   gc_th
% RSMA private s_k  (eq. 6)    alpha_k    sum_{j~=k} alpha_j + l^2  gp_th
%
% With lambda = 0 these are exactly Hu et al. eqs. (5)-(6) and the NOMA/OMA
% models used in the Fig. 4 comparison.

lam2 = 0;
if isfield(p, 'hi_lambda'), lam2 = p.hi_lambda^2; end

ap = p.alpha_p;  k = 1;

S.oma     = mk('OMA',             1,           lam2,                     p.g_oma);
S.noma_1  = mk('NOMA decode s1',  p.a1_noma,   p.a2_noma + lam2,         p.g_noma);
S.noma_2  = mk('NOMA decode s2',  p.a2_noma,   lam2,                     p.g_noma);
S.rsma_c  = mk('RSMA common',     p.alpha_c,   sum(ap) + lam2,           p.gc_th);
S.rsma_p  = mk('RSMA private',    ap(k),       sum(ap) - ap(k) + lam2,   p.gp_th);
S.K_rsma  = numel(ap);
end

function s = mk(name, delta, vartheta, gth)
s.name     = name;
s.delta    = delta;
s.vartheta = vartheta;
s.gth      = gth;
s.ceiling  = delta / vartheta;          % Inf when vartheta = 0
s.reachable = gth < s.ceiling;          % false => outage = 1 at any power
end
