function g = sinr_value(s, rho, x)
% SINR_VALUE  gamma = delta*rho*x / (vartheta*rho*x + 1) for one stream s
% (a struct from sinr_streams), transmit SNR rho = Ps*g and gain x = |h|^2.
X = rho .* x;
g = s.delta .* X ./ (s.vartheta .* X + 1);
end
