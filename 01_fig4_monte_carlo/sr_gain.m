function x = sr_gain(sz, p)
% SR_GAIN  Draw |h|^2 for a Shadowed-Rician channel (Abdi et al. 2003).
%   h = A*exp(j*phi) + Z
%   A^2 ~ Gamma(shape m, scale Omega/m)   (Nakagami-m LOS amplitude)
%   phi ~ U[0, 2pi)
%   Z  ~ CN(0, 2b)                        (diffuse multipath)
% Uses gamma_core (below) instead of randg, because randg needs the
% Statistics and Machine Learning Toolbox. Only rand/randn are used.

A2  = (p.Omega/p.m) * gamma_core(p.m, sz);
phi = 2*pi*rand(sz);
Z   = sqrt(p.b) * (randn(sz) + 1j*randn(sz));
x   = abs(sqrt(A2).*exp(1j*phi) + Z).^2;
end

function g = gamma_core(a, sz)
% GAMMA_CORE  Gamma(shape a, scale 1) samples, no toolbox needed.
% Marsaglia & Tsang (2000) rejection method, vectorised. For a < 1 uses the
% boost Gamma(a) = Gamma(a+1) * U^(1/a).
if a < 1
    g = gamma_core(a + 1, sz) .* rand(sz).^(1/a);
    return;
end
d = a - 1/3;
c = 1/sqrt(9*d);
g = zeros(sz);
todo = true(sz);
while any(todo(:))
    k = nnz(todo);
    z = randn(k, 1);
    v = (1 + c*z).^3;
    u = rand(k, 1);
    ok = v > 0;
    ok(ok) = log(u(ok)) < 0.5*z(ok).^2 + d - d*v(ok) + d*log(v(ok));
    idx = find(todo);
    g(idx(ok)) = d * v(ok);
    todo(idx(ok)) = false;
end
end
