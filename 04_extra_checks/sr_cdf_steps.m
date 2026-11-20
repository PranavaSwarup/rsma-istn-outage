%% SR_CDF_STEPS  Show how sr_cdf builds F(t) from Gamma blocks, step by step.
%   F(t) = sum_n w_n * gammainc(beta*t, n+1)
% Prints the weights w_n, each block's area up to t, and the running total,
% at t = 0.667 (the RSMA bar at Ps = 5 dBW), where F should settle at 0.335.
clear; clc;
setup_extra_paths();
p = istn_params();

b2   = 2*p.b;
lam  = (b2*p.m/(b2*p.m + p.Omega))^p.m / b2;
beta = 1/b2;
del  = p.Omega/(b2*(b2*p.m + p.Omega));
fprintf('lambda = %.4f   beta = %.4f   delta = %.4f\n\n', lam, beta, del);

rho = 10^(5/10) * p.g;
t   = 2.5 / rho;                                   % RSMA common bar at 5 dBW
n   = 0:39;
w   = exp(log(lam) + gammaln(p.m + n) - gammaln(p.m) - gammaln(n + 1) ...
          + n*log(del) - (n + 1)*log(beta));
area = gammainc(beta*t, n + 1);
run  = cumsum(w .* area);

fprintf('t = %.4f  (rho = %.3f)\n', t, rho);
fprintf('  n    weight w_n   block area   running F\n');
for k = 1:16
    fprintf(' %2d    %.4f       %.4f       %.4f\n', n(k), w(k), area(k), run(k));
end
fprintf('\nsum of weights (40 terms) = %.6f   (should be 1)\n', sum(w));
fprintf('F(t) series = %.4f   sr_cdf = %.4f\n', run(end), sr_cdf(t, p));
