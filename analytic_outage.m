function out = analytic_outage(PsdB, T, p, M)
% ANALYTIC_OUTAGE  Numerical (no Monte Carlo) outage curves for Fig. 4.
%   out = analytic_outage(PsdB, T, p)   fields: oma, noma, rsmaA1, rsmaA2, rsmaLo, rsmaUp
%
% Method (exact up to a grid of M cells, default 3000):
%   1. One round's SINR is a monotone function of |h|^2, so its CDF is the
%      S-R CDF (sr_cdf) at the inverse map:
%         OMA      gamma = rho*x                  -> x = y/rho
%         a/b form gamma = a*rho*x/(b*rho*x + 1)  -> x = y/(rho*(a - b*y)),  y < a/b
%   2. Weak user = min of two i.i.d. gains: F_min = 1-(1-F)^2. This is
%      [12] eq. (15) with K = 2, k = 1. With p.order:
%         'round' every round uses F_min (rounds i.i.d.)
%         'first' round 1 uses F_min, rounds 2..T use F (same user kept)
%         'none'  every round uses F
%   3. The CDF of the HARQ-CC sum below the threshold is the T-fold
%      convolution of the per-round probability masses on [0, threshold].
% RSMA uses the generic user, as in eqs. (9)/(11). Bounds follow eq. (8).
% Only valid for perfect SIC and perfect hardware (Hu et al.'s setting).
if nargin < 4, M = 3000; end
switch lower(p.order)
    case 'round', dl = repmat({'min'}, 1, T);
    case 'first', dl = [{'min'}, repmat({'gen'}, 1, T-1)];
    otherwise,    dl = repmat({'gen'}, 1, T);
end
dg = repmat({'gen'}, 1, T);
ac = p.alpha_c; ak = p.alpha_p(1); oth = sum(p.alpha_p) - ak;

for i = 1:numel(PsdB)
    rho = 10^(PsdB(i)/10)*p.g;
    out.oma(i)    = sum_cdf(Inf, 0, rho, p.g_oma, dl, p, M);           % b = 0 -> OMA
    out.noma(i)   = sum_cdf(p.a1_noma, p.a2_noma, rho, p.g_noma, dl, p, M);
    out.rsmaA1(i) = sum_cdf(ac, 1-ac, rho, p.gc_th, dg, p, M);
    out.rsmaA2(i) = sum_cdf(ak, oth,  rho, p.gp_th, dg, p, M);
end
out.rsmaLo = max(out.rsmaA1, out.rsmaA2);
out.rsmaUp = min(out.rsmaA1 + out.rsmaA2, 1);
end

function P = sum_cdf(a, b, rho, th, dists, p, M)
edges = linspace(0, th, M+1);
pm = [];
for t = 1:numel(dists)
    G  = round_cdf(a, b, rho, edges, dists{t}, p);
    pc = diff(G);
    if isempty(pm), pm = pc; else, pm = conv(pm, pc); pm = pm(1:M); end
end
T   = numel(dists);
cut = M - (T-1)/2;                      % midpoint correction for summed cell indices
idx = 0:numel(pm)-1;
wgt = min(max(cut - idx, 0), 1);
P   = sum(pm .* wgt);
end

function G = round_cdf(a, b, rho, y, dist, p)
if isinf(a)                              % OMA
    x = y/rho;
else
    den = a - b*y;
    x = y ./ (rho*max(den, realmin));
    x(den <= 0) = Inf;
end
G = ones(size(x));
fin = isfinite(x);
G(fin) = sr_cdf(x(fin), 1, p);
if strcmp(dist, 'min'), G = 1 - (1 - G).^2; end
end
