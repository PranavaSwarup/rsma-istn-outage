function F = sr_cdf(z, T, p)
% SR_CDF  Exact CDF of the sum of T i.i.d. Shadowed-Rician gains |h|^2.
%   F = sr_cdf(z, T, p)  returns  Pr{ sum_{t=1}^T |h_t|^2 < z }  (same size as z)
%
% Expanding 1F1 in Hu et al. eq. (4):
%   f(x) = lambda*exp(-beta*x)*sum_n (m)_n delta^n x^n /(n!)^2
%        = sum_n w_n * Gamma(shape n+1, rate beta) pdf(x),
%   w_n  = lambda*(m)_n*delta^n / ( n! * beta^(n+1) ),   sum_n w_n = 1.
% All components share the rate beta, so a sum of T gains is again a Gamma
% mixture: weights = T-fold convolution of w_n, shape = n + T.
% Exact up to series truncation (nmax = 400; weights sum to 1 to ~1e-15).
if nargin < 2 || isempty(T), T = 1; end
b = p.b; m = p.m; Om = p.Omega;
lam   = (1/(2*b)) * (2*b*m/(2*b*m + Om))^m;
beta  = 1/(2*b);
delta = Om/(2*b*(2*b*m + Om));

nmax = 400;
n  = (0:nmax).';
lw = log(lam) + gammaln(m+n) - gammaln(m) + n*log(delta) - gammaln(n+1) - (n+1)*log(beta);
w1 = exp(lw);
w  = w1;
for t = 2:T
    w = conv(w, w1);  w = w(1:nmax+1);
end
S = (0:nmax).' + T;                          % total Gamma shape

F  = zeros(size(z));
zz = z(:).';
blk = 2000;                                  % columns per block (memory)
for s = 1:blk:numel(zz)
    idx = s:min(s+blk-1, numel(zz));
    X = repmat(beta*zz(idx), numel(S), 1);
    A = repmat(S, 1, numel(idx));
    F(idx) = w.' * gammainc(X, A);           % MATLAB order: gammainc(x, a)
end
end
