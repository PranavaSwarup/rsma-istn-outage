function f = sr_pdf(x, p, nTerms)
% SR_PDF  PDF of |h|^2 for the Shadowed-Rician channel, Hu et al. eq. (4).
%
%   f(x) = lambda * exp(-beta*x) * 1F1(m; 1; delta*x),   x >= 0
%   lambda = (1/2b) * (2bm/(2bm+Omega))^m
%   beta   = 1/(2b)
%   delta  = Omega / (2b*(2bm+Omega))
%
% 1F1 (Kummer's confluent hypergeometric function) is summed as a series,
% so no Symbolic Math Toolbox is needed:
%   1F1(m;1;z) = sum_n (m)_n z^n / (n!)^2,   (m)_n = Gamma(m+n)/Gamma(m)
% Each term is evaluated in logs to avoid overflow.
%
%   p : struct with fields b, m, Omega (e.g. from istn_params)

if nargin < 3, nTerms = 200; end
b2   = 2*p.b;
lam  = (b2*p.m/(b2*p.m + p.Omega))^p.m / b2;
beta = 1/b2;
del  = p.Omega/(b2*(b2*p.m + p.Omega));

x  = max(x, 0);
S  = zeros(size(x));
lz = log(del*x);                         % log(delta*x); -Inf at x = 0
for n = 0:nTerms-1
    logt = gammaln(p.m + n) - gammaln(p.m) - 2*gammaln(n + 1) + n*lz;
    if n == 0, logt = zeros(size(x)); end    % first term = 1 (also at x = 0)
    S = S + exp(logt - beta*x);              % fold exp(-beta*x) in for stability
end
f = lam * S;
end
