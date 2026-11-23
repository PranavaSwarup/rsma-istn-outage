function F = sr_cdf(y, p)
% SR_CDF  CDF of one Shadowed-Rician gain x = |h|^2:  F(y) = Pr(x < y).  [Step 9]
%
%   PDF: f(x) = lambda * exp(-beta*x) * 1F1(m; 1; delta*x)
%   lambda = (1/2b) (2bm/(2bm+Omega))^m,  beta = 1/(2b),
%   delta  = Omega / (2b (2bm+Omega))
%
%   Expand 1F1 as a series and integrate term by term:
%   F(y) = (lambda/beta) * sum_n c_n * P(n+1, beta*y)
%   c_n  = (m)_n / n! * (delta/beta)^n,   c_0 = 1,
%   c_{n+1} = c_n * (m+n)/(n+1) * (delta/beta)    (recursion avoids overflow)
%   P(s,z) = regularised lower incomplete gamma = gammainc(z, s) in MATLAB.

b = p.b;  m = p.m;  Om = p.Omega;
lambda = (1/(2*b)) * (2*b*m/(2*b*m + Om))^m;
beta   = 1/(2*b);
delta  = Om/(2*b*(2*b*m + Om));
r      = delta/beta;                 % < 1, so the series converges

F = zeros(size(y));
c = 1;                               % c_0
for n = 0:p.nTerms-1
    F = F + c * gammainc(beta*y, n+1);
    c = c * (m+n)/(n+1) * r;         % c_{n+1}
end
F = (lambda/beta) * F;
F = min(max(F, 0), 1);               % guard against round-off
end
