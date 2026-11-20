function F = sr_cdf_T(z, p, T, nTerms)
% SR_CDF_T  CDF of the SUM of T i.i.d. Shadowed-Rician gains,
%           S = |h_1|^2 + ... + |h_T|^2   (one gain per HARQ round).
%
% sr_cdf writes the eq. (4) PDF as a Gamma mixture:
%     f(x) = sum_n w_n * Gamma(shape n+1, rate beta)
%     w_n  = lambda (m)_n delta^n / (n! beta^(n+1))        (sum_n w_n = 1)
% All blocks share the same rate beta, so a sum of T such variables is again
% a Gamma mixture: shapes add (n_1+1) + ... + (n_T+1) = k + T, and the
% weights of k = n_1 + ... + n_T are the T-fold convolution of w_n:
%     F_T(z) = sum_k w^(T)_k * gammainc(beta*z, k + T)
% T = 1 gives back sr_cdf. Used for
%   - OMA over T rounds (its SNR is linear in |h|^2, so the summed SNR is
%     rho * S and the outage is exactly F_T(bar)),
%   - the "repeated interference" HARQ model (harq_repeated_interference.m).
%
%   z : bar(s) on S   p : struct from istn_params   T : rounds (>= 1)

if nargin < 4, nTerms = 150; end
b2   = 2*p.b;
lam  = (b2*p.m/(b2*p.m + p.Omega))^p.m / b2;
beta = 1/b2;
del  = p.Omega/(b2*(b2*p.m + p.Omega));

n  = 0:nTerms-1;
w  = exp(log(lam) + gammaln(p.m + n) - gammaln(p.m) - gammaln(n + 1) ...
         + n*log(del) - (n + 1)*log(beta));          % Gamma-mixture weights
wT = w;
for t = 2:T
    wT = conv(wT, w);
    wT = wT(1:nTerms);                               % tail is negligible
end

zz = beta * max(z, 0);
zz(isinf(zz)) = realmax;                             % F(Inf) = 1
F  = zeros(size(z));
for k = 0:nTerms-1
    F = F + wT(k+1) * gammainc(zz, k + T);
end
F = min(max(F, 0), 1);
end
