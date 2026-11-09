function F = sr_cdf(x, p, nTerms)
% SR_CDF  CDF of |h|^2 for the Shadowed-Rician channel of Hu et al., eq. (4).
%
%   pdf:  f(x) = lambda * exp(-beta*x) * 1F1(m; 1; delta*x)
%            = lambda * sum_n  (m)_n delta^n / (n!)^2 * x^n * exp(-beta*x)
%   CDF:  F(x) = lambda * sum_n  (m)_n delta^n / (n! * beta^(n+1)) * P(n+1, beta*x)
%
%   lambda = (1/2b)(2bm/(2bm+Omega))^m,  beta = 1/(2b),  delta = Omega/(2b(2bm+Omega))
%   P(a, z) = gammainc(z, a), the regularised lower incomplete gamma function.
% The series ratio is delta/beta = Omega/(2bm+Omega) < 1, so 100 terms is
% far more than enough for the paper's average-shadowing parameters.

if nargin < 3, nTerms = 100; end
b2   = 2*p.b;
lam  = (b2*p.m/(b2*p.m + p.Omega))^p.m / b2;
beta = 1/b2;
del  = p.Omega/(b2*(b2*p.m + p.Omega));

z = beta * max(x, 0);
z(isinf(z)) = realmax;          % gammainc(realmax, a) = 1
F = zeros(size(x));
for n = 0:nTerms-1
    logc = gammaln(p.m + n) - gammaln(p.m) - gammaln(n + 1) ...
         + n*log(del) - (n + 1)*log(beta);
    F = F + exp(logc) * gammainc(z, n + 1);
end
F = min(max(lam*F, 0), 1);
end
