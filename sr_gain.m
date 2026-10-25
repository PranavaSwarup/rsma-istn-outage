function x = sr_gain(sz, p)
% SR_GAIN  Draw |h|^2 for a Shadowed-Rician channel (Abdi et al. 2003).
%   h = A*exp(j*phi) + Z
%   A^2 ~ Gamma(shape m, scale Omega/m)   (Nakagami-m LOS amplitude)
%   phi ~ U[0, 2pi)
%   Z  ~ CN(0, 2b)                        (diffuse multipath)
% randg is core MATLAB (no Statistics Toolbox needed).

A2  = (p.Omega/p.m) * randg(p.m, sz);
phi = 2*pi*rand(sz);
Z   = sqrt(p.b) * (randn(sz) + 1j*randn(sz));
x   = abs(sqrt(A2).*exp(1j*phi) + Z).^2;
end
