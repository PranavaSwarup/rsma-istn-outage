function x = sr_gain(sz, p)
% SR_GAIN  Draw Shadowed-Rician channel gains x = |h|^2.   [Step 11.1]
%   h   = A*exp(j*phi) + Z
%   A^2 ~ Gamma(shape m, scale Omega/m)   (Nakagami-m LOS amplitude)
%   phi ~ U[0, 2pi)                       (LOS phase)
%   Z   ~ CN(0, 2b)                       (scattered multipath)
% Check: mean(x) should be Omega + 2b (= 1.087 by default).

A2  = (p.Omega/p.m) * gamma_core(p.m, sz);
phi = 2*pi*rand(sz);
Z   = sqrt(p.b) * (randn(sz) + 1j*randn(sz));
x   = abs(sqrt(A2).*exp(1j*phi) + Z).^2;
end
